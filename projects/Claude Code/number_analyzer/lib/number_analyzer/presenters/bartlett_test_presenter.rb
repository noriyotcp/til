# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for formatting Bartlett test results
#
# Formats Bartlett test results for variance homogeneity testing in multiple output
# formats. The Bartlett test assumes normal distribution and is more precise than
# the Levene test when this assumption is satisfied.
class NumberAnalyzer::Presenters::BartlettTestPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def json_fields
    {
      test_type: @result[:test_type],
      chi_square_statistic: round_value(@result[:chi_square_statistic]),
      p_value: round_value(@result[:p_value]),
      degrees_of_freedom: @result[:degrees_of_freedom],
      significant: @result[:significant],
      interpretation: @result[:interpretation],
      correction_factor: round_value(@result[:correction_factor]),
      pooled_variance: round_value(@result[:pooled_variance])
    }
  end

  def format_quiet
    chi_square_stat = round_value(@result[:chi_square_statistic])
    p_value = round_value(@result[:p_value])
    "#{chi_square_stat} #{p_value}"
  end

  def format_verbose
    build_sections.join("\n")
  end

  private

  def build_sections
    [
      header_section,
      statistics_section,
      decision_section,
      interpretation_section,
      notes_section
    ]
  end

  def header_section
    '=== Bartlett Test Results ==='
  end

  def statistics_section
    [
      '',
      'Test Statistics:',
      "  Chi-square statistic: #{round_value(@result[:chi_square_statistic])}",
      "  p-value: #{round_value(@result[:p_value])}",
      "  Degrees of Freedom: #{@result[:degrees_of_freedom]}",
      "  Correction Factor: #{round_value(@result[:correction_factor])}",
      "  Pooled Variance: #{round_value(@result[:pooled_variance])}"
    ].join("\n")
  end

  def decision_section
    [
      '',
      'Statistical Decision:',
      if @result[:significant]
        "  Result: **Significant difference** (p < 0.05)\n  " \
          'Conclusion: Group variances are not equal'
      else
        "  Result: No significant difference (p ≥ 0.05)\n  " \
          'Conclusion: Group variances are considered equal'
      end
    ].join("\n")
  end

  def interpretation_section
    [
      '',
      'Interpretation:',
      "  #{@result[:interpretation]}"
    ].join("\n")
  end

  def notes_section
    [
      '',
      'Notes:',
      '  - Bartlett test assumes normal distribution',
      '  - More precise than Levene test when normality is satisfied',
      '  - This test is used to check ANOVA assumptions'
    ].join("\n")
  end
end
