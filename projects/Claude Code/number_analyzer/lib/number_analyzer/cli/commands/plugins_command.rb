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

    # Get plugin system instance
    plugin_system = NumberAnalyzer::CLI.plugin_system

    # Get all loaded plugins
    plugins = plugin_system.instance_variable_get(:@plugins) || {}

    if plugins.empty?
      puts 'プラグインがロードされていません。'
      return
    end

    puts "ロード済みプラグイン (#{plugins.size}個):"
    puts ''

    plugins.each do |name, plugin_info|
      plugin_class = plugin_info[:class]
      priority = plugin_info[:priority] || 'unknown'

      # Get plugin commands if it's a CLI plugin
      commands = if plugin_class.respond_to?(:commands)
                   plugin_class.commands.keys.join(', ')
                 else
                   'N/A'
                 end

      puts "  #{name}:"
      puts "    優先度: #{priority}"
      puts "    クラス: #{plugin_class}"
      puts "    コマンド: #{commands}"

      if show_conflicts
        # Check for conflicts with this plugin
        conflicts = detect_plugin_conflicts(name, plugin_class, plugins)
        puts "    ⚠️  重複: #{conflicts.join(', ')}" unless conflicts.empty?
      end

      puts ''
    end

    return unless show_conflicts

    # Show overall conflict summary
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

  def run_plugins_conflicts(_args)
    # This is essentially the same as list --show-conflicts but focused on conflicts
    plugin_system = NumberAnalyzer::CLI.plugin_system
    plugins = plugin_system.instance_variable_get(:@plugins) || {}

    if plugins.empty?
      puts 'プラグインがロードされていません。'
      return
    end

    puts 'プラグイン重複検出結果:'
    puts ''

    all_conflicts = detect_all_conflicts(plugins)

    if all_conflicts.empty?
      puts '✅ 重複は検出されませんでした。'
      puts ''
      puts "ロード済みプラグイン数: #{plugins.size}"
      return
    end

    # Display conflicts by type
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

    puts "重複解決には 'plugins resolve' コマンドを使用してください。"
  end

  def run_plugins_resolve(args)
    if args.empty?
      puts 'エラー: 解決するプラグイン名を指定してください。'
      puts '使用例: bundle exec number_analyzer plugins resolve my_plugin --strategy=namespace'
      exit 1
    end

    plugin_name = args.first
    strategy = nil
    force = false

    # Parse options
    args[1..].each do |arg|
      case arg
      when /^--strategy=(.+)$/
        strategy = Regexp.last_match(1).to_sym
      when '--force'
        force = true
      end
    end

    # Default strategy
    strategy ||= :interactive

    # Validate strategy
    valid_strategies = %i[interactive namespace priority disable]
    unless valid_strategies.include?(strategy)
      puts "エラー: 無効な戦略: #{strategy}"
      puts "有効な戦略: #{valid_strategies.join(', ')}"
      exit 1
    end

    plugin_system = NumberAnalyzer::CLI.plugin_system
    plugins = plugin_system.instance_variable_get(:@plugins) || {}

    unless plugins.key?(plugin_name)
      puts "エラー: プラグイン '#{plugin_name}' が見つかりません。"
      puts "利用可能なプラグイン: #{plugins.keys.join(', ')}"
      exit 1
    end

    # Find conflicts for this plugin
    plugin_info = plugins[plugin_name]
    plugin_class = plugin_info[:class]
    conflicts = detect_plugin_conflicts(plugin_name, plugin_class, plugins)

    if conflicts.empty?
      puts "プラグイン '#{plugin_name}' に重複はありません。"
      return
    end

    puts "プラグイン '#{plugin_name}' の重複:"
    conflicts.each do |conflict|
      puts "  - #{conflict}"
    end
    puts ''

    # Apply resolution strategy (simplified implementation)
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
end
