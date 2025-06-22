# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  def initialize(numbers)
    @numbers = numbers
  end

  def calculate_statistics
    total = @numbers.sum
    average = total.to_f / @numbers.length
    maximum = @numbers.max
    minimum = @numbers.min
    median_value = median
    mode_values = mode
    std_dev = standard_deviation

    display_results(total, average, maximum, minimum, median_value, mode_values, std_dev)
  end

  def median
    sorted = @numbers.sort
    length = sorted.length
    
    if length.odd?
      sorted[length / 2]
    else
      (sorted[length / 2 - 1] + sorted[length / 2]).to_f / 2
    end
  end

  def mode
    frequency = @numbers.tally
    max_frequency = frequency.values.max
    
    return [] if max_frequency == 1
    
    frequency.select { |_, count| count == max_frequency }.keys
  end

  def standard_deviation
    return 0 if @numbers.length <= 1
    
    mean = @numbers.sum.to_f / @numbers.length
    variance = @numbers.sum { |num| (num - mean) ** 2 } / @numbers.length
    Math.sqrt(variance)
  end

  private

  def display_results(total, average, maximum, minimum, median_value, mode_values, std_dev)
    puts "合計: #{total}"
    puts "平均: #{average}"
    puts "最大値: #{maximum}"
    puts "最小値: #{minimum}"
    puts "中央値: #{median_value}"
    puts "最頻値: #{format_mode(mode_values)}"
    puts "標準偏差: #{std_dev.round(2)}"
  end

  def format_mode(mode_values)
    return "なし" if mode_values.empty?
    mode_values.join(", ")
  end
end

# 実行部分
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
analyzer = NumberAnalyzer.new(numbers)
analyzer.calculate_statistics