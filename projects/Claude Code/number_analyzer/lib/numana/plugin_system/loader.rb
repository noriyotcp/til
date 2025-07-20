# frozen_string_literal: true

# Plugin loading functionality
class Numana::PluginSystem::Loader
  def initialize(core_system)
    @core = core_system
  end

  # Load a specific plugin with enhanced dependency resolution and error handling
  def load_plugin(plugin_name)
    return false unless @core.plugins.key?(plugin_name)
    return true if @core.loaded_plugins.include?(plugin_name)
    return false if @core.error_handler.plugin_disabled?(plugin_name)

    context = { plugin_name: plugin_name, operation: :load }

    begin
      # Resolve dependencies with circular dependency detection
      required_plugins = @core.dependency_resolver.resolve(plugin_name, check_versions: true)

      # Load dependencies first
      required_plugins.each do |dep_name|
        next if dep_name == plugin_name || @core.loaded_plugins.include?(dep_name)

        load_plugin_internal(dep_name)
      end

      # Load the plugin itself
      load_plugin_internal(plugin_name)

      true
    rescue Numana::DependencyResolver::CircularDependencyError, Numana::DependencyResolver::UnresolvedDependencyError => e
      @core.error_handler.handle_error(e, context.merge(recovery_strategy: :disable))
      false
    rescue Numana::DependencyResolver::VersionConflictError => e
      handle_version_conflict(e, context)
    rescue LoadError => e
      handle_load_error(e, context)
    rescue StandardError => e
      handle_general_error(e, context)
    end
  end

  # Load multiple plugins with dependency resolution
  def load_plugins(*plugin_names)
    # Resolve all dependencies together
    all_required = @core.dependency_resolver.resolve_multiple(plugin_names)

    success_count = 0
    all_required.each do |plugin_name|
      success_count += 1 if load_plugin(plugin_name)
    end

    success_count
  end

  private

  # Internal plugin loading without dependency resolution
  def load_plugin_internal(plugin_name)
    plugin_info = @core.plugins[plugin_name]
    plugin_class = plugin_info[:class]
    extension_point = plugin_info[:extension_point]

    begin
      case extension_point
      when :statistics_module
        load_statistics_module(plugin_name, plugin_class)
      when :cli_command
        load_cli_command(plugin_name, plugin_class)
      when :file_format
        load_file_format(plugin_name, plugin_class)
      when :output_format
        load_output_format(plugin_name, plugin_class)
      when :validator
        load_validator(plugin_name, plugin_class)
      end

      @core.loaded_plugins.add(plugin_name)
      @core.plugins[plugin_name][:loaded] = true
      @core.error_handler.enable_plugin(plugin_name)
    end
  end

  def handle_version_conflict(error, context)
    recovery = @core.error_handler.handle_error(error, context.merge(recovery_strategy: :fallback))

    if recovery[:action] == :fallback && recovery[:fallback_plugin]
      load_plugin(recovery[:fallback_plugin])
    else
      false
    end
  end

  def handle_load_error(error, context)
    handle_error_with_recovery(error, context.merge(recovery_strategy: :disable))
  end

  def handle_general_error(error, context)
    handle_error_with_recovery(error, context)
  end

  def handle_error_with_recovery(error, context)
    recovery = @core.error_handler.handle_error(error, context)

    case recovery[:action]
    when :retry
      # Retry should be handled at a higher level that has a rescue block
      false
    when :fallback
      recovery[:fallback_plugin] ? load_plugin(recovery[:fallback_plugin]) : false
    else
      false
    end
  end

  def load_statistics_module(_plugin_name, plugin_class)
    # Dynamically include the statistics module into Numana
    Numana.include(plugin_class) if plugin_class.is_a?(Module)

    # Also register CLI commands if the plugin provides them
    return unless plugin_class.respond_to?(:plugin_commands)

    plugin_class.plugin_commands.each do |command_name, method_name|
      Numana::CLI.register_command(command_name, plugin_class, method_name)
    end
  end

  def load_cli_command(_plugin_name, plugin_class)
    # Register CLI commands dynamically
    return unless plugin_class.respond_to?(:plugin_commands)

    plugin_class.plugin_commands.each do |command_name, method_name|
      Numana::CLI.register_command(command_name, plugin_class, method_name)
    end
  end

  def load_file_format(plugin_name, plugin_class)
    # Register file format handlers
    Numana::FileReader.register_format(plugin_name, plugin_class) if defined?(Numana::FileReader)
  end

  def load_output_format(plugin_name, plugin_class)
    # OutputFormatter was removed in Phase 4 refactoring (migrated to FormattingUtils + Presenter Pattern)
    # The register_format method was never implemented - this was a latent bug from initial plugin system design
    # Future plugin-based output formatting should be designed with FormattingUtils-based architecture
    # For now, output format plugins are not supported
  end

  def load_validator(plugin_name, plugin_class)
    # Register data validators
    Numana::DataValidator.register_validator(plugin_name, plugin_class) if defined?(Numana::DataValidator)
  end
end
