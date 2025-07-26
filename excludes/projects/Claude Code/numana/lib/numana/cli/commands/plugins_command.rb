# frozen_string_literal: true

require_relative '../base_command'

# Define the namespace for subcommands
module Numana::Commands::Plugins
end

require_relative 'plugins/list_command'
require_relative 'plugins/conflicts_command'
require_relative 'plugins/resolve_command'

# Main command for managing plugins. Acts as a dispatcher for subcommands.
class Numana::Commands::PluginsCommand < Numana::Commands::BaseCommand
  command 'plugins', 'Manage plugins (list, resolve conflicts)'

  SUBCOMMANDS = {
    'list' => Numana::Commands::Plugins::ListCommand,
    'conflicts' => Numana::Commands::Plugins::ConflictsCommand,
    '--conflicts' => Numana::Commands::Plugins::ConflictsCommand,
    'resolve' => Numana::Commands::Plugins::ResolveCommand
  }.freeze

  def execute(args, global_options = {})
    subcommand_name = args.first
    subcommand_class = SUBCOMMANDS[subcommand_name]

    if subcommand_class
      subcommand_class.new.execute(args[1..], global_options)
    elsif subcommand_name == '--help' || subcommand_name == 'help' || subcommand_name.nil?
      show_help
    else
      handle_unknown_subcommand(subcommand_name)
    end
  rescue StandardError => e
    handle_error(e)
  end

  private

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

  def handle_unknown_subcommand(subcommand)
    puts "Error: Unknown plugins subcommand: #{subcommand}"
    show_help
    exit 1
  end
end
