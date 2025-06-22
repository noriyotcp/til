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
  end
end
