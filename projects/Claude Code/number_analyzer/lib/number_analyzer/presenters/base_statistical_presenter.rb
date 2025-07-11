# frozen_string_literal: true

require 'json'
require_relative '../presenters'

# Base class for statistical test result presentation
#
# Provides a Template Method Pattern implementation for formatting statistical test results
# in multiple output formats (verbose, JSON, quiet). Subclasses must implement the abstract
# methods to provide test-specific formatting logic.
#
# @abstract Subclasses must implement #json_fields, #format_quiet, and #format_verbose
class NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def initialize(result, options = {})
    @result = result
    @options = options
    @precision = options[:precision] || 6
  end

  def format
    case @options[:format]
    when 'json'
      format_json
    when 'quiet'
      format_quiet
    else
      format_verbose
    end
  end

  def format_json
    JSON.generate(json_fields)
  end

  def round_value(value)
    value.round(@precision)
  end

  def format_significance(significant)
    significant ? '**Significant**' : 'Not significant'
  end

  def json_fields
    raise NotImplementedError, 'Subclass must implement json_fields'
  end

  def format_quiet
    raise NotImplementedError, 'Subclass must implement format_quiet'
  end

  def format_verbose
    raise NotImplementedError, 'Subclass must implement format_verbose'
  end
end
