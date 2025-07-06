# frozen_string_literal: true

require_relative '../base_command'
require_relative '../statistical_output_formatter'
require_relative '../t_test_input_handler'
require_relative '../t_test_help_constants'
require_relative '../t_test_output_formatter'

# Command for performing statistical t-test analysis (independent, paired, one-sample)
class NumberAnalyzer::Commands::TTestCommand < NumberAnalyzer::Commands::BaseCommand
  include NumberAnalyzer::CLI::TTestHelpConstants
  command 't-test', 'Perform statistical t-test analysis'

  private

  def validate_arguments(args)
    input_handler.validate_arguments(args)
  end

  def parse_input(args)
    input_handler.parse_input(args)
  end

  def input_handler
    @input_handler ||= NumberAnalyzer::CLI::TTestInputHandler.new(@options)
  end

  def perform_calculation(data)
    test_type = input_handler.determine_test_type

    params = prepare_test_parameters(data, test_type)
    validate_test_data(data, test_type)
    result = execute_t_test(data, params, test_type)
    validate_result(result, test_type)
    enhance_result_metadata(result, data, test_type)
  end

  def prepare_test_parameters(_data, test_type)
    case test_type
    when :one_sample
      population_mean = @options[:population_mean] || @options[:mu]
      { population_mean: Float(population_mean) }
    when :independent, :paired
      {}
    end
  rescue ArgumentError => e
    raise ArgumentError, build_error_message(test_type, e)
  end

  def validate_test_data(data, test_type)
    case test_type
    when :independent
      dataset1, dataset2 = data
      if (dataset1.length - dataset2.length).abs > dataset1.length
        raise ArgumentError,
              "Error: Dataset lengths differ significantly (#{dataset1.length} vs #{dataset2.length})"
      end
    when :paired
      dataset1, dataset2 = data
      if dataset1.length != dataset2.length
        raise ArgumentError,
              "Error: For paired data, both groups must have the same length (#{dataset1.length} vs #{dataset2.length})"
      end
    end
  end

  def execute_t_test(data, params, test_type)
    analyzer = NumberAnalyzer.new(test_type == :one_sample ? data : data.first)
    analyzer.t_test(
      test_type == :one_sample ? nil : data.last,
      { type: test_type }.merge(params)
    )
  end

  def validate_result(result, test_type)
    return unless result.nil?

    error_messages = {
      one_sample: 'Error: Could not perform one-sample t-test. Check your data',
      independent: 'Error: Could not perform t-test. Check your data',
      paired: 'Error: Could not perform paired t-test. Check your data'
    }
    raise ArgumentError, error_messages[test_type]
  end

  def enhance_result_metadata(result, data, test_type)
    metadata = { test_type: test_type }

    case test_type
    when :one_sample
      metadata[:dataset_size] = data.size
      metadata[:population_mean] = result[:population_mean] || @options[:population_mean] || @options[:mu]
    when :independent, :paired
      dataset1, dataset2 = data
      metadata[:dataset1_size] = dataset1.size
      metadata[:dataset2_size] = dataset2.size
    end

    result.merge(metadata)
  end

  def build_error_message(test_type, original_error)
    case test_type
    when :one_sample
      "Error: Invalid population mean: #{@options[:population_mean] || @options[:mu]}"
    else
      original_error.message
    end
  end

  def output_result(result)
    output_formatter.send("format_#{output_format}_output", result)
  end

  def output_formatter
    @output_formatter ||= NumberAnalyzer::CLI::TTestOutputFormatter.new(@options)
  end

  def output_format
    return 'json' if @options[:format] == 'json'
    return 'quiet' if @options[:quiet]

    'standard'
  end

  def show_help
    puts HELP_TEXT
  end

  def default_options
    super.merge({
                  paired: false,
                  one_sample: false,
                  population_mean: nil,
                  mu: nil
                })
  end
end
