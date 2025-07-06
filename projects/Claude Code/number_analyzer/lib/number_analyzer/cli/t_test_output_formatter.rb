# frozen_string_literal: true

require_relative 'statistical_output_formatter'

# Output formatter for t-test results
class NumberAnalyzer::CLI::TTestOutputFormatter
  def initialize(options)
    @options = options
  end

  def format_standard_output(result)
    formatter = NumberAnalyzer::CLI::StatisticalOutputFormatter
    test_type = result[:test_type]

    # Header
    puts formatter.format_test_header('t検定', test_type_japanese(test_type))
    puts

    # Basic statistics
    puts formatter.format_basic_statistics(
      't統計量',
      result[:t_statistic],
      result[:degrees_of_freedom],
      result[:p_value],
      result[:significant],
      @options[:precision]
    )

    # Test-specific dataset information
    dataset_info = build_dataset_info(result)
    puts dataset_info if dataset_info
  end

  def format_json_output(result)
    require 'json'
    puts JSON.generate(result)
  end

  def format_quiet_output(result)
    p_value = result[:p_value]
    if @options[:precision]
      puts format("%.#{@options[:precision]}f", p_value)
    else
      puts format('%.6f', p_value)
    end
  end

  private

  def build_dataset_info(result)
    formatter = NumberAnalyzer::CLI::StatisticalOutputFormatter

    case result[:test_type]
    when :one_sample
      formatter.format_dataset_info(
        population_mean: result[:population_mean],
        dataset_size: result[:dataset_size]
      )
    when :independent
      formatter.format_dataset_info(
        dataset1_size: result[:dataset1_size],
        dataset2_size: result[:dataset2_size]
      )
    when :paired
      "ペア数: #{result[:dataset1_size]}"
    end
  end

  def test_type_japanese(type)
    case type
    when :one_sample
      '一標本'
    when :independent
      '独立2標本'
    when :paired
      '対応あり'
    else
      type.to_s
    end
  end
end
