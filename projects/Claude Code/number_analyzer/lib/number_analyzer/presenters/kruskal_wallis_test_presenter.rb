# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for formatting Kruskal-Wallis test results
#
# Formats Kruskal-Wallis H test results for non-parametric one-way ANOVA in multiple
# output formats. This test compares medians of multiple groups without requiring
# normal distribution assumptions.
class NumberAnalyzer::Presenters::KruskalWallisTestPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def json_fields
    {
      test_type: @result[:test_type],
      h_statistic: round_value(@result[:h_statistic]),
      p_value: round_value(@result[:p_value]),
      degrees_of_freedom: @result[:degrees_of_freedom],
      significant: @result[:significant],
      interpretation: @result[:interpretation],
      group_sizes: @result[:group_sizes],
      total_n: @result[:total_n]
    }
  end

  def format_quiet
    h_stat = round_value(@result[:h_statistic])
    p_value = round_value(@result[:p_value])
    "#{h_stat} #{p_value}"
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
    '=== Kruskal-Wallis H Test ==='
  end

  def statistics_section
    [
      "H-statistic: #{round_value(@result[:h_statistic])}",
      "Degrees of Freedom: #{@result[:degrees_of_freedom]}",
      "p-value: #{round_value(@result[:p_value])}",
      "Total Sample Size: #{@result[:total_n]}",
      "Group Sizes: #{@result[:group_sizes].join(', ')}"
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
      '• Kruskal-Wallis test is a non-parametric test',
      '• Does not require normal distribution assumption but assumes same distribution shape',
      '• If significant difference is found, consider post-hoc tests (e.g., Dunn test)'
    ].join("\n")
  end
end
