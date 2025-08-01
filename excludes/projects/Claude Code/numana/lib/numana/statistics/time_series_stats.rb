# frozen_string_literal: true

# TimeSeriesStats module provides time series analysis functionality
# for the NumberAnalyzer statistical analysis tool
module TimeSeriesStats
  # Analyzes linear trend in the dataset
  # Returns slope, intercept, R-squared, and direction
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

  # Calculates moving average with specified window size
  def moving_average(window_size)
    return nil if @numbers.empty? || window_size <= 0 || window_size > @numbers.length

    result = []
    (@numbers.length - window_size + 1).times do |i|
      window_sum = @numbers[i, window_size].sum
      result << (window_sum.to_f / window_size)
    end

    result
  end

  # Calculates period-over-period growth rates
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

  # Calculates compound annual growth rate (CAGR)
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

  # Calculates average growth rate excluding infinite values
  def average_growth_rate
    rates = growth_rates
    return nil if rates.empty?

    # Filter out infinite values for average calculation
    finite_rates = rates.reject(&:infinite?)
    return nil if finite_rates.empty?

    finite_rates.sum / finite_rates.length
  end

  # Performs seasonal decomposition analysis
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

  # Automatically detects seasonal period in the data
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

  # Returns the seasonal strength of the data
  def seasonal_strength
    decomposition = seasonal_decomposition
    return 0.0 if decomposition.nil?

    decomposition[:seasonal_strength]
  end

  private

  # Calculates trend line using least squares method
  # rubocop:disable Metrics/AbcSize
  def calculate_trend_line(x_values)
    return [nil, nil] if x_values.length != @numbers.length

    n = @numbers.length
    sum_x = x_values.sum
    sum_y = @numbers.sum
    sum_xy = x_values.zip(@numbers).map { |x, y| x * y }.sum
    sum_x_squared = x_values.map { |x| x * x }.sum

    denominator = (n * sum_x_squared) - (sum_x * sum_x)
    return [nil, nil] if denominator.zero?

    slope = ((n * sum_xy) - (sum_x * sum_y)).to_f / denominator
    intercept = (sum_y - (slope * sum_x)).to_f / n

    [slope, intercept]
  end
  # rubocop:enable Metrics/AbcSize

  # Calculates coefficient of determination (R-squared)
  def calculate_r_squared(x_values, slope, intercept)
    y_mean = @numbers.sum.to_f / @numbers.length

    ss_tot = @numbers.sum { |y| (y - y_mean)**2 }
    return 1.0 if ss_tot.zero?

    predicted_values = x_values.map { |x| (slope * x) + intercept }
    ss_res = @numbers.zip(predicted_values).sum { |actual, predicted| (actual - predicted)**2 }

    1.0 - (ss_res / ss_tot)
  end

  # Determines trend direction from slope
  def determine_trend_direction(slope)
    if slope > 0.01
      'Upward trend'
    elsif slope < -0.01
      'Downward trend'
    else
      'Flat trend'
    end
  end

  # Calculates seasonal indices for each position in the period
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

  # Calculates trend component using moving average
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

  # Calculates seasonal strength as variance ratio
  def calculate_seasonal_strength(seasonal_indices)
    return 0.0 if invalid_seasonal_indices?(seasonal_indices)
    return 0.0 if seasonal_indices_show_trend?(seasonal_indices)

    seasonal_variance = calculate_seasonal_variance(seasonal_indices)
    overall_variance = variance

    return 0.0 if overall_variance.zero?

    strength = (seasonal_variance / overall_variance).round(4)
    strength > 0.05 ? strength : 0.0
  end

  # Validates seasonal indices array
  def invalid_seasonal_indices?(seasonal_indices)
    seasonal_indices.empty? || seasonal_indices.length < 2
  end

  # Calculates variance of seasonal indices
  def calculate_seasonal_variance(seasonal_indices)
    mean_seasonal = seasonal_indices.sum.to_f / seasonal_indices.length
    seasonal_indices.sum { |si| (si - mean_seasonal)**2 } / seasonal_indices.length
  end

  # Checks if seasonal indices show a consistent trend pattern
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
