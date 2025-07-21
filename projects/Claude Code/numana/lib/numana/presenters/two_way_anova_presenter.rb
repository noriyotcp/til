# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for two-way ANOVA results
#
# Handles formatting of two-way analysis of variance results including:
# - Main effects for Factor A and Factor B
# - Interaction effects (A × B)
# - Cell means and marginal means
# - F-statistics, p-values, and effect sizes
# - Comprehensive ANOVA table with error and total rows
#
# Supports verbose, JSON, and quiet output formats with precision control.
class Numana::Presenters::TwoWayAnovaPresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    output = []
    output << '=== 二元配置分散分析結果 ==='
    output << ''

    # Marginal means
    output << "全体平均値: #{format_value(@result[:grand_mean])}"
    output << ''

    # Factor A marginal means
    output.concat(build_factor_a_means_section)
    output << ''

    # Factor B marginal means
    output.concat(build_factor_b_means_section)
    output << ''

    # Cell means
    output.concat(build_cell_means_section)
    output << ''

    # Two-way ANOVA table
    output.concat(build_two_way_anova_table)
    output << ''

    # Effect sizes
    output.concat(build_effect_sizes_section)
    output << ''

    # Interpretation
    output << '【解釈】'
    output << @result[:interpretation]

    output.join("\n")
  end

  def format_quiet
    effect_a = extract_effect_values(@result[:main_effects][:factor_a])
    effect_b = extract_effect_values(@result[:main_effects][:factor_b])
    interaction = extract_effect_values(@result[:interaction])

    "A:#{format_effect_string(effect_a)} B:#{format_effect_string(effect_b)} AB:#{format_effect_string(interaction)}"
  end

  def extract_effect_values(effect_data)
    {
      f_stat: format_value(effect_data[:f_statistic]),
      p_value: format_value(effect_data[:p_value]),
      significant: effect_data[:significant]
    }
  end

  def format_effect_string(effect)
    "#{effect[:f_stat]},#{effect[:p_value]},#{effect[:significant]}"
  end

  def json_fields
    base_data = {
      type: 'two_way_anova',
      grand_mean: json_safe_number(apply_precision(@result[:grand_mean], @precision)),
      main_effects: {
        factor_a: build_formatted_effect_data(@result[:main_effects][:factor_a]),
        factor_b: build_formatted_effect_data(@result[:main_effects][:factor_b])
      },
      interaction: build_formatted_effect_data(@result[:interaction]),
      error: build_formatted_error_data,
      total: build_formatted_total_data,
      cell_means: format_cell_means_for_json,
      marginal_means: {
        factor_a: format_marginal_means_for_json(@result[:marginal_means][:factor_a]),
        factor_b: format_marginal_means_for_json(@result[:marginal_means][:factor_b])
      },
      interpretation: @result[:interpretation]
    }

    base_data.merge(dataset_metadata)
  end

  private

  def build_factor_a_means_section
    output = ['【要因A 水準別平均値】']
    @result[:marginal_means][:factor_a].each do |level, mean|
      formatted_mean = format_value(mean)
      output << "  #{level}: #{formatted_mean}"
    end
    output
  end

  def build_factor_b_means_section
    output = ['【要因B 水準別平均値】']
    @result[:marginal_means][:factor_b].each do |level, mean|
      formatted_mean = format_value(mean)
      output << "  #{level}: #{formatted_mean}"
    end
    output
  end

  def build_cell_means_section
    output = ['【セル平均値 (要因A × 要因B)】']
    @result[:cell_means].each do |a_level, b_hash|
      b_hash.each do |b_level, mean|
        formatted_mean = format_value(mean)
        output << "  #{a_level} × #{b_level}: #{formatted_mean}"
      end
    end
    output
  end

  def build_two_way_anova_table
    output = []
    output.concat(build_table_header)
    output.concat(build_main_effects_rows)
    output.concat(build_interaction_row)
    output.concat(build_error_and_total_rows)
    output << ('-' * 80)
    output
  end

  def build_table_header
    [
      '【二元配置分散分析表】',
      '変動要因                  平方和      自由度         平均平方           F値          p値',
      ('-' * 80)
    ]
  end

  def build_main_effects_rows
    [
      build_anova_row('主効果A (要因A)', @result[:main_effects][:factor_a]),
      build_anova_row('主効果B (要因B)', @result[:main_effects][:factor_b])
    ]
  end

  def build_interaction_row
    [build_anova_row('交互作用A×B', @result[:interaction])]
  end

  def build_error_and_total_rows
    [
      build_error_row,
      build_total_row
    ]
  end

  def build_error_row
    ss_error = format_value(@result[:error][:sum_of_squares])
    ms_error = format_value(@result[:error][:mean_squares])
    df_error = @result[:error][:degrees_of_freedom]
    Kernel.format('%-<label>20s %<ss>10s %<df>10s %<ms>15s %<f>12s %<p>12s',
                  label: '誤差', ss: ss_error, df: df_error, ms: ms_error, f: '-', p: '-')
  end

  def build_total_row
    ss_total = format_value(@result[:total][:sum_of_squares])
    df_total = @result[:total][:degrees_of_freedom]
    Kernel.format('%-<label>20s %<ss>10s %<df>10s %<ms>15s %<f>12s %<p>12s',
                  label: '全体', ss: ss_total, df: df_total, ms: '-', f: '-', p: '-')
  end

  def build_anova_row(label, effect_data)
    ss = format_value(effect_data[:sum_of_squares])
    ms = format_value(effect_data[:mean_squares])
    f_stat = format_value(effect_data[:f_statistic])
    p_value = format_value(effect_data[:p_value])
    df_num, = effect_data[:degrees_of_freedom]

    significance = effect_data[:significant] ? '*' : ''
    Kernel.format('%-<label>20s %<ss>10s %<df>10s %<ms>15s %<f>12s %<p>10s%<sig>s',
                  label: label, ss: ss, df: df_num, ms: ms, f: f_stat, p: p_value, sig: significance)
  end

  def build_effect_sizes_section
    eta_a = format_value(@result[:main_effects][:factor_a][:eta_squared])
    eta_b = format_value(@result[:main_effects][:factor_b][:eta_squared])
    eta_ab = format_value(@result[:interaction][:eta_squared])

    [
      '【効果サイズ (Partial η²)】',
      "要因A: #{eta_a}",
      "要因B: #{eta_b}",
      "交互作用A×B: #{eta_ab}"
    ]
  end

  def build_formatted_effect_data(effect_data)
    {
      f_statistic: json_safe_number(apply_precision(effect_data[:f_statistic], @precision)),
      p_value: json_safe_number(apply_precision(effect_data[:p_value], @precision)),
      degrees_of_freedom: effect_data[:degrees_of_freedom],
      sum_of_squares: json_safe_number(apply_precision(effect_data[:sum_of_squares], @precision)),
      mean_squares: json_safe_number(apply_precision(effect_data[:mean_squares], @precision)),
      eta_squared: json_safe_number(apply_precision(effect_data[:eta_squared], @precision)),
      significant: effect_data[:significant]
    }
  end

  def build_formatted_error_data
    {
      sum_of_squares: json_safe_number(apply_precision(@result[:error][:sum_of_squares], @precision)),
      mean_squares: json_safe_number(apply_precision(@result[:error][:mean_squares], @precision)),
      degrees_of_freedom: @result[:error][:degrees_of_freedom]
    }
  end

  def build_formatted_total_data
    {
      sum_of_squares: json_safe_number(apply_precision(@result[:total][:sum_of_squares], @precision)),
      degrees_of_freedom: @result[:total][:degrees_of_freedom]
    }
  end

  def format_cell_means_for_json
    formatted = {}
    @result[:cell_means].each do |a_level, b_hash|
      formatted[a_level] = {}
      b_hash.each do |b_level, mean|
        formatted[a_level][b_level] = json_safe_number(apply_precision(mean, @precision))
      end
    end
    formatted
  end

  def format_marginal_means_for_json(marginal_means)
    marginal_means.transform_values { |mean| json_safe_number(apply_precision(mean, @precision)) }
  end

  # Convert special numeric values to JSON-safe representations
  def json_safe_number(value)
    case value
    when Float::INFINITY, -Float::INFINITY
      nil
    when Float
      value.nan? ? nil : value
    else
      value
    end
  end
end
