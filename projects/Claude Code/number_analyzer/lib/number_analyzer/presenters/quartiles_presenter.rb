# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Quartiles Analysis results
#
# Handles formatting of quartile calculations (Q1, Q2, Q3) for descriptive statistics.
# Provides comprehensive quartile analysis including:
# - Individual quartile values (Q1, Q2/median, Q3) with precision control
# - Support for verbose, JSON, and quiet output formats
# - Dataset metadata integration for enhanced reporting
#
# The quartiles divide a dataset into four equal parts, providing insight into
# data distribution and variability.
class NumberAnalyzer::Presenters::QuartilesPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def format_verbose
    return '' if @result.nil?

    q1 = format_value(@result[:q1])
    q2 = format_value(@result[:q2])
    q3 = format_value(@result[:q3])
    "Q1: #{q1}\nQ2: #{q2}\nQ3: #{q3}"
  end

  def format_quiet
    return '' if @result.nil?

    values = [@result[:q1], @result[:q2], @result[:q3]]
    formatted_values = values.map { |v| format_value(v) }
    formatted_values.join(' ')
  end

  def json_fields
    return {} if @result.nil?

    {
      q1: apply_precision(@result[:q1], @precision),
      q2: apply_precision(@result[:q2], @precision),
      q3: apply_precision(@result[:q3], @precision)
    }.merge(dataset_metadata)
  end
end
