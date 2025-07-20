# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require_relative '../../../../lib/number_analyzer/cli/commands/percentile_command'

RSpec.describe Numana::Commands::PercentileCommand do
  let(:command) { described_class.new }

  describe '#execute' do
    context 'コマンドライン引数での正常実行' do
      it 'calculates 50th percentile (median)' do
        expect { command.execute(%w[50 1 2 3 4 5]) }
          .to output(/3\.0/).to_stdout
      end

      it 'calculates 75th percentile' do
        expect { command.execute(%w[75 1 2 3 4 5 6 7 8 9 10]) }
          .to output(/7\.75/).to_stdout
      end

      it 'calculates 25th percentile' do
        expect { command.execute(%w[25 1 2 3 4 5 6 7 8 9 10]) }
          .to output(/3\.25/).to_stdout
      end

      it 'handles floating point percentile values' do
        expect { command.execute(['33.5', '1', '2', '3', '4', '5']) }
          .to output(/2\.34/).to_stdout
      end

      it 'shows help with --help option' do
        expect { command.execute([], help: true) }
          .to output(/Calculate percentile value/).to_stdout
      end
    end

    context 'JSON出力' do
      it 'outputs JSON format when requested' do
        expect { command.execute(%w[50 1 2 3 4 5], format: 'json') }
          .to output(/"value":3\.0/).to_stdout
      end

      it 'includes dataset_size in JSON output' do
        expect { command.execute(%w[50 1 2 3 4 5], format: 'json') }
          .to output(/"dataset_size":5/).to_stdout
      end
    end

    context 'Precision制御' do
      it 'outputs with specified precision' do
        expect { command.execute(%w[50 1 2 3 4 5], precision: 1) }
          .to output(/3\.0/).to_stdout
      end
    end

    context 'エラーハンドリング' do
      it 'handles invalid percentile value' do
        expect { command.execute(%w[invalid 1 2 3]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles percentile value out of range (negative)' do
        expect { command.execute(%w[-10 1 2 3]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles percentile value out of range (>100)' do
        expect { command.execute(%w[150 1 2 3]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles missing arguments' do
        expect { command.execute(%w[50]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles empty arguments' do
        expect { command.execute([]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles invalid numeric data' do
        expect { command.execute(%w[50 1 invalid 3]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'ファイル入力' do
      let(:test_file) { 'spec/fixtures/test_percentile_data.csv' }

      before do
        FileUtils.mkdir_p('spec/fixtures')
        File.write(test_file, "1\n2\n3\n4\n5")
      end

      after do
        FileUtils.rm_f(test_file)
      end

      it 'reads data from file' do
        expect { command.execute(%w[50], file: test_file) }
          .to output(/3\.0/).to_stdout
      end

      it 'outputs JSON format from file data' do
        expect { command.execute(%w[75], file: test_file, format: 'json') }
          .to output(/"value"/).to_stdout
      end
    end
  end
end
