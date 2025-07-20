# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'number_analyzer/cli/commands/median_command'

RSpec.describe Numana::Commands::MedianCommand do
  let(:command) { described_class.new }

  describe 'command metadata' do
    it 'has correct name and description' do
      expect(command.name).to eq('median')
      expect(command.description).to eq('Calculate the median (middle value) of numbers')
    end
  end

  describe '#perform_calculation' do
    context 'with valid data' do
      it 'calculates median of odd number of elements' do
        result = command.send(:perform_calculation, [1, 3, 5])
        expect(result).to eq(3.0)
      end

      it 'calculates median of even number of elements' do
        result = command.send(:perform_calculation, [1, 2, 3, 4])
        expect(result).to eq(2.5)
      end

      it 'handles single element' do
        result = command.send(:perform_calculation, [42])
        expect(result).to eq(42.0)
      end

      it 'handles unsorted data' do
        result = command.send(:perform_calculation, [5, 1, 3])
        expect(result).to eq(3.0)
      end

      it 'handles negative numbers' do
        result = command.send(:perform_calculation, [-3, -1, -5])
        expect(result).to eq(-3.0)
      end

      it 'handles floating point numbers' do
        result = command.send(:perform_calculation, [1.5, 2.7, 3.1])
        expect(result).to eq(2.7)
      end
    end

    context 'with edge cases' do
      it 'raises error for empty array' do
        expect { command.send(:perform_calculation, []) }
          .to raise_error(ArgumentError, /空の配列/)
      end
    end
  end

  describe '#execute' do
    context 'with command line arguments' do
      it 'calculates median from arguments' do
        expect { command.execute(%w[1 2 3]) }
          .to output("2.0\n").to_stdout
      end

      it 'handles floating point input' do
        expect { command.execute(%w[1.5 2.5 3.5]) }
          .to output("2.5\n").to_stdout
      end
    end

    context 'with file input' do
      let(:test_file) { 'spec/fixtures/median_test.txt' }

      before do
        FileUtils.mkdir_p('spec/fixtures')
        File.write(test_file, "10\n20\n30\n")
      end

      after do
        FileUtils.rm_f(test_file)
      end

      it 'reads data from file' do
        expect { command.execute([], file: test_file) }
          .to output("20.0\n").to_stdout
      end
    end

    context 'with JSON output' do
      it 'formats output as JSON' do
        expect { command.execute(%w[1 2 3], format: 'json') }
          .to output(include('"median": 2.0')).to_stdout
      end
    end

    context 'with precision option' do
      it 'formats output with specified precision' do
        expect { command.execute(%w[1 2 3], precision: 1) }
          .to output("2.0\n").to_stdout
      end
    end

    context 'with quiet mode' do
      it 'outputs only the value' do
        expect { command.execute(%w[1 2 3], quiet: true) }
          .to output("2.0\n").to_stdout
      end
    end

    context 'with help option' do
      it 'shows help information' do
        expect { command.execute([], help: true) }
          .to output(include('median - Calculate the median')).to_stdout
      end
    end

    context 'with invalid input' do
      it 'handles non-numeric arguments' do
        expect { command.execute(%w[1 abc 3]) }
          .to output(include('エラー')).to_stdout
          .and raise_error(SystemExit)
      end

      it 'handles empty arguments' do
        expect { command.execute([]) }
          .to output(include('エラー')).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end
end
