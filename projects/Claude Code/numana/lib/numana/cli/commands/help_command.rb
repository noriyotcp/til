# frozen_string_literal: true

require_relative '../base_command'

# Command for displaying help information
class Numana::Commands::HelpCommand < Numana::Commands::BaseCommand
  command 'help', 'Display help information for commands'

  # Override to show help-specific help instead of general help
  def show_help
    puts <<~HELP
      help - Display help information for commands

      Usage: numana help [COMMAND]

      Arguments:
        COMMAND               Show help for a specific command

      Examples:
        numana help           Show general help
        numana help mean      Show help for mean command
        numana help median    Show help for median command
    HELP
  end

  private

  def validate_arguments(args)
    # Help command can take 0 or 1 argument (command name)
    return if args.empty? || args.length == 1

    raise ArgumentError, 'Help command takes at most one argument (command name)'
  end

  def parse_input(args)
    # Help command doesn't need data parsing
    args
  end

  def perform_calculation(args)
    if args.empty?
      show_general_help
    else
      show_command_help(args.first)
    end
  end

  def output_result(result)
    # Help command handles its own output
  end

  def show_general_help
    puts <<~HELP
      Numana - Statistical Analysis Tool

      Usage:
        bundle exec numana <command> [options] [numbers...]
        bundle exec numana --file data.csv

      Available Commands:
        Basic Statistics:
          mean, median, mode, sum, min, max

        Advanced Analysis:
          variance, std, quartiles, percentile, outliers

        Time Series Analysis:
          trend, moving-average, growth-rate, seasonal

        Statistical Tests:
          t-test, chi-square, anova, correlation

        Analysis of Variance:
          anova, levene, bartlett

        Non-parametric Tests:
          kruskal-wallis, mann-whitney, wilcoxon, friedman

        Plugin Management:
          plugins

      Detailed Help:
        bundle exec numana help <command>
        bundle exec numana <command> --help

      Examples:
        bundle exec numana mean 1 2 3 4 5
        bundle exec numana median --file data.csv
        bundle exec numana histogram --format=json 1 2 3 4 5
    HELP
  end

  def show_command_help(command_name)
    # Check if command exists in CommandRegistry
    if Numana::Commands::CommandRegistry.exists?(command_name)
      command_class = Numana::Commands::CommandRegistry.get(command_name)
      command = command_class.new
      command.show_help
    else
      puts "Unknown command: #{command_name}"
      puts "Use 'bundle exec numana help' to see available commands."
    end
  end
end
