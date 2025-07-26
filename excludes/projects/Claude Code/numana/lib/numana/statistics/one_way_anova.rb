# frozen_string_literal: true

# One-way ANOVA statistical analysis module
# This module provides one-way Analysis of Variance capabilities including:
# - F-statistics calculation with between and within group variance
# - Post-hoc analysis with Tukey HSD and Bonferroni correction
# - Effect size measures (eta squared and omega squared)
module OneWayAnova
  # Performs one-way Analysis of Variance (ANOVA) on multiple groups
  # Returns F-statistic, p-value, effect sizes, and interpretation
  def one_way_anova(*groups)
    validated_groups = validate_anova_input(groups)
    return nil unless validated_groups

    stats = calculate_anova_basic_stats(validated_groups)
    sum_of_squares = calculate_anova_sum_of_squares(validated_groups, stats)
    degrees_of_freedom = calculate_anova_degrees_of_freedom(validated_groups)
    mean_squares = calculate_anova_mean_squares(sum_of_squares, degrees_of_freedom)
    f_statistic, p_value = calculate_anova_f_statistic_and_p_value(mean_squares, degrees_of_freedom)
    effect_sizes = calculate_anova_effect_sizes(sum_of_squares, degrees_of_freedom, mean_squares)

    format_anova_result(stats, sum_of_squares, degrees_of_freedom, mean_squares, f_statistic, p_value, effect_sizes)
  end

  # Performs post-hoc analysis after ANOVA using Tukey HSD or Bonferroni correction
  # Returns pairwise comparisons with significance testing
  def post_hoc_analysis(groups, method: :tukey)
    validated_groups = validate_post_hoc_input(groups)
    return nil unless validated_groups && %i[tukey bonferroni].include?(method)

    anova_result = one_way_anova(*validated_groups)
    return nil if anova_result.nil?

    if method == :tukey
      perform_tukey_analysis(validated_groups, anova_result)
    else
      perform_bonferroni_analysis(validated_groups, anova_result)
    end
  end

  private

  def validate_anova_input(groups)
    groups = groups.compact.reject { |g| g.is_a?(Array) && g.empty? }
    return nil if groups.length < 2
    return nil unless groups.all? { |g| g.is_a?(Array) && !g.empty? }

    groups
  end

  def calculate_anova_basic_stats(groups)
    group_means = groups.map { |group| group.sum.to_f / group.length }
    grand_mean = groups.flatten.sum.to_f / groups.flatten.length
    { group_means: group_means, grand_mean: grand_mean }
  end

  def calculate_anova_sum_of_squares(groups, stats)
    ss_between = calculate_sum_of_squares_between(groups, stats[:group_means], stats[:grand_mean])
    ss_within = calculate_sum_of_squares_within(groups, stats[:group_means])
    { between: ss_between, within: ss_within, total: ss_between + ss_within }
  end

  def calculate_anova_degrees_of_freedom(groups)
    df_between = groups.length - 1
    df_within = groups.flatten.length - groups.length
    { between: df_between, within: df_within, total: df_between + df_within }
  end

  def calculate_anova_mean_squares(sum_of_squares, degrees_of_freedom)
    ms_between = sum_of_squares[:between] / degrees_of_freedom[:between]
    ms_within = degrees_of_freedom[:within].zero? ? 0.0 : sum_of_squares[:within] / degrees_of_freedom[:within]
    { between: ms_between, within: ms_within }
  end

  def calculate_anova_f_statistic_and_p_value(mean_squares, degrees_of_freedom)
    f_statistic = mean_squares[:within].zero? ? Float::INFINITY : mean_squares[:between] / mean_squares[:within]
    p_value = MathUtils.calculate_f_distribution_p_value(f_statistic, degrees_of_freedom[:between], degrees_of_freedom[:within])
    [f_statistic, p_value]
  end

  def calculate_anova_effect_sizes(sum_of_squares, degrees_of_freedom, mean_squares)
    eta_squared = sum_of_squares[:total].zero? ? 0.0 : sum_of_squares[:between] / sum_of_squares[:total]
    omega_squared = calculate_omega_squared(sum_of_squares[:between], degrees_of_freedom[:between], mean_squares[:within], degrees_of_freedom[:total])
    { eta_squared: eta_squared, omega_squared: omega_squared }
  end

  # rubocop:disable Metrics/AbcSize
  def format_anova_result(stats, sum_of_squares, degrees_of_freedom, mean_squares, f_statistic, p_value, effect_sizes)
    {
      f_statistic: f_statistic.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: [degrees_of_freedom[:between], degrees_of_freedom[:within]],
      sum_of_squares: {
        between: sum_of_squares[:between].round(6),
        within: sum_of_squares[:within].round(6),
        total: sum_of_squares[:total].round(6)
      },
      mean_squares: {
        between: mean_squares[:between].round(6),
        within: mean_squares[:within].round(6)
      },
      effect_size: {
        eta_squared: effect_sizes[:eta_squared].round(6),
        omega_squared: effect_sizes[:omega_squared].round(6)
      },
      group_means: stats[:group_means].map { |mean| mean.round(6) },
      grand_mean: stats[:grand_mean].round(6),
      significant: p_value < 0.05,
      interpretation: interpret_anova_results(f_statistic, p_value, effect_sizes[:eta_squared])
    }
  end
  # rubocop:enable Metrics/AbcSize

  def validate_post_hoc_input(groups)
    return nil if groups.nil? || groups.length < 2

    groups.compact.reject { |g| g.is_a?(Array) && g.empty? }
  end

  def perform_tukey_analysis(groups, anova_result)
    ms_within = anova_result[:mean_squares][:within]
    comparisons = generate_pairwise_comparisons(groups) do |group1, group2|
      tukey_pairwise_comparison(group1, group2, groups, ms_within)
    end

    result = { method: 'Tukey HSD', pairwise_comparisons: comparisons }
    result[:warning] = 'ANOVA was not significant. Post-hoc tests may not be appropriate.' unless anova_result[:significant]
    result
  end

  def perform_bonferroni_analysis(groups, anova_result)
    comparisons = generate_pairwise_comparisons(groups) do |group1, group2|
      bonferroni_pairwise_comparison(group1, group2, groups.length)
    end

    adjusted_p_values = bonferroni_adjust(comparisons.map { |c| c[:p_value] })
    comparisons.each_with_index do |comp, idx|
      comp[:adjusted_p_value] = adjusted_p_values[idx]
      comp[:significant] = comp[:adjusted_p_value] < 0.05
    end

    result = { method: 'Bonferroni', pairwise_comparisons: comparisons, adjusted_alpha: 0.05 / comparisons.length }
    result[:warning] = 'ANOVA was not significant. Post-hoc tests may not be appropriate.' unless anova_result[:significant]
    result
  end

  def generate_pairwise_comparisons(groups)
    comparisons = []
    groups.each_with_index do |group1, i|
      groups.each_with_index do |group2, j|
        next if i >= j

        comparison = yield(group1, group2)
        comparison[:groups] = [i + 1, j + 1]
        comparisons << comparison
      end
    end
    comparisons
  end

  # Performs Tukey HSD pairwise comparison
  # rubocop:disable Metrics/AbcSize
  def tukey_pairwise_comparison(group1, group2, all_groups, ms_within)
    stats = calculate_tukey_q_statistic(group1, group2, all_groups, ms_within)
    df_within = all_groups.flatten.length - all_groups.length
    critical_value = tukey_critical_value(all_groups.length, df_within, 0.05)
    p_value = estimate_tukey_p_value(stats[:q_statistic], all_groups.length, df_within)

    {
      mean_difference: stats[:mean_diff].round(6),
      standard_error: stats[:se].round(6),
      q_statistic: stats[:q_statistic].round(6),
      critical_value: critical_value.round(6),
      p_value: p_value.round(6),
      significant: stats[:q_statistic] > critical_value,
      confidence_interval: [
        (stats[:mean_diff] - (critical_value * stats[:se])).round(6),
        (stats[:mean_diff] + (critical_value * stats[:se])).round(6)
      ],
      q_critical: critical_value.round(6)
    }
  end
  # rubocop:enable Metrics/AbcSize

  def calculate_tukey_q_statistic(group1, group2, all_groups, ms_within)
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    mean_diff = (mean1 - mean2).abs

    sizes = all_groups.map(&:length)
    harmonic_n = calculate_harmonic_mean_n(sizes)
    se = Math.sqrt(ms_within / harmonic_n)
    q_statistic = se.zero? ? Float::INFINITY : mean_diff / se

    { mean_diff: mean_diff, se: se, q_statistic: q_statistic }
  end

  # Performs Bonferroni pairwise comparison
  def bonferroni_pairwise_comparison(group1, group2, _num_groups)
    stats = calculate_bonferroni_t_statistic(group1, group2)
    p_value = calculate_two_tailed_p_value(stats[:t_statistic].abs, stats[:df])

    {
      mean_difference: stats[:mean_diff].round(6),
      standard_error: stats[:se_diff].round(6),
      t_statistic: stats[:t_statistic].round(6),
      degrees_of_freedom: stats[:df],
      p_value: p_value.round(6),
      significant: false # Will be updated after Bonferroni adjustment
    }
  end

  # rubocop:disable Metrics/AbcSize
  def calculate_bonferroni_t_statistic(group1, group2)
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    mean_diff = mean1 - mean2

    var1 = variance_of_array(group1)
    var2 = variance_of_array(group2)
    df1 = group1.length - 1
    df2 = group2.length - 1

    pooled_var = (((df1 * var1) + (df2 * var2)) / (df1 + df2))
    pooled_sd = Math.sqrt(pooled_var)
    se_diff = pooled_sd * Math.sqrt((1.0 / group1.length) + (1.0 / group2.length))
    t_statistic = se_diff.zero? ? Float::INFINITY : mean_diff / se_diff

    { mean_diff: mean_diff, se_diff: se_diff, t_statistic: t_statistic, df: df1 + df2 }
  end
  # rubocop:enable Metrics/AbcSize

  # Applies Bonferroni correction to p-values
  def bonferroni_adjust(p_values)
    n_comparisons = p_values.length
    p_values.map { |p| [p * n_comparisons, 1.0].min }
  end
end
