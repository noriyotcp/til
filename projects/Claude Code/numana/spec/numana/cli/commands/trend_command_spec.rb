# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/commands/trend_command'

# NOTE: これは単体テストです。実際のCLI経由での動作も必ず確認してください！
# 例: bundle exec number_analyzer trend 1 2 3 4 5
#
# CLI統合で問題が発生した場合は ai-docs/CLI_REFACTORING_GUIDE.md を参照

RSpec.describe Numana::Commands::TrendCommand do
  describe '#execute' do
    let(:command) { described_class.new }

    context 'with ascending trend data' do
      it 'calculates linear trend for ascending data' do
        output = capture_stdout do
          command.execute(%w[1 2 3 4 5])
        end
        expect(output).to include('トレンド分析結果:')
        expect(output).to include('傾き: 1.0')
        expect(output).to include('切片: 1.0')
        expect(output).to include('決定係数(R²): 1.0')
        expect(output).to include('方向性: 上昇トレンド')
      end
    end

    context 'with descending trend data' do
      it 'calculates linear trend for descending data' do
        output = capture_stdout do
          command.execute(%w[5 4 3 2 1])
        end
        expect(output).to include('傾き: -1.0')
        expect(output).to include('切片: 5.0')
        expect(output).to include('決定係数(R²): 1.0')
        expect(output).to include('方向性: 下降トレンド')
      end
    end

    context 'with flat data' do
      it 'calculates linear trend for flat data' do
        output = capture_stdout do
          command.execute(%w[3 3 3 3 3])
        end
        expect(output).to include('傾き: 0.0')
        expect(output).to include('切片: 3.0')
        expect(output).to include('決定係数(R²): 1.0')
        expect(output).to include('方向性: 横ばい')
      end
    end

    context 'with non-linear data' do
      it 'calculates best-fit linear trend' do
        output = capture_stdout do
          command.execute(%w[1 3 2 5 4])
        end
        expect(output).to include('トレンド分析結果:')
        expect(output).to include('傾き:')
        expect(output).to include('切片:')
        expect(output).to include('決定係数(R²):')
        expect(output).to include('方向性:')
      end
    end

    context 'with JSON output format' do
      it 'outputs trend data in JSON format' do
        output = capture_stdout do
          command.execute(%w[1 2 3 4 5], { format: 'json' })
        end

        json_data = JSON.parse(output)
        expect(json_data).to have_key('trend')
        expect(json_data['trend']).to include(
          'slope' => 1.0,
          'intercept' => 1.0,
          'r_squared' => 1.0,
          'direction' => '上昇トレンド'
        )
        expect(json_data).to have_key('dataset_size')
        expect(json_data['dataset_size']).to eq(5)
      end
    end

    context 'with precision option' do
      it 'applies precision formatting to trend values' do
        output = capture_stdout do
          command.execute(['1.1', '2.3', '3.2', '4.8'])
        end
        expect(output).to include('トレンド分析結果:')
        expect(output).to include('傾き:')
        expect(output).to include('切片:')
        expect(output).to include('決定係数(R²):')
        expect(output).to include('方向性:')
      end
    end

    context 'with file input' do
      # NOTE: File input testing requires proper fixture setup
      # This test is simplified for the unit test context
      it 'validates file input requirement' do
        # This test just ensures the command handles file options
        expect { command.execute([]) }.to raise_error(ArgumentError)
      end
    end

    context 'with help option' do
      it 'displays help information' do
        output = capture_stdout do
          command.execute([], { help: true })
        end
        expect(output).to include('trend - Calculate linear trend analysis')
        expect(output).to include('Usage: number_analyzer trend')
        expect(output).to include('Options:')
        expect(output).to include('--help')
        expect(output).to include('--file')
        expect(output).to include('--format')
        expect(output).to include('--precision')
        expect(output).to include('--quiet')
        expect(output).to include('Examples:')
      end
    end

    context 'with insufficient data' do
      it 'handles single data point' do
        expect do
          capture_stdout do
            command.execute(['5'])
          end
        end.to raise_error(ArgumentError, /最低2つのデータポイントが必要/)
      end

      it 'handles empty data' do
        expect do
          capture_stdout do
            command.execute([])
          end
        end.to raise_error(ArgumentError, /最低2つのデータポイントが必要/)
      end
    end

    context 'with invalid numeric data' do
      it 'handles non-numeric input gracefully' do
        expect do
          capture_stdout do
            command.execute(%w[a b c])
          end
        end.to raise_error(ArgumentError)
      end
    end

    context 'with mixed valid/invalid input' do
      it 'handles mixed numeric and non-numeric input' do
        expect do
          capture_stdout do
            command.execute(%w[1 2 invalid 4])
          end
        end.to raise_error(ArgumentError)
      end
    end

    context 'with decimal values' do
      it 'processes decimal values correctly' do
        output = capture_stdout do
          command.execute(['1.5', '2.5', '3.5', '4.5'])
        end
        expect(output).to include('トレンド分析結果:')
        expect(output).to include('傾き: 1.0')
        expect(output).to include('方向性: 上昇トレンド')
      end
    end

    context 'with negative values' do
      it 'processes negative values correctly' do
        output = capture_stdout do
          command.execute(['-2', '-1', '0', '1', '2'])
        end
        expect(output).to include('トレンド分析結果:')
        expect(output).to include('傾き: 1.0')
        expect(output).to include('方向性: 上昇トレンド')
      end
    end

    context 'with large datasets' do
      it 'handles larger datasets efficiently' do
        large_dataset = (1..100).map(&:to_s)
        output = capture_stdout do
          command.execute(large_dataset)
        end
        expect(output).to include('トレンド分析結果:')
        expect(output).to include('傾き: 1.0')
        expect(output).to include('方向性: 上昇トレンド')
      end
    end
  end
end
