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

  # Performs two-way Analysis of Variance (ANOVA) on factorial design data
  # Returns main effects, interaction effect, F-statistics, p-values, and effect sizes
  def two_way_anova(data, factor_a_levels, factor_b_levels, values)
    # Validate input data structure
    return nil unless valid_two_way_anova_input?(data, factor_a_levels, factor_b_levels, values)

    # Extract unique levels for each factor
    a_levels = factor_a_levels.uniq.sort
    b_levels = factor_b_levels.uniq.sort

    # Create factorial design matrix
    cell_data = create_factorial_matrix({
                                          factor_a_levels: factor_a_levels,
                                          factor_b_levels: factor_b_levels,
                                          values: values,
                                          a_levels: a_levels,
                                          b_levels: b_levels
                                        })

    # Calculate basic statistics
    grand_mean = values.sum.to_f / values.length
    n_total = values.length
    a = a_levels.length  # number of levels in factor A
    b = b_levels.length  # number of levels in factor B

    # Calculate cell means and marginal means
    cell_means, marginal_means_a, marginal_means_b = calculate_factorial_means(cell_data, a_levels, b_levels)

    # Calculate sum of squares
    ss_total = calculate_total_sum_of_squares(values, grand_mean)
    ss_a = calculate_factor_a_sum_of_squares(cell_data, marginal_means_a, grand_mean, a_levels, b)
    ss_b = calculate_factor_b_sum_of_squares(cell_data, marginal_means_b, grand_mean, b_levels, a)
    ss_ab = calculate_interaction_sum_of_squares({
                                                   cell_data: cell_data,
                                                   cell_means: cell_means,
                                                   marginal_means_a: marginal_means_a,
                                                   marginal_means_b: marginal_means_b,
                                                   grand_mean: grand_mean,
                                                   a_levels: a_levels,
                                                   b_levels: b_levels
                                                 })
    ss_error = ss_total - ss_a - ss_b - ss_ab

    # Calculate degrees of freedom
    df_a = a - 1
    df_b = b - 1
    df_ab = (a - 1) * (b - 1)

    # Calculate error degrees of freedom (total cells minus parameters)
    cell_sample_sizes = calculate_cell_sample_sizes(cell_data, a_levels, b_levels)
    df_error = cell_sample_sizes.values.sum - (a * b)
    df_total = n_total - 1

    # Calculate mean squares
    ms_a = df_a.zero? ? 0.0 : ss_a / df_a
    ms_b = df_b.zero? ? 0.0 : ss_b / df_b
    ms_ab = df_ab.zero? ? 0.0 : ss_ab / df_ab
    ms_error = df_error.zero? ? 0.0 : ss_error / df_error

    # Calculate F-statistics
    f_a = if ms_error.zero?
            ms_a.zero? ? 0.0 : Float::INFINITY
          else
            ms_a / ms_error
          end
    f_b = if ms_error.zero?
            ms_b.zero? ? 0.0 : Float::INFINITY
          else
            ms_b / ms_error
          end
    f_ab = if ms_error.zero?
             ms_ab.zero? ? 0.0 : Float::INFINITY
           else
             ms_ab / ms_error
           end

    # Calculate p-values
    p_a = MathUtils.calculate_f_distribution_p_value(f_a, df_a, df_error)
    p_b = MathUtils.calculate_f_distribution_p_value(f_b, df_b, df_error)
    p_ab = MathUtils.calculate_f_distribution_p_value(f_ab, df_ab, df_error)

    # Calculate effect sizes (partial eta squared)
    eta_squared_a = ss_total.zero? ? 0.0 : ss_a / (ss_a + ss_error)
    eta_squared_b = ss_total.zero? ? 0.0 : ss_b / (ss_b + ss_error)
    eta_squared_ab = ss_total.zero? ? 0.0 : ss_ab / (ss_ab + ss_error)

    {
      main_effects: {
        factor_a: {
          f_statistic: f_a.round(6),
          p_value: p_a.round(6),
          degrees_of_freedom: [df_a, df_error],
          sum_of_squares: ss_a.round(6),
          mean_squares: ms_a.round(6),
          eta_squared: eta_squared_a.round(6),
          significant: p_a < 0.05
        },
        factor_b: {
          f_statistic: f_b.round(6),
          p_value: p_b.round(6),
          degrees_of_freedom: [df_b, df_error],
          sum_of_squares: ss_b.round(6),
          mean_squares: ms_b.round(6),
          eta_squared: eta_squared_b.round(6),
          significant: p_b < 0.05
        }
      },
      interaction: {
        f_statistic: f_ab.round(6),
        p_value: p_ab.round(6),
        degrees_of_freedom: [df_ab, df_error],
        sum_of_squares: ss_ab.round(6),
        mean_squares: ms_ab.round(6),
        eta_squared: eta_squared_ab.round(6),
        significant: p_ab < 0.05
      },
      error: {
        sum_of_squares: ss_error.round(6),
        mean_squares: ms_error.round(6),
        degrees_of_freedom: df_error
      },
      total: {
        sum_of_squares: ss_total.round(6),
        degrees_of_freedom: df_total
      },
      grand_mean: grand_mean.round(6),
      cell_means: format_cell_means(cell_means, a_levels, b_levels),
      marginal_means: {
        factor_a: marginal_means_a.transform_values { |v| v.round(6) },
        factor_b: marginal_means_b.transform_values { |v| v.round(6) }
      },
      interpretation: interpret_two_way_anova_results({
                                                        p_a: p_a, p_b: p_b, p_ab: p_ab,
                                                        eta_a: eta_squared_a,
                                                        eta_b: eta_squared_b,
                                                        eta_ab: eta_squared_ab
                                                      })
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

  # Two-way ANOVA helper methods

  # Validate input data structure for two-way ANOVA
  def valid_two_way_anova_input?(data, factor_a_levels, factor_b_levels, values)
    return false unless data.is_a?(Hash) || data.nil?
    return false unless factor_a_levels.is_a?(Array) && factor_b_levels.is_a?(Array) && values.is_a?(Array)
    return false if factor_a_levels.empty? || factor_b_levels.empty? || values.empty?
    return false unless factor_a_levels.length == factor_b_levels.length && factor_b_levels.length == values.length

    # Check that we have at least 2 levels for each factor
    return false if factor_a_levels.uniq.length < 2 || factor_b_levels.uniq.length < 2

    # Check that all values are numeric
    values.all? { |v| v.is_a?(Numeric) }
  end

  # Create factorial design matrix from input data
  def create_factorial_matrix(data_params)
    factor_a_levels = data_params[:factor_a_levels]
    factor_b_levels = data_params[:factor_b_levels]
    values = data_params[:values]
    a_levels = data_params[:a_levels]
    b_levels = data_params[:b_levels]
    cell_data = {}

    # Initialize empty cells
    a_levels.each do |a_level|
      b_levels.each do |b_level|
        cell_data[[a_level, b_level]] = []
      end
    end

    # Fill cells with data
    factor_a_levels.each_with_index do |a_val, i|
      b_val = factor_b_levels[i]
      value = values[i]
      cell_data[[a_val, b_val]] << value
    end

    cell_data
  end

  # Calculate cell means and marginal means for factorial design
  def calculate_factorial_means(cell_data, a_levels, b_levels)
    cell_means = {}
    marginal_means_a = {}
    marginal_means_b = {}

    # Calculate cell means
    a_levels.each do |a_level|
      b_levels.each do |b_level|
        cell_values = cell_data[[a_level, b_level]]
        cell_means[[a_level, b_level]] = cell_values.empty? ? 0.0 : cell_values.sum.to_f / cell_values.length
      end

      # Calculate marginal means for factor A
      all_values = b_levels.flat_map { |b_level| cell_data[[a_level, b_level]] }
      marginal_means_a[a_level] = all_values.empty? ? 0.0 : all_values.sum.to_f / all_values.length
    end

    # Calculate marginal means for factor B
    b_levels.each do |b_level|
      all_values = a_levels.flat_map { |a_level| cell_data[[a_level, b_level]] }
      marginal_means_b[b_level] = all_values.empty? ? 0.0 : all_values.sum.to_f / all_values.length
    end

    [cell_means, marginal_means_a, marginal_means_b]
  end

  # Calculate total sum of squares
  def calculate_total_sum_of_squares(values, grand_mean)
    values.sum { |value| (value - grand_mean)**2 }
  end

  # Calculate sum of squares for factor A main effect
  def calculate_factor_a_sum_of_squares(cell_data, marginal_means_a, grand_mean, a_levels, b)
    a_levels.sum do |a_level|
      # Calculate sample size for this level of factor A
      n_a = cell_data.select { |key, _| key[0] == a_level }.values.flatten.length
      b * ((marginal_means_a[a_level] - grand_mean)**2) * (n_a / b.to_f)
    end
  end

  # Calculate sum of squares for factor B main effect
  def calculate_factor_b_sum_of_squares(cell_data, marginal_means_b, grand_mean, b_levels, a)
    b_levels.sum do |b_level|
      # Calculate sample size for this level of factor B
      n_b = cell_data.select { |key, _| key[1] == b_level }.values.flatten.length
      a * ((marginal_means_b[b_level] - grand_mean)**2) * (n_b / a.to_f)
    end
  end

  # Calculate sum of squares for interaction effect
  def calculate_interaction_sum_of_squares(interaction_params)
    cell_data = interaction_params[:cell_data]
    cell_means = interaction_params[:cell_means]
    marginal_means_a = interaction_params[:marginal_means_a]
    marginal_means_b = interaction_params[:marginal_means_b]
    grand_mean = interaction_params[:grand_mean]
    a_levels = interaction_params[:a_levels]
    b_levels = interaction_params[:b_levels]
    total_interaction_ss = 0.0

    a_levels.each do |a_level|
      b_levels.each do |b_level|
        cell_mean = cell_means[[a_level, b_level]]
        marginal_a = marginal_means_a[a_level]
        marginal_b = marginal_means_b[b_level]

        # Sample size for this cell
        n_ab = cell_data[[a_level, b_level]].length

        interaction_effect = cell_mean - marginal_a - marginal_b + grand_mean
        total_interaction_ss += n_ab * (interaction_effect**2)
      end
    end

    total_interaction_ss
  end

  # Calculate sample sizes for each cell
  def calculate_cell_sample_sizes(cell_data, a_levels, b_levels)
    cell_sizes = {}

    a_levels.each do |a_level|
      b_levels.each do |b_level|
        cell_sizes[[a_level, b_level]] = cell_data[[a_level, b_level]].length
      end
    end

    cell_sizes
  end

  # Format cell means for output
  def format_cell_means(cell_means, a_levels, b_levels)
    formatted = {}

    a_levels.each do |a_level|
      formatted[a_level] = {}
      b_levels.each do |b_level|
        formatted[a_level][b_level] = cell_means[[a_level, b_level]].round(6)
      end
    end

    formatted
  end

  # Interpret two-way ANOVA results
  def interpret_two_way_anova_results(interpretation_params)
    p_a = interpretation_params[:p_a]
    p_b = interpretation_params[:p_b]
    p_ab = interpretation_params[:p_ab]
    eta_a = interpretation_params[:eta_a]
    eta_b = interpretation_params[:eta_b]
    eta_ab = interpretation_params[:eta_ab]
    interpretations = []

    # Main effect A
    if p_a < 0.05
      effect_size_a = interpret_effect_size(eta_a)
      interpretations << "要因A: 有意な主効果あり (p = #{p_a.round(3)}), #{effect_size_a}"
    else
      interpretations << "要因A: 主効果なし (p = #{p_a.round(3)})"
    end

    # Main effect B
    if p_b < 0.05
      effect_size_b = interpret_effect_size(eta_b)
      interpretations << "要因B: 有意な主効果あり (p = #{p_b.round(3)}), #{effect_size_b}"
    else
      interpretations << "要因B: 主効果なし (p = #{p_b.round(3)})"
    end

    # Interaction effect
    if p_ab < 0.05
      effect_size_ab = interpret_effect_size(eta_ab)
      interpretations << "交互作用A×B: 有意な交互作用あり (p = #{p_ab.round(3)}), #{effect_size_ab}"
    else
      interpretations << "交互作用A×B: 交互作用なし (p = #{p_ab.round(3)})"
    end

    interpretations.join(', ')
  end

  # Interpret effect size (partial eta squared)
  def interpret_effect_size(eta_squared)
    case eta_squared
    when 0.0...0.01
      "効果サイズ: 極小 (η² = #{eta_squared.round(3)})"
    when 0.01...0.06
      "効果サイズ: 小 (η² = #{eta_squared.round(3)})"
    when 0.06...0.14
      "効果サイズ: 中 (η² = #{eta_squared.round(3)})"
    else
      "効果サイズ: 大 (η² = #{eta_squared.round(3)})"
    end
  end
end
