# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for formatting Friedman test results
#
# Formats Friedman test results for non-parametric repeated measures analysis in
# multiple output formats. This test is used as an alternative to repeated measures
# ANOVA when normal distribution cannot be assumed.
class Numana::Presenters::FriedmanTestPresenter < Numana::Presenters::BaseStatisticalPresenter
  def json_fields
    {
      test_type: @result[:test_type],
      chi_square_statistic: round_value(@result[:chi_square_statistic]),
      p_value: round_value(@result[:p_value]),
      degrees_of_freedom: @result[:degrees_of_freedom],
      significant: @result[:significant],
      interpretation: @result[:interpretation],
      rank_sums: @result[:rank_sums],
      n_subjects: @result[:n_subjects],
      k_conditions: @result[:k_conditions],
      total_observations: @result[:total_observations]
    }
  end

  def format_quiet
    chi_square = round_value(@result[:chi_square_statistic])
    p_value = round_value(@result[:p_value])
    "#{chi_square} #{p_value}"
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
    '=== Friedman Test ==='
  end

  def statistics_section
    [
      "χ²-statistic: #{round_value(@result[:chi_square_statistic])}",
      "Degrees of Freedom: #{@result[:degrees_of_freedom]}",
      "p-value: #{round_value(@result[:p_value])}",
      "Number of Subjects: #{@result[:n_subjects]}",
      "Number of Conditions: #{@result[:k_conditions]}",
      "Total Observations: #{@result[:total_observations]}",
      "Rank Sums: #{@result[:rank_sums].join(', ')}"
    ].join("\n")
  end

  def interpretation_section
    significance = @result[:significant] ? '**Significant**' : 'Not significant'
    [
      "Result: #{significance} (α = 0.05)",
      "Interpretation: #{@result[:interpretation]}"
    ].join("\n")
  end

  def notes_section
    [
      '',
      'Notes:',
      '• Friedman test is a non-parametric test for repeated measures data',
      '• Used as alternative to repeated measures ANOVA when normal distribution is not assumed',
      '• Assumes same subjects are measured under multiple conditions',
      '• If significant difference is found, consider post-hoc tests (e.g., Nemenyi test)'
    ].join("\n")
  end
end
