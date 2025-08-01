# frozen_string_literal: true

require_relative '../base_command'
require_relative '../../presenters/confidence_interval_presenter'

# Command for calculating confidence interval for population mean
class Numana::Commands::ConfidenceIntervalCommand < Numana::Commands::BaseCommand
  command 'confidence-interval', 'Calculate confidence interval for population mean'

  private

  def validate_arguments(args)
    return if @options[:help]

    # Check if first argument looks like a confidence level
    return unless confidence_level_from_args?(args)

    level = Float(args[0])
    validate_confidence_level(level)
  rescue ArgumentError
    raise ArgumentError, "Error: Invalid confidence level: #{args[0]}"
  end

  def parse_input(args)
    confidence_level = parse_confidence_level_from_args(args)
    remaining_args = confidence_level_from_args?(args) ? args[1..] : args

    require_relative '../data_input_handler'
    data = Numana::Commands::DataInputHandler.parse(remaining_args, @options)

    [data, confidence_level]
  end

  def confidence_level_from_args?(args)
    return false if args.empty?

    begin
      level = Float(args[0])
      # Only consider it a confidence level if it's a reasonable confidence level
      # and there are more arguments (the data values) or file option is set
      level.between?(80, 99) && (args.length > 1 || @options[:file])
    rescue ArgumentError
      false
    end
  end

  def parse_confidence_level_from_args(args)
    # Check if first argument is a confidence level (number between 80-99)
    level = if confidence_level_from_args?(args)
              Float(args[0])
            else
              # Use option or default
              @options[:level] || @options[:confidence_level] || 95
            end

    validate_confidence_level(level)
    level
  rescue ArgumentError
    raise ArgumentError, "Error: Invalid confidence level: #{args[0]}"
  end

  def validate_confidence_level(level)
    return if level.between?(1, 99)

    raise ArgumentError, "Error: Confidence level must be between 1-99: #{level}"
  end

  def perform_calculation(data_and_level)
    data, confidence_level = data_and_level

    raise ArgumentError, 'Error: Confidence interval calculation requires at least 2 data points' if data.length < 2

    analyzer = Numana.new(data)
    result = analyzer.confidence_interval(confidence_level)

    raise ArgumentError, 'Error: Could not calculate confidence interval. Check your data' if result.nil?

    result.merge({
                   confidence_level: confidence_level,
                   dataset_size: data.size
                 })
  end

  def output_result(result)
    # Add sample_mean to result if missing (for compatibility)
    result[:sample_mean] ||= result[:point_estimate]

    presenter = Numana::Presenters::ConfidenceIntervalPresenter.new(result, @options)
    puts presenter.format
  end

  def show_help
    puts <<~HELP
      confidence-interval - #{self.class.description}

      Usage: numana confidence-interval [OPTIONS] [LEVEL] [NUMBERS...]
             numana confidence-interval [OPTIONS] [LEVEL] --file DATA.csv

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --level LEVEL         Confidence level (default: 95)
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (bounds only)

      Examples:
        # 95% confidence interval (default)
        numana confidence-interval 1 2 3 4 5

        # 90% confidence interval#{' '}
        numana confidence-interval 90 1 2 3 4 5

        # Using --level option
        numana confidence-interval --level=99 --file data.csv

        # JSON output with precision
        numana confidence-interval --format=json --precision=2 data.csv

        # Quiet mode (bounds only)
        numana confidence-interval --quiet 95 1.2 1.5 1.8 2.1
    HELP
  end

  def default_options
    super.merge({
                  level: nil,
                  confidence_level: nil
                })
  end
end
