# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Confidence Interval results
#
# Handles formatting of confidence interval calculations including:
# - Confidence level and interval bounds (lower and upper)
# - Point estimate (sample mean) and margin of error
# - Standard error and sample size information
# - Support for different confidence levels (90%, 95%, 99%, etc.)
#
# Supports verbose, JSON, and quiet output formats with precision control.
class Numana::Presenters::ConfidenceIntervalPresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return '' if @result.nil?

    lines = []
    lines << build_confidence_interval_line
    lines << "下限: #{format_value(@result[:lower_bound])}"
    lines << "上限: #{format_value(@result[:upper_bound])}"
    lines << "標本平均: #{format_value(@result[:point_estimate] || @result[:sample_mean])}"
    lines << "誤差の幅: #{format_value(@result[:margin_of_error])}"
    lines << "標準誤差: #{format_value(@result[:standard_error])}"
    lines << "サンプルサイズ: #{@result[:sample_size]}"

    lines.join("\n")
  end

  def format_quiet
    return '' if @result.nil?

    lower = format_value(@result[:lower_bound])
    upper = format_value(@result[:upper_bound])
    "#{lower} #{upper}"
  end

  def json_fields
    return {} if @result.nil?

    base_data = {
      confidence_level: @result[:confidence_level],
      lower_bound: apply_precision(@result[:lower_bound], @precision),
      upper_bound: apply_precision(@result[:upper_bound], @precision),
      point_estimate: apply_precision(@result[:point_estimate] || @result[:sample_mean], @precision),
      margin_of_error: apply_precision(@result[:margin_of_error], @precision),
      standard_error: apply_precision(@result[:standard_error], @precision),
      sample_size: @result[:sample_size]
    }

    base_data.merge(dataset_metadata)
  end

  private

  def build_confidence_interval_line
    level = @result[:confidence_level]
    lower = format_value(@result[:lower_bound])
    upper = format_value(@result[:upper_bound])
    "#{level}%信頼区間: [#{lower}, #{upper}]"
  end
end
