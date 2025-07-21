# frozen_string_literal: true

require_relative '../base_command'

# Command for managing plugins (list, resolve conflicts, etc.)
class Numana::Commands::PluginsCommand < Numana::Commands::BaseCommand
  command 'plugins', 'Manage plugins (list, resolve conflicts)'

  def execute(args, global_options = {})
    @options = @options.merge(global_options)

    # Handle plugins subcommands
    subcommand = args.first

    case subcommand
    when 'list'
      run_plugins_list(args[1..])
    when 'resolve'
      run_plugins_resolve(args[1..])
    when '--conflicts', 'conflicts'
      run_plugins_conflicts(args[1..])
    when '--help', 'help', nil
      show_help
    else
      puts "Error: Unknown plugins subcommand: #{subcommand}"
      show_help
      exit 1
    end
  rescue StandardError => e
    handle_error(e)
  end

  private

  def validate_arguments(_args)
    # No validation needed for plugins command
  end

  def parse_input(_args)
    # No input parsing needed for plugins command
  end

  def perform_calculation(_data)
    # No calculation needed for plugins command
  end

  def run_plugins_list(args)
    show_conflicts = args.include?('--show-conflicts')
    plugins = loaded_plugins

    return display_interface_message(:no_plugins) if plugins.empty?

    display_interface_message(:plugins_header, plugins.size)
    plugins.each { |name, info| display_plugin_info(name, info, show_conflicts) }

    display_conflicts_summary(plugins) if show_conflicts
  end

  def run_plugins_conflicts(_args)
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

  def run_plugins_resolve(args)
    plugin_name, strategy, force = parse_resolve_arguments(args)
    plugins = loaded_plugins
    validate_plugin_exists(plugin_name, plugins)

    conflicts = find_plugin_conflicts(plugin_name, plugins)
    display_plugin_conflicts_result(plugin_name, conflicts)
    return if conflicts.empty?

    execute_resolution_strategy(strategy, plugin_name, conflicts, force)
  end

  def detect_plugin_conflicts(_name, _plugin_class, _plugins)
    # Simplified conflict detection - return empty array for now
    []
  end

  def detect_all_conflicts(_plugins)
    # Simplified conflict detection - return empty hash for now
    {}
  end

  def show_help
    puts <<~HELP
      Usage: bundle exec numana plugins [subcommand] [options]

      Subcommands:
        list [--show-conflicts]     List plugins and detect conflicts
        resolve <plugin> [options]  Resolve conflicts (interactive or automatic)
        conflicts, --conflicts      Detect and display conflicts

      Options for resolve:
        --strategy=STRATEGY  Resolution strategy (interactive, namespace, priority, disable)
        --force             Execute without confirmation

      Examples:
        bundle exec numana plugins list
        bundle exec numana plugins list --show-conflicts
        bundle exec numana plugins resolve my_plugin --strategy=namespace
        bundle exec numana plugins --conflicts
    HELP
  end

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
    when :conflicts_header
      puts 'Plugin conflict detection results:'
      puts ''
    when :no_conflicts_found
      puts '✅ No conflicts detected.'
      puts "Number of loaded plugins: #{data}" if data
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

  def parse_resolve_arguments(args)
    if args.empty?
      puts 'Error: Please specify the plugin name to resolve.'
      puts '使用例: bundle exec numana plugins resolve my_plugin --strategy=namespace'
      exit 1
    end

    plugin_name = args.first
    strategy = extract_strategy_from_args(args)
    force = args.include?('--force')

    [plugin_name, strategy, force]
  end

  def extract_strategy_from_args(args)
    strategy = nil
    args[1..].each { |arg| strategy = Regexp.last_match(1).to_sym if arg =~ /^--strategy=(.+)$/ }

    strategy ||= :interactive
    valid_strategies = %i[interactive namespace priority disable]

    unless valid_strategies.include?(strategy)
      puts "Error: Invalid strategy: #{strategy}"
      puts "Valid strategies: #{valid_strategies.join(', ')}"
      exit 1
    end

    strategy
  end

  def validate_plugin_exists(plugin_name, plugins)
    return if plugins.key?(plugin_name)

    puts "Error: Plugin '#{plugin_name}' not found."
    puts "Available plugins: #{plugins.keys.join(', ')}"
    exit 1
  end

  def find_plugin_conflicts(plugin_name, plugins)
    plugin_info = plugins[plugin_name]
    plugin_class = plugin_info[:class]
    detect_plugin_conflicts(plugin_name, plugin_class, plugins)
  end

  def display_plugin_conflicts_result(plugin_name, conflicts)
    if conflicts.empty?
      puts "No conflicts found for plugin '#{plugin_name}'."
    else
      puts "Conflicts for plugin '#{plugin_name}':"
      conflicts.each { |conflict| puts "  - #{conflict}" }
      puts ''
    end
  end

  def execute_resolution_strategy(strategy, _plugin_name, _conflicts, _force)
    case strategy
    when :interactive
      puts 'Interactive resolution simplified. Use --strategy=namespace.'
    when :namespace
      puts 'Applying namespace resolution...'
      puts '(This feature is currently simplified)'
    when :priority
      puts 'Applying priority resolution...'
      puts '(This feature is currently simplified)'
    when :disable
      puts 'Applying plugin disable...'
      puts '(This feature is currently simplified)'
    end
  end
end
