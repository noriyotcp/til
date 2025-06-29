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

    def self.format_growth_rate(growth_data, options = {})
      case options[:format]
      when 'json'
        format_growth_rate_json(growth_data, options)
      when 'quiet'
        format_growth_rate_quiet(growth_data, options)
      else
        format_growth_rate_default(growth_data, options)
      end
    end

    # Format seasonal analysis output
    def self.format_seasonal(seasonal_data, options = {})
      case options[:format]
      when 'json'
        format_seasonal_json(seasonal_data, options)
      when 'quiet'
        format_seasonal_quiet(seasonal_data, options)
      else
        format_seasonal_default(seasonal_data, options)
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

    private_class_method def self.format_growth_rate_json(growth_data, options)
      formatted_data = build_formatted_growth_data(growth_data, options)
      JSON.generate({ growth_rate_analysis: formatted_data }.merge(dataset_metadata(options)))
    end

    private_class_method def self.build_formatted_growth_data(growth_data, options)
      formatted_rates = growth_data[:growth_rates].map do |rate|
        if rate.infinite?
          rate.positive? ? 'Infinity' : '-Infinity'
        else
          apply_precision(rate, options[:precision])
        end
      end

      {
        period_growth_rates: formatted_rates,
        compound_annual_growth_rate: if growth_data[:compound_annual_growth_rate]
                                       apply_precision(growth_data[:compound_annual_growth_rate], options[:precision])
                                     end,
        average_growth_rate: if growth_data[:average_growth_rate]
                               apply_precision(growth_data[:average_growth_rate], options[:precision])
                             end
      }
    end

    private_class_method def self.format_growth_rate_quiet(growth_data, options)
      cagr = growth_data[:compound_annual_growth_rate]
      avg_growth = growth_data[:average_growth_rate]

      cagr_value = cagr ? apply_precision(cagr, options[:precision]) : ''
      avg_value = avg_growth ? apply_precision(avg_growth, options[:precision]) : ''

      "#{cagr_value} #{avg_value}".strip
    end

    private_class_method def self.format_growth_rate_default(growth_data, options)
      return 'エラー: データが不十分です（2つ以上の値が必要）' if growth_data[:growth_rates].empty?

      result = "成長率分析:\n"
      result += format_period_growth_rates(growth_data[:growth_rates], options)
      result += format_cagr_output(growth_data[:compound_annual_growth_rate], options)
      result += format_average_growth_output(growth_data[:average_growth_rate], options)
      result
    end

    private_class_method def self.format_period_growth_rates(growth_rates, options)
      formatted_rates = growth_rates.map do |rate|
        if rate.infinite?
          rate.positive? ? '+∞%' : '-∞%'
        else
          precision_value = apply_precision(rate, options[:precision])
          format_percentage(precision_value)
        end
      end
      "期間別成長率: #{formatted_rates.join(', ')}\n"
    end

    private_class_method def self.format_cagr_output(cagr, options)
      if cagr
        cagr_formatted = format_percentage(apply_precision(cagr, options[:precision]))
        "複合年間成長率 (CAGR): #{cagr_formatted}\n"
      else
        "複合年間成長率 (CAGR): 計算不可（負の初期値）\n"
      end
    end

    private_class_method def self.format_average_growth_output(avg_growth, options)
      if avg_growth
        avg_formatted = format_percentage(apply_precision(avg_growth, options[:precision]))
        "平均成長率: #{avg_formatted}"
      else
        '平均成長率: 計算不可'
      end
    end

    private_class_method def self.format_seasonal_json(seasonal_data, options)
      if seasonal_data.nil?
        return JSON.generate({ seasonal_analysis: nil, error: 'データが不十分です' }.merge(dataset_metadata(options)))
      end

      formatted_data = build_formatted_seasonal_data(seasonal_data, options)
      JSON.generate({ seasonal_analysis: formatted_data }.merge(dataset_metadata(options)))
    end

    private_class_method def self.build_formatted_seasonal_data(seasonal_data, options)
      formatted_indices = seasonal_data[:seasonal_indices].map do |index|
        apply_precision(index, options[:precision])
      end

      {
        period: seasonal_data[:period],
        seasonal_indices: formatted_indices,
        seasonal_strength: apply_precision(seasonal_data[:seasonal_strength], options[:precision]),
        has_seasonality: seasonal_data[:has_seasonality]
      }
    end

    private_class_method def self.format_seasonal_quiet(seasonal_data, options)
      return '' if seasonal_data.nil?

      strength = apply_precision(seasonal_data[:seasonal_strength], options[:precision])
      has_seasonality = seasonal_data[:has_seasonality] ? 'true' : 'false'
      "#{seasonal_data[:period]} #{strength} #{has_seasonality}"
    end

    private_class_method def self.format_seasonal_default(seasonal_data, options)
      if seasonal_data.nil?
        'エラー: データが不十分です（季節性分析には最低4つの値が必要）'
      else
        formatted_indices = seasonal_data[:seasonal_indices].map do |index|
          apply_precision(index, options[:precision])
        end
        strength_formatted = apply_precision(seasonal_data[:seasonal_strength], options[:precision])
        seasonality_status = seasonal_data[:has_seasonality] ? '季節性あり' : '季節性なし'

        result = "季節性分析結果:\n"
        result += "検出周期: #{seasonal_data[:period]}\n"
        result += "季節指数: #{formatted_indices.join(', ')}\n"
        result += "季節性強度: #{strength_formatted}\n"
        result += "季節性判定: #{seasonality_status}"
        result
      end
    end

    private_class_method def self.format_percentage(value)
      if value == value.to_i # Check if it's a whole number
        format('%+d%%', value.to_i)
      else
        # Use default 2 decimal places, but remove trailing zeros
        formatted = format('%+.2f%%', value)
        formatted.gsub(/\.?0+%$/, '%')
      end
    end
  end
end
