# frozen_string_literal: true

require_relative 'number_analyzer/statistics_presenter'
require_relative 'number_analyzer/statistics/basic_stats'

# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  include BasicStats

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

  def percentile(percentile_value)
    return nil if @numbers.empty?
    return @numbers.first if @numbers.length == 1

    sorted = @numbers.sort
    rank = (percentile_value / 100.0) * (sorted.length - 1)

    lower_index = rank.floor
    upper_index = rank.ceil

    if lower_index == upper_index
      sorted[lower_index]
    else
      weight = rank - lower_index
      (sorted[lower_index] * (1 - weight)) + (sorted[upper_index] * weight)
    end
  end

  def quartiles
    {
      q1: percentile(25),
      q2: median,
      q3: percentile(75)
    }
  end

  def interquartile_range
    return nil if @numbers.empty?

    q = quartiles
    q[:q3] - q[:q1]
  end

  def outliers
    return [] if @numbers.empty? || @numbers.length <= 2

    q = quartiles
    iqr = interquartile_range

    return [] if iqr.zero? # 全て同じ値の場合

    lower_bound = q[:q1] - (1.5 * iqr)
    upper_bound = q[:q3] + (1.5 * iqr)

    @numbers.select { |num| num < lower_bound || num > upper_bound }
  end

  def deviation_scores
    return [] if @numbers.empty?

    mean = average_value
    std_dev = standard_deviation

    # 標準偏差が0の場合は、全ての値を50とする
    return Array.new(@numbers.length, 50.0) if std_dev.zero?

    @numbers.map do |number|
      ((((number - mean) / std_dev) * 10) + 50).round(2)
    end
  end

  def frequency_distribution = @numbers.tally

  def linear_trend
    return nil if @numbers.empty? || @numbers.length < 2

    x_values = (0...@numbers.length).to_a
    slope, intercept = calculate_trend_line(x_values)
    return nil if slope.nil?

    r_squared = calculate_r_squared(x_values, slope, intercept)
    direction = determine_trend_direction(slope)

    {
      slope: slope.round(10),
      intercept: intercept.round(10),
      r_squared: r_squared.round(10),
      direction: direction
    }
  end

  def correlation(other_dataset)
    return nil if @numbers.empty? || other_dataset.empty?
    return nil if @numbers.length != other_dataset.length

    # Calculate means
    mean_x = @numbers.sum.to_f / @numbers.length
    mean_y = other_dataset.sum.to_f / other_dataset.length

    # Calculate numerator and denominators for Pearson correlation
    numerator = 0.0
    sum_sq_x = 0.0
    sum_sq_y = 0.0

    @numbers.length.times do |i|
      diff_x = @numbers[i] - mean_x
      diff_y = other_dataset[i] - mean_y

      numerator += diff_x * diff_y
      sum_sq_x += diff_x * diff_x
      sum_sq_y += diff_y * diff_y
    end

    # Avoid division by zero
    denominator = Math.sqrt(sum_sq_x * sum_sq_y)
    return 0.0 if denominator.zero?

    # Return Pearson correlation coefficient
    (numerator / denominator).round(10)
  end

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

  def moving_average(window_size)
    return nil if @numbers.empty? || window_size <= 0 || window_size > @numbers.length

    result = []
    (@numbers.length - window_size + 1).times do |i|
      window_sum = @numbers[i, window_size].sum
      result << (window_sum.to_f / window_size)
    end

    result
  end

  def growth_rates
    return [] if @numbers.empty? || @numbers.length < 2

    result = []
    (1...@numbers.length).each do |i|
      previous_value = @numbers[i - 1]
      current_value = @numbers[i]

      # Handle division by zero
      if previous_value.zero?
        result << (current_value.zero? ? 0.0 : Float::INFINITY)
      else
        growth_rate = ((current_value - previous_value).to_f / previous_value) * 100
        result << growth_rate.round(10)
      end
    end

    result
  end

  def compound_annual_growth_rate
    return nil if @numbers.empty? || @numbers.length < 2

    initial_value = @numbers.first
    final_value = @numbers.last
    periods = @numbers.length - 1

    # Handle zero or negative initial value
    return nil if initial_value <= 0

    # Handle zero final value
    return -100.0 if final_value.zero?

    # Calculate CAGR
    cagr = (((final_value.to_f / initial_value)**(1.0 / periods)) - 1) * 100
    cagr.round(10)
  end

  def average_growth_rate
    rates = growth_rates
    return nil if rates.empty?

    # Filter out infinite values for average calculation
    finite_rates = rates.reject(&:infinite?)
    return nil if finite_rates.empty?

    finite_rates.sum / finite_rates.length
  end

  def seasonal_decomposition(period = nil)
    return nil if @numbers.empty? || @numbers.length < 4

    detected_period = period || detect_seasonal_period
    return nil if detected_period.nil? || detected_period < 2

    # Ensure we have enough data for at least 2 complete cycles
    return nil if @numbers.length < (detected_period * 2)

    seasonal_indices = calculate_seasonal_indices(detected_period)
    trend_component = calculate_trend_component(detected_period)
    seasonal_strength = calculate_seasonal_strength(seasonal_indices)

    {
      period: detected_period,
      seasonal_indices: seasonal_indices,
      trend_component: trend_component,
      seasonal_strength: seasonal_strength,
      has_seasonality: seasonal_strength > 0.1
    }
  end

  def detect_seasonal_period
    return nil if @numbers.length < 4

    # Test common seasonal periods
    candidate_periods = [2, 3, 4, 6, 12]
    candidate_periods.select! { |p| @numbers.length >= p * 2 }
    return nil if candidate_periods.empty?

    best_period = nil
    best_strength = 0.0

    candidate_periods.each do |period|
      seasonal_indices = calculate_seasonal_indices(period)
      strength = calculate_seasonal_strength(seasonal_indices)

      if strength > best_strength
        best_strength = strength
        best_period = period
      end
    end

    # Only return period if seasonality is significant
    best_strength > 0.1 ? best_period : nil
  end

  def seasonal_strength
    decomposition = seasonal_decomposition
    return 0.0 if decomposition.nil?

    decomposition[:seasonal_strength]
  end

  def t_test(other_data, type: :independent, population_mean: nil)
    return nil if @numbers.empty?

    case type
    when :independent
      independent_t_test(other_data)
    when :paired
      paired_t_test(other_data)
    when :one_sample
      one_sample_t_test(population_mean)
    else
      raise ArgumentError, "Invalid t-test type: #{type}. Use :independent, :paired, or :one_sample"
    end
  end

  def confidence_interval(confidence_level, type: :mean)
    return nil if @numbers.empty? || @numbers.length < 2

    raise ArgumentError, 'Confidence level must be between 1 and 99' unless confidence_level.between?(1, 99)

    case type
    when :mean
      mean_confidence_interval(confidence_level)
    else
      raise ArgumentError, "Invalid confidence interval type: #{type}. Use :mean"
    end
  end

  def chi_square_test(expected_data = nil, type: :independence)
    return nil if @numbers.empty? || @numbers.length < 2

    case type
    when :independence
      chi_square_independence_test(expected_data)
    when :goodness_of_fit
      chi_square_goodness_of_fit_test(expected_data)
    else
      raise ArgumentError, "Invalid chi-square test type: #{type}. Use :independence or :goodness_of_fit"
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
    p_value = calculate_f_distribution_p_value(f_statistic, df_between, df_within)

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
    p_value = calculate_f_distribution_p_value(f_statistic, df_between, df_within)

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
    p_value = 2 * (1 - standard_normal_cdf(z_statistic.abs))

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

  def calculate_trend_line(x_values)
    n = @numbers.length
    x_mean = x_values.sum.to_f / n
    y_mean = average_value

    numerator = 0.0
    denominator = 0.0

    n.times do |i|
      x_diff = x_values[i] - x_mean
      y_diff = @numbers[i] - y_mean

      numerator += x_diff * y_diff
      denominator += x_diff * x_diff
    end

    return [nil, nil] if denominator.zero?

    slope = numerator / denominator
    intercept = y_mean - (slope * x_mean)
    [slope, intercept]
  end

  def calculate_r_squared(x_values, slope, intercept)
    y_mean = average_value
    ss_total = @numbers.sum { |y| (y - y_mean)**2 }

    ss_residual = x_values.each_with_index.sum do |x, i|
      predicted = (slope * x) + intercept
      (@numbers[i] - predicted)**2
    end

    ss_total.zero? ? 1.0 : 1.0 - (ss_residual / ss_total)
  end

  def determine_trend_direction(slope)
    if slope > 0.001
      '上昇'
    elsif slope < -0.001
      '下降'
    else
      '横ばい'
    end
  end

  def calculate_seasonal_indices(period)
    return [] if @numbers.length < period

    # Group data by seasonal position
    seasonal_groups = Array.new(period) { [] }
    @numbers.each_with_index do |value, index|
      seasonal_position = index % period
      seasonal_groups[seasonal_position] << value
    end

    # Calculate average for each seasonal position
    seasonal_indices = seasonal_groups.map do |group|
      group.empty? ? 0.0 : group.sum.to_f / group.length
    end

    # Check if we have at least 2 complete cycles for validation
    complete_cycles = @numbers.length / period
    return [] if complete_cycles < 2

    seasonal_indices
  end

  def calculate_trend_component(period)
    return [] if @numbers.length < period

    # Simple moving average for trend
    trend = []
    half_period = period / 2

    @numbers.each_with_index do |_, index|
      if index >= half_period && index < (@numbers.length - half_period)
        start_index = index - half_period
        end_index = index + half_period
        window = @numbers[start_index..end_index]
        trend << (window.sum.to_f / window.length)
      else
        trend << @numbers[index]
      end
    end

    trend
  end

  def calculate_seasonal_strength(seasonal_indices)
    return 0.0 if invalid_seasonal_indices?(seasonal_indices)
    return 0.0 if seasonal_indices_show_trend?(seasonal_indices)

    seasonal_variance = calculate_seasonal_variance(seasonal_indices)
    overall_variance = variance

    return 0.0 if overall_variance.zero?

    strength = (seasonal_variance / overall_variance).round(4)
    strength > 0.05 ? strength : 0.0
  end

  def invalid_seasonal_indices?(seasonal_indices)
    seasonal_indices.empty? || seasonal_indices.length < 2
  end

  def calculate_seasonal_variance(seasonal_indices)
    mean_seasonal = seasonal_indices.sum.to_f / seasonal_indices.length
    seasonal_indices.sum { |si| (si - mean_seasonal)**2 } / seasonal_indices.length
  end

  def seasonal_indices_show_trend?(seasonal_indices)
    return false if seasonal_indices.length < 3

    # Calculate differences between consecutive seasonal indices
    differences = (1...seasonal_indices.length).map do |i|
      seasonal_indices[i] - seasonal_indices[i - 1]
    end

    # Check if differences show a consistent trend
    avg_diff = differences.sum.to_f / differences.length
    diff_variance = differences.sum { |d| (d - avg_diff)**2 } / differences.length

    # If variance is low and average difference is significant, it's trending
    diff_variance < 0.1 && avg_diff.abs > 0.1
  end

  def independent_t_test(other_data)
    return nil if invalid_data_for_independent_test?(other_data)

    stats1 = calculate_sample_statistics(@numbers)
    stats2 = calculate_sample_statistics(other_data)

    welch_test_result(stats1, stats2)
  end

  def paired_t_test(other_data)
    return nil if invalid_data_for_paired_test?(other_data)

    differences = calculate_paired_differences(other_data)
    return nil if differences.length < 2

    paired_test_result(differences)
  end

  def one_sample_t_test(population_mean)
    return nil if population_mean.nil?

    n = @numbers.length
    return nil if n < 2

    sample_mean = @numbers.sum.to_f / n
    sample_var = @numbers.sum { |x| (x - sample_mean)**2 } / (n - 1)
    standard_error = Math.sqrt(sample_var / n)

    return nil if standard_error.zero?

    t_statistic = (sample_mean - population_mean) / standard_error
    df = n - 1
    p_value = calculate_two_tailed_p_value(t_statistic, df)

    {
      test_type: 'one_sample',
      t_statistic: t_statistic.round(10),
      degrees_of_freedom: df,
      p_value: p_value.round(10),
      sample_mean: sample_mean.round(10),
      population_mean: population_mean.round(10),
      n: n,
      significant: p_value < 0.05
    }
  end

  def welch_degrees_of_freedom(variance1, count1, variance2, count2)
    numerator = ((variance1 / count1) + (variance2 / count2))**2
    term1 = ((variance1 / count1)**2) / (count1 - 1)
    term2 = ((variance2 / count2)**2) / (count2 - 1)
    denominator = term1 + term2

    return count1 + count2 - 2 if denominator.zero?

    numerator / denominator
  end

  def calculate_two_tailed_p_value(t_statistic, degrees_of_freedom)
    # Approximation for t-distribution CDF using normal approximation for large df
    # For small df, this is less accurate but sufficient for basic statistical testing
    abs_t = t_statistic.abs

    if degrees_of_freedom >= 30
      # Use normal approximation for large samples
      z_score = abs_t
      p_one_tail = 1.0 - standard_normal_cdf(z_score)
    else
      # Simple approximation for small samples
      # This is not as accurate as proper t-distribution but provides reasonable estimates
      p_one_tail = approximate_t_distribution_cdf(abs_t, degrees_of_freedom)
    end

    # Two-tailed test
    2.0 * p_one_tail
  end

  def standard_normal_cdf(z_score)
    # Approximation of standard normal CDF using error function approximation
    # This is reasonably accurate for most practical purposes
    0.5 * (1.0 + erf(z_score / Math.sqrt(2.0)))
  end

  def erf(value)
    # Approximation of error function using Abramowitz and Stegun formula
    # Maximum error: 1.5 × 10^−7
    a1 = 0.254829592
    a2 = -0.284496736
    a3 = 1.421413741
    a4 = -1.453152027
    a5 = 1.061405429
    p = 0.3275911

    sign = value >= 0 ? 1 : -1
    value = value.abs

    t = 1.0 / (1.0 + (p * value))
    y = 1.0 - (((((((((a5 * t) + a4) * t) + a3) * t) + a2) * t) + a1) * t * Math.exp(-value * value))

    sign * y
  end

  def approximate_t_distribution_cdf(t_value, degrees_of_freedom)
    # Simple approximation for t-distribution
    # Not highly accurate but sufficient for basic statistical testing
    return 0.5 - (Math.atan(t_value) / Math::PI) if degrees_of_freedom <= 1

    # For df > 1, use approximation that converges to normal distribution
    adjustment = 1.0 + ((t_value * t_value) / (4.0 * degrees_of_freedom))
    normal_approx = standard_normal_cdf(t_value / Math.sqrt(adjustment))
    1.0 - normal_approx
  end

  def invalid_data_for_independent_test?(other_data)
    other_data.nil? || other_data.empty?
  end

  def invalid_data_for_paired_test?(other_data)
    other_data.nil? || other_data.empty? || @numbers.length != other_data.length
  end

  def calculate_sample_statistics(data)
    n = data.length
    mean = data.sum.to_f / n
    variance = n > 1 ? data.sum { |x| (x - mean)**2 } / (n - 1) : 0.0

    { n: n, mean: mean, variance: variance }
  end

  def welch_test_result(stats1, stats2)
    standard_error = Math.sqrt((stats1[:variance] / stats1[:n]) + (stats2[:variance] / stats2[:n]))
    return nil if standard_error.zero?

    t_statistic = (stats1[:mean] - stats2[:mean]) / standard_error
    df = welch_degrees_of_freedom(stats1[:variance], stats1[:n], stats2[:variance], stats2[:n])
    p_value = calculate_two_tailed_p_value(t_statistic, df)

    {
      test_type: 'independent_samples',
      t_statistic: t_statistic.round(10),
      degrees_of_freedom: df.round(2),
      p_value: p_value.round(10),
      mean1: stats1[:mean].round(10),
      mean2: stats2[:mean].round(10),
      n1: stats1[:n],
      n2: stats2[:n],
      significant: p_value < 0.05
    }
  end

  def calculate_paired_differences(other_data)
    @numbers.zip(other_data).map { |a, b| a - b }
  end

  def paired_test_result(differences)
    n = differences.length
    mean_diff = differences.sum.to_f / n
    var_diff = differences.sum { |d| (d - mean_diff)**2 } / (n - 1)
    standard_error = Math.sqrt(var_diff / n)

    return nil if standard_error.zero?

    t_statistic = mean_diff / standard_error
    df = n - 1
    p_value = calculate_two_tailed_p_value(t_statistic, df)

    {
      test_type: 'paired_samples',
      t_statistic: t_statistic.round(10),
      degrees_of_freedom: df,
      p_value: p_value.round(10),
      mean_difference: mean_diff.round(10),
      n: n,
      significant: p_value < 0.05
    }
  end

  def mean_confidence_interval(confidence_level)
    n = @numbers.length
    sample_mean = average_value
    standard_err = standard_error

    return nil if standard_err.zero?

    # Calculate t-critical value for two-tailed test
    alpha = (100 - confidence_level) / 100.0
    df = n - 1
    t_critical = calculate_t_critical_value(alpha / 2, df)

    margin_of_error = t_critical * standard_err

    {
      confidence_level: confidence_level,
      point_estimate: sample_mean.round(10),
      lower_bound: (sample_mean - margin_of_error).round(10),
      upper_bound: (sample_mean + margin_of_error).round(10),
      margin_of_error: margin_of_error.round(10),
      standard_error: standard_err.round(10),
      sample_size: n
    }
  end

  def standard_error
    return 0.0 if @numbers.length <= 1

    sample_std = Math.sqrt(sample_variance)
    sample_std / Math.sqrt(@numbers.length)
  end

  def sample_variance
    return 0.0 if @numbers.length <= 1

    mean = average_value
    @numbers.sum { |x| (x - mean)**2 } / (@numbers.length - 1)
  end

  def calculate_t_critical_value(alpha, degrees_of_freedom)
    return inverse_normal_cdf(1 - alpha) if degrees_of_freedom >= 30

    base_t_value = lookup_t_value(degrees_of_freedom)
    confidence_factor = calculate_confidence_factor(alpha)
    base_t_value * confidence_factor
  end

  def lookup_t_value(degrees_of_freedom)
    t_values = {
      1 => 12.706, 2 => 4.303, 3 => 3.182, 4 => 2.776, 5 => 2.571,
      6 => 2.447, 7 => 2.365, 8 => 2.306, 9 => 2.262, 10 => 2.228,
      11 => 2.201, 12 => 2.179, 13 => 2.160, 14 => 2.145, 15 => 2.131,
      16 => 2.120, 17 => 2.110, 18 => 2.101, 19 => 2.093, 20 => 2.086,
      25 => 2.060, 29 => 2.045
    }

    t_values[degrees_of_freedom] || 2.045 # Default to df=29 value
  end

  def calculate_confidence_factor(alpha)
    two_tailed_alpha = alpha * 2
    return 1.3 if two_tailed_alpha.between?(0.009, 0.011) # 99% CI
    return 1.0 if two_tailed_alpha.between?(0.049, 0.051) # 95% CI
    return 0.8 if two_tailed_alpha.between?(0.099, 0.101) # 90% CI

    1.0 # Default factor
  end

  def inverse_normal_cdf(probability)
    # Approximation of inverse normal CDF using Beasley-Springer-Moro algorithm
    # This provides reasonable accuracy for confidence interval calculations

    return -Float::INFINITY if probability <= 0
    return Float::INFINITY if probability >= 1
    return 0.0 if probability.between?(0.499, 0.501)

    # Use symmetry for probability > 0.5
    return -inverse_normal_cdf(1 - probability) if probability > 0.5

    # Approximation for 0 < probability < 0.5
    t = Math.sqrt(-2 * Math.log(probability))

    # Coefficients for the approximation
    c0 = 2.515517
    c1 = 0.802853
    c2 = 0.010328
    d1 = 1.432788
    d2 = 0.189269
    d3 = 0.001308

    numerator = c0 + (c1 * t) + (c2 * t * t)
    denominator = 1 + (d1 * t) + (d2 * t * t) + (d3 * t * t * t)

    -(t - (numerator / denominator))
  end

  def chi_square_independence_test(contingency_table)
    return nil unless contingency_table.is_a?(Array) && contingency_table.first.is_a?(Array)

    observed = contingency_table
    rows = observed.length
    cols = observed.first.length

    # Calculate row and column totals
    row_totals = observed.map(&:sum)
    col_totals = (0...cols).map { |j| observed.sum { |row| row[j] } }
    grand_total = row_totals.sum

    return nil if grand_total.zero?

    # Calculate expected frequencies
    expected = Array.new(rows) do |i|
      Array.new(cols) do |j|
        (row_totals[i] * col_totals[j]).to_f / grand_total
      end
    end

    # Validate expected frequency conditions
    expected_frequencies_valid = validate_expected_frequencies?(expected.flatten)
    warning = expected_frequencies_valid ? nil : '警告: 期待度数が5未満のセルがあります。結果の信頼性が低い可能性があります。'

    # Calculate chi-square statistic
    chi_square = calculate_chi_square_statistic(observed.flatten, expected.flatten)
    degrees_of_freedom = (rows - 1) * (cols - 1)
    p_value = calculate_chi_square_p_value(chi_square, degrees_of_freedom)

    # Calculate Cramér's V (effect size)
    min_dimension = [rows - 1, cols - 1].min
    cramers_v = min_dimension.positive? ? Math.sqrt(chi_square / (grand_total * min_dimension)) : 0.0

    {
      test_type: 'independence',
      chi_square_statistic: chi_square.round(10),
      degrees_of_freedom: degrees_of_freedom,
      p_value: p_value.round(10),
      significant: p_value < 0.05,
      cramers_v: cramers_v.round(10),
      observed_frequencies: observed,
      expected_frequencies: expected.map { |row| row.map { |val| val.round(10) } },
      expected_frequencies_valid: expected_frequencies_valid,
      warning: warning
    }
  end

  def chi_square_goodness_of_fit_test(expected_frequencies)
    observed_frequencies = @numbers

    # Handle uniform distribution assumption
    if expected_frequencies.nil?
      total = observed_frequencies.sum
      categories = observed_frequencies.length
      expected_frequencies = Array.new(categories, total.to_f / categories)
    end

    # Validate input dimensions
    if observed_frequencies.length != expected_frequencies.length
      raise ArgumentError, 'Observed and expected frequencies must have same length'
    end

    return nil if observed_frequencies.empty?

    # Validate expected frequency conditions
    expected_frequencies_valid = validate_expected_frequencies?(expected_frequencies)
    warning = expected_frequencies_valid ? nil : '警告: 期待度数が5未満のカテゴリがあります。結果の信頼性が低い可能性があります。'

    # Calculate chi-square statistic
    chi_square = calculate_chi_square_statistic(observed_frequencies, expected_frequencies)
    degrees_of_freedom = observed_frequencies.length - 1
    p_value = calculate_chi_square_p_value(chi_square, degrees_of_freedom)

    {
      test_type: 'goodness_of_fit',
      chi_square_statistic: chi_square.round(10),
      degrees_of_freedom: degrees_of_freedom,
      p_value: p_value.round(10),
      significant: p_value < 0.05,
      observed_frequencies: observed_frequencies,
      expected_frequencies: expected_frequencies.map { |val| val.round(10) },
      expected_frequencies_valid: expected_frequencies_valid,
      warning: warning
    }
  end

  def calculate_chi_square_statistic(observed, expected)
    observed.zip(expected).sum do |obs, exp|
      next 0.0 if exp.zero?

      ((obs - exp)**2).to_f / exp
    end
  end

  def validate_expected_frequencies?(expected_frequencies)
    # Rule: All expected frequencies should be ≥ 5
    # Alternative: At least 80% should be ≥ 5 and minimum should be ≥ 1
    all_valid = expected_frequencies.all? { |freq| freq >= 5 }
    return true if all_valid

    # Check alternative rule
    valid_count = expected_frequencies.count { |freq| freq >= 5 }
    percentage_valid = valid_count.to_f / expected_frequencies.length
    min_frequency = expected_frequencies.min

    percentage_valid >= 0.8 && min_frequency >= 1
  end

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
    # Using interpolation for p-value estimation
    critical_values = chi_square_critical_values[degrees_freedom] || {}

    return 1.0 if chi_square <= 0

    # For a more accurate estimation, find where chi_square falls
    # Critical values are stored as alpha => critical_value
    # We need to find which alpha level corresponds to our chi_square value

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

    0.001 # Very small p-value for large chi-square values
  end

  def calculate_chi_square_p_value_normal_approximation(chi_square, degrees_freedom)
    # For large degrees_freedom, chi-square approaches normal distribution
    # Using continuity correction: χ² ~ N(df, 2*df)
    mean = degrees_freedom
    variance = 2 * degrees_freedom
    std_dev = Math.sqrt(variance)

    z_score = (chi_square - mean) / std_dev

    # Convert to p-value using normal distribution (two-tailed)
    # Using complementary error function approximation
    1.0 - normal_cdf(z_score)
  end

  def normal_cdf(z_score)
    # Standard normal cumulative distribution function approximation
    return 0.0 if z_score < -6
    return 1.0 if z_score > 6

    # Using Abramowitz and Stegun approximation
    sign = z_score.negative? ? -1 : 1
    z_score = z_score.abs

    # Constants for the approximation
    a1 = 0.254829592
    a2 = -0.284496736
    a3 = 1.421413741
    a4 = -1.453152027
    a5 = 1.061405429
    p = 0.3275911

    t = 1.0 / (1.0 + (p * z_score))
    error_function = 1.0 - (((((((((a5 * t) + a4) * t) + a3) * t) + a2) * t) + a1) * t * Math.exp(-z_score * z_score))

    result = 0.5 * (1 + (sign * error_function))
    result.clamp(0.0, 1.0)
  end

  def chi_square_critical_values
    # Pre-calculated critical values for chi-square distribution
    # Format: df => { alpha => critical_value }
    {
      1 => { 0.001 => 10.83, 0.01 => 6.635, 0.05 => 3.841, 0.10 => 2.706, 0.20 => 1.642, 0.30 => 1.074, 0.40 => 0.708,
             0.50 => 0.455, 0.60 => 0.275, 0.70 => 0.148, 0.80 => 0.064, 0.90 => 0.016, 0.95 => 0.004, 0.99 => 0.0002 },
      2 => { 0.001 => 13.82, 0.01 => 9.210, 0.05 => 5.991, 0.10 => 4.605, 0.20 => 3.219, 0.30 => 2.408, 0.40 => 1.833,
             0.50 => 1.386, 0.60 => 1.022, 0.70 => 0.713, 0.80 => 0.446, 0.90 => 0.211, 0.95 => 0.103, 0.99 => 0.020 },
      3 => { 0.001 => 16.27, 0.01 => 11.34, 0.05 => 7.815, 0.10 => 6.251, 0.20 => 4.642, 0.30 => 3.665, 0.40 => 2.946,
             0.50 => 2.366, 0.60 => 1.869, 0.70 => 1.424, 0.80 => 1.005, 0.90 => 0.584, 0.95 => 0.352, 0.99 => 0.115 },
      4 => { 0.001 => 18.47, 0.01 => 13.28, 0.05 => 9.488, 0.10 => 7.779, 0.20 => 5.989, 0.30 => 4.878, 0.40 => 4.045,
             0.50 => 3.357, 0.60 => 2.753, 0.70 => 2.195, 0.80 => 1.649, 0.90 => 1.064, 0.95 => 0.711, 0.99 => 0.297 },
      5 => { 0.001 => 20.52, 0.01 => 15.09, 0.05 => 11.07, 0.10 => 9.236, 0.20 => 7.289, 0.30 => 6.064, 0.40 => 5.132,
             0.50 => 4.351, 0.60 => 3.656, 0.70 => 3.000, 0.80 => 2.343, 0.90 => 1.610, 0.95 => 1.145, 0.99 => 0.554 },
      6 => { 0.001 => 22.46, 0.01 => 16.81, 0.05 => 12.59, 0.10 => 10.64, 0.20 => 8.558, 0.30 => 7.231, 0.40 => 6.211,
             0.50 => 5.348, 0.60 => 4.570, 0.70 => 3.828, 0.80 => 3.070, 0.90 => 2.204, 0.95 => 1.635, 0.99 => 0.872 },
      7 => { 0.001 => 24.32, 0.01 => 18.48, 0.05 => 14.07, 0.10 => 12.02, 0.20 => 9.803, 0.30 => 8.383, 0.40 => 7.283,
             0.50 => 6.346, 0.60 => 5.493, 0.70 => 4.671, 0.80 => 3.822, 0.90 => 2.833, 0.95 => 2.167, 0.99 => 1.239 },
      8 => { 0.001 => 26.12, 0.01 => 20.09, 0.05 => 15.51, 0.10 => 13.36, 0.20 => 11.03, 0.30 => 9.524, 0.40 => 8.351,
             0.50 => 7.344, 0.60 => 6.423, 0.70 => 5.527, 0.80 => 4.594, 0.90 => 3.490, 0.95 => 2.733, 0.99 => 1.646 },
      9 => { 0.001 => 27.88, 0.01 => 21.67, 0.05 => 16.92, 0.10 => 14.68, 0.20 => 12.24, 0.30 => 10.66, 0.40 => 9.414,
             0.50 => 8.343, 0.60 => 7.357, 0.70 => 6.393, 0.80 => 5.380, 0.90 => 4.168, 0.95 => 3.325, 0.99 => 2.088 },
      10 => { 0.001 => 29.59, 0.01 => 23.21, 0.05 => 18.31, 0.10 => 15.99, 0.20 => 13.44, 0.30 => 11.78, 0.40 => 10.47,
              0.50 => 9.342, 0.60 => 8.295, 0.70 => 7.267, 0.80 => 6.179, 0.90 => 4.865, 0.95 => 3.940, 0.99 => 2.558 }
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

  def calculate_f_distribution_p_value(f_statistic, df_numerator, df_denominator)
    return 1.0 if f_statistic.infinite? || f_statistic.nan?
    return 1.0 if f_statistic <= 0

    # Simplified F-distribution p-value calculation using critical values
    # This is an approximation for common cases
    f_critical_values

    # Find appropriate p-value by comparing with critical values
    alphas = [0.001, 0.01, 0.05, 0.10, 0.25, 0.50]

    alphas.each do |alpha|
      critical_value = interpolate_f_critical_value(df_numerator, df_denominator, alpha)
      return alpha if f_statistic <= critical_value
    end

    # If F-statistic is higher than all critical values, p < 0.001
    0.001
  end

  def f_critical_values
    # Simplified F-critical values for common df combinations at α = 0.05
    # Format: [df_numerator, df_denominator] => critical_value
    {
      [1, 1] => 161.4, [1, 2] => 18.51, [1, 3] => 10.13, [1, 4] => 7.71, [1, 5] => 6.61,
      [1, 10] => 4.96, [1, 20] => 4.35, [1, 30] => 4.17, [1, 40] => 4.08, [1, 60] => 4.00,
      [2, 1] => 199.5, [2, 2] => 19.00, [2, 3] => 9.55, [2, 4] => 6.94, [2, 5] => 5.79,
      [2, 10] => 4.10, [2, 20] => 3.49, [2, 30] => 3.32, [2, 40] => 3.23, [2, 60] => 3.15,
      [3, 1] => 215.7, [3, 2] => 19.16, [3, 3] => 9.28, [3, 4] => 6.59, [3, 5] => 5.41,
      [3, 10] => 3.71, [3, 20] => 3.10, [3, 30] => 2.92, [3, 40] => 2.84, [3, 60] => 2.76,
      [4, 1] => 224.6, [4, 2] => 19.25, [4, 3] => 9.12, [4, 4] => 6.39, [4, 5] => 5.19,
      [4, 10] => 3.48, [4, 20] => 2.87, [4, 30] => 2.69, [4, 40] => 2.61, [4, 60] => 2.53,
      [5, 1] => 230.2, [5, 2] => 19.30, [5, 3] => 9.01, [5, 4] => 6.26, [5, 5] => 5.05,
      [5, 10] => 3.33, [5, 20] => 2.71, [5, 30] => 2.53, [5, 40] => 2.45, [5, 60] => 2.37
    }
  end

  def interpolate_f_critical_value(df_num, df_den, alpha)
    # Simplified interpolation for F critical values
    # Returns approximate critical value for F(df_num, df_den) at given alpha
    base_critical = f_critical_values[[df_num, df_den]] ||
                    f_critical_values[[df_num, [df_den, 60].min]] ||
                    3.0 # Default fallback

    # Adjust for different alpha levels (rough approximation)
    if alpha <= 0.001
      base_critical * 2.5
    elsif alpha <= 0.01
      base_critical * 1.5
    elsif alpha <= 0.05
      base_critical
    elsif alpha <= 0.10
      base_critical * 0.7
    elsif alpha <= 0.25
      base_critical * 0.4
    else
      base_critical * 0.2
    end
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
