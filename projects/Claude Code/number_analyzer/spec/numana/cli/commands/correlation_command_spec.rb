# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/commands/correlation_command'

# NOTE: これは単体テストです。実際のCLI経由での動作も必ず確認してください！
# 例: bundle exec number_analyzer correlation 1 2 3 -- 4 5 6
#
# CLI統合で問題が発生した場合は ai-docs/CLI_REFACTORING_GUIDE.md を参照

RSpec.describe NumberAnalyzer::Commands::CorrelationCommand do
  describe '#execute' do
    let(:command) { described_class.new }

    context 'with numeric arguments separated by --' do
      it 'calculates correlation coefficient between two datasets' do
        output = capture_stdout do
          command.execute(['1', '2', '3', '--', '2', '4', '6'])
        end
        expect(output).to include('相関係数: 1.0000')
        expect(output).to include('強い正の相関')
      end

      it 'handles negative correlation' do
        output = capture_stdout do
          command.execute(['1', '2', '3', '--', '6', '4', '2'])
        end
        expect(output).to include('相関係数: -1.0000')
        expect(output).to include('強い負の相関')
      end

      it 'handles no correlation' do
        output = capture_stdout do
          command.execute(['1', '2', '3', '--', '2', '2', '2'])
        end
        expect(output).to include('相関係数: 0.0000')
        expect(output).to include('ほぼ無相関')
      end
    end

    context 'with file inputs' do
      let(:fixture_path) { File.join(__dir__, '..', '..', '..', 'fixtures') }
      let(:data1_path) { File.join(fixture_path, 'correlation_data1.csv') }
      let(:data2_path) { File.join(fixture_path, 'correlation_data2.csv') }

      it 'calculates correlation from two CSV files' do
        output = capture_stdout do
          command.execute([data1_path, data2_path])
        end
        expect(output).to include('相関係数: 1.0000')
      end
    end

    context 'with JSON output format' do
      it 'outputs correlation in JSON format' do
        output = capture_stdout do
          command.execute(['1', '2', '3', '--', '2', '4', '6'], format: 'json')
        end
        json = JSON.parse(output)
        expect(json['correlation']).to eq(1.0)
        expect(json['interpretation']).to include('強い正の相関')
        expect(json['dataset1_size']).to eq(3)
        expect(json['dataset2_size']).to eq(3)
      end
    end

    context 'with precision option' do
      it 'formats correlation with specified precision' do
        output = capture_stdout do
          command.execute(['1', '2', '3', '4', '--', '2', '3', '4', '5'], precision: 2)
        end
        expect(output).to include('相関係数: 0.98')
      end
    end

    context 'with quiet mode' do
      it 'outputs only the correlation value' do
        output = capture_stdout do
          command.execute(['1', '2', '3', '--', '2', '4', '6'], quiet: true)
        end
        expect(output.strip).to eq('1.0')
      end
    end

    context 'error handling' do
      it 'raises error when datasets have different lengths' do
        expect do
          capture_stdout do
            command.execute(['1', '2', '3', '--', '4', '5'])
          end
        end.to raise_error(SystemExit)
      end

      it 'raises error when no separator is provided' do
        expect do
          capture_stdout do
            command.execute(%w[1 2 3 4 5])
          end
        end.to raise_error(SystemExit)
      end

      it 'raises error with less than 2 data points' do
        expect do
          capture_stdout do
            command.execute(['1', '--', '2'])
          end
        end.to raise_error(SystemExit)
      end

      it 'raises error with empty datasets' do
        expect do
          capture_stdout do
            command.execute(['--'])
          end
        end.to raise_error(SystemExit)
      end
    end

    context 'with help option' do
      it 'shows help message' do
        output = capture_stdout do
          command.execute([], help: true)
        end
        expect(output).to include('correlation - Calculate Pearson correlation coefficient')
        expect(output).to include('Usage:')
        expect(output).to include('Options:')
      end
    end
  end

  describe '.command_name' do
    it 'returns the correct command name' do
      expect(described_class.command_name).to eq('correlation')
    end
  end

  describe '.description' do
    it 'returns the correct description' do
      expect(described_class.description).to eq('Calculate Pearson correlation coefficient between two datasets')
    end
  end
end
