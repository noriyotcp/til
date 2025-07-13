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
  attr_reader :result, :options, :precision

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
      # Handle backward compatibility with options[:quiet]
      @options[:quiet] ? format_quiet : format_verbose
    end
  end

  def format_json
    JSON.generate(json_fields)
  end

  def round_value(value)
    return value unless value.is_a?(Numeric)

    value.round(@precision)
  end

  def format_significance(significant)
    significant ? '**Significant**' : 'Not significant'
  end

  # Apply precision to numeric values - compatible with OutputFormatter
  def apply_precision(value, precision = nil)
    return value unless precision && value.is_a?(Numeric)

    value.round(precision)
  end

  # Format numeric values for different output modes
  def format_value(value, mode = :default)
    formatted_value = apply_precision(value, @precision)
    case mode
    when :json
      formatted_value
    else
      formatted_value.to_s
    end
  end

  # Build dataset metadata for JSON output
  def dataset_metadata
    metadata = {}
    metadata[:dataset_size] = @options[:dataset_size] if @options[:dataset_size]
    metadata[:dataset1_size] = @options[:dataset1_size] if @options[:dataset1_size]
    metadata[:dataset2_size] = @options[:dataset2_size] if @options[:dataset2_size]
    metadata
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
