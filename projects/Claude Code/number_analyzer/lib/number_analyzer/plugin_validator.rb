# frozen_string_literal: true

require 'digest'
require 'json'

# Plugin Validation and Security System for NumberAnalyzer
# Provides security validation and integrity checking for external plugins
class NumberAnalyzer
  # Security validation system for plugins
  class PluginValidator
    # Validation errors
    class ValidationError < StandardError; end
    class SecurityViolationError < ValidationError; end
    class IntegrityCheckError < ValidationError; end
    class MaliciousCodeError < ValidationError; end

    # Security risk levels
    RISK_LEVELS = {
      low: 0,
      medium: 1,
      high: 2,
      critical: 3
    }.freeze

    # Dangerous patterns to check for
    DANGEROUS_PATTERNS = [
      # System command execution
      /`[^`]*`/,                           # Backticks
      /system\s*\(/,                       # system() calls
      /exec\s*\(/,                         # exec() calls
      /spawn\s*\(/,                        # spawn() calls
      /Process\.\w+/,                      # Process class usage
      /IO\.popen/,                         # IO.popen calls
      /Open3\./,                           # Open3 usage

      # File system access
      /File\.(delete|unlink|rm)/,          # File deletion
      /FileUtils\.(rm|remove)/,            # FileUtils deletion
      /Dir\.(delete|rmdir)/,               # Directory deletion
      /File\.chmod/,                       # Permission changes
      /File\.chown/,                       # Ownership changes

      # Network access
      /Net::/,                             # Net library usage
      /URI\.open/,                         # URI.open calls
      /open-uri/,                          # open-uri require
      /Net::HTTP/,                         # HTTP client usage
      /TCPSocket/,                         # TCP socket usage
      /UDPSocket/,                         # UDP socket usage

      # Code evaluation
      /eval\s*\(/,                         # eval() calls
      /instance_eval/,                     # instance_eval calls
      /class_eval/,                        # class_eval calls
      /module_eval/,                       # module_eval calls
      /binding\.eval/,                     # binding.eval calls

      # Dynamic loading
      /require\s+[^'"][^'"]*[^'"]$/,       # Dynamic require
      /load\s+[^'"][^'"]*[^'"]$/,          # Dynamic load
      /autoload/,                          # Autoload usage

      # Global variable manipulation
      /\$[A-Z]/,                           # Global variables
      /global_variables/,                  # Global variable access

      # Environment manipulation
      /ENV\[[^\]]*\]\s*=/,                 # Environment variable setting
      /ENV\.store/,                        # ENV.store calls

      # Database/External services
      /ActiveRecord::/,                    # ActiveRecord usage
      /Sequel::/,                          # Sequel usage
      /Redis/,                             # Redis usage
      /Mysql/,                             # MySQL usage
      /Postgres/ # PostgreSQL usage
    ].freeze

    # Suspicious method patterns
    SUSPICIOUS_METHODS = %w[
      send public_send method define_method alias_method
      remove_method undef_method const_set const_missing
      method_missing singleton_method __send__
    ].freeze

    class << self
      # Validate plugin file for security and integrity
      def validate_plugin_file(file_path, options = {})
        raise ValidationError, "Plugin file does not exist: #{file_path}" unless File.exist?(file_path)

        results = {
          file_path: file_path,
          valid: true,
          risk_level: :low,
          warnings: [],
          errors: [],
          security_issues: [],
          integrity_check: nil,
          metadata: {}
        }

        begin
          # Read and analyze file content
          content = File.read(file_path)

          # Basic integrity checks
          perform_integrity_checks(file_path, content, results)

          # Security analysis
          perform_security_analysis(content, results, options)

          # Metadata extraction and validation
          extract_and_validate_metadata(content, results)

          # Structure validation
          validate_plugin_structure(content, results)

          # Overall risk assessment
          assess_overall_risk(results)
        rescue StandardError => e
          results[:valid] = false
          results[:errors] << "Validation failed: #{e.message}"
          results[:risk_level] = :critical
        end

        results
      end

      # Validate plugin metadata
      def validate_metadata(metadata)
        errors = []
        warnings = []

        # Required fields
        required_fields = %w[name version description author]
        required_fields.each do |field|
          errors << "Missing required field: #{field}" unless metadata[field]
        end

        # Version format validation
        if metadata['version'] && !metadata['version'].match?(/^\d+\.\d+\.\d+/)
          errors << "Invalid version format: #{metadata['version']}. Expected semantic versioning (x.y.z)"
        end

        # Author validation
        warnings << 'Author field is empty' if metadata['author'] && metadata['author'].to_s.strip.empty?

        # Dependencies validation
        if metadata['dependencies']
          deps = metadata['dependencies']
          errors << 'Dependencies must be an array of strings' unless deps.is_a?(Array) && deps.all? { |dep| dep.is_a?(String) }
        end

        # Commands validation
        if metadata['commands']
          commands = metadata['commands']
          errors << 'Commands must be a hash or array' unless commands.is_a?(Hash) || commands.is_a?(Array)
        end

        {
          valid: errors.empty?,
          errors: errors,
          warnings: warnings
        }
      end

      # Check if author is trusted
      def trusted_author?(author, trusted_authors = [])
        return false if author.nil? || author.to_s.strip.empty?

        trusted_authors.include?(author.to_s.strip)
      end

      # Generate security report
      def generate_security_report(validation_results)
        {
          summary: {
            total_files: validation_results.size,
            valid_files: validation_results.count { |r| r[:valid] },
            high_risk_files: validation_results.count { |r| %i[high critical].include?(r[:risk_level]) },
            total_security_issues: validation_results.sum { |r| r[:security_issues].size }
          },
          by_risk_level: {
            low: validation_results.count { |r| r[:risk_level] == :low },
            medium: validation_results.count { |r| r[:risk_level] == :medium },
            high: validation_results.count { |r| r[:risk_level] == :high },
            critical: validation_results.count { |r| r[:risk_level] == :critical }
          },
          security_issues: validation_results.flat_map { |r| r[:security_issues] }.group_by { |issue| issue[:type] },
          recommendations: generate_recommendations(validation_results)
        }
      end

      private

      def perform_integrity_checks(file_path, content, results)
        # File size check
        file_size = File.size(file_path)
        results[:warnings] << "Large plugin file (#{file_size} bytes). Consider splitting into multiple files." if file_size > 1_048_576 # 1MB

        # Encoding check
        unless content.valid_encoding?
          results[:errors] << 'File contains invalid encoding'
          results[:valid] = false
          return
        end

        # Basic syntax check (Ruby)
        begin
          RubyVM::InstructionSequence.compile(content)
        rescue SyntaxError => e
          results[:errors] << "Syntax error: #{e.message}"
          results[:valid] = false
        end

        # Generate file hash for integrity
        results[:integrity_check] = {
          sha256: Digest::SHA256.hexdigest(content),
          size: file_size,
          encoding: content.encoding.name
        }
      end

      def perform_security_analysis(content, results, options)
        security_config = options[:security_config] || {}

        # Check for dangerous patterns
        check_dangerous_patterns(content, results)

        # Check for suspicious method usage
        check_suspicious_methods(content, results)

        # Check network access if not allowed
        check_network_access(content, results) unless security_config['allow_network_access']

        # Check system command execution if not allowed
        check_system_commands(content, results) unless security_config['allow_system_commands']

        # Check for code obfuscation
        check_code_obfuscation(content, results)
      end

      def check_dangerous_patterns(content, results)
        DANGEROUS_PATTERNS.each do |pattern|
          matches = content.scan(pattern)
          next if matches.empty?

          issue = {
            type: 'dangerous_pattern',
            pattern: pattern.source,
            matches: matches.size,
            risk_level: :high,
            description: "Potentially dangerous code pattern detected: #{pattern.source}"
          }

          results[:security_issues] << issue
        end
      end

      def check_suspicious_methods(content, results)
        SUSPICIOUS_METHODS.each do |method|
          pattern = /\b#{Regexp.escape(method)}\b/
          matches = content.scan(pattern)
          next if matches.empty?

          issue = {
            type: 'suspicious_method',
            method: method,
            matches: matches.size,
            risk_level: :medium,
            description: "Suspicious method usage detected: #{method}"
          }

          results[:security_issues] << issue
        end
      end

      def check_network_access(content, results)
        network_patterns = [
          %r{require\s+['"]net/},
          /require\s+['"]uri['"]/,
          /require\s+['"]open-uri['"]/,
          /Net::/,
          /URI\./,
          /TCPSocket/,
          /UDPSocket/
        ]

        network_patterns.each do |pattern|
          matches = content.scan(pattern)
          next if matches.empty?

          issue = {
            type: 'network_access',
            pattern: pattern.source,
            matches: matches.size,
            risk_level: :high,
            description: 'Network access detected but not allowed by security policy'
          }

          results[:security_issues] << issue
        end
      end

      def check_system_commands(content, results)
        system_patterns = [
          /`[^`]*`/,
          /system\s*\(/,
          /exec\s*\(/,
          /spawn\s*\(/,
          /Process\./,
          /IO\.popen/
        ]

        system_patterns.each do |pattern|
          matches = content.scan(pattern)
          next if matches.empty?

          issue = {
            type: 'system_command',
            pattern: pattern.source,
            matches: matches.size,
            risk_level: :critical,
            description: 'System command execution detected but not allowed by security policy'
          }

          results[:security_issues] << issue
        end
      end

      def check_code_obfuscation(content, results)
        # Check for base64 encoded strings (potential obfuscation)
        base64_pattern = %r{["'][A-Za-z0-9+/]{20,}={0,2}["']}
        base64_matches = content.scan(base64_pattern)

        if base64_matches.size > 3
          issue = {
            type: 'obfuscation',
            matches: base64_matches.size,
            risk_level: :medium,
            description: 'Potential code obfuscation detected (multiple base64 strings)'
          }

          results[:security_issues] << issue
        end

        # Check for excessive string concatenation (potential obfuscation)
        concat_pattern = /["'][^"']*["']\s*\+\s*["'][^"']*["']/
        concat_matches = content.scan(concat_pattern)

        return unless concat_matches.size > 10

        issue = {
          type: 'obfuscation',
          matches: concat_matches.size,
          risk_level: :low,
          description: 'Potential string obfuscation detected (excessive concatenation)'
        }

        results[:security_issues] << issue
      end

      def extract_and_validate_metadata(content, results)
        metadata = {}

        # Extract metadata from content
        metadata['name'] = extract_plugin_name(content)
        metadata['version'] = extract_plugin_version(content)
        metadata['description'] = extract_plugin_description(content)
        metadata['author'] = extract_plugin_author(content)
        metadata['dependencies'] = extract_plugin_dependencies(content)
        metadata['commands'] = extract_plugin_commands(content)

        # Validate extracted metadata
        validation = validate_metadata(metadata)

        results[:metadata] = metadata
        results[:errors].concat(validation[:errors])
        results[:warnings].concat(validation[:warnings])

        results[:valid] = false unless validation[:valid]
      end

      def extract_plugin_name(content)
        content.match(/plugin_name\s+['"]([^'"]+)['"]/)&.captures&.first
      end

      def extract_plugin_version(content)
        content.match(/plugin_version\s+['"]([^'"]+)['"]/)&.captures&.first
      end

      def extract_plugin_description(content)
        content.match(/plugin_description\s+['"]([^'"]+)['"]/)&.captures&.first
      end

      def extract_plugin_author(content)
        content.match(/plugin_author\s+['"]([^'"]+)['"]/)&.captures&.first
      end

      def extract_plugin_dependencies(content)
        deps_match = content.match(/plugin_dependencies\s+\[(.*?)\]/m)
        return [] unless deps_match

        deps_string = deps_match.captures.first
        deps_string.scan(/['"]([^'"]+)['"]/).flatten
      end

      def extract_plugin_commands(content)
        # Extract commands from plugin_commands method
        commands_match = content.match(/def\s+self\.plugin_commands.*?\{(.*?)\}/m)
        return {} unless commands_match

        commands_string = commands_match.captures.first
        commands = {}

        commands_string.scan(/['"]([^'"]+)['"]\s*=>\s*:(\w+)/) do |command, method|
          commands[command] = method
        end

        commands
      end

      def validate_plugin_structure(content, results)
        # Check for required plugin interface inclusion
        unless content.include?('NumberAnalyzer::StatisticsPlugin') ||
               content.include?('NumberAnalyzer::CLIPlugin') ||
               content.include?('NumberAnalyzer::FileFormatPlugin') ||
               content.include?('NumberAnalyzer::OutputFormatPlugin') ||
               content.include?('NumberAnalyzer::ValidatorPlugin')
          results[:warnings] << 'Plugin does not include any recognized NumberAnalyzer plugin interface'
        end

        # Check for plugin metadata methods
        required_methods = %w[plugin_name plugin_version]
        required_methods.each do |method|
          results[:warnings] << "Plugin missing recommended metadata method: #{method}" unless content.include?(method)
        end
      end

      def assess_overall_risk(results)
        # Calculate risk based on security issues
        max_risk = :low

        results[:security_issues].each do |issue|
          case issue[:risk_level]
          when :critical
            max_risk = :critical
          when :high
            max_risk = :high if max_risk != :critical
          when :medium
            max_risk = :medium if [:low].include?(max_risk)
          end
        end

        # Increase risk if there are errors
        max_risk = :high if results[:errors].any? && max_risk == :low

        results[:risk_level] = max_risk
      end

      def generate_recommendations(validation_results)
        recommendations = []

        # Security recommendations
        high_risk_count = validation_results.count { |r| %i[high critical].include?(r[:risk_level]) }
        recommendations << "Review #{high_risk_count} high-risk plugins before enabling" if high_risk_count.positive?

        # Common issues
        all_issues = validation_results.flat_map { |r| r[:security_issues] }
        issue_types = all_issues.group_by { |issue| issue[:type] }

        recommendations << 'Consider sandboxing plugins that execute system commands' if issue_types['system_command']&.any?

        recommendations << 'Review network access requirements for plugins' if issue_types['network_access']&.any?

        recommendations << 'Investigate plugins with potential code obfuscation' if issue_types['obfuscation']&.any?

        recommendations
      end
    end
  end
end
