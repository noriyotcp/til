# frozen_string_literal: true

require 'English'
require_relative '../../lib/number_analyzer/cli'

RSpec.describe NumberAnalyzer::CLI do
  let(:script_path) { File.join(__dir__, '..', '..', 'lib', 'number_analyzer', 'cli.rb') }

  describe 'CLI.parse_arguments' do
    context 'with no arguments' do
      it 'returns default array' do
        result = NumberAnalyzer::CLI.parse_arguments([])
        expect(result).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
      end
    end

    context 'with valid integer arguments' do
      it 'parses integers correctly' do
        result = NumberAnalyzer::CLI.parse_arguments(%w[1 2 3 4 5])
        expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0])
      end
    end

    context 'with valid float arguments' do
      it 'parses floats correctly' do
        result = NumberAnalyzer::CLI.parse_arguments(['1.5', '2.7', '3.2'])
        expect(result).to eq([1.5, 2.7, 3.2])
      end
    end

    context 'with mixed valid arguments' do
      it 'parses mixed integers and floats' do
        result = NumberAnalyzer::CLI.parse_arguments(['1', '2.5', '3', '4.7'])
        expect(result).to eq([1.0, 2.5, 3.0, 4.7])
      end
    end

    context 'with invalid arguments' do
      it 'exits with error message for non-numeric input' do
        expect { NumberAnalyzer::CLI.parse_arguments(%w[1 abc 3]) }
          .to output(/エラー: 無効な引数が見つかりました: abc/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'exits with error message for all invalid input' do
        expect { NumberAnalyzer::CLI.parse_arguments(%w[abc def]) }
          .to output(/エラー: 無効な引数が見つかりました: abc, def/).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end

  describe 'CLI file option' do
    it 'parses --file option correctly' do
      require 'tempfile'

      Tempfile.create(['test', '.csv']) do |file|
        file.write("numbers\n1\n2\n3")
        file.rewind

        result = NumberAnalyzer::CLI.parse_arguments(['--file', file.path])
        expect(result).to eq([1.0, 2.0, 3.0])
      end
    end

    it 'parses -f option correctly' do
      require 'tempfile'

      Tempfile.create(['test', '.json']) do |file|
        file.write('[4, 5, 6]')
        file.rewind

        result = NumberAnalyzer::CLI.parse_arguments(['-f', file.path])
        expect(result).to eq([4.0, 5.0, 6.0])
      end
    end

    it 'exits with error when file path is missing after --file' do
      expect do
        NumberAnalyzer::CLI.parse_arguments(['--file'])
      end.to output(/エラー: --fileオプションにはファイルパスを指定してください/).to_stdout
                                                        .and raise_error(SystemExit)
    end

    it 'exits with error when file does not exist' do
      expect do
        NumberAnalyzer::CLI.parse_arguments(['--file', '/nonexistent/file.csv'])
      end.to output(/ファイル読み込みエラー/).to_stdout
                                  .and raise_error(SystemExit)
    end
  end

  describe 'CLI integration' do
    it 'runs with default values when no arguments provided' do
      output = `ruby "#{script_path}"`
      expect(output).to include('合計: 55')
      expect(output).to include('平均: 5.5')
      expect(output).to include('中央値: 5.5')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'runs with custom values when arguments provided' do
      output = `ruby "#{script_path}" 1 2 3 4 5`
      expect(output).to include('合計: 15')
      expect(output).to include('平均: 3')
      expect(output).to include('中央値: 3')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'handles decimal input correctly' do
      output = `ruby "#{script_path}" 1.5 2.7 3.2`
      expect(output).to include('合計: 7.4')
      expect(output).to include('中央値: 2.7')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'exits with error for invalid input' do
      output = `ruby "#{script_path}" 1 2 abc 4 2>&1`
      expect(output).to include('エラー: 無効な引数が見つかりました: abc')
      expect($CHILD_STATUS.success?).to be false
    end

    it 'runs with file input using --file option' do
      require 'tempfile'

      Tempfile.create(['test', '.csv']) do |file|
        file.write("numbers\n10\n20\n30")
        file.rewind

        output = `ruby "#{script_path}" --file "#{file.path}"`
        expect(output).to include('合計: 60')
        expect(output).to include('平均: 20')
        expect(output).to include('中央値: 20')
        expect($CHILD_STATUS.success?).to be true
      end
    end

    it 'runs with fixture CSV file' do
      fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
      output = `ruby "#{script_path}" --file "#{fixture_path}"`
      expect(output).to include('合計: 205')
      expect(output).to include('平均: 20.5')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'runs with fixture JSON file' do
      fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.json')
      output = `ruby "#{script_path}" -f "#{fixture_path}"`
      expect(output).to include('合計: 550')
      expect(output).to include('平均: 55')
      expect($CHILD_STATUS.success?).to be true
    end
  end

  describe 'CLI.run with subcommands' do
    context 'median subcommand' do
      it 'returns median value' do
        expect { NumberAnalyzer::CLI.run(%w[median 1 2 3 4 5]) }
          .to output("3.0\n").to_stdout
      end

      it 'handles even number of values' do
        expect { NumberAnalyzer::CLI.run(%w[median 1 2 3 4]) }
          .to output("2.5\n").to_stdout
      end
    end

    context 'mean subcommand' do
      it 'returns mean value' do
        expect { NumberAnalyzer::CLI.run(%w[mean 1 2 3 4 5]) }
          .to output("3.0\n").to_stdout
      end

      it 'handles decimal values' do
        expect { NumberAnalyzer::CLI.run(['mean', '1.5', '2.5', '3.5']) }
          .to output("2.5\n").to_stdout
      end
    end

    context 'mode subcommand' do
      it 'returns mode value' do
        expect { NumberAnalyzer::CLI.run(%w[mode 1 2 2 3]) }
          .to output("2.0\n").to_stdout
      end

      it 'returns multiple modes' do
        expect { NumberAnalyzer::CLI.run(%w[mode 1 1 2 2]) }
          .to output("1.0, 2.0\n").to_stdout
      end

      it 'returns no mode message when no mode exists' do
        expect { NumberAnalyzer::CLI.run(%w[mode 1 2 3]) }
          .to output("モードなし\n").to_stdout
      end
    end

    context 'sum subcommand' do
      it 'returns sum value' do
        expect { NumberAnalyzer::CLI.run(%w[sum 1 2 3 4 5]) }
          .to output("15.0\n").to_stdout
      end

      it 'handles decimal values' do
        expect { NumberAnalyzer::CLI.run(['sum', '1.5', '2.5']) }
          .to output("4.0\n").to_stdout
      end
    end

    context 'min subcommand' do
      it 'returns minimum value' do
        expect { NumberAnalyzer::CLI.run(%w[min 5 1 3 2 4]) }
          .to output("1.0\n").to_stdout
      end

      it 'handles negative values' do
        expect { NumberAnalyzer::CLI.run(['min', '-1', '5', '-3']) }
          .to output("-3.0\n").to_stdout
      end
    end

    context 'max subcommand' do
      it 'returns maximum value' do
        expect { NumberAnalyzer::CLI.run(%w[max 5 1 3 2 4]) }
          .to output("5.0\n").to_stdout
      end

      it 'handles negative values' do
        expect { NumberAnalyzer::CLI.run(['max', '-1', '-5', '-3']) }
          .to output("-1.0\n").to_stdout
      end
    end

    context 'histogram subcommand' do
      it 'displays histogram' do
        expected_output = <<~OUTPUT
          度数分布ヒストグラム:
          1.0: ■ (1)
          2.0: ■■ (2)
          3.0: ■■■ (3)
        OUTPUT

        expect { NumberAnalyzer::CLI.run(%w[histogram 1 2 2 3 3 3]) }
          .to output(expected_output).to_stdout
      end
    end

    context 'subcommands with file input' do
      it 'handles median with CSV file' do
        fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
        expect { NumberAnalyzer::CLI.run(['median', '--file', fixture_path]) }
          .to output("10.0\n").to_stdout
      end

      it 'handles mean with JSON file' do
        fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.json')
        expect { NumberAnalyzer::CLI.run(['mean', '-f', fixture_path]) }
          .to output("55.0\n").to_stdout
      end
    end

    context 'subcommand error handling' do
      it 'exits with error for subcommand without arguments' do
        expect { NumberAnalyzer::CLI.run(['median']) }
          .to output(/エラー: 数値または --file オプションを指定してください。/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'exits with error for invalid file path' do
        expect { NumberAnalyzer::CLI.run(['mean', '--file', 'nonexistent.csv']) }
          .to output(/ファイル読み込みエラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'exits with error for invalid numeric arguments' do
        expect { NumberAnalyzer::CLI.run(%w[sum 1 abc 3]) }
          .to output(/エラー: 無効な引数が見つかりました: abc/).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'backward compatibility' do
      it 'runs full analysis when no subcommand provided' do
        expect { NumberAnalyzer::CLI.run(%w[1 2 3]) }
          .to output(/合計: 6/).to_stdout
      end

      it 'runs with default values when no arguments' do
        expect { NumberAnalyzer::CLI.run([]) }
          .to output(/合計: 55/).to_stdout
      end
    end
  end
end
