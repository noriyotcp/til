# frozen_string_literal: true

require_relative 'number_analyzer/statistics_presenter'
require_relative 'number_analyzer/statistics/basic_stats'
require_relative 'number_analyzer/statistics/math_utils'
require_relative 'number_analyzer/statistics/advanced_stats'
require_relative 'number_analyzer/statistics/correlation_stats'
require_relative 'number_analyzer/statistics/time_series_stats'
require_relative 'number_analyzer/statistics/hypothesis_testing'

# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  include BasicStats
  include AdvancedStats
  include CorrelationStats
  include TimeSeriesStats
  include HypothesisTesting

  def initialize(numbers)
    @numbers = numbers
  end

  def calculate_statistics
    stats = {
      total: @numbers.sum,
      average: average_value,
      maximum: @numbers.max,
      minimum: @numbers.min,
      median_value: median,
      variance: variance,
      mode_values: mode,
      std_dev: standard_deviation,
      iqr: interquartile_range,
      outlier_values: outliers,
      deviation_scores: deviation_scores,
      frequency_distribution: frequency_distribution
    }

    StatisticsPresenter.display_results(stats)
  end

  def median = percentile(50)

  def frequency_distribution = @numbers.tally

  def display_histogram
    puts '度数分布ヒストグラム:'

    freq_dist = frequency_distribution

    if freq_dist.empty?
      puts '(データが空です)'
      return
    end

    freq_dist.sort.each do |value, count|
      bar = '■' * count
      puts "#{value}: #{bar} (#{count})"
    end
  end

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

  def kruskal_wallis_test(*groups)
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

    # Combine all values and calculate ranks
    all_values = groups.flatten
    all_values_with_group_index = []

    groups.each_with_index do |group, group_idx|
      group.each do |value|
        all_values_with_group_index << [value, group_idx]
      end
    end

    # Sort by value and assign ranks
    sorted_values = all_values_with_group_index.sort_by(&:first)
    ranks = calculate_ranks_with_ties(sorted_values.map(&:first))

    # Calculate rank sums for each group
    rank_sums = Array.new(k, 0.0)
    sorted_values.each_with_index do |(_value, group_idx), i|
      rank_sums[group_idx] += ranks[i]
    end

    # Calculate H statistic
    # H = [12/(N(N+1))] * [Σ(Ri²/ni)] - 3(N+1)
    sum_rank_squares_over_n = rank_sums.each_with_index.sum do |rank_sum, i|
      (rank_sum**2) / group_sizes[i].to_f
    end

    h_statistic = ((12.0 / (n_total * (n_total + 1))) * sum_rank_squares_over_n) - (3 * (n_total + 1))

    # Apply tie correction if there are ties
    h_statistic = apply_tie_correction_to_h(h_statistic, all_values)

    # Degrees of freedom
    df = k - 1

    # Calculate p-value using chi-square distribution
    p_value = calculate_chi_square_p_value(h_statistic, df)

    # Determine significance and interpretation
    significant = p_value < 0.05
    interpretation = if significant
                       'グループ間に統計的有意差が認められる（中央値が等しくない）'
                     else
                       'グループ間に統計的有意差は認められない（中央値が等しいと考えられる）'
                     end

    {
      test_type: 'Kruskal-Wallis H Test',
      h_statistic: h_statistic.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: df,
      significant: significant,
      interpretation: interpretation,
      group_sizes: group_sizes,
      total_n: n_total
    }
  end

  def mann_whitney_u_test(group1, group2)
    # Validate input - need exactly 2 groups
    return nil if group1.nil? || group2.nil?
    return nil unless group1.is_a?(Array) && group2.is_a?(Array)
    return nil if group1.empty? || group2.empty?

    # Calculate basic parameters
    n1 = group1.length
    n2 = group2.length
    n_total = n1 + n2

    # Combine groups with labels for ranking
    combined_data = group1.map { |value| [value, 1] } + group2.map { |value| [value, 2] }

    # Sort by value and calculate ranks
    sorted_data = combined_data.sort_by(&:first)
    ranks = calculate_ranks_with_ties(sorted_data.map(&:first))

    # Calculate rank sums for each group
    r1 = 0.0 # Rank sum for group 1
    r2 = 0.0 # Rank sum for group 2

    sorted_data.each_with_index do |(_value, group_label), i|
      if group_label == 1
        r1 += ranks[i]
      else
        r2 += ranks[i]
      end
    end

    # Calculate U statistics
    # U1 = n1 * n2 + n1 * (n1 + 1) / 2 - R1
    # U2 = n1 * n2 + n2 * (n2 + 1) / 2 - R2
    u1 = (n1 * n2) + ((n1 * (n1 + 1)) / 2.0) - r1
    u2 = (n1 * n2) + ((n2 * (n2 + 1)) / 2.0) - r2

    # Test statistic is the smaller U value
    u_statistic = [u1, u2].min

    # Calculate mean U for both large and small samples
    mean_u = (n1 * n2) / 2.0

    # For large samples, use normal approximation with tie correction
    if n1 >= 8 && n2 >= 8
      # Apply tie correction for variance calculation
      variance_u = calculate_mann_whitney_variance(n1, n2, sorted_data.map(&:first))

      # Continuity correction
      z_statistic = if u_statistic > mean_u
                      (u_statistic - mean_u - 0.5) / Math.sqrt(variance_u)
                    else
                      (u_statistic - mean_u + 0.5) / Math.sqrt(variance_u)
                    end
    else
      # For small samples, use exact test (approximation)
      # This is a simplified approach - exact tables would be more accurate
      variance_u = (n1 * n2 * (n1 + n2 + 1)) / 12.0
      z_statistic = (u_statistic - mean_u) / Math.sqrt(variance_u)
    end

    # Two-tailed p-value using normal distribution (same for both cases)
    p_value = 2 * (1 - MathUtils.standard_normal_cdf(z_statistic.abs))

    # Calculate effect size (r = z / sqrt(N))
    effect_size = z_statistic.abs / Math.sqrt(n_total)

    # Determine significance and interpretation
    significant = p_value < 0.05
    interpretation = if significant
                       'グループ間に統計的有意差が認められる（分布に違いがある）'
                     else
                       'グループ間に統計的有意差は認められない（分布に違いはないと考えられる）'
                     end

    {
      test_type: 'Mann-Whitney U Test',
      u_statistic: u_statistic.round(6),
      u1: u1.round(6),
      u2: u2.round(6),
      z_statistic: z_statistic.round(6),
      p_value: p_value.round(6),
      significant: significant,
      interpretation: interpretation,
      effect_size: effect_size.round(6),
      group_sizes: [n1, n2],
      rank_sums: [r1.round(2), r2.round(2)],
      total_n: n_total
    }
  end

  private

  # Helper method for Bonferroni correction and Bartlett test
  def calculate_two_tailed_p_value(t_statistic, degrees_of_freedom)
    # Approximation for t-distribution CDF using normal approximation for large df
    abs_t = t_statistic.abs

    if degrees_of_freedom >= 30
      # Use normal approximation for large samples
      z_score = abs_t
      p_one_tail = 1.0 - standard_normal_cdf(z_score)
    else
      # Simple approximation for small samples
      p_one_tail = MathUtils.approximate_t_distribution_cdf(abs_t, degrees_of_freedom)
    end

    # Two-tailed test
    2.0 * p_one_tail
  end

  # Standard normal CDF helper
  def standard_normal_cdf(z)
    MathUtils.standard_normal_cdf(z)
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
    1.0 - standard_normal_cdf(z)
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

  # ANOVA helper methods
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

  def calculate_omega_squared(ss_between, df_between, ms_within, df_total)
    numerator = ss_between - (df_between * ms_within)
    denominator = (ss_between + ((df_total + 1) * ms_within))
    denominator.zero? ? 0.0 : numerator / denominator
  end

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

  def calculate_tukey_q_statistic(group1, group2)
    # This is a helper method for testing
    # In practice, it's called within tukey_pairwise_comparison
    mean1 = group1.sum.to_f / group1.length
    mean2 = group2.sum.to_f / group2.length
    mean_diff = (mean1 - mean2).abs

    # For this test helper, we'll use a simple approximation
    pooled_variance = (variance_of_array(group1) + variance_of_array(group2)) / 2
    n_harmonic = calculate_harmonic_mean_n([group1.length, group2.length])
    se = Math.sqrt(pooled_variance / n_harmonic)

    se.zero? ? 0.0 : mean_diff / se
  end

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

  def variance_of_array(array)
    return 0.0 if array.length <= 1

    mean = array.sum.to_f / array.length
    array.sum { |x| (x - mean)**2 } / (array.length - 1)
  end

  def calculate_ranks_with_ties(values)
    # Sort values with original indices to handle ties properly
    sorted_with_index = values.each_with_index.sort_by(&:first)
    ranks = Array.new(values.length)

    i = 0
    while i < sorted_with_index.length
      # Find the extent of the current tie group
      current_value = sorted_with_index[i][0]
      tie_start = i
      tie_end = i

      tie_end += 1 while tie_end < sorted_with_index.length && sorted_with_index[tie_end][0] == current_value

      # Calculate average rank for the tie group
      # Ranks are 1-indexed, so we add 1 to the starting position
      average_rank = (tie_start + tie_end + 1).to_f / 2.0

      # Assign the average rank to all values in the tie group
      (tie_start...tie_end).each do |j|
        original_index = sorted_with_index[j][1]
        ranks[original_index] = average_rank
      end

      i = tie_end
    end

    ranks
  end

  def apply_tie_correction_to_h(h_statistic, all_values)
    # Count occurrences of each value to identify ties
    value_counts = all_values.tally

    # Calculate tie correction factor
    # C = 1 - [Σ(ti³ - ti)] / [N³ - N]
    # where ti is the number of tied observations for each distinct value
    n_total = all_values.length
    tie_sum = value_counts.values.sum { |count| (count**3) - count }

    return h_statistic if tie_sum.zero? # No ties, no correction needed

    correction_factor = 1.0 - (tie_sum.to_f / ((n_total**3) - n_total))

    # Apply correction: H_corrected = H / C
    h_statistic / correction_factor
  end

  def calculate_mann_whitney_variance(size1, size2, all_values)
    # Basic variance without tie correction
    basic_variance = (size1 * size2 * (size1 + size2 + 1)) / 12.0

    # Apply tie correction
    value_counts = all_values.tally
    tie_correction = value_counts.values.sum do |count|
      if count > 1
        count * ((count**2) - 1)
      else
        0
      end
    end

    # Corrected variance: σ²U = (n1*n2/12) * [(n1+n2+1) - Σ(ti³-ti)/(n1+n2)(n1+n2-1)]
    if tie_correction.positive?
      total_n = size1 + size2
      tie_factor = tie_correction / (total_n * (total_n - 1))
      basic_variance * (1 - (tie_factor / (size1 + size2 + 1)))
    else
      basic_variance
    end
  end
end
