# frozen_string_literal: true

require_relative '../base_command'

# Command for analyzing growth rates including period-over-period rates and CAGR
class Numana::Commands::GrowthRateCommand < Numana::Commands::BaseCommand
  command 'growth-rate', 'Analyze growth rates including period-over-period rates and CAGR'

  private

  def parse_input(args)
    require_relative '../data_input_handler'
    Numana::Commands::DataInputHandler.parse(args, @options)
  end

  def perform_calculation(data)
    raise ArgumentError, 'Error: Growth rate calculation requires at least 2 data points' if data.length < 2

    analyzer = Numana.new(data)

    # Calculate growth rate metrics
    growth_rates = analyzer.growth_rates
    cagr = analyzer.compound_annual_growth_rate
    avg_growth = analyzer.average_growth_rate

    # Convert percentage format to decimal format for presenter consistency
    # NumberAnalyzer returns percentages (10.0 = 10%), but presenter expects decimals (0.1 = 10%)
    {
      growth_rates: growth_rates.map { |rate| rate.infinite? ? rate : rate / 100.0 },
      compound_annual_growth_rate: cagr ? cagr / 100.0 : nil,
      average_growth_rate: avg_growth ? avg_growth / 100.0 : nil,
      dataset_size: data.size
    }
  end

  def output_result(result)
    require_relative '../../presenters/growth_rate_presenter'
    presenter = Numana::Presenters::GrowthRatePresenter.new(result, @options)
    puts presenter.format
  end

  def show_help
    puts <<~HELP
      growth-rate - #{self.class.description}

      Usage: numana growth-rate [OPTIONS] [NUMBERS...]

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (CAGR only)

      Examples:
        # Basic growth rate analysis
        numana growth-rate 100 110 121 133

        # From file with JSON output
        numana growth-rate --format=json --file sales.csv

        # Custom precision
        numana growth-rate --precision=1 50 55 60 62

        # Quiet mode (CAGR only)
        numana growth-rate --quiet 100 120 144
    HELP
  end
end
