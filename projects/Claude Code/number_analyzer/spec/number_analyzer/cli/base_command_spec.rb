# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/base_command'

RSpec.describe NumberAnalyzer::Commands::BaseCommand do
  # テスト用の具象コマンドクラスを定義
  let(:test_command_class) do
    Class.new(described_class) do
      command 'test', 'Test command description'

      protected

      def perform_calculation(data)
        data.sum
      end
    end
  end

  let(:command) { test_command_class.new }

  describe '.command' do
    it 'sets command name and description' do
      expect(test_command_class.command_name).to eq('test')
      expect(test_command_class.description).to eq('Test command description')
    end
  end

  describe '#initialize' do
    it 'initializes with command metadata' do
      expect(command.name).to eq('test')
      expect(command.description).to eq('Test command description')
      expect(command.options).to include(
        format: nil,
        precision: nil,
        quiet: false,
        help: false,
        file: nil
      )
    end
  end

  describe '#execute' do
    context 'with help option' do
      it 'shows help and returns' do
        expect(command).to receive(:show_help)
        expect(command).not_to receive(:perform_calculation)

        command.execute([], help: true)
      end
    end

    context 'with valid arguments' do
      it 'processes data and outputs result' do
        expect { command.execute(%w[1 2 3]) }.to output("6.0\n").to_stdout
      end

      it 'merges global options' do
        expect { command.execute(%w[1 2 3], format: 'json') }
          .to output(include('"value": 6')).to_stdout
      end
    end

    context 'with invalid arguments' do
      it 'handles errors gracefully' do
        allow(command).to receive(:parse_input).and_raise(ArgumentError, 'Invalid input')

        expect { command.execute(%w[invalid]) }
          .to output(include('エラー: Invalid input')).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'with file input' do
      it 'delegates to DataInputHandler' do
        expect(NumberAnalyzer::Commands::DataInputHandler)
          .to receive(:parse).with([], hash_including(file: 'test.csv')).and_return([1, 2, 3])

        expect { command.execute([], file: 'test.csv') }.to output("6\n").to_stdout
      end
    end
  end

  describe '#validate_arguments' do
    it 'has default implementation that does nothing' do
      expect { command.send(:validate_arguments, %w[1 2 3]) }.not_to raise_error
    end
  end

  describe '#perform_calculation' do
    it 'must be implemented by subclasses' do
      base_command = described_class.new
      expect { base_command.send(:perform_calculation, []) }
        .to raise_error(NotImplementedError)
    end
  end

  describe '#output_result' do
    context 'standard output' do
      it 'formats value as string' do
        expect { command.send(:output_result, 42) }.to output("42\n").to_stdout
      end
    end

    context 'with JSON format' do
      before { command.instance_variable_set(:@options, { format: 'json' }) }

      it 'delegates to OutputFormatter' do
        expect(NumberAnalyzer::OutputFormatter)
          .to receive(:format).with(42, hash_including(format: 'json')).and_return('{"value": 42}')

        expect { command.send(:output_result, 42) }.to output("{\"value\": 42}\n").to_stdout
      end
    end

    context 'with precision option' do
      before { command.instance_variable_set(:@options, { precision: 2 }) }

      it 'passes precision to formatter' do
        expect(NumberAnalyzer::OutputFormatter)
          .to receive(:format).with(3.14159, hash_including(precision: 2)).and_return('3.14')

        expect { command.send(:output_result, 3.14159) }.to output("3.14\n").to_stdout
      end
    end

    context 'with quiet mode' do
      before { command.instance_variable_set(:@options, { quiet: true }) }

      it 'outputs only the value' do
        expect { command.send(:output_result, 42) }.to output("42\n").to_stdout
      end
    end
  end

  describe '#handle_error' do
    it 'outputs error message and exits' do
      error = StandardError.new('Test error')

      expect { command.send(:handle_error, error) }
        .to output("エラー: Test error\n").to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  describe '#show_help' do
    it 'displays command help information' do
      expect { command.send(:show_help) }
        .to output(include('test - Test command description')).to_stdout
    end
  end
end
