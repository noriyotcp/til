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
    # Validate input - groups should be arrays of numbers
    groups = groups.compact

    # Remove empty groups
    groups = groups.reject { |group| group.is_a?(Array) && group.empty? }

    return nil if groups.length < 2

    # Ensure each group has at least one value and is an array
    groups.each do |group|
      return nil unless group.is_a?(Array)
      return nil if group.empty?
    end

    # Calculate basic statistics
    group_means = groups.map { |group| group.sum.to_f / group.length }
    grand_mean = groups.flatten.sum.to_f / groups.flatten.length

    # Calculate sum of squares
    ss_between = calculate_sum_of_squares_between(groups, group_means, grand_mean)
    ss_within = calculate_sum_of_squares_within(groups, group_means)
    ss_total = ss_between + ss_within

    # Calculate degrees of freedom
    df_between = groups.length - 1
    df_within = groups.flatten.length - groups.length
    df_total = df_between + df_within

    # Calculate mean squares
    ms_between = ss_between / df_between
    ms_within = df_within.zero? ? 0.0 : ss_within / df_within

    # Calculate F-statistic
    f_statistic = ms_within.zero? ? Float::INFINITY : ms_between / ms_within

    # Calculate p-value using F-distribution approximation
    p_value = MathUtils.calculate_f_distribution_p_value(f_statistic, df_between, df_within)

    # Calculate effect sizes
    eta_squared = ss_total.zero? ? 0.0 : ss_between / ss_total
    omega_squared = calculate_omega_squared(ss_between, df_between, ms_within, df_total)

    {
      f_statistic: f_statistic.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: [df_between, df_within],
      sum_of_squares: {
        between: ss_between.round(6),
        within: ss_within.round(6),
        total: ss_total.round(6)
      },
      mean_squares: {
        between: ms_between.round(6),
        within: ms_within.round(6)
      },
      effect_size: {
        eta_squared: eta_squared.round(6),
        omega_squared: omega_squared.round(6)
      },
      group_means: group_means.map { |mean| mean.round(6) },
      grand_mean: grand_mean.round(6),
      significant: p_value < 0.05,
      interpretation: interpret_anova_results(f_statistic, p_value, eta_squared)
    }
  end

  # Performs post-hoc analysis after ANOVA using Tukey HSD or Bonferroni correction
  # Returns pairwise comparisons with significance testing
  def post_hoc_analysis(groups, method: :tukey)
    # Validate input
    return nil if groups.nil? || groups.length < 2
    return nil unless %i[tukey bonferroni].include?(method)

    # Clean groups
    groups = groups.compact.reject { |g| g.is_a?(Array) && g.empty? }
    return nil if groups.length < 2

    # Run ANOVA first to get MSE
    anova_result = one_way_anova(*groups)
    return nil if anova_result.nil?

    ms_within = anova_result[:mean_squares][:within]

    # Generate all pairwise comparisons
    comparisons = []
    groups.each_with_index do |group1, i|
      groups.each_with_index do |group2, j|
        next if i >= j # Only unique pairs

        comparison = if method == :tukey
                       tukey_pairwise_comparison(group1, group2, groups, ms_within)
                     else
                       bonferroni_pairwise_comparison(group1, group2, groups.length)
                     end

        comparison[:groups] = [i + 1, j + 1] # 1-indexed group labels
        comparisons << comparison
      end
    end

    # Apply Bonferroni adjustment if needed
    if method == :bonferroni
      adjusted_p_values = bonferroni_adjust(comparisons.map { |c| c[:p_value] })
      comparisons.each_with_index do |comp, idx|
        comp[:adjusted_p_value] = adjusted_p_values[idx]
        comp[:significant] = comp[:adjusted_p_value] < 0.05
      end
    end

    result = {
      method: method == :tukey ? 'Tukey HSD' : 'Bonferroni',
      pairwise_comparisons: comparisons
    }

    # Add adjusted alpha for Bonferroni
    result[:adjusted_alpha] = 0.05 / comparisons.length if method == :bonferroni

    # Add warning if ANOVA was not significant
    result[:warning] = 'ANOVA was not significant. Post-hoc tests may not be appropriate.' unless anova_result[:significant]

    result
  end

  private

  # Performs Tukey HSD pairwise comparison
  def tukey_pairwise_comparison(group1, group2, all_groups, ms_within)
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    mean_diff = (mean1 - mean2).abs

    # Calculate sizes for harmonic mean
    sizes = all_groups.map(&:length)
    harmonic_n = calculate_harmonic_mean_n(sizes)

    # Calculate standard error
    se = Math.sqrt(ms_within / harmonic_n)

    # Calculate q-statistic
    q_statistic = se.zero? ? Float::INFINITY : mean_diff / se

    # Get critical value and estimate p-value
    df_within = all_groups.flatten.length - all_groups.length
    critical_value = tukey_critical_value(all_groups.length, df_within, 0.05)
    p_value = estimate_tukey_p_value(q_statistic, all_groups.length, df_within)

    {
      mean_difference: mean_diff.round(6),
      standard_error: se.round(6),
      q_statistic: q_statistic.round(6),
      critical_value: critical_value.round(6),
      p_value: p_value.round(6),
      significant: q_statistic > critical_value,
      confidence_interval: [
        (mean_diff - (critical_value * se)).round(6),
        (mean_diff + (critical_value * se)).round(6)
      ],
      q_critical: critical_value.round(6)
    }
  end

  # Performs Bonferroni pairwise comparison
  def bonferroni_pairwise_comparison(group1, group2, _num_groups)
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    mean_diff = mean1 - mean2

    # Calculate pooled variance
    var1 = variance_of_array(group1)
    var2 = variance_of_array(group2)
    df1 = group1.length - 1
    df2 = group2.length - 1

    # Pooled standard deviation
    pooled_var = (((df1 * var1) + (df2 * var2)) / (df1 + df2))
    pooled_sd = Math.sqrt(pooled_var)

    # Standard error of the mean difference
    se_diff = pooled_sd * Math.sqrt((1.0 / group1.length) + (1.0 / group2.length))

    # Calculate t-statistic
    t_statistic = se_diff.zero? ? Float::INFINITY : mean_diff / se_diff

    # Degrees of freedom
    df = df1 + df2

    # Two-tailed p-value using t-distribution
    p_value = calculate_two_tailed_p_value(t_statistic.abs, df)

    {
      mean_difference: mean_diff.round(6),
      standard_error: se_diff.round(6),
      t_statistic: t_statistic.round(6),
      degrees_of_freedom: df,
      p_value: p_value.round(6),
      significant: false # Will be updated after Bonferroni adjustment
    }
  end

  # Applies Bonferroni correction to p-values
  def bonferroni_adjust(p_values)
    n_comparisons = p_values.length
    p_values.map { |p| [p * n_comparisons, 1.0].min }
  end
end
