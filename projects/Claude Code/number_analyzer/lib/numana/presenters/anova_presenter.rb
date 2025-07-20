# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for one-way ANOVA results
#
# Handles formatting of one-way analysis of variance results including:
# - F-statistic and p-value
# - Degrees of freedom (between and within groups)
# - Sum of squares decomposition
# - Effect sizes (eta squared and omega squared)
# - Group statistics and ANOVA table
#
# Supports verbose, JSON, and quiet output formats with precision control.
class NumberAnalyzer::Presenters::AnovaPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def format_verbose
    output = []
    output << '=== 一元配置分散分析結果 ==='
    output << ''

    # Group statistics
    output << "グループ平均値: #{format_group_means}"
    output << "全体平均値: #{format_value(@result[:grand_mean])}"
    output << ''

    # ANOVA table
    output.concat(build_anova_table)
    output << ''

    # Statistical significance
    output.concat(build_significance_section)
    output << ''

    # Effect sizes
    output.concat(build_effect_size_section)
    output << ''

    # Interpretation
    output << "解釈: #{@result[:interpretation]}"

    output.join("\n")
  end

  def format_quiet
    f_stat = format_value(@result[:f_statistic])
    p_value = format_value(@result[:p_value])
    eta_sq = format_value(@result[:effect_size][:eta_squared])
    df_between, df_within = @result[:degrees_of_freedom]
    significant = @result[:significant]

    "#{f_stat} #{df_between} #{df_within} #{p_value} #{eta_sq} #{significant}"
  end

  def json_fields
    base_data = {
      test_type: 'one_way_anova',
      f_statistic: apply_precision(@result[:f_statistic], @precision),
      p_value: apply_precision(@result[:p_value], @precision),
      degrees_of_freedom: {
        between: @result[:degrees_of_freedom][0],
        within: @result[:degrees_of_freedom][1]
      },
      sum_of_squares: build_sum_of_squares_json,
      mean_squares: build_mean_squares_json,
      effect_size: build_effect_size_json,
      group_means: @result[:group_means].map { |mean| apply_precision(mean, @precision) },
      grand_mean: apply_precision(@result[:grand_mean], @precision),
      significant: @result[:significant],
      interpretation: @result[:interpretation]
    }

    base_data.merge(dataset_metadata)
  end

  private

  def format_group_means
    formatted_means = @result[:group_means].map { |mean| format_value(mean) }
    formatted_means.join(', ')
  end

  def build_anova_table
    output = []
    output << '【分散分析表】'
    output << '変動要因                  平方和      自由度         平均平方           F値'
    output << ('-' * 60)

    values = extract_anova_values
    output.concat(format_anova_rows(values))
    output
  end

  def extract_anova_values
    {
      ss_between: format_value(@result[:sum_of_squares][:between]),
      ss_within: format_value(@result[:sum_of_squares][:within]),
      ss_total: format_value(@result[:sum_of_squares][:total]),
      ms_between: format_value(@result[:mean_squares][:between]),
      ms_within: format_value(@result[:mean_squares][:within]),
      f_stat: format_value(@result[:f_statistic]),
      df_between: @result[:degrees_of_freedom][0],
      df_within: @result[:degrees_of_freedom][1]
    }
  end

  def format_anova_rows(values)
    [
      format_anova_row('群間', values[:ss_between], values[:df_between], values[:ms_between], values[:f_stat]),
      format_anova_row('群内', values[:ss_within], values[:df_within], values[:ms_within], '-'),
      format_anova_row('全体', values[:ss_total], values[:df_between] + values[:df_within], '-', '-')
    ]
  end

  def format_anova_row(source, sum_squares, degrees_freedom, mean_squares, f_value)
    Kernel.format('%-<source>12s %<ss>12s %<df>8d %<ms>12s %<f>12s',
                  source: source, ss: sum_squares, df: degrees_freedom, ms: mean_squares, f: f_value)
  end

  def build_significance_section
    f_stat = format_value(@result[:f_statistic])
    p_value = format_value(@result[:p_value])
    significance = @result[:significant] ? '有意' : '非有意'

    [
      "F統計量: #{f_stat}",
      "p値: #{p_value}",
      "結果: #{significance} (α = 0.05)"
    ]
  end

  def build_effect_size_section
    eta_sq = format_value(@result[:effect_size][:eta_squared])
    omega_sq = format_value(@result[:effect_size][:omega_squared])

    [
      '効果サイズ:',
      "  η² (eta squared): #{eta_sq}",
      "  ω² (omega squared): #{omega_sq}"
    ]
  end

  def build_sum_of_squares_json
    {
      between: apply_precision(@result[:sum_of_squares][:between], @precision),
      within: apply_precision(@result[:sum_of_squares][:within], @precision),
      total: apply_precision(@result[:sum_of_squares][:total], @precision)
    }
  end

  def build_mean_squares_json
    {
      between: apply_precision(@result[:mean_squares][:between], @precision),
      within: apply_precision(@result[:mean_squares][:within], @precision)
    }
  end

  def build_effect_size_json
    {
      eta_squared: apply_precision(@result[:effect_size][:eta_squared], @precision),
      omega_squared: apply_precision(@result[:effect_size][:omega_squared], @precision)
    }
  end
end
