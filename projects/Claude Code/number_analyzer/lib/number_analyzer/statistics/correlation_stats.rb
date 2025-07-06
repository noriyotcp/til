# frozen_string_literal: true

# Module providing statistical functions for correlation analysis
module CorrelationStats
  # Calculate Pearson correlation coefficient
  # @param other_dataset [Array<Numeric>] Dataset to compare against
  # @return [Float, nil] Correlation coefficient (range -1 to 1), nil if calculation not possible
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

  # Interpret correlation coefficient strength
  # @param correlation_value [Float] Correlation coefficient
  # @return [String] Description of correlation strength in English
  def interpret_correlation(correlation_value)
    abs_value = correlation_value.abs
    case abs_value
    when 0.8..1.0
      correlation_value.positive? ? 'Strong positive correlation' : 'Strong negative correlation'
    when 0.5..0.8
      correlation_value.positive? ? 'Moderate positive correlation' : 'Moderate negative correlation'
    when 0.3..0.5
      correlation_value.positive? ? 'Weak positive correlation' : 'Weak negative correlation'
    else
      'No correlation'
    end
  end
end
