# frozen_string_literal: true

# Help generation module for Numana CLI
# Provides comprehensive help information for commands
module Numana::CLI::HelpGenerator
  extend self

  # Show help information for a specific command
  def show_command_help(command, description = nil)
    description ||= default_description_for(command)

    puts <<~HELP
      Usage: bundle exec numana #{command} [options] numbers...

      Description: #{description}

      Options:
        --format json     Output in JSON format
        --precision N     Round to N decimal places
        --quiet          Minimal output (no labels)
        --file FILE, -f  Read numbers from file
        --help           Show this help

      Examples:
        bundle exec numana #{command} 1 2 3 4 5
        bundle exec numana #{command} --format=json 1 2 3
        bundle exec numana #{command} --precision=2 1.234 2.567
        bundle exec numana #{command} --file data.csv
    HELP
  end

  # Show help information for chi-square command
  def show_chi_square_help
    puts <<~HELP
      Usage: bundle exec numana chi-square [options] numbers...

      Description: Perform chi-square test for independence or goodness-of-fit

      Options:
        --independence    Perform independence test
        --goodness-of-fit Perform goodness-of-fit test
        --uniform        Test against uniform distribution
        --format json     Output in JSON format
        --precision N     Round to N decimal places
        --quiet          Minimal output (no labels)
        --file FILE, -f  Read numbers from file
        --help           Show this help

      Examples:
        bundle exec numana chi-square --independence 30 20 -- 15 35
        bundle exec numana chi-square --goodness-of-fit observed.csv expected.csv
        bundle exec numana chi-square --uniform 8 12 10 15 9 6
    HELP
  end

  # Show general help information
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

  # Show help for plugin-related commands
  def show_plugin_help
    puts <<~HELP
      Usage: bundle exec numana plugins [subcommand] [options]

      Description: Manage Numana plugins

      Subcommands:
        list               List all available plugins
        list --conflicts   Show plugin conflicts
        conflicts          Show plugin conflicts
        resolve <plugin>   Resolve plugin conflicts

      Resolution Strategies:
        --strategy=interactive   Interactive conflict resolution
        --strategy=namespace     Use namespace prefixes
        --strategy=priority      Use priority-based resolution
        --strategy=disable       Disable conflicting plugin

      Examples:
        bundle exec numana plugins list
        bundle exec numana plugins list --show-conflicts
        bundle exec numana plugins conflicts
        bundle exec numana plugins resolve myplugin --strategy=interactive
    HELP
  end

  # Command descriptions lookup table
  COMMAND_DESCRIPTIONS = {
    'mean' => 'Calculate the arithmetic mean (average) of numbers',
    'median' => 'Calculate the median (middle value) of numbers',
    'mode' => 'Find the most frequently occurring value(s)',
    'sum' => 'Calculate the sum of all numbers',
    'min' => 'Find the minimum value',
    'max' => 'Find the maximum value',
    'variance' => 'Calculate the variance of numbers',
    'std' => 'Calculate the standard deviation',
    'quartiles' => 'Calculate the quartiles (Q1, Q2, Q3)',
    'percentile' => 'Calculate the specified percentile',
    'outliers' => 'Identify outliers using IQR method',
    'histogram' => 'Generate histogram of the data',
    'correlation' => 'Calculate Pearson correlation coefficient',
    't-test' => 'Perform t-test analysis',
    'anova' => 'Perform analysis of variance',
    'trend' => 'Analyze linear trend in time series',
    'moving-average' => 'Calculate moving average',
    'growth-rate' => 'Calculate growth rates',
    'seasonal' => 'Analyze seasonal patterns',
    'plugins' => 'Manage Numana plugins'
  }.freeze

  private

  # Get default description for a command
  def default_description_for(command)
    COMMAND_DESCRIPTIONS.fetch(command, 'Perform statistical analysis')
  end
end
