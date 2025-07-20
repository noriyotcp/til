# frozen_string_literal: true

# Plugin health monitoring and reporting
class Numana::PluginSystem::HealthMonitor
  def initialize(core_system)
    @core = core_system
  end

  # Get plugin health status
  def plugin_health_check
    @core.available_plugins.each_with_object({}) do |plugin_name, health|
      health[plugin_name] = {
        loaded: @core.plugin_loaded?(plugin_name),
        disabled: @core.error_handler.plugin_disabled?(plugin_name),
        dependencies_satisfied: dependencies_satisfied?(plugin_name),
        missing_dependencies: missing_dependencies(plugin_name),
        errors: @core.error_handler.error_statistics[:errors_by_plugin][plugin_name] || 0
      }
    end
  end

  # Generate error report
  def error_report
    PluginErrorReport.generate(@core.error_handler)
  end

  # Check if a plugin has satisfied dependencies
  def dependencies_satisfied?(plugin_name)
    @core.dependency_resolver.dependencies_satisfied?(plugin_name)
  end

  # Get missing dependencies for a plugin
  def missing_dependencies(plugin_name)
    @core.dependency_resolver.missing_dependencies(plugin_name)
  end

  # Register a fallback plugin
  def register_fallback(plugin_name, fallback_plugin_name)
    @core.error_handler.register_fallback(plugin_name, fallback_plugin_name)
  end
end
