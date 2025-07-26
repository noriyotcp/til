# frozen_string_literal: true

# Help text constants for TTestCommand
module Numana::CLI::TTestHelpConstants
  HELP_TEXT = <<~HELP.freeze
    t-test - Perform statistical t-test analysis

    Usage: numana t-test [OPTIONS] [DATA...]

    Test Types:
      Independent samples (default): Compare two independent groups
      Paired samples:               Compare paired/matched data#{'  '}
      One-sample:                   Compare sample to known population mean

    Options:
      --help                        Show this help message
      --paired                      Perform paired samples t-test
      --one-sample                  Perform one-sample t-test
      --population-mean MEAN        Population mean for one-sample test
      --mu MEAN                     Population mean (alias for --population-mean)
      --format FORMAT               Output format (json)
      --precision N                 Number of decimal places
      --quiet                       Minimal output (p-value only)

    Examples:
      # Independent samples t-test
      numana t-test 1 2 3 -- 4 5 6
      numana t-test group1.csv group2.csv

      # Paired samples t-test
      numana t-test --paired before.csv after.csv
      numana t-test --paired 10 12 14 -- 15 18 20

      # One-sample t-test
      numana t-test --one-sample --population-mean=100 --file data.csv
      numana t-test --one-sample --mu=50 45 48 52 49

      # JSON output with precision
      numana t-test --format=json --precision=3 group1.csv group2.csv
  HELP
end
