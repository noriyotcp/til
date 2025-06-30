# frozen_string_literal: true

require_relative 'number_analyzer/statistics_presenter'
require_relative 'number_analyzer/statistics/basic_stats'
require_relative 'number_analyzer/statistics/math_utils'
require_relative 'number_analyzer/statistics/advanced_stats'
require_relative 'number_analyzer/statistics/correlation_stats'
require_relative 'number_analyzer/statistics/time_series_stats'
require_relative 'number_analyzer/statistics/hypothesis_testing'
require_relative 'number_analyzer/statistics/anova_stats'

# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  include BasicStats
  include AdvancedStats
  include CorrelationStats
  include TimeSeriesStats
  include HypothesisTesting
  include ANOVAStats

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
