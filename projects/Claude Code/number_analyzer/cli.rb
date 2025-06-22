# frozen_string_literal: true

require_relative 'number_analyzer'

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