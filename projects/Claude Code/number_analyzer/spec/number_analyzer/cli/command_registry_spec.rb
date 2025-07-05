# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/command_registry'
require 'number_analyzer/cli/base_command'

RSpec.describe NumberAnalyzer::Commands::CommandRegistry do
  let(:test_command_class) do
    Class.new(NumberAnalyzer::Commands::BaseCommand) do
      command 'test', 'Test command for registry'

      protected

      def perform_calculation(data)
        data.sum * 2 # Simple test calculation
      end
    end
  end

  let(:another_command_class) do
    Class.new(NumberAnalyzer::Commands::BaseCommand) do
      command 'another', 'Another test command'

      protected

      def perform_calculation(data)
        data.max
      end
    end
  end

  before do
    # Clear registry before each test
    described_class.clear
  end

  describe '.register' do
    it 'registers a command class' do
      described_class.register(test_command_class)
      expect(described_class.get('test')).to eq(test_command_class)
    end

    it 'allows multiple command registrations' do
      described_class.register(test_command_class)
      described_class.register(another_command_class)

      expect(described_class.get('test')).to eq(test_command_class)
      expect(described_class.get('another')).to eq(another_command_class)
    end

    it 'overwrites existing command with same name' do
      described_class.register(test_command_class)
      described_class.register(another_command_class)

      # Register different class with same name
      new_test_class = Class.new(NumberAnalyzer::Commands::BaseCommand) do
        command 'test', 'New test command'
      end

      described_class.register(new_test_class)
      expect(described_class.get('test')).to eq(new_test_class)
    end
  end

  describe '.get' do
    before do
      described_class.register(test_command_class)
    end

    it 'returns registered command class' do
      expect(described_class.get('test')).to eq(test_command_class)
    end

    it 'returns nil for unregistered command' do
      expect(described_class.get('nonexistent')).to be_nil
    end
  end

  describe '.exists?' do
    before do
      described_class.register(test_command_class)
    end

    it 'returns true for registered command' do
      expect(described_class.exists?('test')).to be true
    end

    it 'returns false for unregistered command' do
      expect(described_class.exists?('nonexistent')).to be false
    end
  end

  describe '.all' do
    it 'returns empty array when no commands registered' do
      expect(described_class.all).to eq([])
    end

    it 'returns sorted list of command names' do
      described_class.register(test_command_class)
      described_class.register(another_command_class)

      expect(described_class.all).to eq(%w[another test])
    end
  end

  describe '.execute' do
    before do
      described_class.register(test_command_class)
    end

    context 'with registered command' do
      it 'creates instance and executes command' do
        expect { described_class.execute('test', %w[1 2 3]) }
          .to output("12.0\n").to_stdout # (1+2+3) * 2 = 12
      end

      it 'passes options to command execution' do
        expect { described_class.execute('test', %w[1 2 3], format: 'json') }
          .to output(include('"value": 12')).to_stdout
      end

      it 'returns true on successful execution' do
        result = nil
        expect { result = described_class.execute('test', %w[1 2 3]) }
          .to output(anything).to_stdout
        expect(result).to be true
      end
    end

    context 'with unregistered command' do
      it 'returns false' do
        result = described_class.execute('nonexistent', %w[1 2 3])
        expect(result).to be false
      end

      it 'does not output anything' do
        expect { described_class.execute('nonexistent', %w[1 2 3]) }
          .not_to output.to_stdout
      end
    end

    context 'with command execution error' do
      it 'lets the error bubble up' do
        allow_any_instance_of(test_command_class).to receive(:execute).and_raise(StandardError, 'Test error')

        expect { described_class.execute('test', %w[1 2 3]) }
          .to raise_error(StandardError, 'Test error')
      end
    end
  end

  describe '.clear' do
    it 'removes all registered commands' do
      described_class.register(test_command_class)
      described_class.register(another_command_class)

      expect(described_class.all.size).to eq(2)

      described_class.clear
      expect(described_class.all).to be_empty
    end
  end
end
