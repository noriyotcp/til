# frozen_string_literal: true

# Help text constants for TTestCommand
module NumberAnalyzer::CLI::TTestHelpConstants
  HELP_TEXT = <<~HELP.freeze
    t-test - Perform statistical t-test analysis

    Usage: number_analyzer t-test [OPTIONS] [DATA...]

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
      number_analyzer t-test 1 2 3 -- 4 5 6
      number_analyzer t-test group1.csv group2.csv

      # Paired samples t-test
      number_analyzer t-test --paired before.csv after.csv
      number_analyzer t-test --paired 10 12 14 -- 15 18 20

      # One-sample t-test
      number_analyzer t-test --one-sample --population-mean=100 --file data.csv
      number_analyzer t-test --one-sample --mu=50 45 48 52 49

      # JSON output with precision
      number_analyzer t-test --format=json --precision=3 group1.csv group2.csv
  HELP
end
