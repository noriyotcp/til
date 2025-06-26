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
      outlier_values: outliers
    }

    display_results(stats)
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

  def percentile(p)
    return nil if @numbers.empty?
    return @numbers.first if @numbers.length == 1
    
    sorted = @numbers.sort
    rank = (p / 100.0) * (sorted.length - 1)
    
    lower_index = rank.floor
    upper_index = rank.ceil
    
    if lower_index == upper_index
      sorted[lower_index]
    else
      weight = rank - lower_index
      sorted[lower_index] * (1 - weight) + sorted[upper_index] * weight
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
    
    return [] if iqr == 0  # 全て同じ値の場合
    
    lower_bound = q[:q1] - 1.5 * iqr
    upper_bound = q[:q3] + 1.5 * iqr
    
    @numbers.select { |num| num < lower_bound || num > upper_bound }
  end

  def standard_deviation
    Math.sqrt(variance)
  end

  private

  def average_value
    @numbers.sum.to_f / @numbers.length
  end

  def display_results(stats)
    puts "合計: #{stats[:total]}"
    puts "平均: #{stats[:average]}"
    puts "最大値: #{stats[:maximum]}"
    puts "最小値: #{stats[:minimum]}"
    puts "中央値: #{stats[:median_value]}"
    puts "分散: #{stats[:variance].round(2)}"
    puts "最頻値: #{format_mode(stats[:mode_values])}"
    puts "標準偏差: #{stats[:std_dev].round(2)}"
    puts "四分位範囲(IQR): #{stats[:iqr]&.round(2) || 'なし'}"
    puts "外れ値: #{format_outliers(stats[:outlier_values])}"
  end

  def format_mode(mode_values)
    return 'なし' if mode_values.empty?

    mode_values.join(', ')
  end

  def format_outliers(outlier_values)
    return 'なし' if outlier_values.empty?

    outlier_values.join(', ')
  end
end

