# frozen_string_literal: true

# Scans plugin code for security vulnerabilities
class Numana::PluginValidator::SecurityScanner
  DANGEROUS_PATTERNS = [
    /`[^`]*`/, /system\s*\(/, /exec\s*\(/, /spawn\s*\(/, /Process\.\w+/,
    /IO\.popen/, /Open3\./, /File\.(delete|unlink|rm)/, /FileUtils\.(rm|remove)/,
    /Dir\.(delete|rmdir)/, /File\.chmod/, /File\.chown/, /eval\s*\(/,
    /instance_eval/, /class_eval/, /module_eval/, /binding\.eval/,
    /require\s+[^'"][^'"]*[^'"]$/, /load\s+[^'"][^'"]*[^'"]$/, /autoload/,
    /\$[A-Z]/, /global_variables/, /ENV\[[^\]]*\]\s*=/, /ENV\.store/
  ].freeze

  SUSPICIOUS_METHODS = %w[
    send public_send method define_method alias_method
    remove_method undef_method const_set const_missing
    method_missing singleton_method __send__
  ].freeze

  def initialize(content, security_config = {})
    @content = content
    @security_config = security_config || {}
  end

  def scan
    issues = []
    issues.concat(check_dangerous_patterns)
    issues.concat(check_suspicious_methods)
    issues.concat(check_network_access) unless @security_config['allow_network_access']
    issues.concat(check_system_commands) unless @security_config['allow_system_commands']
    issues.concat(check_code_obfuscation)
    issues
  end

  private

  def check_dangerous_patterns
    DANGEROUS_PATTERNS.flat_map do |pattern|
      next [] if @content.scan(pattern).empty?

      [{
        type: 'dangerous_pattern', pattern: pattern.source,
        risk_level: :high, description: "Potentially dangerous code pattern detected: #{pattern.source}"
      }]
    end
  end

  def check_suspicious_methods
    SUSPICIOUS_METHODS.flat_map do |method|
      pattern = /\b#{Regexp.escape(method)}\b/
      next [] if @content.scan(pattern).empty?

      [{
        type: 'suspicious_method', method: method,
        risk_level: :medium, description: "Suspicious method usage detected: #{method}"
      }]
    end
  end

  def check_network_access
    network_patterns = [%r{require\s+['"]net/}, /Net::/, /URI\./, /TCPSocket/, /UDPSocket/, /open-uri/]
    network_patterns.flat_map do |pattern|
      next [] if @content.scan(pattern).empty?

      [{
        type: 'network_access', pattern: pattern.source,
        risk_level: :high, description: 'Network access detected'
      }]
    end
  end

  def check_system_commands
    system_patterns = [/`[^`]*`/, /system\s*\(/, /exec\s*\(/, /spawn\s*\(/, /Process\./, /IO\.popen/]
    system_patterns.flat_map do |pattern|
      next [] if @content.scan(pattern).empty?

      [{
        type: 'system_command', pattern: pattern.source,
        risk_level: :critical, description: 'System command execution detected'
      }]
    end
  end

  def check_code_obfuscation
    issues = []
    base64_pattern = %r{["'][A-Za-z0-9+/]{20,}={0,2}["']}
    if @content.scan(base64_pattern).size > 3
      issues << { type: 'obfuscation', risk_level: :medium, description: 'Potential code obfuscation detected (multiple base64 strings)' }
    end
    concat_pattern = /["'][^"']*["']\s*\+\s*["'][^"']*["']/
    if @content.scan(concat_pattern).size > 10
      issues << { type: 'obfuscation', risk_level: :low, description: 'Potential string obfuscation detected (excessive concatenation)' }
    end
    issues
  end
end
