# frozen_string_literal: true

# ANOVA (Analysis of Variance) statistical analysis module
# This module provides comprehensive variance analysis capabilities including:
# - One-way ANOVA with F-statistics and effect size measures
# - Post-hoc analysis with Tukey HSD and Bonferroni correction
# - Variance homogeneity tests (Levene and Bartlett tests)
module ANOVAStats
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
    unless anova_result[:significant]
      result[:warning] = 'ANOVA was not significant. Post-hoc tests may not be appropriate.'
    end

    result
  end

  # Levene test for variance homogeneity (Brown-Forsythe modification)
  # Used as prerequisite check for ANOVA assumptions
  def levene_test(*groups)
    # Validate input - need at least 2 groups
    groups = groups.compact
    groups = groups.reject { |group| group.is_a?(Array) && group.empty? }

    return nil if groups.length < 2

    # Ensure each group has at least one value and is an array
    groups.each do |group|
      return nil unless group.is_a?(Array)
      return nil if group.empty?
    end

    # Calculate basic parameters
    k = groups.length # number of groups
    n_total = groups.flatten.length # total sample size

    # Calculate median for each group (Brown-Forsythe modification)
    group_medians = groups.map { |group| calculate_group_median(group) }

    # Transform data: Zij = |Xij - median_i|
    z_groups = groups.each_with_index.map do |group, i|
      median_i = group_medians[i]
      group.map { |x| (x - median_i).abs }
    end

    # Calculate group means of Z values
    z_group_means = z_groups.map { |z_group| z_group.sum.to_f / z_group.length }

    # Calculate overall mean of Z values
    all_z_values = z_groups.flatten
    z_overall_mean = all_z_values.sum.to_f / all_z_values.length

    # Calculate sum of squares between groups
    ss_between = 0.0
    z_groups.each_with_index do |z_group, i|
      n_i = z_group.length
      z_bar_i = z_group_means[i]
      ss_between += n_i * ((z_bar_i - z_overall_mean)**2)
    end

    # Calculate sum of squares within groups
    ss_within = 0.0
    z_groups.each_with_index do |z_group, i|
      z_bar_i = z_group_means[i]
      z_group.each do |z_ij|
        ss_within += (z_ij - z_bar_i)**2
      end
    end

    # Calculate degrees of freedom
    df_between = k - 1
    df_within = n_total - k

    # Calculate mean squares
    ms_between = ss_between / df_between
    ms_within = df_within.zero? ? 0.0 : ss_within / df_within

    # Calculate F-statistic
    f_statistic = if ms_within.zero?
                    ms_between.zero? ? 0.0 : Float::INFINITY
                  else
                    ms_between / ms_within
                  end

    # Calculate p-value using F-distribution
    p_value = MathUtils.calculate_f_distribution_p_value(f_statistic, df_between, df_within)

    # Determine significance and interpretation
    significant = p_value < 0.05
    interpretation = if significant
                       '分散の等質性仮説は棄却される（各グループの分散は等しくない）'
                     else
                       '分散の等質性仮説は棄却されない（各グループの分散は等しいと考えられる）'
                     end

    {
      test_type: 'Levene Test (Brown-Forsythe)',
      f_statistic: f_statistic.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: [df_between, df_within],
      significant: significant,
      interpretation: interpretation
    }
  end

  # Bartlett test for variance homogeneity (assumes normality)
  # Provides high precision variance equality testing under normal distribution
  def bartlett_test(*groups)
    # Validate input - need at least 2 groups
    groups = groups.compact
    groups = groups.reject { |group| group.is_a?(Array) && group.empty? }

    return nil if groups.length < 2

    # Ensure each group has at least one value and is an array
    groups.each do |group|
      return nil unless group.is_a?(Array)
      return nil if group.empty?
    end

    # Calculate basic parameters
    k = groups.length # number of groups
    n_total = groups.flatten.length # total sample size
    group_sizes = groups.map(&:length)

    # Calculate sample variances for each group
    group_variances = groups.map do |group|
      next 0.0 if group.length <= 1

      mean = group.sum.to_f / group.length
      sum_squared_deviations = group.sum { |x| (x - mean)**2 }
      sum_squared_deviations / (group.length - 1)
    end

    # Calculate pooled variance (S²p)
    numerator = group_variances.each_with_index.sum do |var, i|
      (group_sizes[i] - 1) * var
    end
    pooled_variance = numerator / (n_total - k)

    # Handle edge case where all variances are zero
    if pooled_variance <= 0.0 || group_variances.all? { |var| var <= 0.0 }
      return {
        test_type: 'Bartlett Test',
        chi_square_statistic: 0.0,
        p_value: 1.0,
        degrees_of_freedom: k - 1,
        significant: false,
        interpretation: '分散の等質性仮説は棄却されない（各グループの分散は等しいと考えられる）',
        correction_factor: 1.0,
        pooled_variance: 0.0
      }
    end

    # Calculate correction factor C
    # C = 1 + (1/(3(k-1))) * [Σ(1/(ni-1)) - 1/(N-k)]
    sum_inverse_df = group_sizes.sum { |n_i| 1.0 / (n_i - 1) }
    inverse_total_df = 1.0 / (n_total - k)
    correction_factor = 1.0 + ((1.0 / (3.0 * (k - 1))) * (sum_inverse_df - inverse_total_df))

    # Calculate Bartlett statistic
    # χ² = (1/C) * [(N-k)ln(S²p) - Σ(ni-1)ln(S²i)]
    pooled_log_variance = Math.log(pooled_variance)
    sum_weighted_log_variances = group_variances.each_with_index.sum do |var, i|
      next 0.0 if var <= 0.0

      (group_sizes[i] - 1) * Math.log(var)
    end

    chi_square_statistic = (((n_total - k) * pooled_log_variance) - sum_weighted_log_variances) / correction_factor

    # Degrees of freedom
    df = k - 1

    # Calculate p-value using chi-square distribution
    p_value = calculate_chi_square_p_value(chi_square_statistic, df)

    # Determine significance and interpretation
    significant = p_value < 0.05
    interpretation = if significant
                       '分散の等質性仮説は棄却される（各グループの分散は等しくない）'
                     else
                       '分散の等質性仮説は棄却されない（各グループの分散は等しいと考えられる）'
                     end

    {
      test_type: 'Bartlett Test',
      chi_square_statistic: chi_square_statistic.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: df,
      significant: significant,
      interpretation: interpretation,
      correction_factor: correction_factor.round(6),
      pooled_variance: pooled_variance.round(6)
    }
  end

  private

  # ANOVA helper methods for sum of squares calculations
  def calculate_sum_of_squares_between(groups, group_means, grand_mean)
    groups.zip(group_means).sum do |group, group_mean|
      group.length * ((group_mean - grand_mean)**2)
    end
  end

  def calculate_sum_of_squares_within(groups, group_means)
    groups.zip(group_means).sum do |group, group_mean|
      group.sum { |value| (value - group_mean)**2 }
    end
  end

  # Calculate omega squared effect size for ANOVA
  def calculate_omega_squared(ss_between, df_between, ms_within, df_total)
    numerator = ss_between - (df_between * ms_within)
    denominator = (ss_between + ((df_total + 1) * ms_within))
    denominator.zero? ? 0.0 : numerator / denominator
  end

  # Interpret ANOVA results with effect size classification
  def interpret_anova_results(_f_statistic, p_value, eta_squared)
    significance = p_value < 0.05 ? '有意' : '非有意'

    effect_size_interpretation = case eta_squared
                                 when 0.0...0.01
                                   '効果サイズ: 極小'
                                 when 0.01...0.06
                                   '効果サイズ: 小'
                                 when 0.06...0.14
                                   '効果サイズ: 中'
                                 else
                                   '効果サイズ: 大'
                                 end

    "#{significance}差あり (p = #{p_value.round(3)}), #{effect_size_interpretation} (η² = #{eta_squared.round(3)})"
  end

  # Post-hoc analysis methods
  def tukey_pairwise_comparison(group1, group2, all_groups, ms_within)
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    mean_diff = (mean1 - mean2).abs

    # Calculate q-statistic
    n_harmonic = calculate_harmonic_mean_n([group1.length, group2.length])
    se = Math.sqrt(ms_within / n_harmonic)
    q_statistic = mean_diff / se

    # Get critical value and p-value
    k = all_groups.length # number of groups
    df_within = all_groups.flatten.length - k
    q_critical = tukey_critical_value(k, df_within, 0.05)

    # Estimate p-value based on q-statistic
    p_value = estimate_tukey_p_value(q_statistic, k, df_within)

    {
      mean_difference: mean_diff.round(6),
      q_statistic: q_statistic.round(6),
      q_critical: q_critical.round(6),
      p_value: p_value.round(6),
      significant: q_statistic > q_critical
    }
  end

  def bonferroni_pairwise_comparison(group1, group2, _num_groups)
    # Calculate t-test statistics directly
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    var1 = variance_of_array(group1)
    var2 = variance_of_array(group2)
    n1 = group1.length
    n2 = group2.length

    # Welch's t-test
    se = Math.sqrt((var1 / n1) + (var2 / n2))
    return nil if se.zero?

    t_statistic = (mean1 - mean2) / se

    # Calculate degrees of freedom using Welch-Satterthwaite equation
    df = (((var1 / n1) + (var2 / n2))**2) /
         ((((var1 / n1)**2) / (n1 - 1)) + (((var2 / n2)**2) / (n2 - 1)))

    # Calculate p-value
    p_value = calculate_two_tailed_p_value(t_statistic, df)

    {
      mean_difference: (mean1 - mean2).abs.round(6),
      t_statistic: t_statistic.abs.round(6),
      p_value: p_value.round(6)
    }
  end

  def bonferroni_adjust(p_values)
    n_comparisons = p_values.length
    p_values.map { |p| [p * n_comparisons, 1.0].min }
  end

  def calculate_harmonic_mean_n(sizes)
    n = sizes.length
    n / sizes.sum { |size| 1.0 / size }
  end

  # Tukey HSD critical value approximation
  def tukey_critical_value(num_groups, deg_freedom, _alpha)
    # Approximation of Tukey's studentized range critical values
    # For common values at alpha = 0.05
    tukey_table = {
      2 => { 5 => 3.64, 10 => 3.15, 15 => 3.01, 20 => 2.95, 30 => 2.89, 60 => 2.83 },
      3 => { 5 => 4.60, 10 => 3.88, 15 => 3.67, 20 => 3.58, 30 => 3.49, 60 => 3.40 },
      4 => { 5 => 5.22, 10 => 4.33, 15 => 4.08, 20 => 3.96, 30 => 3.85, 60 => 3.74 },
      5 => { 5 => 5.67, 10 => 4.65, 15 => 4.37, 20 => 4.23, 30 => 4.10, 60 => 3.98 }
    }

    # Find closest values
    k_key = num_groups.clamp(2, 5) # Clamp k between 2 and 5

    # Find closest df
    df_keys = tukey_table[k_key].keys.sort
    df_key = df_keys.min_by { |key| (key - deg_freedom).abs }

    # Adjust if df is very large
    df_key = 60 if deg_freedom > 60

    tukey_table[k_key][df_key] || 3.5 # Default fallback
  end

  # Estimate p-value for Tukey test (approximation)
  def estimate_tukey_p_value(q_statistic, num_groups, deg_freedom)
    # Rough estimation of p-value from q-statistic
    # This is an approximation since exact calculation requires complex integration

    # Get critical values for different alpha levels
    q_one_percent = tukey_critical_value(num_groups, deg_freedom, 0.01) * 1.3 # Rough scaling
    q_five_percent = tukey_critical_value(num_groups, deg_freedom, 0.05)
    q_ten_percent = tukey_critical_value(num_groups, deg_freedom, 0.05) * 0.9 # Rough scaling

    if q_statistic >= q_one_percent
      0.001
    elsif q_statistic >= q_five_percent
      0.001 + ((0.05 - 0.001) * (q_one_percent - q_statistic) / (q_one_percent - q_five_percent))
    elsif q_statistic >= q_ten_percent
      0.05 + ((0.1 - 0.05) * (q_five_percent - q_statistic) / (q_five_percent - q_ten_percent))
    else
      # For smaller q values, use exponential decay approximation
      0.1 * Math.exp(-(q_ten_percent - q_statistic))
    end.clamp(0.0001, 0.9999)
  end

  # Helper method for calculating median (Brown-Forsythe modification)
  def calculate_group_median(array)
    return nil if array.empty?

    sorted = array.sort
    length = sorted.length

    if length.odd?
      sorted[length / 2]
    else
      mid1 = sorted[(length / 2) - 1]
      mid2 = sorted[length / 2]
      (mid1 + mid2) / 2.0
    end
  end

  # Calculate sample variance for an array
  def variance_of_array(array)
    return 0.0 if array.length <= 1

    mean = array.sum.to_f / array.length
    array.sum { |x| (x - mean)**2 } / (array.length - 1)
  end

  # Chi-square p-value calculation for Bartlett test
  def calculate_chi_square_p_value(chi_square, degrees_of_freedom)
    # For small degrees of freedom, use pre-calculated critical values
    if degrees_of_freedom <= 30
      calculate_chi_square_p_value_table(chi_square, degrees_of_freedom)
    else
      # For larger df, use normal approximation
      calculate_chi_square_p_value_normal_approximation(chi_square, degrees_of_freedom)
    end
  end

  def calculate_chi_square_p_value_table(chi_square, degrees_freedom)
    # Pre-calculated critical values for common significance levels
    critical_values = chi_square_critical_values[degrees_freedom] || {}

    return 1.0 if chi_square <= 0

    # Simple p-value estimation based on critical value comparison
    return 0.99 if chi_square <= (critical_values[0.99] || 0)
    return 0.95 if chi_square <= (critical_values[0.95] || 0)
    return 0.90 if chi_square <= (critical_values[0.90] || 0)
    return 0.80 if chi_square <= (critical_values[0.80] || 0)
    return 0.70 if chi_square <= (critical_values[0.70] || 0)
    return 0.60 if chi_square <= (critical_values[0.60] || 0)
    return 0.50 if chi_square <= (critical_values[0.50] || 0)
    return 0.40 if chi_square <= (critical_values[0.40] || 0)
    return 0.30 if chi_square <= (critical_values[0.30] || 0)
    return 0.20 if chi_square <= (critical_values[0.20] || 0)
    return 0.10 if chi_square <= (critical_values[0.10] || 0)
    return 0.05 if chi_square <= (critical_values[0.05] || 0)
    return 0.01 if chi_square <= (critical_values[0.01] || 0)

    0.001
  end

  def calculate_chi_square_p_value_normal_approximation(chi_square, degrees_freedom)
    # Wilson-Hilferty transformation for large degrees of freedom
    h = 2.0 / (9.0 * degrees_freedom)
    z = (((chi_square / degrees_freedom)**(1.0 / 3.0)) - (1.0 - h)) / Math.sqrt(h)

    # Use standard normal distribution to find p-value
    1.0 - MathUtils.standard_normal_cdf(z)
  end

  def chi_square_critical_values
    # Critical values for chi-square distribution (minimal set for Bartlett test)
    {
      1 => { 0.99 => 0.000, 0.95 => 0.004, 0.90 => 0.016, 0.05 => 3.841, 0.01 => 6.635 },
      2 => { 0.99 => 0.020, 0.95 => 0.103, 0.90 => 0.211, 0.05 => 5.991, 0.01 => 9.210 },
      3 => { 0.99 => 0.115, 0.95 => 0.352, 0.90 => 0.584, 0.05 => 7.815, 0.01 => 11.345 },
      4 => { 0.99 => 0.297, 0.95 => 0.711, 0.90 => 1.064, 0.05 => 9.488, 0.01 => 13.277 },
      5 => { 0.99 => 0.554, 0.95 => 1.145, 0.90 => 1.610, 0.05 => 11.070, 0.01 => 15.086 }
    }
  end

  # Helper method for Bonferroni correction
  def calculate_two_tailed_p_value(t_statistic, degrees_of_freedom)
    # Approximation for t-distribution CDF using normal approximation for large df
    abs_t = t_statistic.abs

    if degrees_of_freedom >= 30
      # Use normal approximation for large samples
      z_score = abs_t
      p_one_tail = 1.0 - MathUtils.standard_normal_cdf(z_score)
    else
      # Simple approximation for small samples
      p_one_tail = MathUtils.approximate_t_distribution_cdf(abs_t, degrees_of_freedom)
    end

    # Two-tailed test
    2.0 * p_one_tail
  end
end
