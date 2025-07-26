# frozen_string_literal: true

# Plugin validation functionality
class Numana::PluginRegistry::Validator
  class << self
    def validate_plugin_name!(name)
      raise Numana::PluginRegistry::Core::InvalidPluginError, 'Plugin name cannot be nil or empty' if name.nil? || name.to_s.strip.empty?
      raise Numana::PluginRegistry::Core::InvalidPluginError, 'Plugin name must be a string or symbol' unless [String, Symbol].include?(name.class)
    end

    def validate_plugin_class!(plugin_class)
      raise Numana::PluginRegistry::Core::InvalidPluginError, 'Plugin class cannot be nil' if plugin_class.nil?
      raise Numana::PluginRegistry::Core::InvalidPluginError, 'Plugin must be a Module or Class' unless plugin_class.is_a?(Module)
    end

    def validate_metadata!(metadata)
      required_fields = %i[name version]
      required_fields.each do |field|
        raise Numana::PluginRegistry::Core::InvalidPluginError, "Plugin metadata missing required field: #{field}" if metadata[field].nil?
      end

      # Validate version format
      unless metadata[:version].match?(/^\d+\.\d+\.\d+/)
        raise Numana::PluginRegistry::Core::InvalidPluginError,
              "Invalid version format: #{metadata[:version]}. Expected semantic versioning (x.y.z)"
      end

      # Validate dependencies format
      dependencies = metadata[:dependencies]
      return unless dependencies && !dependencies.is_a?(Array)

      raise Numana::PluginRegistry::Core::InvalidPluginError, 'Plugin dependencies must be an array'
    end
  end
end
