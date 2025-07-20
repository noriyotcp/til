# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating linear trend analysis (slope, intercept, R²)
class Numana::Commands::TrendCommand < Numana::Commands::BaseCommand
  command 'trend', 'Calculate linear trend analysis (slope, intercept, R²)'

  private

  def perform_calculation(data)
    raise ArgumentError, 'Error: Trend analysis requires at least 2 data points' if data.length < 2

    analyzer = Numana.new(data)
    result = analyzer.linear_trend

    raise ArgumentError, 'Error: Trend analysis calculation failed' if result.nil?

    result
  end

  def output_result(result)
    @options[:dataset_size] = @data&.size if @data
    presenter = Numana::Presenters::TrendPresenter.new(result, @options)
    puts presenter.format
  end

  def parse_input(args)
    @data = super
    @data
  end

  def show_help
    puts <<~HELP
      trend - #{self.class.description}

      Usage: number_analyzer trend [OPTIONS] NUMBERS...
             number_analyzer trend [OPTIONS] --file FILE

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (slope intercept r_squared)

      Examples:
        # Ascending trend
        number_analyzer trend 1 2 3 4 5

        # File input
        number_analyzer trend --file data.csv

        # JSON output
        number_analyzer trend --format=json 1 2 3 4 5

        # Quiet mode with precision
        number_analyzer trend --quiet --precision=2 1.1 2.3 3.2 4.8
    HELP
  end
end
