# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating moving average with customizable window size
class NumberAnalyzer::Commands::MovingAverageCommand < NumberAnalyzer::Commands::BaseCommand
  command 'moving-average', 'Calculate moving average with specified window size'

  private

  def validate_arguments(_args)
    return if @options[:help]

    # Window size validation
    return unless @options[:window] && @options[:window] <= 0

    raise ArgumentError, 'Error: Window size must be a positive integer'
  end

  def parse_input(args)
    require_relative '../data_input_handler'
    NumberAnalyzer::Commands::DataInputHandler.parse(args, @options)
  end

  def perform_calculation(data)
    # Parse window size from options or use default
    window_size = @options[:window] || 3

    begin
      window_size = Integer(window_size)
    rescue ArgumentError
      raise ArgumentError, "Error: Invalid window size: #{@options[:window]}"
    end

    raise ArgumentError, 'Error: Window size must be a positive integer' if window_size <= 0

    analyzer = NumberAnalyzer.new(data)
    result = analyzer.moving_average(window_size)

    {
      moving_average: result,
      window_size: window_size,
      dataset_size: data.size
    }
  end

  def output_result(result)
    if @options[:format] == 'json'
      output_json(result)
    elsif @options[:quiet]
      output_quiet(result)
    else
      output_standard(result)
    end
  end

  def output_json(result)
    require 'json'
    puts JSON.generate(result)
  end

  def output_quiet(result)
    values = result[:moving_average]
    formatted_values = if @options[:precision]
                         values.map { |v| format("%.#{@options[:precision]}f", v) }
                       else
                         values.map { |v| format('%.2f', v) }
                       end
    puts formatted_values.join(' ')
  end

  def output_standard(result)
    moving_average = result[:moving_average]
    window_size = result[:window_size]
    dataset_size = result[:dataset_size]

    puts "移動平均 (ウィンドウサイズ: #{window_size}):"

    formatted_values = if @options[:precision]
                         moving_average.map { |v| format("%.#{@options[:precision]}f", v) }
                       else
                         moving_average.map { |v| format('%.2f', v) }
                       end

    puts formatted_values.join(', ')
    puts "元データサイズ: #{dataset_size}, 移動平均数: #{moving_average.length}"
  end

  def show_help
    puts <<~HELP
      moving-average - #{self.class.description}

      Usage: number_analyzer moving-average [OPTIONS] [NUMBERS...]

      Options:
        --help                Show this help message
        --file FILE           Read numbers from a file
        --window N            Window size for moving average (default: 3)
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (values only)

      Examples:
        # Default 3-period moving average
        number_analyzer moving-average 1 2 3 4 5 6 7

        # 5-period moving average
        number_analyzer moving-average --window=5 1 2 3 4 5 6 7 8 9

        # From file with JSON output
        number_analyzer moving-average --file sales.csv --format=json

        # Custom precision
        number_analyzer moving-average --precision=2 --window=3 1.1 2.3 3.2 4.8
    HELP
  end

  def default_options
    super.merge({
                  window: nil
                })
  end
end
