# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Mode Analysis results
#
# Handles formatting of mode calculations for descriptive statistics.
# The mode represents the most frequently occurring value(s) in a dataset.
# Provides comprehensive mode analysis including:
# - Single or multiple mode values with appropriate formatting
# - Graceful handling of datasets with no mode (all values unique)
# - Support for verbose, JSON, and quiet output formats
# - Japanese localization for user-friendly verbose output
#
# Supports all output modes with dataset metadata integration.
class Numana::Presenters::ModePresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'モードなし' if mode_empty?

    @result.join(', ')
  end

  def format_quiet
    return '' if mode_empty?

    @result.join(' ')
  end

  def json_fields
    formatted_mode = mode_empty? ? nil : @result
    { mode: formatted_mode }.merge(dataset_metadata)
  end

  private

  def mode_empty?
    @result.nil? || @result.empty?
  end
end
