# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  def initialize(numbers)
    @numbers = numbers
  end

  def calculate_statistics
    stats = {
      total: @numbers.sum,
      average: @numbers.sum.to_f / @numbers.length,
      maximum: @numbers.max,
      minimum: @numbers.min,
      median_value: median,
      mode_values: mode,
      std_dev: standard_deviation
    }

    display_results(stats)
  end

  def median
    sorted = @numbers.sort
    length = sorted.length

    if length.odd?
      sorted[length / 2]
    else
      (sorted[(length / 2) - 1] + sorted[length / 2]).to_f / 2
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
    variance = @numbers.sum { |num| (num - mean)**2 } / @numbers.length
    Math.sqrt(variance)
  end

  private

  def display_results(stats)
    puts "合計: #{stats[:total]}"
    puts "平均: #{stats[:average]}"
    puts "最大値: #{stats[:maximum]}"
    puts "最小値: #{stats[:minimum]}"
    puts "中央値: #{stats[:median_value]}"
    puts "最頻値: #{format_mode(stats[:mode_values])}"
    puts "標準偏差: #{stats[:std_dev].round(2)}"
  end

  def format_mode(mode_values)
    return 'なし' if mode_values.empty?

    mode_values.join(', ')
  end
end

# Command Line Interface for NumberAnalyzer
class CLI
  def self.parse_arguments(argv = ARGV)
    if argv.empty?
      # デフォルト配列を使用
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    else
      # コマンドライン引数から数値を取得
      invalid_args = []
      numbers = argv.map do |arg|
        Float(arg)
      rescue ArgumentError
        invalid_args << arg
        nil
      end.compact

      unless invalid_args.empty?
        puts "エラー: 無効な引数が見つかりました: #{invalid_args.join(', ')}"
        puts '数値のみを入力してください。'
        exit 1
      end

      if numbers.empty?
        puts 'エラー: 有効な数値が見つかりませんでした。'
        exit 1
      end

      numbers
    end
  end
end

# 実行部分（スクリプトとして実行された場合のみ）
if __FILE__ == $PROGRAM_NAME
  numbers = CLI.parse_arguments
  analyzer = NumberAnalyzer.new(numbers)
  analyzer.calculate_statistics
end