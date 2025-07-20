# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# GrowthRatePresenter: Handles formatting of growth rate analysis results
# Supports all standard output formats (default, JSON, quiet) with precision control
# Consolidates logic from both OutputFormatter and GrowthRateCommand
#
# Expected result format:
#   {
#     growth_rates: [0.1, 0.2, 0.15],              # Period-over-period rates (decimal)
#     compound_annual_growth_rate: 0.125,          # CAGR (decimal)
#     average_growth_rate: 0.15,                   # Average rate (decimal)
#     dataset_size: 4
#   }
#
# Example usage:
#   result = { growth_rates: [0.1, 0.1], compound_annual_growth_rate: 0.1, average_growth_rate: 0.1, dataset_size: 3 }
#   presenter = Numana::Presenters::GrowthRatePresenter.new(result, options)
#   puts presenter.format
class Numana::Presenters::GrowthRatePresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'エラー: データが不十分です（2つ以上の値が必要）' if growth_rate_invalid?

    result = "成長率分析:\n"
    result += format_period_growth_rates_verbose
    result += format_cagr_output_verbose
    result += format_average_growth_output_verbose
    result
  end

  def format_quiet
    return '' if growth_rate_invalid?

    cagr = @result[:compound_annual_growth_rate]
    avg_growth = @result[:average_growth_rate]

    cagr_value = cagr ? format_value(cagr) : ''
    avg_value = avg_growth ? format_value(avg_growth) : ''

    "#{cagr_value} #{avg_value}".strip
  end

  def json_fields
    return { growth_rate_analysis: nil, error: 'データが不十分です' }.merge(dataset_metadata) if growth_rate_invalid?

    {
      growth_rate_analysis: build_formatted_growth_data
    }.merge(dataset_metadata)
  end

  private

  def growth_rate_invalid?
    @result.nil? || @result[:growth_rates].nil? || @result[:growth_rates].empty?
  end

  def format_period_growth_rates_verbose
    growth_rates = @result[:growth_rates]
    formatted_rates = growth_rates.map do |rate|
      if rate.infinite?
        rate.positive? ? '+∞%' : '-∞%'
      else
        format_percentage_display(rate)
      end
    end
    "期間別成長率: #{formatted_rates.join(', ')}\n"
  end

  def format_cagr_output_verbose
    cagr = @result[:compound_annual_growth_rate]
    if cagr
      cagr_formatted = format_percentage_display(cagr)
      "複合年間成長率 (CAGR): #{cagr_formatted}\n"
    else
      "複合年間成長率 (CAGR): 計算不可（負の初期値）\n"
    end
  end

  def format_average_growth_output_verbose
    avg_growth = @result[:average_growth_rate]
    if avg_growth
      avg_formatted = format_percentage_display(avg_growth)
      "平均成長率: #{avg_formatted}"
    else
      '平均成長率: 計算不可'
    end
  end

  def build_formatted_growth_data
    formatted_rates = @result[:growth_rates].map do |rate|
      if rate.infinite?
        rate.positive? ? 'Infinity' : '-Infinity'
      else
        apply_precision(rate, @precision)
      end
    end

    {
      period_growth_rates: formatted_rates,
      compound_annual_growth_rate: (@result[:compound_annual_growth_rate] ? apply_precision(@result[:compound_annual_growth_rate], @precision) : nil),
      average_growth_rate: (@result[:average_growth_rate] ? apply_precision(@result[:average_growth_rate], @precision) : nil)
    }
  end

  # Format percentage for display (with % sign)
  # Convert decimal to percentage (0.1 -> 10%)
  def format_percentage_display(value)
    percentage_value = value * 100 # Convert decimal to percentage
    precision_value = apply_precision(percentage_value, @precision)
    format_percentage_sign(precision_value)
  end

  # Format percentage with proper + sign and % symbol
  def format_percentage_sign(value)
    if value == value.to_i # Check if it's a whole number
      Kernel.format('%+d%%', value.to_i)
    elsif @options[:precision] # Explicitly set precision
      formatted = Kernel.format("%+.#{@precision}f%%", value)
      # For precision 4 and above, maintain trailing zeros to show precision
      # For precision 3 and below, remove trailing zeros for readability
      if @precision >= 4
        formatted
      else
        formatted.gsub(/\.?0+%$/, '%')
      end
    else
      # Use default 2 decimal places for standard formatting and remove trailing zeros
      formatted = Kernel.format('%+.2f%%', value)
      formatted.gsub(/\.?0+%$/, '%')
    end
  end
end
