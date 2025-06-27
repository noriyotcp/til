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
end
