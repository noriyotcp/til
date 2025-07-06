# frozen_string_literal: true

# Shared formatter for complex statistical command output
# Reduces code duplication and complexity in Command Pattern classes
class NumberAnalyzer::CLI::StatisticalOutputFormatter
  class << self
    # Format value with precision control
    def format_value(value, precision = nil)
      return 'N/A' if value.nil?

      if precision
        format("%.#{precision}f", value)
      else
        case value
        when Float
          format('%.4f', value)
        else
          value.to_s
        end
      end
    end

    # Format significance result
    def format_significance(significant, _alpha = 0.05)
      significant ? 'Significant' : 'Not significant'
    end

    # Format test result header with test type
    def format_test_header(test_name, test_type = nil)
      header = "#{test_name} Results"
      header += " (#{test_type})" if test_type
      "#{header}:\n"
    end

    # Format basic test statistics (common pattern)
    def format_basic_statistics(statistic_name, statistic_value, degrees_of_freedom, p_value, significant, precision = nil)
      result = []
      result << "#{statistic_name}: #{format_value(statistic_value, precision)}"
      result << "Degrees of Freedom: #{degrees_of_freedom}" if degrees_of_freedom
      result << "p-value: #{format_value(p_value, precision || 6)}"
      result << "Significance (α=0.05): #{format_significance(significant)}"
      result.join("\n")
    end

    # Format effect size (common in statistical tests)
    def format_effect_size(effect_name, effect_value, precision = nil)
      "#{effect_name}: #{format_value(effect_value, precision)}"
    end

    # Format dataset information
    def format_dataset_info(options = {})
      info = []

      info << "Dataset Size: #{options[:dataset_size]}" if options[:dataset_size]

      if options[:dataset1_size] && options[:dataset2_size]
        info << "Group 1 Size: #{options[:dataset1_size]}"
        info << "Group 2 Size: #{options[:dataset2_size]}"
      end

      info << "Population Mean: #{options[:population_mean]}" if options[:population_mean]

      info.join("\n") unless info.empty?
    end

    # Format frequency data (for chi-square)
    def format_frequencies(observed, expected = nil, precision = nil)
      result = []

      if observed
        formatted_observed = observed.map { |freq| format_value(freq, precision || 1) }
        result << "Observed Frequencies: #{formatted_observed.join(', ')}"
      end

      if expected
        formatted_expected = expected.map { |freq| format_value(freq, precision || 2) }
        result << "Expected Frequencies: #{formatted_expected.join(', ')}"
      end

      result.join("\n")
    end

    # Format arrays with precision (for time series data)
    def format_array_values(values, precision = nil)
      return 'N/A' if values.nil? || values.empty?

      formatted = values.map { |v| format_value(v, precision) }
      formatted.join(', ')
    end

    # Format confidence intervals
    def format_confidence_interval(lower, upper, precision = nil)
      lower_str = format_value(lower, precision)
      upper_str = format_value(upper, precision)
      "[#{lower_str}, #{upper_str}]"
    end

    # Format interpretation text with line breaks
    def format_interpretation(lines)
      return '' if lines.nil? || lines.empty?

      Array(lines).join("\n")
    end

    # Format seasonal strength levels
    def format_seasonal_strength_level(strength)
      case strength
      when 0...0.3
        'Weak'
      when 0.3...0.6
        'Moderate'
      when 0.6...0.8
        'Strong'
      else
        'Very Strong'
      end
    end

    # Format trend direction
    def format_trend_direction(direction)
      case direction.to_s.downcase
      when 'increasing', 'up', 'positive'
        'Increasing'
      when 'decreasing', 'down', 'negative'
        'Decreasing'
      when 'stable', 'flat', 'none'
        'Stable'
      else
        direction.to_s
      end
    end
  end
end
