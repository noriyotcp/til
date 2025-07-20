# frozen_string_literal: true

require 'json'

# FormattingUtils provides shared formatting utilities for NumberAnalyzer
# Used by Presenter classes for consistent output formatting across all statistical commands
#
# This module consolidates common formatting logic that was previously scattered
# across the codebase, providing a clean, reusable interface for:
# - Value formatting with precision control
# - Array formatting for different output modes
# - JSON output generation with metadata
# - Dataset metadata management
#
# Usage:
#   include Numana::FormattingUtils
#   formatted = format_value(3.14159, precision: 2) # => "3.14"
#   json_result = format_json_value(42, {dataset_size: 100}) # => JSON with metadata
module Numana::FormattingUtils
  # Format single numeric value based on options
  # Supports precision control and JSON output format
  #
  # @param value [Numeric] The value to format
  # @param options [Hash] Formatting options
  # @option options [Integer] :precision Number of decimal places
  # @option options [String] :format Output format ('json' or default)
  # @return [String] Formatted value
  def format_value(value, options = {})
    formatted_value = apply_precision(value, options[:precision])

    case options[:format]
    when 'json'
      format_json_value(formatted_value, options)
    else
      formatted_value.to_s
    end
  end

  # Format array of values based on options
  # Supports different output modes: default (comma-separated), quiet (space-separated), JSON
  #
  # @param values [Array<Numeric>] Array of values to format
  # @param options [Hash] Formatting options
  # @option options [Integer] :precision Number of decimal places
  # @option options [String] :format Output format ('json', 'quiet', or default)
  # @return [String] Formatted array as string
  def format_array(values, options = {})
    formatted_values = values.map { |v| apply_precision(v, options[:precision]) }

    case options[:format]
    when 'json'
      format_json_array(formatted_values, options)
    when 'quiet'
      formatted_values.join(' ')
    else
      formatted_values.join(', ')
    end
  end

  # Apply precision rounding to numeric values
  # Returns the original value if precision is not specified or value is not numeric
  #
  # @param value [Object] The value to apply precision to
  # @param precision [Integer, nil] Number of decimal places (nil for no rounding)
  # @return [Object] Rounded value (if numeric and precision given) or original value
  def apply_precision(value, precision)
    return value unless precision && value.is_a?(Numeric)

    value.round(precision)
  end

  # Generate JSON output for a single value with metadata
  #
  # @param value [Object] The value to include in JSON
  # @param options [Hash] Options for metadata generation
  # @return [String] JSON string with value and metadata
  def format_json_value(value, options)
    result = { value: value }
    result.merge!(dataset_metadata(options))
    JSON.generate(result)
  end

  # Generate JSON output for an array of values with metadata
  #
  # @param values [Array] The values to include in JSON
  # @param options [Hash] Options for metadata generation
  # @return [String] JSON string with values and metadata
  def format_json_array(values, options)
    result = { values: values }
    result.merge!(dataset_metadata(options))
    JSON.generate(result)
  end

  # Extract dataset metadata from options
  # Currently supports dataset_size, can be extended for other metadata
  #
  # @param options [Hash] Options hash that may contain metadata
  # @return [Hash] Metadata hash for inclusion in JSON output
  def dataset_metadata(options)
    metadata = {}
    metadata[:dataset_size] = options[:dataset_size] if options[:dataset_size]
    metadata
  end
end
