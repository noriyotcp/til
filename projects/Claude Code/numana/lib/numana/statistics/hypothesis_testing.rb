# frozen_string_literal: true

require_relative 'math_utils'

# HypothesisTesting module provides statistical hypothesis testing functionality
# for the NumberAnalyzer statistical analysis tool
module HypothesisTesting
  # Performs t-test analysis for comparing means
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

  # Calculates confidence interval for population mean
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

  # Performs chi-square test for independence or goodness-of-fit
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

  private

  # Performs independent samples t-test (Welch's t-test)
  def independent_t_test(other_data)
    return nil if invalid_data_for_independent_test?(other_data)

    stats1 = calculate_sample_statistics(@numbers)
    stats2 = calculate_sample_statistics(other_data)

    welch_test_result(stats1, stats2)
  end

  # Performs paired samples t-test
  def paired_t_test(other_data)
    return nil if invalid_data_for_paired_test?(other_data)

    differences = calculate_paired_differences(other_data)
    return nil if differences.length < 2

    paired_test_result(differences)
  end

  # Performs one-sample t-test
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

  # Calculates confidence interval for population mean
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

  # Performs chi-square test for independence
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
    warning = expected_frequencies_valid ? nil : 'Warning: Some cells have expected frequencies below 5. Results may be unreliable.'

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

  # Performs chi-square goodness-of-fit test
  def chi_square_goodness_of_fit_test(expected_frequencies)
    observed_frequencies = @numbers

    # Handle uniform distribution assumption
    if expected_frequencies.nil?
      total = observed_frequencies.sum
      categories = observed_frequencies.length
      expected_frequencies = Array.new(categories, total.to_f / categories)
    end

    # Validate input dimensions
    raise ArgumentError, 'Observed and expected frequencies must have same length' if observed_frequencies.length != expected_frequencies.length

    return nil if observed_frequencies.empty?

    # Validate expected frequency conditions
    expected_frequencies_valid = validate_expected_frequencies?(expected_frequencies)
    warning = expected_frequencies_valid ? nil : 'Warning: Some categories have expected frequencies below 5. Results may be unreliable.'

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

  # Helper methods for t-test calculations
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

  def calculate_paired_differences(other_data)
    @numbers.zip(other_data).map { |a, b| a - b }
  end

  def welch_test_result(stats1, stats2)
    standard_error = Math.sqrt((stats1[:variance] / stats1[:n]) + (stats2[:variance] / stats2[:n]))
    return nil if standard_error.zero?

    t_statistic = (stats1[:mean] - stats2[:mean]) / standard_error
    df = welch_degrees_of_freedom(stats1[:variance], stats1[:n], stats2[:variance], stats2[:n])
    p_value = calculate_two_tailed_p_value(t_statistic, df)

    {
      test_type: 'independent',
      t_statistic: t_statistic.round(10),
      degrees_of_freedom: df.round(10),
      p_value: p_value.round(10),
      group1_mean: stats1[:mean].round(10),
      group2_mean: stats2[:mean].round(10),
      mean_difference: (stats1[:mean] - stats2[:mean]).round(10),
      standard_error: standard_error.round(10),
      n1: stats1[:n],
      n2: stats2[:n],
      significant: p_value < 0.05
    }
  end

  def paired_test_result(differences)
    n = differences.length
    mean_diff = differences.sum.to_f / n
    var_diff = differences.sum { |d| (d - mean_diff)**2 } / (n - 1)
    se_diff = Math.sqrt(var_diff / n)

    return nil if se_diff.zero?

    t_statistic = mean_diff / se_diff
    df = n - 1
    p_value = calculate_two_tailed_p_value(t_statistic, df)

    {
      test_type: 'paired',
      t_statistic: t_statistic.round(10),
      degrees_of_freedom: df,
      p_value: p_value.round(10),
      mean_difference: mean_diff.round(10),
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
      p_one_tail = 1.0 - MathUtils.standard_normal_cdf(z_score)
    else
      # Simple approximation for small samples
      # This is not as accurate as proper t-distribution but provides reasonable estimates
      p_one_tail = MathUtils.approximate_t_distribution_cdf(abs_t, degrees_of_freedom)
    end

    # Two-tailed test
    2.0 * p_one_tail
  end

  # Helper methods for confidence intervals
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

  # Helper methods for chi-square tests
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

    0.001
  end

  def calculate_chi_square_p_value_normal_approximation(chi_square, degrees_of_freedom)
    # Wilson-Hilferty transformation for large degrees of freedom
    h = 2.0 / (9.0 * degrees_of_freedom)
    z = (((chi_square / degrees_of_freedom)**(1.0 / 3.0)) - (1.0 - h)) / Math.sqrt(h)

    # Use standard normal distribution to find p-value
    1.0 - MathUtils.standard_normal_cdf(z)
  end

  def chi_square_critical_values
    # Critical values for chi-square distribution
    # Format: degrees_of_freedom => { alpha => critical_value }
    {
      1 => { 0.99 => 0.000, 0.95 => 0.004, 0.90 => 0.016, 0.80 => 0.064, 0.70 => 0.148,
             0.60 => 0.275, 0.50 => 0.455, 0.40 => 0.708, 0.30 => 1.074, 0.20 => 1.642,
             0.10 => 2.706, 0.05 => 3.841, 0.01 => 6.635 },
      2 => { 0.99 => 0.020, 0.95 => 0.103, 0.90 => 0.211, 0.80 => 0.446, 0.70 => 0.713,
             0.60 => 1.022, 0.50 => 1.386, 0.40 => 1.833, 0.30 => 2.408, 0.20 => 3.219,
             0.10 => 4.605, 0.05 => 5.991, 0.01 => 9.210 },
      3 => { 0.99 => 0.115, 0.95 => 0.352, 0.90 => 0.584, 0.80 => 1.005, 0.70 => 1.424,
             0.60 => 1.869, 0.50 => 2.366, 0.40 => 2.946, 0.30 => 3.665, 0.20 => 4.642,
             0.10 => 6.251, 0.05 => 7.815, 0.01 => 11.345 },
      4 => { 0.99 => 0.297, 0.95 => 0.711, 0.90 => 1.064, 0.80 => 1.649, 0.70 => 2.195,
             0.60 => 2.753, 0.50 => 3.357, 0.40 => 4.045, 0.30 => 4.878, 0.20 => 5.989,
             0.10 => 7.779, 0.05 => 9.488, 0.01 => 13.277 },
      5 => { 0.99 => 0.554, 0.95 => 1.145, 0.90 => 1.610, 0.80 => 2.343, 0.70 => 3.000,
             0.60 => 3.655, 0.50 => 4.351, 0.40 => 5.132, 0.30 => 6.064, 0.20 => 7.289,
             0.10 => 9.236, 0.05 => 11.070, 0.01 => 15.086 }
      # Add more degrees of freedom as needed
    }
  end
end
