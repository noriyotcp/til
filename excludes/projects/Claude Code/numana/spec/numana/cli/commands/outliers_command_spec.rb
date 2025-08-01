# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require_relative '../../../../lib/numana/cli/commands/outliers_command'

RSpec.describe Numana::Commands::OutliersCommand do
  let(:command) { described_class.new }

  describe '#execute' do
    context 'コマンドライン引数での正常実行' do
      it 'detects outliers in simple dataset' do
        expect { command.execute(%w[1 2 3 100]) }
          .to output(/100\.0/).to_stdout
      end

      it 'returns no outliers for normal dataset' do
        expect { command.execute(%w[1 2 3 4 5]) }
          .to output(/なし/).to_stdout
      end

      it 'handles floating point numbers' do
        expect { command.execute(['1.0', '2.0', '3.0', '100.5']) }
          .to output(/100\.5/).to_stdout
      end

      it 'shows help with --help option' do
        expect { command.execute([], help: true) }
          .to output(/Detect outliers using IQR/).to_stdout
      end
    end

    context 'JSON出力' do
      it 'outputs JSON format when requested' do
        expect { command.execute(%w[1 2 3 100], format: 'json') }
          .to output(/"outliers"/).to_stdout
      end

      it 'includes dataset_size in JSON output' do
        expect { command.execute(%w[1 2 3 100], format: 'json') }
          .to output(/"dataset_size":4/).to_stdout
      end
    end

    context 'Quiet出力' do
      it 'outputs quiet format when requested' do
        expect { command.execute(%w[1 2 3 100], format: 'quiet') }
          .to output(/100\.0/).to_stdout
      end

      it 'outputs empty line for no outliers in quiet mode' do
        expect { command.execute(%w[1 2 3 4 5], format: 'quiet') }
          .to output("\n").to_stdout
      end
    end

    context 'エラーハンドリング' do
      it 'handles invalid arguments gracefully' do
        expect { command.execute(%w[1 invalid 3]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles empty arguments gracefully' do
        expect { command.execute([]) }
          .to output(/エラー/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles insufficient data for outlier calculation' do
        expect { command.execute(%w[1]) }
          .to output(/なし/).to_stdout
      end
    end

    context 'ファイル入力' do
      let(:test_file) { 'spec/fixtures/test_outliers_data.csv' }

      before do
        FileUtils.mkdir_p('spec/fixtures')
        File.write(test_file, "1\n2\n3\n100")
      end

      after do
        FileUtils.rm_f(test_file)
      end

      it 'reads data from file' do
        expect { command.execute([], file: test_file) }
          .to output(/100\.0/).to_stdout
      end

      it 'outputs JSON format from file data' do
        expect { command.execute([], file: test_file, format: 'json') }
          .to output(/"outliers"/).to_stdout
      end
    end
  end
end
