# frozen_string_literal: true

# Validates plugin metadata
class Numana::PluginValidator::MetadataValidator
  def initialize(metadata)
    @metadata = metadata
    @errors = []
    @warnings = []
  end

  def validate
    validate_required_fields
    validate_version_format
    validate_author
    validate_dependencies
    validate_commands

    { valid: @errors.empty?, errors: @errors, warnings: @warnings }
  end

  private

  def validate_required_fields
    %w[name version description author].each do |field|
      @errors << "Missing required field: #{field}" unless @metadata[field]
    end
  end

  def validate_version_format
    return unless @metadata['version'] && !@metadata['version'].match?(/^\d+\.\d+\.\d+/)

    @errors << "Invalid version format: #{@metadata['version']}. Expected semantic versioning (x.y.z)"
  end

  def validate_author
    author = @metadata['author']
    @warnings << 'Author field is empty' if author.to_s.strip.empty?
  end

  def validate_dependencies
    return unless @metadata['dependencies']

    deps = @metadata['dependencies']
    @errors << 'Dependencies must be an array of strings' unless deps.is_a?(Array) && deps.all? { |dep| dep.is_a?(String) }
  end

  def validate_commands
    return unless @metadata['commands']

    commands = @metadata['commands']
    @errors << 'Commands must be a hash or array' unless commands.is_a?(Hash) || commands.is_a?(Array)
  end
end
