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

    # Format correlation coefficient output
    def self.format_correlation(correlation_value, options = {})
      case options[:format]
      when 'json'
        formatted_correlation = correlation_value.nil? ? nil : apply_precision(correlation_value, options[:precision])
        JSON.generate({ correlation: formatted_correlation }.merge(dataset_metadata(options)))
      when 'quiet'
        correlation_value.nil? ? '' : apply_precision(correlation_value, options[:precision]).to_s
      else
        if correlation_value.nil?
          'エラー: データセットが無効です'
        else
          formatted_value = apply_precision(correlation_value, options[:precision])
          "相関係数: #{formatted_value} (#{interpret_correlation(formatted_value)})"
        end
      end
    end

    # Format trend analysis output
    def self.format_trend(trend_data, options = {})
      case options[:format]
      when 'json'
        format_trend_json(trend_data, options)
      when 'quiet'
        format_trend_quiet(trend_data, options)
      else
        format_trend_default(trend_data, options)
      end
    end

    # Format moving average output
    def self.format_moving_average(moving_avg_data, options = {})
      case options[:format]
      when 'json'
        format_moving_average_json(moving_avg_data, options)
      when 'quiet'
        format_moving_average_quiet(moving_avg_data, options)
      else
        format_moving_average_default(moving_avg_data, options)
      end
    end

    private_class_method def self.format_trend_json(trend_data, options)
      return JSON.generate({ trend: nil }.merge(dataset_metadata(options))) if trend_data.nil?

      formatted_trend = build_formatted_trend_data(trend_data, options)
      JSON.generate({ trend: formatted_trend }.merge(dataset_metadata(options)))
    end

    private_class_method def self.build_formatted_trend_data(trend_data, options)
      {
        slope: apply_precision(trend_data[:slope], options[:precision]),
        intercept: apply_precision(trend_data[:intercept], options[:precision]),
        r_squared: apply_precision(trend_data[:r_squared], options[:precision]),
        direction: trend_data[:direction]
      }
    end

    private_class_method def self.format_trend_quiet(trend_data, options)
      return '' if trend_data.nil?

      slope = apply_precision(trend_data[:slope], options[:precision])
      intercept = apply_precision(trend_data[:intercept], options[:precision])
      r_squared = apply_precision(trend_data[:r_squared], options[:precision])
      "#{slope} #{intercept} #{r_squared}"
    end

    private_class_method def self.format_trend_default(trend_data, options)
      if trend_data.nil?
        'エラー: データが不十分です（2つ以上の値が必要）'
      else
        slope = apply_precision(trend_data[:slope], options[:precision])
        intercept = apply_precision(trend_data[:intercept], options[:precision])
        r_squared = apply_precision(trend_data[:r_squared], options[:precision])

        "トレンド分析結果:\n傾き: #{slope}\n切片: #{intercept}\n決定係数(R²): #{r_squared}\n方向性: #{trend_data[:direction]}"
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

    private_class_method def self.interpret_correlation(value)
      abs_value = value.abs
      case abs_value
      when 0.8..1.0
        value.positive? ? '強い正の相関' : '強い負の相関'
      when 0.5..0.8
        value.positive? ? '中程度の正の相関' : '中程度の負の相関'
      when 0.3..0.5
        value.positive? ? '弱い正の相関' : '弱い負の相関'
      else
        'ほぼ無相関'
      end
    end

    private_class_method def self.format_moving_average_json(moving_avg_data, options)
      if moving_avg_data.nil?
        return JSON.generate({ moving_average: nil, error: 'データが不十分です' }.merge(dataset_metadata(options)))
      end

      formatted_values = moving_avg_data.map { |value| apply_precision(value, options[:precision]) }
      result = {
        moving_average: formatted_values,
        window_size: options[:window_size]
      }
      result.merge!(dataset_metadata(options))
      JSON.generate(result)
    end

    private_class_method def self.format_moving_average_quiet(moving_avg_data, options)
      return '' if moving_avg_data.nil?

      formatted_values = moving_avg_data.map { |value| apply_precision(value, options[:precision]) }
      formatted_values.join(' ')
    end

    private_class_method def self.format_moving_average_default(moving_avg_data, options)
      if moving_avg_data.nil?
        'エラー: データが不十分です（ウィンドウサイズがデータ長を超えています）'
      else
        formatted_values = moving_avg_data.map { |value| apply_precision(value, options[:precision]) }
        window_size = options[:window_size] || 3

        header = "移動平均（ウィンドウサイズ: #{window_size}）:"
        values_display = formatted_values.join(', ')
        "#{header}\n#{values_display}"
      end
    end
  end
end
