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

    display_results(total, average, maximum, minimum)
  end

  private

  def display_results(total, average, maximum, minimum)
    puts "合計: #{total}"
    puts "平均: #{average}"
    puts "最大値: #{maximum}"
    puts "最小値: #{minimum}"
  end
end

# 実行部分
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
analyzer = NumberAnalyzer.new(numbers)
analyzer.calculate_statistics