# frozen_string_literal: true

# ANOVA helper methods and variance homogeneity tests
# This module provides shared statistical methods for ANOVA calculations including:
# - Levene and Bartlett tests for variance homogeneity
# - Sum of squares calculations
# - Statistical distribution utilities
# - Effect size interpretation
module AnovaHelpers
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
                       'Homogeneity of variance hypothesis is rejected (group variances are not equal)'
                     else
                       'Homogeneity of variance hypothesis is not rejected (group variances are considered equal)'
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
        interpretation: 'Homogeneity of variance hypothesis is not rejected (group variances are assumed equal)',
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
                       'Homogeneity of variance hypothesis is rejected (group variances are not equal)'
                     else
                       'Homogeneity of variance hypothesis is not rejected (group variances are considered equal)'
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

  # ANOVA helper methods
  def calculate_sum_of_squares_between(groups, group_means, grand_mean)
    groups.each_with_index.sum do |group, i|
      group.length * ((group_means[i] - grand_mean)**2)
    end
  end

  def calculate_sum_of_squares_within(groups, group_means)
    groups.each_with_index.sum do |group, i|
      group.sum { |value| (value - group_means[i])**2 }
    end
  end

  def calculate_omega_squared(ss_between, df_between, ms_within, df_total)
    numerator = ss_between - (df_between * ms_within)
    denominator = ss_between + ((df_total + 1) * ms_within)
    return 0.0 if denominator.zero? || numerator.negative?

    numerator / denominator
  end

  def interpret_anova_results(_f_statistic, p_value, eta_squared)
    effect_size = interpret_effect_size(eta_squared)

    if p_value < 0.05
      "The differences between group means are statistically significant (p = #{p_value.round(4)}) with #{effect_size} effect size."
    else
      "The differences between group means are not statistically significant (p = #{p_value.round(4)})."
    end
  end

  # Tukey HSD critical value and p-value estimation methods
  def calculate_harmonic_mean_n(sizes)
    k = sizes.length
    sum_reciprocals = sizes.sum { |n| 1.0 / n }
    k / sum_reciprocals
  end

  def tukey_critical_value(num_groups, deg_freedom, _alpha)
    # Tukey q critical values table approximation
    # For alpha = 0.05
    q_table = {
      3 => { 10 => 3.88, 20 => 3.58, 30 => 3.49, 60 => 3.40, 120 => 3.36, Float::INFINITY => 3.31 },
      4 => { 10 => 4.33, 20 => 3.96, 30 => 3.84, 60 => 3.74, 120 => 3.68, Float::INFINITY => 3.63 },
      5 => { 10 => 4.65, 20 => 4.23, 30 => 4.10, 60 => 3.98, 120 => 3.92, Float::INFINITY => 3.86 },
      6 => { 10 => 4.91, 20 => 4.47, 30 => 4.30, 60 => 4.16, 120 => 4.10, Float::INFINITY => 4.03 },
      7 => { 10 => 5.12, 20 => 4.65, 30 => 4.46, 60 => 4.31, 120 => 4.24, Float::INFINITY => 4.17 },
      8 => { 10 => 5.30, 20 => 4.79, 30 => 4.60, 60 => 4.44, 120 => 4.36, Float::INFINITY => 4.29 },
      9 => { 10 => 5.46, 20 => 4.91, 30 => 4.72, 60 => 4.55, 120 => 4.47, Float::INFINITY => 4.39 },
      10 => { 10 => 5.60, 20 => 5.01, 30 => 4.82, 60 => 4.65, 120 => 4.56, Float::INFINITY => 4.47 }
    }

    # Default for larger number of groups
    q_table[num_groups] = { 10 => 6.0, 20 => 5.4, 30 => 5.2, 60 => 5.0, 120 => 4.9, Float::INFINITY => 4.8 } unless q_table.key?(num_groups)

    # Find closest degrees of freedom
    available_dfs = [10, 20, 30, 60, 120, Float::INFINITY]
    closest_df = available_dfs.min_by { |df| (df - deg_freedom).abs }

    q_table[num_groups][closest_df] || 4.0
  end

  def estimate_tukey_p_value(q_statistic, num_groups, deg_freedom)
    # Get critical value
    critical_value = tukey_critical_value(num_groups, deg_freedom, 0.05)

    # Rough p-value estimation based on q-statistic
    if q_statistic >= critical_value * 1.5
      0.001  # Very highly significant
    elsif q_statistic >= critical_value * 1.2
      0.01   # Highly significant
    elsif q_statistic >= critical_value
      0.04   # Significant
    elsif q_statistic >= critical_value * 0.9
      0.06   # Marginally not significant
    elsif q_statistic >= critical_value * 0.8
      0.10   # Not significant
    else
      0.20   # Clearly not significant
    end
  end

  # Statistical calculation utilities
  def calculate_group_median(array)
    return nil if array.empty?

    sorted = array.sort
    n = sorted.length

    if n.odd?
      sorted[n / 2]
    else
      (sorted[(n / 2) - 1] + sorted[n / 2]) / 2.0
    end
  end

  def variance_of_array(array)
    return 0.0 if array.length <= 1

    mean = array.sum.to_f / array.length
    sum_squared_deviations = array.sum { |x| (x - mean)**2 }
    sum_squared_deviations / (array.length - 1)
  end

  def calculate_chi_square_p_value(chi_square, degrees_of_freedom)
    return 1.0 if chi_square <= 0 || degrees_of_freedom <= 0

    # Try to use table lookup first for common values
    p_value_from_table = calculate_chi_square_p_value_table(chi_square, degrees_of_freedom)
    return p_value_from_table if p_value_from_table

    # Otherwise use normal approximation for large df
    calculate_chi_square_p_value_normal_approximation(chi_square, degrees_of_freedom)
  end

  def calculate_chi_square_p_value_table(chi_square, degrees_freedom)
    # Chi-square critical values for common alpha levels
    # Organized as df => { alpha => critical_value }
    critical_values = chi_square_critical_values

    return nil unless critical_values.key?(degrees_freedom)

    # Find p-value by comparing with critical values
    df_values = critical_values[degrees_freedom]

    # Check each alpha level
    return 0.001 if chi_square > df_values[0.001]
    return 0.01 if chi_square > df_values[0.01]
    return 0.05 if chi_square > df_values[0.05]
    return 0.10 if chi_square > df_values[0.10]

    # If chi_square is less than all critical values, p > 0.10
    0.15
  end

  def calculate_chi_square_p_value_normal_approximation(chi_square, degrees_freedom)
    # For large df, use normal approximation
    # Z = sqrt(2 * chi_square) - sqrt(2 * df - 1)
    z = Math.sqrt(2 * chi_square) - Math.sqrt((2 * degrees_freedom) - 1)

    # Calculate p-value using standard normal CDF
    1.0 - MathUtils.standard_normal_cdf(z)
  end

  def chi_square_critical_values
    {
      1 => { 0.10 => 2.706, 0.05 => 3.841, 0.01 => 6.635, 0.001 => 10.828 },
      2 => { 0.10 => 4.605, 0.05 => 5.991, 0.01 => 9.210, 0.001 => 13.816 },
      3 => { 0.10 => 6.251, 0.05 => 7.815, 0.01 => 11.345, 0.001 => 16.266 },
      4 => { 0.10 => 7.779, 0.05 => 9.488, 0.01 => 13.277, 0.001 => 18.467 },
      5 => { 0.10 => 9.236, 0.05 => 11.070, 0.01 => 15.086, 0.001 => 20.515 }
    }
  end

  def calculate_two_tailed_p_value(t_statistic, degrees_of_freedom)
    # Use MathUtils t-distribution approximation
    # Get one-tailed p-value first
    one_tailed_p = if t_statistic >= 0
                     1.0 - MathUtils.approximate_t_distribution_cdf(t_statistic, degrees_of_freedom)
                   else
                     MathUtils.approximate_t_distribution_cdf(t_statistic, degrees_of_freedom)
                   end

    # Convert to two-tailed
    2.0 * one_tailed_p
  end

  def interpret_effect_size(eta_squared)
    if eta_squared >= 0.14
      'large'
    elsif eta_squared >= 0.06
      'medium'
    elsif eta_squared >= 0.01
      'small'
    else
      'negligible'
    end
  end
end
