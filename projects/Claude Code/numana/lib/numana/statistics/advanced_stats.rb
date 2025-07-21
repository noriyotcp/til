# frozen_string_literal: true

# Advanced statistical analysis functions
module AdvancedStats
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
      q2: percentile(50),
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

    mean_value = mean
    std_dev = standard_deviation

    # 標準偏差が0の場合は、全ての値を50とする
    return Array.new(@numbers.length, 50.0) if std_dev.zero?

    @numbers.map do |number|
      ((((number - mean_value) / std_dev) * 10) + 50).round(2)
    end
  end
end
