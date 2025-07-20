# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require_relative '../../../../lib/number_analyzer/cli/commands/histogram_command'

RSpec.describe NumberAnalyzer::Commands::HistogramCommand do
  let(:command) { described_class.new }

  describe '#execute' do
    context 'コマンドライン引数での正常実行' do
      it 'displays histogram for simple dataset' do
        expect { command.execute(%w[1 2 2 3 3 3]) }
          .to output(/度数分布/).to_stdout
      end

      it 'handles single value dataset' do
        expect { command.execute(%w[42]) }
          .to output(/度数分布/).to_stdout
      end

      it 'handles floating point numbers' do
        expect { command.execute(['1.5', '2.7', '3.14']) }
          .to output(/度数分布/).to_stdout
      end

      it 'shows help with --help option' do
        expect { command.execute([], help: true) }
          .to output(/Display frequency distribution histogram/).to_stdout
      end
    end

    context 'JSON出力' do
      it 'outputs JSON format when requested' do
        expect { command.execute(%w[1 2 3], format: 'json') }
          .to output(/"histogram"/).to_stdout
      end

      it 'includes dataset_size in JSON output' do
        expect { command.execute(%w[1 2 3], format: 'json') }
          .to output(/"dataset_size":3/).to_stdout
      end
    end

    context 'Quiet出力' do
      it 'outputs quiet format when requested' do
        expect { command.execute(%w[1 2 2 3], format: 'quiet') }
          .to output(/1\.0:1 2\.0:2 3\.0:1/).to_stdout
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
    end

    context 'ファイル入力' do
      let(:test_file) { 'spec/fixtures/test_histogram_data.csv' }

      before do
        FileUtils.mkdir_p('spec/fixtures')
        File.write(test_file, "1\n2\n2\n3\n3\n3")
      end

      after do
        FileUtils.rm_f(test_file)
      end

      it 'reads data from file' do
        expect { command.execute([], file: test_file) }
          .to output(/度数分布/).to_stdout
      end

      it 'outputs JSON format from file data' do
        expect { command.execute([], file: test_file, format: 'json') }
          .to output(/"histogram"/).to_stdout
      end
    end
  end
end
