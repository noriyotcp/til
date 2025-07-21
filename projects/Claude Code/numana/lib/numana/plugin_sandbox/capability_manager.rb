# frozen_string_literal: true

require 'set'

# Capability manager for plugin security
# Manages permission-based access control with 5 risk levels
class Numana::PluginSandbox::CapabilityManager
  CAPABILITIES = {
    read_data: {
      description: 'プラグインが入力データを読み取る',
      risk_level: :low,
      requires_approval: false,
      auto_grant: true
    },

    write_output: {
      description: 'プラグインが結果を出力する',
      risk_level: :low,
      requires_approval: false,
      auto_grant: true
    },

    file_read: {
      description: 'ファイルシステムからのデータ読み取り',
      risk_level: :medium,
      requires_approval: true,
      auto_grant: false,
      restricted_paths: %w[./data ./input ./tmp /tmp/number_analyzer],
      blocked_paths: %w[/etc /usr /bin /sbin ~/.ssh ~/.aws]
    },

    file_write: {
      description: 'ファイルシステムへのデータ書き込み',
      risk_level: :medium,
      requires_approval: true,
      auto_grant: false,
      restricted_paths: %w[./output ./tmp /tmp/number_analyzer],
      blocked_paths: %w[/etc /usr /bin /sbin ~ ~/.ssh ~/.aws]
    },

    network_access: {
      description: '外部ネットワークへのアクセス（API等）',
      risk_level: :high,
      requires_approval: true,
      auto_grant: false,
      allowed_hosts: %w[api.example.com data.government.gov api.census.gov],
      blocked_hosts: %w[*.suspicious-domain.com *.malware.com localhost 127.0.0.1]
    },

    external_command: {
      description: '外部コマンドの実行',
      risk_level: :critical,
      requires_approval: true,
      auto_grant: false,
      allowed_commands: %w[R python3 julia octave],
      blocked_commands: %w[rm mv cp chmod sudo su bash sh curl wget]
    },

    system_info: {
      description: 'システム情報の取得',
      risk_level: :medium,
      requires_approval: true,
      auto_grant: false,
      allowed_info: %w[cpu_count memory_total ruby_version platform]
    }
  }.freeze

  RISK_LEVELS = {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }.freeze

  def initialize(trusted_plugins = [])
    @trusted_plugins = Set.new(trusted_plugins.map(&:to_s))
    @granted_capabilities = Hash.new { |h, k| h[k] = Set.new }
    @capability_requests = []
    @violation_log = []
  end

  # Verify that a plugin has the required capabilities
  def verify_capabilities(plugin_name, requested_capabilities)
    plugin_name = plugin_name.to_s
    requested_capabilities = Array(requested_capabilities).map(&:to_sym)

    # Trusted plugins get all capabilities automatically
    if @trusted_plugins.include?(plugin_name)
      grant_capabilities(plugin_name, requested_capabilities)
      return true
    end

    # Check each requested capability
    requested_capabilities.each do |capability|
      unless CAPABILITIES.key?(capability)
        log_violation(plugin_name, :unknown_capability, capability)
        raise Numana::PluginCapabilityError,
              "Unknown capability requested: #{capability}"
      end

      capability_config = CAPABILITIES[capability]

      # Auto-grant low-risk capabilities
      if capability_config[:auto_grant]
        grant_capability(plugin_name, capability)
        next
      end

      # Check if capability has been explicitly granted
      next if capability_granted?(plugin_name, capability)

      log_violation(plugin_name, :capability_denied, capability)

      next unless capability_config[:requires_approval]

      raise Numana::PluginCapabilityError,
            "Capability '#{capability}' (#{capability_config[:risk_level]} risk) requires explicit approval. " \
            "Description: #{capability_config[:description]}"
    end

    true
  end

  # Grant a specific capability to a plugin
  def grant_capability(plugin_name, capability)
    plugin_name = plugin_name.to_s
    capability = capability.to_sym

    raise ArgumentError, "Unknown capability: #{capability}" unless CAPABILITIES.key?(capability)

    @granted_capabilities[plugin_name] << capability
    log_capability_grant(plugin_name, capability)
  end

  # Grant multiple capabilities to a plugin
  def grant_capabilities(plugin_name, capabilities)
    capabilities.each { |cap| grant_capability(plugin_name, cap) }
  end

  # Check if a plugin has been granted a specific capability
  def capability_granted?(plugin_name, capability)
    plugin_name = plugin_name.to_s
    capability = capability.to_sym

    @trusted_plugins.include?(plugin_name) ||
      @granted_capabilities[plugin_name].include?(capability)
  end

  # Revoke a capability from a plugin
  def revoke_capability(plugin_name, capability)
    plugin_name = plugin_name.to_s
    capability = capability.to_sym

    @granted_capabilities[plugin_name].delete(capability)
    log_capability_revoke(plugin_name, capability)
  end

  # Get all capabilities for a plugin
  def plugin_capabilities(plugin_name)
    plugin_name = plugin_name.to_s

    if @trusted_plugins.include?(plugin_name)
      CAPABILITIES.keys
    else
      @granted_capabilities[plugin_name].to_a
    end
  end

  # List all available capabilities
  def list_capabilities(risk_level: nil)
    capabilities = CAPABILITIES

    capabilities = capabilities.select { |_, config| config[:risk_level] == risk_level } if risk_level

    capabilities.map do |name, config|
      {
        name: name,
        description: config[:description],
        risk_level: config[:risk_level],
        requires_approval: config[:requires_approval],
        auto_grant: config[:auto_grant]
      }
    end
  end

  # Get capability configuration
  def capability_config(capability)
    CAPABILITIES[capability&.to_sym]
  end

  # Validate resource access for a capability
  def validate_resource_access(plugin_name, capability, resource)
    capability_config = CAPABILITIES[capability&.to_sym]
    return false unless capability_config
    return false unless capability_granted?(plugin_name, capability)

    case capability
    when :file_read, :file_write
      validate_file_access(capability_config, resource)
    when :network_access
      validate_network_access(capability_config, resource)
    when :external_command
      validate_command_access(capability_config, resource)
    else
      true # No additional validation needed
    end
  end

  # Get security statistics
  def security_stats
    {
      trusted_plugins: @trusted_plugins.size,
      total_granted_capabilities: @granted_capabilities.values.sum(&:size),
      capability_requests: @capability_requests.size,
      violations: @violation_log.size,
      plugins_with_capabilities: @granted_capabilities.keys.size
    }
  end

  # Get violation log
  def violation_log(limit: 100)
    @violation_log.last(limit)
  end

  private

  def validate_file_access(capability_config, file_path)
    file_path = File.expand_path(file_path)

    # Check blocked paths first
    blocked_paths = capability_config[:blocked_paths] || []
    blocked_paths.each do |blocked|
      expanded_blocked = File.expand_path(blocked)
      return false if file_path.start_with?(expanded_blocked)
    end

    # Check if path is in allowed list
    restricted_paths = capability_config[:restricted_paths] || []
    return true if restricted_paths.empty? # No restrictions

    restricted_paths.any? do |allowed|
      expanded_allowed = File.expand_path(allowed)
      file_path.start_with?(expanded_allowed)
    end
  end

  def validate_network_access(capability_config, host)
    # Check blocked hosts first
    blocked_hosts = capability_config[:blocked_hosts] || []
    return false if host_matches_patterns(host, blocked_hosts)

    # Check allowed hosts
    allowed_hosts = capability_config[:allowed_hosts] || []
    return true if allowed_hosts.empty? # No restrictions

    host_matches_patterns(host, allowed_hosts)
  end

  def validate_command_access(capability_config, command)
    command_name = command.is_a?(Array) ? command.first : command

    # Check blocked commands first
    blocked_commands = capability_config[:blocked_commands] || []
    return false if blocked_commands.include?(command_name)

    # Check allowed commands
    allowed_commands = capability_config[:allowed_commands] || []
    return true if allowed_commands.empty? # No restrictions

    allowed_commands.include?(command_name)
  end

  def host_matches_patterns(host, patterns)
    patterns.any? do |pattern|
      if pattern.include?('*')
        # Convert glob pattern to regex
        regex_pattern = pattern.gsub('.', '\\.').gsub('*', '.*')
        host.match?(/\A#{regex_pattern}\z/)
      else
        host == pattern
      end
    end
  end

  def log_capability_grant(plugin_name, capability)
    @capability_requests << {
      timestamp: Time.now,
      plugin: plugin_name,
      action: :grant,
      capability: capability,
      risk_level: CAPABILITIES[capability][:risk_level]
    }
  end

  def log_capability_revoke(plugin_name, capability)
    @capability_requests << {
      timestamp: Time.now,
      plugin: plugin_name,
      action: :revoke,
      capability: capability,
      risk_level: CAPABILITIES[capability][:risk_level]
    }
  end

  def log_violation(plugin_name, violation_type, details)
    @violation_log << {
      timestamp: Time.now,
      plugin: plugin_name,
      violation_type: violation_type,
      details: details,
      severity: determine_violation_severity(violation_type, details)
    }
  end

  def determine_violation_severity(violation_type, details)
    case violation_type
    when :unknown_capability
      :medium
    when :capability_denied
      capability_config = CAPABILITIES[details]
      case capability_config&.dig(:risk_level)
      when :critical
        :high
      when :high
        :medium
      else
        :low
      end
    else
      :low
    end
  end
end
