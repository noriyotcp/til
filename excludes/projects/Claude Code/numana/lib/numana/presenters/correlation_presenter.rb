# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Correlation Analysis results
#
# Handles formatting of Pearson correlation coefficient with statistical interpretation.
# Provides comprehensive correlation analysis including:
# - Correlation coefficient value with precision control
# - Statistical interpretation (strong, moderate, weak, none)
# - Error handling for invalid datasets
# - Support for verbose, JSON, and quiet output formats
#
# Supports all output modes with dataset metadata integration.
class Numana::Presenters::CorrelationPresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'エラー: データセットが無効です' if correlation_invalid?

    formatted_value = format_value(@result)
    "相関係数: #{formatted_value} (#{interpret_correlation(formatted_value)})"
  end

  def format_quiet
    return '' if correlation_invalid?

    format_value(@result)
  end

  def json_fields
    return { correlation: nil }.merge(dataset_metadata) if correlation_invalid?

    {
      correlation: apply_precision(@result, @precision)
    }.merge(dataset_metadata)
  end

  private

  def correlation_invalid?
    @result.nil?
  end

  def interpret_correlation(value)
    # Use NumberAnalyzer's built-in correlation interpretation
    # Convert to numeric if it's a string (from format_value)
    numeric_value = value.is_a?(String) ? value.to_f : value
    analyzer = Numana.new([])
    analyzer.interpret_correlation(numeric_value)
  end
end
