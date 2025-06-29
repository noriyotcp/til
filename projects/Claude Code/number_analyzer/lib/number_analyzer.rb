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
end
