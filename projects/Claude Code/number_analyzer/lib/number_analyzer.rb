# frozen_string_literal: true

require_relative 'number_analyzer/statistics_presenter'

# 数値配列の統計を計算するプログラム
class NumberAnalyzer
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

  def mode
    frequency = @numbers.tally
    max_frequency = frequency.values.max

    return [] if max_frequency == 1

    frequency.select { |_, count| count == max_frequency }.keys
  end

  def variance
    return 0.0 if @numbers.length <= 1

    mean = average_value
    @numbers.sum { |num| (num - mean)**2 } / @numbers.length
  end

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

  def standard_deviation = Math.sqrt(variance)

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

  private

  def average_value = @numbers.sum.to_f / @numbers.length

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
end
