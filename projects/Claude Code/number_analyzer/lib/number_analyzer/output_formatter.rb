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
      # Create a dummy NumberAnalyzer instance to access the interpret_correlation method
      analyzer = NumberAnalyzer.new([])
      analyzer.interpret_correlation(value)
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

    # Format t-test output based on options
    def self.format_t_test(t_test_data, options = {})
      case options[:format]
      when 'json'
        format_t_test_json(t_test_data, options)
      when 'quiet'
        format_t_test_quiet(t_test_data, options)
      else
        format_t_test_default(t_test_data, options)
      end
    end

    private_class_method def self.format_t_test_json(t_test_data, options)
      formatted_data = build_base_json_data(t_test_data, options)
      add_test_specific_json_fields(formatted_data, t_test_data, options)
      add_dataset_size_info(formatted_data, options)
      JSON.pretty_generate(formatted_data)
    end

    private_class_method def self.format_t_test_quiet(t_test_data, options)
      t_stat = apply_precision(t_test_data[:t_statistic], options[:precision])
      df = apply_precision(t_test_data[:degrees_of_freedom], options[:precision])
      p_val = apply_precision(t_test_data[:p_value], options[:precision])
      significant = t_test_data[:significant]

      "#{t_stat} #{df} #{p_val} #{significant}"
    end

    private_class_method def self.format_t_test_default(t_test_data, options)
      result = build_default_header(t_test_data, options)
      result += build_test_specific_details(t_test_data, options)
      result += build_significance_conclusion(t_test_data)
      result
    end

    private_class_method def self.build_base_json_data(t_test_data, options)
      {
        test_type: t_test_data[:test_type],
        t_statistic: apply_precision(t_test_data[:t_statistic], options[:precision]),
        degrees_of_freedom: apply_precision(t_test_data[:degrees_of_freedom], options[:precision]),
        p_value: apply_precision(t_test_data[:p_value], options[:precision]),
        significant: t_test_data[:significant]
      }
    end

    private_class_method def self.add_test_specific_json_fields(formatted_data, t_test_data, options)
      case t_test_data[:test_type]
      when 'independent_samples'
        add_independent_samples_json_fields(formatted_data, t_test_data, options)
      when 'paired_samples'
        add_paired_samples_json_fields(formatted_data, t_test_data, options)
      when 'one_sample'
        add_one_sample_json_fields(formatted_data, t_test_data, options)
      end
    end

    private_class_method def self.add_independent_samples_json_fields(formatted_data, t_test_data, options)
      formatted_data[:mean1] = apply_precision(t_test_data[:mean1], options[:precision])
      formatted_data[:mean2] = apply_precision(t_test_data[:mean2], options[:precision])
      formatted_data[:n1] = t_test_data[:n1]
      formatted_data[:n2] = t_test_data[:n2]
    end

    private_class_method def self.add_paired_samples_json_fields(formatted_data, t_test_data, options)
      formatted_data[:mean_difference] = apply_precision(t_test_data[:mean_difference], options[:precision])
      formatted_data[:n] = t_test_data[:n]
    end

    private_class_method def self.add_one_sample_json_fields(formatted_data, t_test_data, options)
      formatted_data[:sample_mean] = apply_precision(t_test_data[:sample_mean], options[:precision])
      formatted_data[:population_mean] = apply_precision(t_test_data[:population_mean], options[:precision])
      formatted_data[:n] = t_test_data[:n]
    end

    private_class_method def self.add_dataset_size_info(formatted_data, options)
      if options[:dataset1_size]
        formatted_data[:dataset1_size] = options[:dataset1_size]
        formatted_data[:dataset2_size] = options[:dataset2_size]
      elsif options[:dataset_size]
        formatted_data[:dataset_size] = options[:dataset_size]
      end
    end

    private_class_method def self.build_default_header(t_test_data, options)
      test_type_names = {
        'independent_samples' => '独立2標本t検定',
        'paired_samples' => '対応ありt検定',
        'one_sample' => '一標本t検定'
      }

      test_name = test_type_names[t_test_data[:test_type]] || t_test_data[:test_type]
      t_stat = apply_precision(t_test_data[:t_statistic], options[:precision])
      df = apply_precision(t_test_data[:degrees_of_freedom], options[:precision])
      p_val = apply_precision(t_test_data[:p_value], options[:precision])

      result = "T検定結果:\n"
      result += "検定タイプ: #{test_name}\n"
      result += "統計量: t = #{t_stat}\n"
      result += "自由度: df = #{df}\n"
      result += "p値: #{p_val}\n"
      result
    end

    private_class_method def self.build_test_specific_details(t_test_data, options)
      case t_test_data[:test_type]
      when 'independent_samples'
        build_independent_samples_details(t_test_data, options)
      when 'paired_samples'
        build_paired_samples_details(t_test_data, options)
      when 'one_sample'
        build_one_sample_details(t_test_data, options)
      else
        ''
      end
    end

    private_class_method def self.build_independent_samples_details(t_test_data, options)
      mean1 = apply_precision(t_test_data[:mean1], options[:precision])
      mean2 = apply_precision(t_test_data[:mean2], options[:precision])
      "グループ1: 平均 = #{mean1}, n = #{t_test_data[:n1]}\n" \
        "グループ2: 平均 = #{mean2}, n = #{t_test_data[:n2]}\n"
    end

    private_class_method def self.build_paired_samples_details(t_test_data, options)
      mean_diff = apply_precision(t_test_data[:mean_difference], options[:precision])
      "平均差: #{mean_diff}\n" \
        "サンプルサイズ: n = #{t_test_data[:n]}\n"
    end

    private_class_method def self.build_one_sample_details(t_test_data, options)
      sample_mean = apply_precision(t_test_data[:sample_mean], options[:precision])
      pop_mean = apply_precision(t_test_data[:population_mean], options[:precision])
      "標本平均: #{sample_mean}\n" \
        "母集団平均: #{pop_mean}\n" \
        "サンプルサイズ: n = #{t_test_data[:n]}\n"
    end

    private_class_method def self.build_significance_conclusion(t_test_data)
      alpha_level = 0.05
      if t_test_data[:significant]
        "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差あり"
      else
        "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差なし"
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

    # Format confidence interval data based on options
    def self.format_confidence_interval(ci_data, options = {})
      return '' if ci_data.nil?

      case options[:format]
      when 'json'
        format_confidence_interval_json(ci_data, options)
      when 'quiet'
        format_confidence_interval_quiet(ci_data, options)
      else
        format_confidence_interval_default(ci_data, options)
      end
    end

    private_class_method def self.format_confidence_interval_default(ci_data, options)
      formatted_data = build_formatted_confidence_interval_data(ci_data, options)
      build_confidence_interval_result_lines(formatted_data).join("\n")
    end

    private_class_method def self.build_confidence_interval_result_lines(formatted_data)
      confidence_interval_line = build_confidence_interval_line(formatted_data)

      [
        confidence_interval_line,
        "下限: #{formatted_data[:lower_bound]}",
        "上限: #{formatted_data[:upper_bound]}",
        "標本平均: #{formatted_data[:point_estimate]}",
        "誤差の幅: #{formatted_data[:margin_of_error]}",
        "標準誤差: #{formatted_data[:standard_error]}",
        "サンプルサイズ: #{formatted_data[:sample_size]}"
      ]
    end

    private_class_method def self.build_confidence_interval_line(formatted_data)
      level = formatted_data[:confidence_level]
      lower = formatted_data[:lower_bound]
      upper = formatted_data[:upper_bound]
      "#{level}%信頼区間: [#{lower}, #{upper}]"
    end

    private_class_method def self.format_confidence_interval_json(ci_data, options)
      formatted_data = build_formatted_confidence_interval_data(ci_data, options)
      formatted_data[:dataset_size] = options[:dataset_size] if options[:dataset_size]

      JSON.generate(formatted_data)
    end

    private_class_method def self.format_confidence_interval_quiet(ci_data, options)
      formatted_data = build_formatted_confidence_interval_data(ci_data, options)
      "#{formatted_data[:lower_bound]} #{formatted_data[:upper_bound]}"
    end

    private_class_method def self.build_formatted_confidence_interval_data(ci_data, options)
      {
        confidence_level: ci_data[:confidence_level],
        lower_bound: apply_precision(ci_data[:lower_bound], options[:precision]),
        upper_bound: apply_precision(ci_data[:upper_bound], options[:precision]),
        point_estimate: apply_precision(ci_data[:point_estimate], options[:precision]),
        margin_of_error: apply_precision(ci_data[:margin_of_error], options[:precision]),
        standard_error: apply_precision(ci_data[:standard_error], options[:precision]),
        sample_size: ci_data[:sample_size]
      }
    end

    # Format chi-square test data based on options
    def self.format_chi_square(chi_square_data, options = {})
      return '' if chi_square_data.nil?

      case options[:format]
      when 'json'
        format_chi_square_json(chi_square_data, options)
      when 'quiet'
        format_chi_square_quiet(chi_square_data, options)
      else
        format_chi_square_default(chi_square_data, options)
      end
    end

    private_class_method def self.format_chi_square_default(chi_square_data, options)
      formatted_data = build_formatted_chi_square_data(chi_square_data, options)
      build_chi_square_result_lines(formatted_data).join("\n")
    end

    private_class_method def self.build_chi_square_result_lines(formatted_data)
      test_type_names = {
        'independence' => '独立性検定',
        'goodness_of_fit' => '適合度検定'
      }

      test_name = test_type_names[formatted_data[:test_type]] || formatted_data[:test_type]

      lines = [
        'カイ二乗検定結果:',
        "検定タイプ: #{test_name}",
        "統計量: χ² = #{formatted_data[:chi_square_statistic]}",
        "自由度: df = #{formatted_data[:degrees_of_freedom]}",
        "p値: #{formatted_data[:p_value]}",
        build_significance_conclusion_chi_square(formatted_data[:significant])
      ]

      # Add effect size for independence tests
      if formatted_data[:test_type] == 'independence' && formatted_data[:cramers_v]
        lines << "効果サイズ (Cramér's V): #{formatted_data[:cramers_v]}"
      end

      # Add frequency validation warning if needed
      lines << (formatted_data[:warning] || '期待度数条件: 満たしている')

      lines
    end

    private_class_method def self.build_significance_conclusion_chi_square(significant)
      alpha_level = 0.05
      if significant
        "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差あり"
      else
        "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差なし"
      end
    end

    private_class_method def self.format_chi_square_json(chi_square_data, options)
      formatted_data = build_formatted_chi_square_data(chi_square_data, options)
      formatted_data[:dataset_size] = options[:dataset_size] if options[:dataset_size]

      JSON.generate(formatted_data)
    end

    private_class_method def self.format_chi_square_quiet(chi_square_data, options)
      formatted_data = build_formatted_chi_square_data(chi_square_data, options)
      chi_square = formatted_data[:chi_square_statistic]
      df = formatted_data[:degrees_of_freedom]
      p_value = formatted_data[:p_value]
      significant = formatted_data[:significant]

      "#{chi_square} #{df} #{p_value} #{significant}"
    end

    private_class_method def self.build_formatted_chi_square_data(chi_square_data, options)
      formatted_data = {
        test_type: chi_square_data[:test_type],
        chi_square_statistic: apply_precision(chi_square_data[:chi_square_statistic], options[:precision]),
        degrees_of_freedom: chi_square_data[:degrees_of_freedom],
        p_value: apply_precision(chi_square_data[:p_value], options[:precision]),
        significant: chi_square_data[:significant],
        expected_frequencies_valid: chi_square_data[:expected_frequencies_valid],
        warning: chi_square_data[:warning]
      }

      # Add effect size for independence tests
      if chi_square_data[:cramers_v]
        formatted_data[:cramers_v] = apply_precision(chi_square_data[:cramers_v], options[:precision])
      end

      # Add frequency data for detailed analysis
      if chi_square_data[:observed_frequencies]
        formatted_data[:observed_frequencies] = chi_square_data[:observed_frequencies]
      end

      if chi_square_data[:expected_frequencies]
        formatted_data[:expected_frequencies] = chi_square_data[:expected_frequencies]
      end

      formatted_data
    end

    # Format ANOVA output
    def self.format_anova(anova_data, options = {})
      case options[:format]
      when 'json'
        format_anova_json(anova_data, options)
      when 'quiet'
        format_anova_quiet(anova_data, options)
      else
        format_anova_default(anova_data, options)
      end
    end

    private_class_method def self.format_anova_json(anova_data, options)
      formatted_data = build_formatted_anova_data(anova_data, options)
      JSON.generate(formatted_data)
    end

    private_class_method def self.format_anova_default(anova_data, options)
      output = []
      output << '=== 一元配置分散分析結果 ==='
      output << ''

      # Group statistics
      output << "グループ平均値: #{format_array(anova_data[:group_means], options)}"
      output << "全体平均値: #{apply_precision(anova_data[:grand_mean], options[:precision])}"
      output << ''

      # ANOVA table
      output << '【分散分析表】'
      output << '変動要因                  平方和      自由度         平均平方           F値'
      output << ('-' * 60)

      ss_between = apply_precision(anova_data[:sum_of_squares][:between], options[:precision])
      ss_within = apply_precision(anova_data[:sum_of_squares][:within], options[:precision])
      ss_total = apply_precision(anova_data[:sum_of_squares][:total], options[:precision])

      ms_between = apply_precision(anova_data[:mean_squares][:between], options[:precision])
      ms_within = apply_precision(anova_data[:mean_squares][:within], options[:precision])

      f_stat = apply_precision(anova_data[:f_statistic], options[:precision])
      df_between, df_within = anova_data[:degrees_of_freedom]

      output << format('%-<factor>12s %<ss>12s %<df>8d %<ms>12s %<f_stat>12s', factor: '群間', ss: ss_between,
                                                                               df: df_between, ms: ms_between,
                                                                               f_stat: f_stat)
      output << format('%-<factor>12s %<ss>12s %<df>8d %<ms>12s %<f_stat>12s', factor: '群内', ss: ss_within,
                                                                               df: df_within, ms: ms_within,
                                                                               f_stat: '-')
      output << format('%-<factor>12s %<ss>12s %<df>8d %<ms>12s %<f_stat>12s', factor: '全体', ss: ss_total,
                                                                               df: df_between + df_within, ms: '-',
                                                                               f_stat: '-')
      output << ''

      # Statistical significance
      p_value = apply_precision(anova_data[:p_value], options[:precision])
      significance = anova_data[:significant] ? '有意' : '非有意'
      output << "F統計量: #{f_stat}"
      output << "p値: #{p_value}"
      output << "結果: #{significance} (α = 0.05)"
      output << ''

      # Effect sizes
      eta_sq = apply_precision(anova_data[:effect_size][:eta_squared], options[:precision])
      omega_sq = apply_precision(anova_data[:effect_size][:omega_squared], options[:precision])
      output << '効果サイズ:'
      output << "  η² (eta squared): #{eta_sq}"
      output << "  ω² (omega squared): #{omega_sq}"
      output << ''

      # Interpretation
      output << "解釈: #{anova_data[:interpretation]}"

      output.join("\n")
    end

    private_class_method def self.format_anova_quiet(anova_data, options)
      f_stat = apply_precision(anova_data[:f_statistic], options[:precision])
      p_value = apply_precision(anova_data[:p_value], options[:precision])
      eta_sq = apply_precision(anova_data[:effect_size][:eta_squared], options[:precision])
      df_between, df_within = anova_data[:degrees_of_freedom]
      significant = anova_data[:significant]

      "#{f_stat} #{df_between} #{df_within} #{p_value} #{eta_sq} #{significant}"
    end

    # Format two-way ANOVA results based on options
    def self.format_two_way_anova(anova_data, options = {})
      case options[:format]
      when 'json'
        format_two_way_anova_json(anova_data, options)
      when 'quiet'
        format_two_way_anova_quiet(anova_data, options)
      else
        format_two_way_anova_default(anova_data, options)
      end
    end

    private_class_method def self.format_two_way_anova_json(anova_data, options)
      formatted_data = build_formatted_two_way_anova_data(anova_data, options)
      JSON.generate(formatted_data)
    end

    private_class_method def self.format_two_way_anova_default(anova_data, options)
      output = []
      output << '=== 二元配置分散分析結果 ==='
      output << ''

      # Marginal means
      output << "全体平均値: #{apply_precision(anova_data[:grand_mean], options[:precision])}"
      output << ''

      # Factor A marginal means
      output << '【要因A 水準別平均値】'
      anova_data[:marginal_means][:factor_a].each do |level, mean|
        formatted_mean = apply_precision(mean, options[:precision])
        output << "  #{level}: #{formatted_mean}"
      end
      output << ''

      # Factor B marginal means
      output << '【要因B 水準別平均値】'
      anova_data[:marginal_means][:factor_b].each do |level, mean|
        formatted_mean = apply_precision(mean, options[:precision])
        output << "  #{level}: #{formatted_mean}"
      end
      output << ''

      # Cell means
      output << '【セル平均値 (要因A × 要因B)】'
      anova_data[:cell_means].each do |a_level, b_hash|
        b_hash.each do |b_level, mean|
          formatted_mean = apply_precision(mean, options[:precision])
          output << "  #{a_level} × #{b_level}: #{formatted_mean}"
        end
      end
      output << ''

      # Two-way ANOVA table
      output << '【二元配置分散分析表】'
      output << '変動要因                  平方和      自由度         平均平方           F値          p値'
      output << ('-' * 80)

      # Main effect A
      format_two_way_anova_row(output, '主効果A (要因A)', anova_data[:main_effects][:factor_a], options)

      # Main effect B
      format_two_way_anova_row(output, '主効果B (要因B)', anova_data[:main_effects][:factor_b], options)

      # Interaction
      format_two_way_anova_row(output, '交互作用A×B', anova_data[:interaction], options)

      # Error
      ss_error = apply_precision(anova_data[:error][:sum_of_squares], options[:precision])
      ms_error = apply_precision(anova_data[:error][:mean_squares], options[:precision])
      df_error = anova_data[:error][:degrees_of_freedom]
      output << format('%-20s %10s %10s %15s %12s %12s', '誤差', ss_error, df_error, ms_error, '-', '-')

      # Total
      ss_total = apply_precision(anova_data[:total][:sum_of_squares], options[:precision])
      df_total = anova_data[:total][:degrees_of_freedom]
      output << format('%-20s %10s %10s %15s %12s %12s', '全体', ss_total, df_total, '-', '-', '-')

      output << ('-' * 80)
      output << ''

      # Effect sizes
      output << '【効果サイズ (Partial η²)】'
      eta_a = apply_precision(anova_data[:main_effects][:factor_a][:eta_squared], options[:precision])
      eta_b = apply_precision(anova_data[:main_effects][:factor_b][:eta_squared], options[:precision])
      eta_ab = apply_precision(anova_data[:interaction][:eta_squared], options[:precision])

      output << "要因A: #{eta_a}"
      output << "要因B: #{eta_b}"
      output << "交互作用A×B: #{eta_ab}"
      output << ''

      # Interpretation
      output << '【解釈】'
      output << anova_data[:interpretation]

      output.join("\n")
    end

    private_class_method def self.format_two_way_anova_row(output, label, effect_data, options)
      ss = apply_precision(effect_data[:sum_of_squares], options[:precision])
      ms = apply_precision(effect_data[:mean_squares], options[:precision])
      f_stat = apply_precision(effect_data[:f_statistic], options[:precision])
      p_value = apply_precision(effect_data[:p_value], options[:precision])
      df_num, = effect_data[:degrees_of_freedom]

      significance = effect_data[:significant] ? '*' : ''
      output << format('%-20s %10s %10s %15s %12s %10s%s', label, ss, df_num, ms, f_stat, p_value, significance)
    end

    private_class_method def self.format_two_way_anova_quiet(anova_data, options)
      # Main effect A
      f_a = apply_precision(anova_data[:main_effects][:factor_a][:f_statistic], options[:precision])
      p_a = apply_precision(anova_data[:main_effects][:factor_a][:p_value], options[:precision])
      sig_a = anova_data[:main_effects][:factor_a][:significant]

      # Main effect B
      f_b = apply_precision(anova_data[:main_effects][:factor_b][:f_statistic], options[:precision])
      p_b = apply_precision(anova_data[:main_effects][:factor_b][:p_value], options[:precision])
      sig_b = anova_data[:main_effects][:factor_b][:significant]

      # Interaction
      f_ab = apply_precision(anova_data[:interaction][:f_statistic], options[:precision])
      p_ab = apply_precision(anova_data[:interaction][:p_value], options[:precision])
      sig_ab = anova_data[:interaction][:significant]

      "A:#{f_a},#{p_a},#{sig_a} B:#{f_b},#{p_b},#{sig_b} AB:#{f_ab},#{p_ab},#{sig_ab}"
    end

    private_class_method def self.build_formatted_two_way_anova_data(anova_data, options)
      {
        type: 'two_way_anova',
        grand_mean: json_safe_number(apply_precision(anova_data[:grand_mean], options[:precision])),
        main_effects: {
          factor_a: build_formatted_effect_data(anova_data[:main_effects][:factor_a], options),
          factor_b: build_formatted_effect_data(anova_data[:main_effects][:factor_b], options)
        },
        interaction: build_formatted_effect_data(anova_data[:interaction], options),
        error: {
          sum_of_squares: json_safe_number(apply_precision(anova_data[:error][:sum_of_squares], options[:precision])),
          mean_squares: json_safe_number(apply_precision(anova_data[:error][:mean_squares], options[:precision])),
          degrees_of_freedom: anova_data[:error][:degrees_of_freedom]
        },
        total: {
          sum_of_squares: json_safe_number(apply_precision(anova_data[:total][:sum_of_squares], options[:precision])),
          degrees_of_freedom: anova_data[:total][:degrees_of_freedom]
        },
        cell_means: format_cell_means_for_json(anova_data[:cell_means], options),
        marginal_means: {
          factor_a: format_marginal_means_for_json(anova_data[:marginal_means][:factor_a], options),
          factor_b: format_marginal_means_for_json(anova_data[:marginal_means][:factor_b], options)
        },
        interpretation: anova_data[:interpretation]
      }
    end

    private_class_method def self.build_formatted_effect_data(effect_data, options)
      {
        f_statistic: json_safe_number(apply_precision(effect_data[:f_statistic], options[:precision])),
        p_value: json_safe_number(apply_precision(effect_data[:p_value], options[:precision])),
        degrees_of_freedom: effect_data[:degrees_of_freedom],
        sum_of_squares: json_safe_number(apply_precision(effect_data[:sum_of_squares], options[:precision])),
        mean_squares: json_safe_number(apply_precision(effect_data[:mean_squares], options[:precision])),
        eta_squared: json_safe_number(apply_precision(effect_data[:eta_squared], options[:precision])),
        significant: effect_data[:significant]
      }
    end

    private_class_method def self.format_cell_means_for_json(cell_means, options)
      formatted = {}
      cell_means.each do |a_level, b_hash|
        formatted[a_level] = {}
        b_hash.each do |b_level, mean|
          formatted[a_level][b_level] = json_safe_number(apply_precision(mean, options[:precision]))
        end
      end
      formatted
    end

    private_class_method def self.format_marginal_means_for_json(marginal_means, options)
      marginal_means.transform_values { |mean| json_safe_number(apply_precision(mean, options[:precision])) }
    end

    # Convert special numeric values to JSON-safe representations
    private_class_method def self.json_safe_number(value)
      case value
      when Float::INFINITY
        nil
      when -Float::INFINITY
        nil
      when Float
        value.nan? ? nil : value
      else
        value
      end
    end

    def self.format_post_hoc(post_hoc_data, options = {})
      return format_post_hoc_json(post_hoc_data, options) if options[:format] == 'json'
      return format_post_hoc_quiet(post_hoc_data, options) if options[:quiet]

      format_post_hoc_default(post_hoc_data, options)
    end

    private_class_method def self.format_post_hoc_json(post_hoc_data, options)
      formatted_data = build_formatted_post_hoc_data(post_hoc_data, options)
      JSON.generate(formatted_data)
    end

    private_class_method def self.format_post_hoc_default(post_hoc_data, options)
      lines = []
      lines << "=== Post-hoc Analysis (#{post_hoc_data[:method]}) ==="

      # Add warning if present
      lines << "\n#{post_hoc_data[:warning]}" if post_hoc_data[:warning]

      # Add adjusted alpha for Bonferroni
      if post_hoc_data[:adjusted_alpha]
        lines << "調整済みα値: #{apply_precision(post_hoc_data[:adjusted_alpha], options[:precision])}"
      end

      lines << "\nペアワイズ比較:"
      lines << ('-' * 60)

      # Format pairwise comparisons
      post_hoc_data[:pairwise_comparisons].each do |comparison|
        group1, group2 = comparison[:groups]
        lines << "\nグループ #{group1} vs グループ #{group2}:"

        lines << "  平均値の差: #{apply_precision(comparison[:mean_difference], options[:precision])}"
        if post_hoc_data[:method] == 'Tukey HSD'
          lines << "  q統計量: #{apply_precision(comparison[:q_statistic], options[:precision])}"
          lines << "  q臨界値: #{apply_precision(comparison[:q_critical], options[:precision])}"
          lines << "  p値: #{apply_precision(comparison[:p_value], options[:precision])}"
        else # Bonferroni
          lines << "  t統計量: #{apply_precision(comparison[:t_statistic], options[:precision])}"
          lines << "  p値: #{apply_precision(comparison[:p_value], options[:precision])}"
          lines << "  調整済みp値: #{apply_precision(comparison[:adjusted_p_value], options[:precision])}"
        end

        lines << "  有意差: #{comparison[:significant] ? 'あり' : 'なし'}"
      end

      lines.join("\n")
    end

    private_class_method def self.format_post_hoc_quiet(post_hoc_data, _options)
      # Quiet format: method comparison_count significant_count
      comparison_count = post_hoc_data[:pairwise_comparisons].length
      significant_count = post_hoc_data[:pairwise_comparisons].count { |c| c[:significant] }

      "#{post_hoc_data[:method]} #{comparison_count} #{significant_count}"
    end

    private_class_method def self.build_formatted_post_hoc_data(post_hoc_data, options)
      formatted_data = {
        method: post_hoc_data[:method],
        pairwise_comparisons: []
      }

      formatted_data[:warning] = post_hoc_data[:warning] if post_hoc_data[:warning]
      if post_hoc_data[:adjusted_alpha]
        formatted_data[:adjusted_alpha] =
          apply_precision(post_hoc_data[:adjusted_alpha], options[:precision])
      end

      post_hoc_data[:pairwise_comparisons].each do |comparison|
        formatted_comparison = {
          groups: comparison[:groups],
          mean_difference: apply_precision(comparison[:mean_difference], options[:precision]),
          significant: comparison[:significant]
        }

        if post_hoc_data[:method] == 'Tukey HSD'
          formatted_comparison[:q_statistic] = apply_precision(comparison[:q_statistic], options[:precision])
          formatted_comparison[:q_critical] = apply_precision(comparison[:q_critical], options[:precision])
          formatted_comparison[:p_value] = apply_precision(comparison[:p_value], options[:precision])
        else # Bonferroni
          formatted_comparison[:t_statistic] = apply_precision(comparison[:t_statistic], options[:precision])
          formatted_comparison[:p_value] = apply_precision(comparison[:p_value], options[:precision])
          formatted_comparison[:adjusted_p_value] = apply_precision(comparison[:adjusted_p_value], options[:precision])
        end

        formatted_data[:pairwise_comparisons] << formatted_comparison
      end

      formatted_data
    end

    private_class_method def self.build_formatted_anova_data(anova_data, options)
      {
        test_type: 'one_way_anova',
        f_statistic: apply_precision(anova_data[:f_statistic], options[:precision]),
        p_value: apply_precision(anova_data[:p_value], options[:precision]),
        degrees_of_freedom: {
          between: anova_data[:degrees_of_freedom][0],
          within: anova_data[:degrees_of_freedom][1]
        },
        sum_of_squares: {
          between: apply_precision(anova_data[:sum_of_squares][:between], options[:precision]),
          within: apply_precision(anova_data[:sum_of_squares][:within], options[:precision]),
          total: apply_precision(anova_data[:sum_of_squares][:total], options[:precision])
        },
        mean_squares: {
          between: apply_precision(anova_data[:mean_squares][:between], options[:precision]),
          within: apply_precision(anova_data[:mean_squares][:within], options[:precision])
        },
        effect_size: {
          eta_squared: apply_precision(anova_data[:effect_size][:eta_squared], options[:precision]),
          omega_squared: apply_precision(anova_data[:effect_size][:omega_squared], options[:precision])
        },
        group_means: anova_data[:group_means].map { |mean| apply_precision(mean, options[:precision]) },
        grand_mean: apply_precision(anova_data[:grand_mean], options[:precision]),
        significant: anova_data[:significant],
        interpretation: anova_data[:interpretation]
      }
    end
  end
end
