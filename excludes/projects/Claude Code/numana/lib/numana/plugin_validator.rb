# frozen_string_literal: true

require 'digest'
require 'json'

# Establish the namespace first
# rubocop:disable Lint/EmptyClass
class Numana::PluginValidator
end
# rubocop:enable Lint/EmptyClass

require_relative 'plugin_validator/security_scanner'
require_relative 'plugin_validator/metadata_validator'
require_relative 'plugin_validator/validation_reporter'

# Reopen the class to add implementation
class Numana::PluginValidator
  # Validation errors
  class ValidationError < StandardError; end

  RISK_LEVELS = {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }.freeze

  class << self
    def validate_plugin_file(file_path, options = {})
      raise ValidationError, "Plugin file does not exist: #{file_path}" unless File.exist?(file_path)

      results = {
        file_path: file_path, valid: true, risk_level: :low,
        warnings: [], errors: [], security_issues: [],
        integrity_check: nil, metadata: {}
      }

      begin
        content = File.read(file_path)
        perform_integrity_checks(file_path, content, results)
        results[:security_issues] = SecurityScanner.new(content, options[:security_config]).scan
        extract_and_validate_metadata(content, results)
        validate_plugin_structure(content, results)
        assess_overall_risk(results)
      rescue StandardError => e
        results[:valid] = false
        results[:errors] << "Validation failed: #{e.message}"
        results[:risk_level] = :critical
      end

      results
    end

    # Check if author is trusted
    def trusted_author?(author, trusted_authors = [])
      return false if author.nil? || author.to_s.strip.empty?

      trusted_authors.include?(author.to_s.strip)
    end

    # Generate security report
    def generate_security_report(validation_results)
      ValidationReporter.new(validation_results).generate
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

    def extract_and_validate_metadata(content, results)
      metadata = extract_metadata_from_content(content)
      validation = MetadataValidator.new(metadata).validate

      results[:metadata] = metadata
      results[:errors].concat(validation[:errors])
      results[:warnings].concat(validation[:warnings])
      results[:valid] = false unless validation[:valid]
    end

    def extract_metadata_from_content(content)
      {
        'name' => extract_plugin_name(content),
        'version' => extract_plugin_version(content),
        'description' => extract_plugin_description(content),
        'author' => extract_plugin_author(content),
        'dependencies' => extract_plugin_dependencies(content),
        'commands' => extract_plugin_commands(content)
      }
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
      unless content.include?('Numana::StatisticsPlugin') ||
             content.include?('Numana::CLIPlugin') ||
             content.include?('Numana::FileFormatPlugin') ||
             content.include?('Numana::OutputFormatPlugin') ||
             content.include?('Numana::ValidatorPlugin')
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
  end
end
