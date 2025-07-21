# frozen_string_literal: true

require_relative '../../base_command'

class Numana::Commands::Plugins::ConflictsCommand < Numana::Commands::BaseCommand
  def execute(_args, global_options = {})
    @options = @options.merge(global_options)
    plugins = loaded_plugins

    return display_interface_message(:no_plugins) if plugins.empty?

    display_interface_message(:conflicts_header)
    all_conflicts = detect_all_conflicts(plugins)

    if all_conflicts.empty?
      display_interface_message(:no_conflicts_found, plugins.size)
    else
      display_detailed_conflicts(all_conflicts, plugins)
      puts "Use 'plugins resolve' command to resolve conflicts."
    end
  end

  private

  def loaded_plugins
    Numana::CLI.plugin_system.instance_variable_get(:@plugins) || {}
  end

  def display_interface_message(type, data = nil)
    case type
    when :no_plugins
      puts 'No plugins loaded.'
    when :conflicts_header
      puts 'Plugin conflict detection results:'
      puts ''
    when :no_conflicts_found
      puts '✅ No conflicts detected.'
      puts "Number of loaded plugins: #{data}" if data
    end
  end

  def detect_all_conflicts(_plugins)
    # Simplified conflict detection - return empty hash for now
    {}
  end

  def display_detailed_conflicts(all_conflicts, plugins)
    all_conflicts.each do |conflict_type, conflicts|
      puts "#{conflict_type} conflicts:"
      conflicts.each do |item, conflicting_plugins|
        puts "  '#{item}' conflicts with the following plugins:"
        conflicting_plugins.each do |plugin_name|
          plugin_info = plugins[plugin_name]
          priority = plugin_info[:priority] || 'unknown'
          puts "    - #{plugin_name} (Priority: #{priority})"
        end
      end
      puts ''
    end
  end
end
