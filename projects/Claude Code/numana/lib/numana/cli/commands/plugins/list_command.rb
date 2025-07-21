# frozen_string_literal: true

require_relative '../../base_command'

class Numana::Commands::Plugins::ListCommand < Numana::Commands::BaseCommand
  def execute(args, global_options = {})
    @options = @options.merge(global_options)
    show_conflicts = args.include?('--show-conflicts')
    plugins = loaded_plugins

    return display_interface_message(:no_plugins) if plugins.empty?

    display_interface_message(:plugins_header, plugins.size)
    plugins.each { |name, info| display_plugin_info(name, info, show_conflicts) }

    display_conflicts_summary(plugins) if show_conflicts
  end

  private

  def loaded_plugins
    Numana::CLI.plugin_system.instance_variable_get(:@plugins) || {}
  end

  def display_interface_message(type, data = nil)
    case type
    when :no_plugins
      puts 'No plugins loaded.'
    when :plugins_header
      puts "Loaded plugins (#{data}):"
      puts ''
    end
  end

  def display_plugin_info(name, plugin_info, show_conflicts)
    plugin_class = plugin_info[:class]
    priority = plugin_info[:priority] || 'unknown'
    commands = extract_plugin_commands(plugin_class)

    puts "  #{name}:"
    puts "    Priority: #{priority}"
    puts "    Class: #{plugin_class}"
    puts "    Commands: #{commands}"

    display_conflicts_if_requested(name, plugin_class, show_conflicts) if show_conflicts
    puts ''
  end

  def extract_plugin_commands(plugin_class)
    plugin_class.respond_to?(:commands) ? plugin_class.commands.keys.join(', ') : 'N/A'
  end

  def display_conflicts_if_requested(name, plugin_class, show_conflicts)
    return unless show_conflicts

    conflicts = detect_plugin_conflicts(name, plugin_class, loaded_plugins)
    puts "    ⚠️  Conflicts: #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def display_conflicts_summary(plugins)
    all_conflicts = detect_all_conflicts(plugins)
    if all_conflicts.any?
      puts 'Conflict summary:'
      all_conflicts.each do |conflict_type, details|
        puts "  #{conflict_type}: #{details}"
      end
    else
      puts '✅ No conflicts detected.'
    end
  end

  def detect_plugin_conflicts(_name, _plugin_class, _plugins)
    # Simplified conflict detection - return empty array for now
    []
  end

  def detect_all_conflicts(_plugins)
    # Simplified conflict detection - return empty hash for now
    {}
  end
end
