# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Levene Test results
#
# Formats Levene Test (Brown-Forsythe Modified) results in multiple output formats.
# The Levene test is used to assess the equality of variances in different groups
# and is commonly used to check ANOVA assumptions.
class NumberAnalyzer::Presenters::LeveneTestPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def json_fields
    {
      test_type: @result[:test_type],
      f_statistic: round_value(@result[:f_statistic]),
      p_value: round_value(@result[:p_value]),
      degrees_of_freedom: @result[:degrees_of_freedom],
      significant: @result[:significant],
      interpretation: @result[:interpretation]
    }
  end

  def format_quiet
    f_stat = round_value(@result[:f_statistic])
    p_value = round_value(@result[:p_value])
    "#{f_stat} #{p_value}"
  end

  def format_verbose
    build_sections.join("\n")
  end

  private

  def build_sections
    [
      header_section,
      '',
      statistics_section,
      '',
      decision_section,
      '',
      interpretation_section,
      '',
      notes_section
    ]
  end

  def header_section
    '=== Levene Test Results (Brown-Forsythe Modified) ==='
  end

  def statistics_section
    [
      'Test Statistics:',
      "  F-statistic: #{round_value(@result[:f_statistic])}",
      "  p-value: #{round_value(@result[:p_value])}",
      "  Degrees of Freedom: #{@result[:degrees_of_freedom][0]}, #{@result[:degrees_of_freedom][1]}"
    ].join("\n")
  end

  def decision_section
    [
      'Statistical Decision:',
      decision_result,
      decision_conclusion
    ].join("\n")
  end

  def decision_result
    if @result[:significant]
      '  Result: **Significant difference** (p < 0.05)'
    else
      '  Result: No significant difference (p ≥ 0.05)'
    end
  end

  def decision_conclusion
    if @result[:significant]
      '  Conclusion: Group variances are not equal'
    else
      '  Conclusion: Group variances are considered equal'
    end
  end

  def interpretation_section
    [
      'Interpretation:',
      "  #{@result[:interpretation]}"
    ].join("\n")
  end

  def notes_section
    [
      'Notes:',
      '  - Brown-Forsythe modification is robust against outliers',
      '  - This test is used to check ANOVA assumptions'
    ].join("\n")
  end
end
