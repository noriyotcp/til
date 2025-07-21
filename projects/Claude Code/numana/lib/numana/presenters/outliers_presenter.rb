# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Outliers Analysis results
#
# Handles formatting of outlier detection results for descriptive statistics.
# Outliers are data points that fall significantly outside the expected range,
# typically identified using the IQR (Interquartile Range) method.
# Provides comprehensive outlier analysis including:
# - Individual outlier values with precision control
# - Graceful handling of datasets with no outliers
# - Support for verbose, JSON, and quiet output formats
# - Japanese localization for user-friendly verbose output
#
# Supports all output modes with dataset metadata integration.
class Numana::Presenters::OutliersPresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'なし' if outliers_empty?

    formatted_values = @result.map { |v| format_value(v) }
    formatted_values.join(', ')
  end

  def format_quiet
    return '' if outliers_empty?

    formatted_values = @result.map { |v| format_value(v) }
    formatted_values.join(' ')
  end

  def json_fields
    formatted_outliers = outliers_empty? ? [] : @result.map { |v| apply_precision(v, @precision) }
    { outliers: formatted_outliers }.merge(dataset_metadata)
  end

  private

  def outliers_empty?
    @result.nil? || @result.empty?
  end
end
