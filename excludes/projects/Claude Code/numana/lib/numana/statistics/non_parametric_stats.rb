# frozen_string_literal: true

require_relative '../statistics/math_utils'

# ノンパラメトリック統計検定モジュール
module NonParametricStats
  def kruskal_wallis_test(*groups)
    validated_groups = validate_groups_for_kruskal_wallis(groups)
    return nil unless validated_groups

    params = {
      k: validated_groups.length,
      n_total: validated_groups.flatten.length,
      group_sizes: validated_groups.map(&:length)
    }

    all_values, rank_sums = calculate_kruskal_wallis_ranks(validated_groups, params[:k])
    h_statistic = calculate_h_statistic(rank_sums, params, all_values)
    degrees_of_freedom = params[:k] - 1
    p_value = calculate_chi_square_p_value(h_statistic, degrees_of_freedom)

    format_kruskal_wallis_result(h_statistic, p_value, degrees_of_freedom, params)
  end

  def mann_whitney_u_test(group1, group2)
    return nil unless mann_whitney_input_valid?(group1, group2)

    size1 = group1.length
    size2 = group2.length
    all_values, rank_sums = calculate_mann_whitney_ranks(group1, group2)
    u_stats = calculate_u_statistics(rank_sums, size1, size2)
    z_stats = calculate_mann_whitney_z_score(u_stats[:u_statistic], size1, size2, all_values)

    format_mann_whitney_result(u_stats, z_stats, size1, size2, rank_sums)
  end

  def friedman_test(*groups)
    validated_groups = validate_friedman_input(groups)
    return nil unless validated_groups

    num_conditions = validated_groups.length
    num_subjects = validated_groups.first.length
    rank_matrix = calculate_friedman_rank_matrix(validated_groups, num_subjects, num_conditions)
    rank_sums = calculate_friedman_rank_sums(rank_matrix, num_conditions, num_subjects)
    chi_square_statistic = calculate_friedman_statistic(rank_sums, num_subjects, num_conditions)
    chi_square_statistic = apply_friedman_tie_correction(chi_square_statistic, rank_matrix, num_subjects, num_conditions)

    degrees_of_freedom = num_conditions - 1
    p_value = calculate_chi_square_p_value(chi_square_statistic, degrees_of_freedom)

    format_friedman_result(chi_square_statistic, p_value, degrees_of_freedom, rank_sums, num_subjects, num_conditions)
  end

  def wilcoxon_signed_rank_test(before, after)
    return nil unless wilcoxon_input_valid?(before, after)

    differences = before.zip(after).map { |b, a| a - b }
    non_zero_diffs = differences.reject(&:zero?)
    n_effective = non_zero_diffs.length

    return format_wilcoxon_zero_difference_result(before.length) if n_effective.zero?

    abs_diffs = non_zero_diffs.map(&:abs)
    ranks = calculate_ranks_with_ties(abs_diffs)
    signed_ranks = non_zero_diffs.zip(ranks).map { |diff, rank| diff.positive? ? rank : -rank }

    w_stats = calculate_w_statistics(signed_ranks)
    z_stats = calculate_wilcoxon_z_score(w_stats[:w_statistic], n_effective, abs_diffs)

    format_wilcoxon_result(w_stats, z_stats, before.length, n_effective)
  end

  private

  def validate_groups_for_kruskal_wallis(groups)
    groups = groups.compact.reject { |g| g.is_a?(Array) && g.empty? }
    return nil if groups.length < 2
    return nil unless groups.all? { |g| g.is_a?(Array) && !g.empty? }

    groups
  end

  def calculate_kruskal_wallis_ranks(groups, num_groups)
    all_values_with_group_index = []
    groups.each_with_index do |group, group_idx|
      group.each { |value| all_values_with_group_index << [value, group_idx] }
    end

    sorted_values = all_values_with_group_index.sort_by(&:first)
    ranks = calculate_ranks_with_ties(sorted_values.map(&:first))

    rank_sums = Array.new(num_groups, 0.0)
    sorted_values.each_with_index do |(_value, group_idx), i|
      rank_sums[group_idx] += ranks[i]
    end

    [sorted_values.map(&:first), rank_sums]
  end

  def calculate_h_statistic(rank_sums, params, all_values)
    sum_rank_squares_over_n = rank_sums.each_with_index.sum do |rank_sum, i|
      (rank_sum**2) / params[:group_sizes][i].to_f
    end

    n_total = params[:n_total]
    h_statistic = ((12.0 / (n_total * (n_total + 1))) * sum_rank_squares_over_n) - (3 * (n_total + 1))

    apply_tie_correction_to_h(h_statistic, all_values)
  end

  def format_kruskal_wallis_result(h_statistic, p_value, degrees_of_freedom, params)
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
      degrees_of_freedom: degrees_of_freedom,
      significant: significant,
      interpretation: interpretation,
      group_sizes: params[:group_sizes],
      total_n: params[:n_total]
    }
  end

  def mann_whitney_input_valid?(group1, group2)
    return false if group1.nil? || group2.nil?
    return false unless group1.is_a?(Array) && group2.is_a?(Array)

    !group1.empty? && !group2.empty?
  end

  def calculate_mann_whitney_ranks(group1, group2)
    combined_data = group1.map { |value| [value, 1] } + group2.map { |value| [value, 2] }
    sorted_data = combined_data.sort_by(&:first)
    ranks = calculate_ranks_with_ties(sorted_data.map(&:first))

    r1 = 0.0
    r2 = 0.0
    sorted_data.each_with_index do |(_value, group_label), i|
      group_label == 1 ? r1 += ranks[i] : r2 += ranks[i]
    end

    [sorted_data.map(&:first), { r1: r1, r2: r2 }]
  end

  def calculate_u_statistics(rank_sums, size1, size2)
    r1 = rank_sums[:r1]
    r2 = rank_sums[:r2]
    u1 = (size1 * size2) + ((size1 * (size1 + 1)) / 2.0) - r1
    u2 = (size1 * size2) + ((size2 * (size2 + 1)) / 2.0) - r2
    { u1: u1, u2: u2, u_statistic: [u1, u2].min }
  end

  def calculate_mann_whitney_z_score(u_statistic, size1, size2, all_values)
    mean_u = (size1 * size2) / 2.0
    variance_u = calculate_mann_whitney_variance(size1, size2, all_values)
    return { z_statistic: 0, p_value: 1.0, effect_size: 0 } if variance_u.zero?

    z_statistic = calculate_z_score_with_continuity_correction(u_statistic, mean_u, variance_u, size1, size2)

    p_value = 2 * (1 - MathUtils.standard_normal_cdf(z_statistic.abs))
    effect_size = z_statistic.abs / Math.sqrt(size1 + size2)
    { z_statistic: z_statistic, p_value: p_value, effect_size: effect_size }
  end

  def calculate_z_score_with_continuity_correction(u_statistic, mean_u, variance_u, size1, size2)
    z_statistic = (u_statistic - mean_u) / Math.sqrt(variance_u)
    return z_statistic unless size1 >= 8 && size2 >= 8

    if u_statistic > mean_u
      (u_statistic - mean_u - 0.5) / Math.sqrt(variance_u)
    else
      (u_statistic - mean_u + 0.5) / Math.sqrt(variance_u)
    end
  end

  def format_mann_whitney_result(u_stats, z_stats, size1, size2, rank_sums)
    significant = z_stats[:p_value] < 0.05
    interpretation = if significant
                       'Statistically significant difference found between groups (distributions differ)'
                     else
                       'No statistically significant difference found between groups (no difference in distributions)'
                     end

    {
      test_type: 'Mann-Whitney U Test',
      u_statistic: u_stats[:u_statistic].round(6),
      u1: u_stats[:u1].round(6),
      u2: u_stats[:u2].round(6),
      z_statistic: z_stats[:z_statistic].round(6),
      p_value: z_stats[:p_value].round(6),
      significant: significant,
      interpretation: interpretation,
      effect_size: z_stats[:effect_size].round(6),
      group_sizes: [size1, size2],
      rank_sums: [rank_sums[:r1].round(2), rank_sums[:r2].round(2)],
      total_n: size1 + size2
    }
  end

  def validate_friedman_input(groups)
    groups = groups.compact.reject { |g| g.is_a?(Array) && g.empty? }
    return nil if groups.length < 3
    return nil unless groups.all? { |g| g.is_a?(Array) && !g.empty? }
    return nil unless groups.map(&:length).uniq.length == 1

    groups
  end

  def calculate_friedman_rank_matrix(groups, num_subjects, num_conditions)
    rank_matrix = Array.new(num_subjects) { Array.new(num_conditions) }
    (0...num_subjects).each do |subject|
      subject_scores = groups.map { |group| group[subject] }
      subject_ranks = calculate_ranks_with_ties(subject_scores)
      (0...num_conditions).each do |condition|
        rank_matrix[subject][condition] = subject_ranks[condition]
      end
    end
    rank_matrix
  end

  def calculate_friedman_rank_sums(rank_matrix, num_conditions, num_subjects)
    rank_sums = Array.new(num_conditions, 0.0)
    (0...num_conditions).each do |condition|
      rank_sums[condition] = (0...num_subjects).sum { |subject| rank_matrix[subject][condition] }
    end
    rank_sums
  end

  def calculate_friedman_statistic(rank_sums, num_subjects, num_conditions)
    sum_of_squared_rank_sums = rank_sums.sum { |rank_sum| rank_sum**2 }
    ((12.0 / (num_subjects * num_conditions * (num_conditions + 1))) * sum_of_squared_rank_sums) - (3 * num_subjects * (num_conditions + 1))
  end

  def format_friedman_result(chi_square_statistic, p_value, degrees_of_freedom, rank_sums, num_subjects, num_conditions)
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
      degrees_of_freedom: degrees_of_freedom,
      significant: significant,
      interpretation: interpretation,
      rank_sums: rank_sums.map { |sum| sum.round(2) },
      n_subjects: num_subjects,
      k_conditions: num_conditions,
      total_observations: num_subjects * num_conditions
    }
  end

  def wilcoxon_input_valid?(before, after)
    return false if before.nil? || after.nil?
    return false unless before.is_a?(Array) && after.is_a?(Array)
    return false if before.empty? || after.empty?

    before.length == after.length
  end

  def format_wilcoxon_zero_difference_result(num_pairs)
    {
      test_type: 'Wilcoxon Signed-Rank Test', w_statistic: 0, w_plus: 0, w_minus: 0,
      z_statistic: 0, p_value: 1.0, significant: false,
      interpretation: 'No significant difference found as all differences are zero',
      n_pairs: num_pairs, n_effective: 0, n_zeros: num_pairs
    }
  end

  def calculate_w_statistics(signed_ranks)
    w_plus = signed_ranks.select(&:positive?).sum
    w_minus = signed_ranks.select(&:negative?).map(&:abs).sum
    { w_plus: w_plus, w_minus: w_minus, w_statistic: [w_plus, w_minus].min }
  end

  def calculate_wilcoxon_z_score(w_statistic, n_effective, abs_diffs)
    mean_w = (n_effective * (n_effective + 1)) / 4.0
    variance_w = calculate_wilcoxon_variance(n_effective, abs_diffs)
    return { z_statistic: 0, p_value: 1.0, effect_size: 0 } if variance_w.zero?

    z_statistic = if w_statistic > mean_w
                    (w_statistic - mean_w - 0.5) / Math.sqrt(variance_w)
                  else
                    (w_statistic - mean_w + 0.5) / Math.sqrt(variance_w)
                  end

    p_value = 2 * (1 - MathUtils.standard_normal_cdf(z_statistic.abs))
    effect_size = z_statistic.abs / Math.sqrt(n_effective)
    { z_statistic: z_statistic, p_value: p_value, effect_size: effect_size }
  end

  def format_wilcoxon_result(w_stats, z_stats, n_pairs, n_effective)
    significant = z_stats[:p_value] < 0.05
    interpretation = if significant
                       'Statistically significant difference found between paired data'
                     else
                       'No statistically significant difference found between paired data'
                     end

    {
      test_type: 'Wilcoxon Signed-Rank Test',
      w_statistic: w_stats[:w_statistic].round(6),
      w_plus: w_stats[:w_plus].round(6),
      w_minus: w_stats[:w_minus].round(6),
      z_statistic: z_stats[:z_statistic].round(6),
      p_value: z_stats[:p_value].round(6),
      significant: significant,
      interpretation: interpretation,
      effect_size: z_stats[:effect_size].round(6),
      n_pairs: n_pairs,
      n_effective: n_effective,
      n_zeros: n_pairs - n_effective
    }
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
    basic_variance = (n_pairs * (n_pairs + 1) * ((2 * n_pairs) + 1)) / 24.0
    tie_correction = calculate_tie_correction(abs_diffs)

    return basic_variance if tie_correction.zero?

    (basic_variance - (tie_correction / 48.0))
  end

  def calculate_tie_correction(values)
    value_counts = values.tally
    value_counts.values.sum do |count|
      count > 1 ? count * ((count**2) - 1) : 0
    end
  end

  def apply_friedman_tie_correction(chi_square_statistic, rank_matrix, num_subjects, num_conditions)
    # Calculate tie correction for Friedman test
    # For each subject (row), count ties across their rankings
    total_tie_correction = 0.0

    (0...num_subjects).each do |subject|
      subject_ranks = (0...num_conditions).map { |condition| rank_matrix[subject][condition] }

      # Count occurrences of each rank for this subject
      rank_counts = subject_ranks.tally

      # Calculate tie correction for this subject: Σ(ti³ - ti)
      subject_tie_correction = rank_counts.values.sum { |count| (count**3) - count }
      total_tie_correction += subject_tie_correction
    end

    # Apply correction if there are ties
    # Corrected χ² = χ² / [1 - (Σ(ti³ - ti)) / (n * k * (k² - 1))]
    if total_tie_correction.positive?
      denominator = num_subjects * num_conditions * ((num_conditions**2) - 1)
      correction_factor = 1.0 - (total_tie_correction / denominator)

      # Avoid division by zero
      return chi_square_statistic if correction_factor <= 0

      chi_square_statistic / correction_factor
    else
      chi_square_statistic
    end
  end
end
