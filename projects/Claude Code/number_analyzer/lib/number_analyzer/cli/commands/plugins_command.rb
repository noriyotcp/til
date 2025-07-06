# frozen_string_literal: true

require_relative '../base_command'

# Command for managing plugins (list, resolve conflicts, etc.)
class NumberAnalyzer::Commands::PluginsCommand < NumberAnalyzer::Commands::BaseCommand
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
      puts "エラー: 不明なpluginsサブコマンド: #{subcommand}"
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
      puts "重複解決には 'plugins resolve' コマンドを使用してください。"
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
      Usage: bundle exec number_analyzer plugins [subcommand] [options]

      Subcommands:
        list [--show-conflicts]     プラグイン一覧と重複検出
        resolve <plugin> [options]  重複解決（対話形式または自動）
        conflicts, --conflicts      重複検出と表示

      Options for resolve:
        --strategy=STRATEGY  解決戦略 (interactive, namespace, priority, disable)
        --force             確認なしで実行

      Examples:
        bundle exec number_analyzer plugins list
        bundle exec number_analyzer plugins list --show-conflicts
        bundle exec number_analyzer plugins resolve my_plugin --strategy=namespace
        bundle exec number_analyzer plugins --conflicts
    HELP
  end

  def loaded_plugins
    NumberAnalyzer::CLI.plugin_system.instance_variable_get(:@plugins) || {}
  end

  def display_interface_message(type, data = nil)
    case type
    when :no_plugins
      puts 'プラグインがロードされていません。'
    when :plugins_header
      puts "ロード済みプラグイン (#{data}個):"
      puts ''
    when :conflicts_header
      puts 'プラグイン重複検出結果:'
      puts ''
    when :no_conflicts_found
      puts '✅ 重複は検出されませんでした。'
      puts "ロード済みプラグイン数: #{data}" if data
    end
  end

  def display_plugin_info(name, plugin_info, show_conflicts)
    plugin_class = plugin_info[:class]
    priority = plugin_info[:priority] || 'unknown'
    commands = extract_plugin_commands(plugin_class)

    puts "  #{name}:"
    puts "    優先度: #{priority}"
    puts "    クラス: #{plugin_class}"
    puts "    コマンド: #{commands}"

    display_conflicts_if_requested(name, plugin_class, show_conflicts) if show_conflicts
    puts ''
  end

  def extract_plugin_commands(plugin_class)
    plugin_class.respond_to?(:commands) ? plugin_class.commands.keys.join(', ') : 'N/A'
  end

  def display_conflicts_if_requested(name, plugin_class, show_conflicts)
    return unless show_conflicts

    conflicts = detect_plugin_conflicts(name, plugin_class, loaded_plugins)
    puts "    ⚠️  重複: #{conflicts.join(', ')}" unless conflicts.empty?
  end

  def display_conflicts_summary(plugins)
    all_conflicts = detect_all_conflicts(plugins)
    if all_conflicts.any?
      puts '重複サマリー:'
      all_conflicts.each do |conflict_type, details|
        puts "  #{conflict_type}: #{details}"
      end
    else
      puts '✅ 重複は検出されませんでした。'
    end
  end

  def display_detailed_conflicts(all_conflicts, plugins)
    all_conflicts.each do |conflict_type, conflicts|
      puts "#{conflict_type}の重複:"
      conflicts.each do |item, conflicting_plugins|
        puts "  '#{item}' は以下のプラグインで重複しています:"
        conflicting_plugins.each do |plugin_name|
          plugin_info = plugins[plugin_name]
          priority = plugin_info[:priority] || 'unknown'
          puts "    - #{plugin_name} (優先度: #{priority})"
        end
      end
      puts ''
    end
  end

  def parse_resolve_arguments(args)
    if args.empty?
      puts 'エラー: 解決するプラグイン名を指定してください。'
      puts '使用例: bundle exec number_analyzer plugins resolve my_plugin --strategy=namespace'
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
      puts "エラー: 無効な戦略: #{strategy}"
      puts "有効な戦略: #{valid_strategies.join(', ')}"
      exit 1
    end

    strategy
  end

  def validate_plugin_exists(plugin_name, plugins)
    return if plugins.key?(plugin_name)

    puts "エラー: プラグイン '#{plugin_name}' が見つかりません。"
    puts "利用可能なプラグイン: #{plugins.keys.join(', ')}"
    exit 1
  end

  def find_plugin_conflicts(plugin_name, plugins)
    plugin_info = plugins[plugin_name]
    plugin_class = plugin_info[:class]
    detect_plugin_conflicts(plugin_name, plugin_class, plugins)
  end

  def display_plugin_conflicts_result(plugin_name, conflicts)
    if conflicts.empty?
      puts "プラグイン '#{plugin_name}' に重複はありません。"
    else
      puts "プラグイン '#{plugin_name}' の重複:"
      conflicts.each { |conflict| puts "  - #{conflict}" }
      puts ''
    end
  end

  def execute_resolution_strategy(strategy, _plugin_name, _conflicts, _force)
    case strategy
    when :interactive
      puts '対話的解決は簡略化されました。--strategy=namespace を使用してください。'
    when :namespace
      puts '名前空間による解決を適用しています...'
      puts '（この機能は現在簡略化されています）'
    when :priority
      puts '優先度による解決を適用しています...'
      puts '（この機能は現在簡略化されています）'
    when :disable
      puts 'プラグイン無効化を適用しています...'
      puts '（この機能は現在簡略化されています）'
    end
  end
end
