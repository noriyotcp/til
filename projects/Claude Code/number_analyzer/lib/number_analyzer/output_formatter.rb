# frozen_string_literal: true

require 'json'

# Output formatting utilities for NumberAnalyzer CLI
class NumberAnalyzer
  # Handles different output formats (JSON, quiet mode, precision control)
  class OutputFormatter
    # Format single numeric value based on options
    def self.format_value(value, options = {})
      formatted_value = apply_precision(value, options[:precision])

      case options[:format]
      when 'json'
        format_json_value(formatted_value, options)
      else
        formatted_value.to_s
      end
    end

    # Format array of values based on options
    def self.format_array(values, options = {})
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

    # Format quartiles output based on options
    def self.format_quartiles(quartiles, options = {})
      case options[:format]
      when 'json'
        format_quartiles_json(quartiles, options)
      when 'quiet'
        format_quartiles_quiet(quartiles, options)
      else
        format_quartiles_default(quartiles, options)
      end
    end

    private_class_method def self.format_quartiles_json(quartiles, options)
      formatted_quartiles = {
        q1: apply_precision(quartiles[:q1], options[:precision]),
        q2: apply_precision(quartiles[:q2], options[:precision]),
        q3: apply_precision(quartiles[:q3], options[:precision])
      }
      JSON.generate(formatted_quartiles.merge(dataset_metadata(options)))
    end

    private_class_method def self.format_quartiles_quiet(quartiles, options)
      values = [quartiles[:q1], quartiles[:q2], quartiles[:q3]]
      format_array(values, options.merge(format: 'quiet'))
    end

    private_class_method def self.format_quartiles_default(quartiles, options)
      q1 = apply_precision(quartiles[:q1], options[:precision])
      q2 = apply_precision(quartiles[:q2], options[:precision])
      q3 = apply_precision(quartiles[:q3], options[:precision])
      "Q1: #{q1}\nQ2: #{q2}\nQ3: #{q3}"
    end

    # Format mode output (handles empty mode case)
    def self.format_mode(mode_values, options = {})
      case options[:format]
      when 'json'
        formatted_mode = mode_values.empty? ? nil : mode_values
        JSON.generate({ mode: formatted_mode }.merge(dataset_metadata(options)))
      when 'quiet'
        mode_values.empty? ? '' : mode_values.join(' ')
      else
        mode_values.empty? ? 'モードなし' : mode_values.join(', ')
      end
    end

    # Format outliers output (handles empty outliers case)
    def self.format_outliers(outlier_values, options = {})
      case options[:format]
      when 'json'
        formatted_outliers = outlier_values.map { |v| apply_precision(v, options[:precision]) }
        JSON.generate({ outliers: formatted_outliers }.merge(dataset_metadata(options)))
      when 'quiet'
        outlier_values.empty? ? '' : format_array(outlier_values, options.merge(format: 'quiet'))
      else
        outlier_values.empty? ? 'なし' : format_array(outlier_values, options)
      end
    end

    private_class_method def self.apply_precision(value, precision)
      return value unless precision && value.is_a?(Numeric)

      value.round(precision)
    end

    private_class_method def self.format_json_value(value, options)
      result = { value: value }
      result.merge!(dataset_metadata(options))
      JSON.generate(result)
    end

    private_class_method def self.format_json_array(values, options)
      result = { values: values }
      result.merge!(dataset_metadata(options))
      JSON.generate(result)
    end

    private_class_method def self.dataset_metadata(options)
      metadata = {}
      metadata[:dataset_size] = options[:dataset_size] if options[:dataset_size]
      metadata
    end
  end
end
