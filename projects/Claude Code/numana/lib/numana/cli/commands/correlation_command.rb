# frozen_string_literal: true

require_relative '../base_command'

# Command for calculating Pearson correlation coefficient between two datasets
class Numana::Commands::CorrelationCommand < Numana::Commands::BaseCommand
  command 'correlation', 'Calculate Pearson correlation coefficient between two datasets'

  private

  def validate_arguments(args)
    return if @options[:help]

    # Valid cases: file mode or args with '--' separator
    return if @options[:file] || args.include?('--') || (args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') })

    raise ArgumentError, <<~ERROR
      Error: correlation command requires two datasets.
      Examples: bundle exec numana correlation 1 2 3 -- 4 5 6
               bundle exec numana correlation data1.csv data2.csv
    ERROR
  end

  def parse_input(args)
    # Check if inputs are files
    if args.length == 2 && args.all? { |arg| arg.end_with?('.csv', '.json', '.txt') }
      parse_file_datasets(args)
    elsif args.include?('--')
      parse_numeric_datasets(args)
    else
      raise ArgumentError, <<~ERROR
        Error: Use "--" to separate two datasets or specify two files.
        Examples: bundle exec numana correlation 1 2 3 -- 4 5 6
                 bundle exec numana correlation data1.csv data2.csv
      ERROR
    end
  end

  def parse_file_datasets(files)
    require_relative '../../file_reader'

    dataset1 = FileReader.read_from_file(files[0])
    dataset2 = FileReader.read_from_file(files[1])

    [dataset1, dataset2]
  end

  def parse_numeric_datasets(args)
    separator_index = args.index('--')

    dataset1_args = args[0...separator_index]
    dataset2_args = args[(separator_index + 1)..]

    raise ArgumentError, 'Error: Both datasets need values' if dataset1_args.empty? || dataset2_args.empty?

    dataset1 = parse_numbers(dataset1_args)
    dataset2 = parse_numbers(dataset2_args)

    [dataset1, dataset2]
  end

  def parse_numbers(args)
    args.map do |arg|
      Float(arg)
    rescue ArgumentError
      raise ArgumentError, "Invalid number: #{arg}"
    end
  end

  def perform_calculation(data)
    dataset1, dataset2 = data

    raise ArgumentError, "Error: Dataset lengths differ (#{dataset1.length} vs #{dataset2.length})" if dataset1.length != dataset2.length

    raise ArgumentError, 'Error: Correlation calculation requires at least 2 data points' if dataset1.length < 2

    analyzer = Numana.new(dataset1)
    correlation = analyzer.correlation(dataset2)
    interpretation = analyzer.interpret_correlation(correlation)

    {
      correlation: correlation,
      interpretation: interpretation,
      dataset1_size: dataset1.length,
      dataset2_size: dataset2.length
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
    value = result[:correlation]
    if @options[:precision]
      puts format("%.#{@options[:precision]}f", value)
    else
      puts value.round(1)
    end
  end

  def output_standard(result)
    correlation = result[:correlation]

    formatted_correlation = if @options[:precision]
                              format("%.#{@options[:precision]}f", correlation)
                            else
                              format('%.4f', correlation)
                            end

    puts "Correlation coefficient: #{formatted_correlation}"
    puts "Interpretation: #{result[:interpretation]}"
    puts "Dataset 1 size: #{result[:dataset1_size]}"
    puts "Dataset 2 size: #{result[:dataset2_size]}"
  end

  def show_help
    puts <<~HELP
      correlation - #{self.class.description}

      Usage: numana correlation [OPTIONS] DATA1 -- DATA2
             numana correlation [OPTIONS] FILE1 FILE2

      Options:
        --help                Show this help message
        --format FORMAT       Output format (json)
        --precision N         Number of decimal places
        --quiet               Minimal output (correlation value only)

      Examples:
        # Numeric input with separator
        numana correlation 1 2 3 -- 2 4 6

        # File input
        numana correlation data1.csv data2.csv

        # JSON output
        numana correlation --format=json 1 2 3 -- 2 4 6
    HELP
  end
end
