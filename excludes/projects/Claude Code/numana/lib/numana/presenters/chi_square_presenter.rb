# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for Chi-square test results
#
# Handles formatting of chi-square test results including:
# - Independence test and goodness-of-fit test
# - Chi-square statistic, degrees of freedom, and p-value
# - Effect size (Cramér's V) for independence tests
# - Expected frequency validation warnings
# - Observed and expected frequencies for detailed analysis
#
# Supports verbose, JSON, and quiet output formats with precision control.
class Numana::Presenters::ChiSquarePresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return '' if @result.nil?

    test_type_names = {
      'independence' => '独立性検定',
      'goodness_of_fit' => '適合度検定'
    }

    test_name = test_type_names[@result[:test_type]] || @result[:test_type]

    lines = []
    lines << 'カイ二乗検定結果:'
    lines << "検定タイプ: #{test_name}"
    lines << "統計量: χ² = #{format_value(@result[:chi_square_statistic])}"
    lines << "自由度: df = #{@result[:degrees_of_freedom]}"
    lines << "p値: #{format_value(@result[:p_value])}"
    lines << build_significance_conclusion

    # Add effect size for independence tests
    lines << "効果サイズ (Cramér's V): #{format_value(@result[:cramers_v])}" if @result[:test_type] == 'independence' && @result[:cramers_v]

    # Add frequency validation warning if needed
    lines << (@result[:warning] || '期待度数条件: 満たしている')

    lines.join("\n")
  end

  def format_quiet
    return '' if @result.nil?

    chi_square = format_value(@result[:chi_square_statistic])
    df = @result[:degrees_of_freedom]
    p_value = format_value(@result[:p_value])
    significant = @result[:significant]

    "#{chi_square} #{df} #{p_value} #{significant}"
  end

  def json_fields
    return {} if @result.nil?

    base_data = {
      test_type: @result[:test_type],
      chi_square_statistic: apply_precision(@result[:chi_square_statistic], @precision),
      degrees_of_freedom: @result[:degrees_of_freedom],
      p_value: apply_precision(@result[:p_value], @precision),
      significant: @result[:significant],
      expected_frequencies_valid: @result[:expected_frequencies_valid],
      warning: @result[:warning]
    }

    # Add effect size for independence tests
    base_data[:cramers_v] = apply_precision(@result[:cramers_v], @precision) if @result[:cramers_v]

    # Add frequency data for detailed analysis
    base_data[:observed_frequencies] = @result[:observed_frequencies] if @result[:observed_frequencies]

    base_data[:expected_frequencies] = @result[:expected_frequencies] if @result[:expected_frequencies]

    base_data.merge(dataset_metadata)
  end

  private

  def build_significance_conclusion
    alpha_level = 0.05
    if @result[:significant]
      "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差あり"
    else
      "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差なし"
    end
  end
end
