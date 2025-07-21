# frozen_string_literal: true

# BasicStats module containing fundamental statistical calculations
# 基本統計量の計算を提供するモジュール
module BasicStats
  # Calculate sum of all numbers
  # 全数値の合計を計算
  def sum
    @numbers.sum
  end

  # Calculate arithmetic mean (average)
  # 算術平均を計算
  def mean
    average_value
  end

  # Find the most frequently occurring value(s)
  # 最頻値を計算
  def mode
    frequency = @numbers.tally
    max_frequency = frequency.values.max

    return [] if max_frequency == 1

    frequency.select { |_, count| count == max_frequency }.keys
  end

  # Calculate population variance
  # 母分散を計算
  def variance
    return 0.0 if @numbers.length <= 1

    mean = average_value
    @numbers.sum { |num| (num - mean)**2 } / @numbers.length
  end

  # Calculate standard deviation
  # 標準偏差を計算
  def standard_deviation
    Math.sqrt(variance)
  end

  private

  # Calculate average value (mean)
  # 平均値を計算
  def average_value
    @numbers.sum.to_f / @numbers.length
  end
end
