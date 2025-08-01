# frozen_string_literal: true

require_relative 'plugin_registry/core'
require_relative 'plugin_registry/discovery'

# Centralized Plugin Registry for NumberAnalyzer
# Main interface that delegates to core components
class Numana::PluginRegistry
  class << self
    def initialize_registry
      core.initialize_registry
    end

    def register(plugin_name, plugin_class, options = {})
      core.register(plugin_name, plugin_class, options)
    end

    def discover_plugins
      Numana::PluginRegistry::Discovery.discover_plugins(core)
    end

    def load_plugin(plugin_name)
      Numana::PluginRegistry::Discovery.load_plugin(plugin_name, core)
    end

    def all_plugins
      core.all_plugins
    end

    def loaded_plugins
      core.loaded_plugins
    end

    def plugin_metadata(plugin_name)
      core.plugin_metadata(plugin_name)
    end

    def registered?(plugin_name)
      core.registered?(plugin_name)
    end

    def loaded?(plugin_name)
      core.loaded?(plugin_name)
    end

    def plugin_info(plugin_name)
      core.plugin_info(plugin_name)
    end

    def plugins_by_category(category)
      Numana::PluginRegistry::Discovery.plugins_by_category(category, core)
    end

    def plugins_by_extension_point(extension_point)
      Numana::PluginRegistry::Discovery.plugins_by_extension_point(extension_point, core)
    end

    def add_plugin_directory(directory)
      Numana::PluginRegistry::Discovery.add_plugin_directory(directory, core)
    end

    def remove_plugin_directory(directory)
      Numana::PluginRegistry::Discovery.remove_plugin_directory(directory, core)
    end

    def plugin_directories
      core.initialize_registry unless core.plugins
      core.plugin_directories.dup
    end

    def clear!
      core.clear!
    end

    def status_report
      core.status_report
    end

    private

    def core
      @core ||= Numana::PluginRegistry::Core
    end
  end
end
