# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for formatting Mann-Whitney U test results
#
# Formats Mann-Whitney U test results for non-parametric two-group comparison in
# multiple output formats. This test is used as an alternative to the t-test when
# normal distribution cannot be assumed.
class Numana::Presenters::MannWhitneyTestPresenter < Numana::Presenters::BaseStatisticalPresenter
  def json_fields
    {
      test_type: @result[:test_type],
      u_statistic: round_value(@result[:u_statistic]),
      u1: round_value(@result[:u1]),
      u2: round_value(@result[:u2]),
      z_statistic: round_value(@result[:z_statistic]),
      p_value: round_value(@result[:p_value]),
      significant: @result[:significant],
      interpretation: @result[:interpretation],
      effect_size: round_value(@result[:effect_size]),
      group_sizes: @result[:group_sizes],
      rank_sums: @result[:rank_sums],
      total_n: @result[:total_n]
    }
  end

  def format_quiet
    u_stat = round_value(@result[:u_statistic])
    p_value = round_value(@result[:p_value])
    "#{u_stat} #{p_value}"
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
    '=== Mann-Whitney U Test ==='
  end

  def statistics_section
    [
      "U-statistic: #{round_value(@result[:u_statistic])}",
      "U1: #{round_value(@result[:u1])}, U2: #{round_value(@result[:u2])}",
      "z-statistic: #{round_value(@result[:z_statistic])}",
      "p-value: #{round_value(@result[:p_value])}",
      "Effect Size (r): #{round_value(@result[:effect_size])}",
      "Group Sizes: #{@result[:group_sizes].join(', ')}",
      "Rank Sums: #{@result[:rank_sums].join(', ')}"
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
      '• Mann-Whitney U test is a non-parametric test for two-group comparison',
      '• Used as alternative to t-test when normal distribution is not assumed',
      '• Robust against outliers due to rank-based testing',
      '• Assumes same distribution shape but tests for location (median) differences'
    ].join("\n")
  end
end
