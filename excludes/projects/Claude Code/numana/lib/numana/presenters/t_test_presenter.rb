# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# Presenter for T-test results
#
# Handles formatting of all three types of t-tests:
# - Independent samples t-test (Welch's t-test)
# - Paired samples t-test
# - One-sample t-test
#
# Supports verbose, JSON, and quiet output formats with precision control.
class Numana::Presenters::TTestPresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    test_type_names = {
      'independent_samples' => '独立2標本t検定',
      'paired_samples' => '対応ありt検定',
      'one_sample' => '一標本t検定'
    }

    test_name = test_type_names[@result[:test_type]] || @result[:test_type]

    result_lines = []
    result_lines << 'T検定結果:'
    result_lines << "検定タイプ: #{test_name}"
    result_lines << "統計量: t = #{format_value(@result[:t_statistic])}"
    result_lines << "自由度: df = #{format_value(@result[:degrees_of_freedom])}"
    result_lines << "p値: #{format_value(@result[:p_value])}"

    result_lines.concat(build_test_specific_details)
    result_lines << build_significance_conclusion

    result_lines.join("\n")
  end

  def format_quiet
    t_stat = format_value(@result[:t_statistic])
    df = format_value(@result[:degrees_of_freedom])
    p_val = format_value(@result[:p_value])
    significant = @result[:significant]

    "#{t_stat} #{df} #{p_val} #{significant}"
  end

  def json_fields
    base_data = {
      test_type: @result[:test_type],
      t_statistic: apply_precision(@result[:t_statistic], @precision),
      degrees_of_freedom: apply_precision(@result[:degrees_of_freedom], @precision),
      p_value: apply_precision(@result[:p_value], @precision),
      significant: @result[:significant]
    }

    add_test_specific_json_fields(base_data)
    base_data.merge(dataset_metadata)
  end

  private

  def build_test_specific_details
    case @result[:test_type]
    when 'independent_samples'
      build_independent_samples_details
    when 'paired_samples'
      build_paired_samples_details
    when 'one_sample'
      build_one_sample_details
    else
      []
    end
  end

  def build_independent_samples_details
    mean1 = format_value(@result[:mean1])
    mean2 = format_value(@result[:mean2])
    [
      "グループ1: 平均 = #{mean1}, n = #{@result[:n1]}",
      "グループ2: 平均 = #{mean2}, n = #{@result[:n2]}"
    ]
  end

  def build_paired_samples_details
    mean_diff = format_value(@result[:mean_difference])
    [
      "平均差: #{mean_diff}",
      "サンプルサイズ: n = #{@result[:n]}"
    ]
  end

  def build_one_sample_details
    sample_mean = format_value(@result[:sample_mean])
    pop_mean = format_value(@result[:population_mean])
    [
      "標本平均: #{sample_mean}",
      "母集団平均: #{pop_mean}",
      "サンプルサイズ: n = #{@result[:n]}"
    ]
  end

  def build_significance_conclusion
    alpha_level = 0.05
    if @result[:significant]
      "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差あり"
    else
      "結論: 有意水準#{(alpha_level * 100).to_i}%で有意差なし"
    end
  end

  def add_test_specific_json_fields(base_data)
    case @result[:test_type]
    when 'independent_samples'
      add_independent_samples_json_fields(base_data)
    when 'paired_samples'
      add_paired_samples_json_fields(base_data)
    when 'one_sample'
      add_one_sample_json_fields(base_data)
    end
  end

  def add_independent_samples_json_fields(base_data)
    base_data[:mean1] = apply_precision(@result[:mean1], @precision)
    base_data[:mean2] = apply_precision(@result[:mean2], @precision)
    base_data[:n1] = @result[:n1]
    base_data[:n2] = @result[:n2]
  end

  def add_paired_samples_json_fields(base_data)
    base_data[:mean_difference] = apply_precision(@result[:mean_difference], @precision)
    base_data[:n] = @result[:n]
  end

  def add_one_sample_json_fields(base_data)
    base_data[:sample_mean] = apply_precision(@result[:sample_mean], @precision)
    base_data[:population_mean] = apply_precision(@result[:population_mean], @precision)
    base_data[:n] = @result[:n]
  end
end
