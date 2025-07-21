# frozen_string_literal: true

require_relative '../base_command'
require_relative '../../presenters/seasonal_presenter'

# Command for analyzing seasonal patterns and decomposition
class Numana::Commands::SeasonalCommand < Numana::Commands::BaseCommand
  command 'seasonal', 'Analyze seasonal patterns and decomposition'

  private

  def validate_arguments(_args)
    return if @options[:help]

    # Period validation
    return unless @options[:period]

    begin
      period = Integer(@options[:period])
      raise ArgumentError, 'Error: Period must be 2 or greater' if period < 2
    rescue ArgumentError => e
      raise ArgumentError, e.message.include?('Period must be 2 or greater') ? e.message : "Error: Invalid period: #{@options[:period]}"
    end
  end

  def parse_input(args)
    require_relative '../data_input_handler'
    Numana::Commands::DataInputHandler.parse(args, @options)
  end

  def perform_calculation(data)
    raise ArgumentError, 'Error: Seasonal analysis requires at least 4 data points' if data.length < 4

    # Parse period from options if provided
    period = nil
    if @options[:period]
      begin
        period = Integer(@options[:period])
        raise ArgumentError, 'Error: Period must be 2 or greater' if period < 2
      rescue ArgumentError => e
        raise ArgumentError, e.message.include?('Period must be 2 or greater') ? e.message : "Error: Invalid period: #{@options[:period]}"
      end
    end

    analyzer = Numana.new(data)
    result = analyzer.seasonal_decomposition(period)

    result.merge({
                   dataset_size: data.size,
                   specified_period: period
                 })
  end

  def output_result(result)
    @options[:dataset_size] = result[:dataset_size] if result[:dataset_size]
    presenter = Numana::Presenters::SeasonalPresenter.new(result, @options)
    puts presenter.format
  end

  def show_help
    puts <<~HELP
      seasonal - #{self.class.description}

      Usage: number_analyzer seasonal [OPTIONS] [NUMBERS...]

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --period N            Specify seasonal period (default: auto-detect)
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (seasonal strength only)

      Examples:
        # Auto-detect seasonal period
        number_analyzer seasonal 10 20 15 25 12 22 17 27

        # Specify quarterly data (period=4)
        number_analyzer seasonal --period=4 100 120 110 130 105 125 115 135

        # From file with JSON output
        number_analyzer seasonal --format=json --file quarterly.csv

        # Custom precision
        number_analyzer seasonal --period=4 --precision=2 sales_data.csv
    HELP
  end

  def default_options
    super.merge({
                  period: nil
                })
  end
end
