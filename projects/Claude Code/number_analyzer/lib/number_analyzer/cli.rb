# frozen_string_literal: true

require_relative '../number_analyzer'
require_relative 'file_reader'

# Command Line Interface for NumberAnalyzer
class NumberAnalyzer
  # Handles command-line argument parsing and validation for NumberAnalyzer
  class CLI
    def self.parse_arguments(argv = ARGV)
      # ファイルオプションをチェック
      file_index = find_file_option_index(argv)
      
      if file_index
        file_path = argv[file_index + 1]
        if file_path.nil? || file_path.start_with?('-')
          puts 'エラー: --fileオプションにはファイルパスを指定してください。'
          exit 1
        end
        
        begin
          FileReader.read_from_file(file_path)
        rescue => e
          puts "ファイル読み込みエラー: #{e.message}"
          exit 1
        end
      elsif argv.empty?
        # デフォルト配列を使用
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      else
        # コマンドライン引数から数値を取得
        parse_numeric_arguments(argv)
      end
    end

    private_class_method def self.find_file_option_index(argv)
      argv.each_with_index do |arg, index|
        return index if arg == '--file' || arg == '-f'
      end
      nil
    end

    private_class_method def self.parse_numeric_arguments(argv)
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
  numbers = NumberAnalyzer::CLI.parse_arguments
  analyzer = NumberAnalyzer.new(numbers)
  analyzer.calculate_statistics
end
