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
end
