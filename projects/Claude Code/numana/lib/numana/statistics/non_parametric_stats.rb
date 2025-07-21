# frozen_string_literal: true

require_relative '../statistics/math_utils'

# ノンパラメトリック統計検定モジュール
module NonParametricStats
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
                       'Statistically significant difference found between groups (medians are not equal)'
                     else
                       'No statistically significant difference found between groups (medians are considered equal)'
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
                       'Statistically significant difference found between groups (distributions differ)'
                     else
                       'No statistically significant difference found between groups (no difference in distributions)'
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

  def friedman_test(*groups)
    # Validate input - need at least 3 related groups (repeated measures)
    groups = groups.compact
    groups = groups.reject { |group| group.is_a?(Array) && group.empty? }

    return nil if groups.length < 3

    # Ensure each group has the same length (repeated measures requirement)
    # and contains valid numeric data
    groups.each do |group|
      return nil unless group.is_a?(Array)
      return nil if group.empty?
    end

    # Check for equal group sizes (requirement for repeated measures design)
    group_sizes = groups.map(&:length)
    return nil unless group_sizes.uniq.length == 1

    # Calculate basic parameters
    k = groups.length # number of conditions (treatments)
    n = groups.first.length # number of subjects (blocks)

    # Create a matrix for ranking: each row is a subject, each column is a condition
    # We need to rank each subject's scores across conditions
    rank_matrix = Array.new(n) { Array.new(k) }

    # For each subject (row), rank their scores across all conditions (columns)
    (0...n).each do |subject|
      subject_scores = groups.map { |group| group[subject] }
      subject_ranks = calculate_ranks_with_ties(subject_scores)

      (0...k).each do |condition|
        rank_matrix[subject][condition] = subject_ranks[condition]
      end
    end

    # Calculate rank sums for each condition (column sums)
    rank_sums = Array.new(k, 0.0)
    (0...k).each do |condition|
      rank_sums[condition] = (0...n).sum { |subject| rank_matrix[subject][condition] }
    end

    # Calculate Friedman test statistic
    # χ² = [12/(n*k*(k+1))] * [Σ(Rj²)] - 3*n*(k+1)
    # where Rj is the rank sum for condition j
    sum_of_squared_rank_sums = rank_sums.sum { |rank_sum| rank_sum**2 }

    chi_square_statistic = ((12.0 / (n * k * (k + 1))) * sum_of_squared_rank_sums) - (3 * n * (k + 1))

    # Apply tie correction if there are ties within subjects
    chi_square_statistic = apply_friedman_tie_correction(chi_square_statistic, rank_matrix, n, k)

    # Degrees of freedom
    df = k - 1

    # Calculate p-value using chi-square distribution
    p_value = calculate_chi_square_p_value(chi_square_statistic, df)

    # Determine significance and interpretation
    significant = p_value < 0.05
    interpretation = if significant
                       'Statistically significant difference found between conditions (condition effect in repeated measures)'
                     else
                       'No statistically significant difference found between conditions (no condition effect in repeated measures)'
                     end

    {
      test_type: 'Friedman Test',
      chi_square_statistic: chi_square_statistic.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: df,
      significant: significant,
      interpretation: interpretation,
      rank_sums: rank_sums.map { |sum| sum.round(2) },
      n_subjects: n,
      k_conditions: k,
      total_observations: n * k
    }
  end

  def wilcoxon_signed_rank_test(before, after)
    # Validate input - need paired data of same length
    return nil if before.nil? || after.nil?
    return nil unless before.is_a?(Array) && after.is_a?(Array)
    return nil if before.empty? || after.empty?
    return nil if before.length != after.length

    n = before.length

    # Calculate differences for each pair
    differences = before.zip(after).map { |b, a| a - b }

    # Remove zero differences (they don't contribute to the test)
    non_zero_diffs = differences.reject(&:zero?)
    n_effective = non_zero_diffs.length

    # If all differences are zero, no significant difference
    if n_effective.zero?
      return {
        test_type: 'Wilcoxon Signed-Rank Test',
        w_statistic: 0,
        w_plus: 0,
        w_minus: 0,
        z_statistic: 0,
        p_value: 1.0,
        significant: false,
        interpretation: 'No significant difference found as all differences are zero',
        n_pairs: n,
        n_effective: 0,
        n_zeros: n
      }
    end

    # Calculate absolute values of differences
    abs_diffs = non_zero_diffs.map(&:abs)

    # Rank the absolute differences
    ranks = calculate_ranks_with_ties(abs_diffs)

    # Calculate signed ranks
    signed_ranks = non_zero_diffs.zip(ranks).map do |diff, rank|
      diff.positive? ? rank : -rank
    end

    # Calculate W+ and W- (sum of positive and negative ranks)
    w_plus = signed_ranks.select(&:positive?).sum
    w_minus = signed_ranks.select(&:negative?).map(&:abs).sum

    # Test statistic is the smaller of W+ and W-
    w_statistic = [w_plus, w_minus].min

    # Calculate mean and variance for normal approximation
    mean_w = (n_effective * (n_effective + 1)) / 4.0

    # Calculate variance with tie correction
    variance_w = calculate_wilcoxon_variance(n_effective, abs_diffs)

    # Calculate z-statistic with continuity correction
    z_statistic = if w_statistic > mean_w
                    (w_statistic - mean_w - 0.5) / Math.sqrt(variance_w)
                  else
                    (w_statistic - mean_w + 0.5) / Math.sqrt(variance_w)
                  end

    # Two-tailed p-value
    p_value = 2 * (1 - MathUtils.standard_normal_cdf(z_statistic.abs))

    # Calculate effect size (r = z / sqrt(n))
    effect_size = z_statistic.abs / Math.sqrt(n_effective)

    # Determine significance and interpretation
    significant = p_value < 0.05
    interpretation = if significant
                       'Statistically significant difference found between paired data'
                     else
                       'No statistically significant difference found between paired data'
                     end

    {
      test_type: 'Wilcoxon Signed-Rank Test',
      w_statistic: w_statistic.round(6),
      w_plus: w_plus.round(6),
      w_minus: w_minus.round(6),
      z_statistic: z_statistic.round(6),
      p_value: p_value.round(6),
      significant: significant,
      interpretation: interpretation,
      effect_size: effect_size.round(6),
      n_pairs: n,
      n_effective: n_effective,
      n_zeros: n - n_effective
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

      # Find all values that are tied with the current value
      tie_end += 1 while tie_end < sorted_with_index.length && sorted_with_index[tie_end][0] == current_value

      # Calculate average rank for tied values
      # Ranks are 1-indexed, so add 1 to indices
      average_rank = (tie_start + tie_end + 1).to_f / 2

      # Assign average rank to all tied values
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

  def calculate_wilcoxon_variance(n_pairs, abs_diffs)
    # Basic variance without tie correction
    basic_variance = (n_pairs * (n_pairs + 1) * ((2 * n_pairs) + 1)) / 24.0

    # Apply tie correction
    value_counts = abs_diffs.tally
    tie_correction = value_counts.values.sum do |count|
      if count > 1
        count * ((count**2) - 1)
      else
        0
      end
    end

    # Corrected variance: σ²W = [n(n+1)(2n+1) - Σ(ti(ti²-1)/2)] / 24
    if tie_correction.positive?
      (((n * (n + 1) * ((2 * n) + 1)) - (tie_correction / 2.0)) / 24.0)
    else
      basic_variance
    end
  end

  def apply_friedman_tie_correction(chi_square_statistic, rank_matrix, n_subjects, k_conditions)
    # Calculate tie correction for Friedman test
    # For each subject (row), count ties across their rankings
    total_tie_correction = 0.0

    (0...n_subjects).each do |subject|
      subject_ranks = (0...k_conditions).map { |condition| rank_matrix[subject][condition] }

      # Count occurrences of each rank for this subject
      rank_counts = subject_ranks.tally

      # Calculate tie correction for this subject: Σ(ti³ - ti)
      subject_tie_correction = rank_counts.values.sum { |count| (count**3) - count }
      total_tie_correction += subject_tie_correction
    end

    # Apply correction if there are ties
    # Corrected χ² = χ² / [1 - (Σ(ti³ - ti)) / (n * k * (k² - 1))]
    if total_tie_correction.positive?
      denominator = n_subjects * k_conditions * ((k_conditions**2) - 1)
      correction_factor = 1.0 - (total_tie_correction / denominator)

      # Avoid division by zero
      return chi_square_statistic if correction_factor <= 0

      chi_square_statistic / correction_factor
    else
      chi_square_statistic
    end
  end
end
