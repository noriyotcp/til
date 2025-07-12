# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for formatting Wilcoxon signed-rank test results
#
# Formats Wilcoxon signed-rank test results for non-parametric paired sample comparison
# in multiple output formats. This test is used as an alternative to the paired t-test
# when normal distribution cannot be assumed.
class NumberAnalyzer::Presenters::WilcoxonTestPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def json_fields
    {
      test_type: @result[:test_type],
      w_statistic: round_value(@result[:w_statistic]),
      w_plus: round_value(@result[:w_plus]),
      w_minus: round_value(@result[:w_minus]),
      z_statistic: round_value(@result[:z_statistic]),
      p_value: round_value(@result[:p_value]),
      significant: @result[:significant],
      interpretation: @result[:interpretation],
      effect_size: round_value(@result[:effect_size]),
      n_pairs: @result[:n_pairs],
      n_effective: @result[:n_effective],
      n_zeros: @result[:n_zeros]
    }
  end

  def format_quiet
    w_stat = round_value(@result[:w_statistic])
    p_value = round_value(@result[:p_value])
    "#{w_stat} #{p_value}"
  end

  def format_verbose
    build_sections.compact.join("\n")
  end

  private

  def build_sections
    [
      header_section,
      statistics_section,
      interpretation_section,
      notes_section
    ]
  end

  def header_section
    '=== Wilcoxon Signed-Rank Test ==='
  end

  def statistics_section
    [
      "W-statistic: #{round_value(@result[:w_statistic])}",
      "W+ (positive rank sum): #{round_value(@result[:w_plus])}",
      "W- (negative rank sum): #{round_value(@result[:w_minus])}",
      "z-statistic: #{round_value(@result[:z_statistic])}",
      "p-value: #{round_value(@result[:p_value])}",
      "Effect Size (r): #{round_value(@result[:effect_size])}",
      "Number of Pairs: #{@result[:n_pairs]}",
      "Effective Pairs: #{@result[:n_effective]} (Zero differences excluded: #{@result[:n_zeros]})"
    ].join("\n")
  end

  def interpretation_section
    significance = @result[:significant] ? '**Significant**' : 'Not significant'
    effect_magnitude = interpret_effect_size

    [
      "Result: #{significance} (α = 0.05)",
      "Interpretation: #{@result[:interpretation]}",
      effect_magnitude
    ].join("\n")
  end

  def interpret_effect_size
    effect_size = @result[:effect_size]
    case effect_size
    when 0.0...0.1
      'Effect Size: Negligible'
    when 0.1...0.3
      'Effect Size: Small'
    when 0.3...0.5
      'Effect Size: Medium'
    else
      'Effect Size: Large'
    end
  end

  def notes_section
    [
      '',
      'Notes:',
      '• Wilcoxon signed-rank test is a non-parametric test for paired data',
      '• Used as alternative to paired t-test when normal distribution is not assumed',
      '• Assumes symmetric distribution of differences but normality is not required',
      '• Zero differences are excluded from the test'
    ].join("\n")
  end
end
