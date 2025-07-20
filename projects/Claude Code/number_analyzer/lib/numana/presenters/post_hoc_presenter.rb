# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Post-hoc analysis results
#
# Handles formatting of ANOVA post-hoc test results including:
# - Tukey HSD (Honestly Significant Difference) test
# - Bonferroni correction method
# - Pairwise comparisons with method-specific statistics
# - Adjusted alpha levels and significance testing
# - Warning messages for assumption violations
#
# Supports verbose, JSON, and quiet output formats with precision control.
class NumberAnalyzer::Presenters::PostHocPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def format_verbose
    lines = []
    lines << "=== Post-hoc Analysis (#{@result[:method]}) ==="

    # Add warning if present
    lines << "\n#{@result[:warning]}" if @result[:warning]

    # Add adjusted alpha for Bonferroni
    lines << "調整済みα値: #{format_value(@result[:adjusted_alpha])}" if @result[:adjusted_alpha]

    lines << "\nペアワイズ比較:"
    lines << ('-' * 60)

    # Format pairwise comparisons
    @result[:pairwise_comparisons].each do |comparison|
      lines.concat(build_comparison_section(comparison))
    end

    lines.join("\n")
  end

  def format_quiet
    # Quiet format: method comparison_count significant_count
    comparison_count = @result[:pairwise_comparisons].length
    significant_count = @result[:pairwise_comparisons].count { |c| c[:significant] }

    "#{@result[:method]} #{comparison_count} #{significant_count}"
  end

  def json_fields
    base_data = {
      method: @result[:method],
      pairwise_comparisons: []
    }

    base_data[:warning] = @result[:warning] if @result[:warning]
    base_data[:adjusted_alpha] = apply_precision(@result[:adjusted_alpha], @precision) if @result[:adjusted_alpha]

    @result[:pairwise_comparisons].each do |comparison|
      base_data[:pairwise_comparisons] << build_formatted_comparison(comparison)
    end

    base_data.merge(dataset_metadata)
  end

  private

  def build_comparison_section(comparison)
    group1, group2 = comparison[:groups]
    lines = []
    lines << "\nグループ #{group1} vs グループ #{group2}:"
    lines << "  平均値の差: #{format_value(comparison[:mean_difference])}"

    if @result[:method] == 'Tukey HSD'
      lines.concat(build_tukey_statistics(comparison))
    else # Bonferroni
      lines.concat(build_bonferroni_statistics(comparison))
    end

    lines << "  有意差: #{comparison[:significant] ? 'あり' : 'なし'}"
    lines
  end

  def build_tukey_statistics(comparison)
    [
      "  q統計量: #{format_value(comparison[:q_statistic])}",
      "  q臨界値: #{format_value(comparison[:q_critical])}",
      "  p値: #{format_value(comparison[:p_value])}"
    ]
  end

  def build_bonferroni_statistics(comparison)
    [
      "  t統計量: #{format_value(comparison[:t_statistic])}",
      "  p値: #{format_value(comparison[:p_value])}",
      "  調整済みp値: #{format_value(comparison[:adjusted_p_value])}"
    ]
  end

  def build_formatted_comparison(comparison)
    formatted_comparison = {
      groups: comparison[:groups],
      mean_difference: apply_precision(comparison[:mean_difference], @precision),
      significant: comparison[:significant]
    }

    if @result[:method] == 'Tukey HSD'
      add_tukey_json_fields(formatted_comparison, comparison)
    else # Bonferroni
      add_bonferroni_json_fields(formatted_comparison, comparison)
    end

    formatted_comparison
  end

  def add_tukey_json_fields(formatted_comparison, comparison)
    formatted_comparison[:q_statistic] = apply_precision(comparison[:q_statistic], @precision)
    formatted_comparison[:q_critical] = apply_precision(comparison[:q_critical], @precision)
    formatted_comparison[:p_value] = apply_precision(comparison[:p_value], @precision)
  end

  def add_bonferroni_json_fields(formatted_comparison, comparison)
    formatted_comparison[:t_statistic] = apply_precision(comparison[:t_statistic], @precision)
    formatted_comparison[:p_value] = apply_precision(comparison[:p_value], @precision)
    formatted_comparison[:adjusted_p_value] = apply_precision(comparison[:adjusted_p_value], @precision)
  end
end
