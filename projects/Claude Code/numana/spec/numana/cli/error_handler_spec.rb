# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/error_handler'

RSpec.describe Numana::CLI::ErrorHandler do
  describe '.handle_unknown_command' do
    let(:available_commands) { %w[mean median mode sum variance std] }

    context 'when similar commands exist' do
      it 'suggests similar commands for typos' do
        expect { described_class.handle_unknown_command('mena', available_commands) }
          .to raise_error(Numana::CLI::ErrorHandler::CLIError) do |error|
          expect(error.message).to eq('Unknown command: mena')
          expect(error.suggestion).to eq('Did you mean: mean?')
          expect(error.error_code).to eq(:unknown_command)
        end
      end

      it 'suggests multiple similar commands' do
        expect { described_class.handle_unknown_command('mde', available_commands) }
          .to raise_error(Numana::CLI::ErrorHandler::CLIError) do |error|
          expect(error.suggestion).to include('mode')
          # Should suggest commands within distance 2
        end
      end
    end

    context 'when no similar commands exist' do
      it 'provides help context' do
        expect { described_class.handle_unknown_command('xyz', available_commands) }
          .to raise_error(Numana::CLI::ErrorHandler::CLIError) do |error|
          expect(error.message).to eq('Unknown command: xyz')
          expect(error.context).to eq("Use 'bundle exec number_analyzer help' for available commands.")
          expect(error.suggestion).to be_nil
        end
      end
    end
  end

  describe '.handle_invalid_option' do
    it 'suggests similar options for typos' do
      expect { described_class.handle_invalid_option('--helpp') }
        .to raise_error(Numana::CLI::ErrorHandler::CLIError) do |error|
        expect(error.message).to eq('Invalid option: --helpp')
        expect(error.suggestion).to eq('Did you mean: --help?')
        expect(error.error_code).to eq(:invalid_option)
      end
    end

    it 'includes command context when provided' do
      expect { described_class.handle_invalid_option('--bad', 'mean') }
        .to raise_error(Numana::CLI::ErrorHandler::CLIError) do |error|
        expect(error.command).to eq('mean')
      end
    end
  end

  describe '.handle_argument_error' do
    it 'provides context for numeric values' do
      expect { described_class.handle_argument_error('invalid number format') }
        .to raise_error(Numana::CLI::ErrorHandler::CLIError) do |error|
        expect(error.message).to eq('Argument error: invalid number format')
        expect(error.context).to eq('Please provide numeric values')
        expect(error.error_code).to eq(:invalid_argument)
      end
    end
  end

  describe '.find_similar_commands' do
    let(:commands) { %w[mean median mode sum variance] }

    it 'finds commands within distance 1' do
      similar = described_class.find_similar_commands('mena', commands)
      expect(similar).to eq(['mean'])
    end

    it 'finds commands within distance 2' do
      similar = described_class.find_similar_commands('mdan', commands)
      expect(similar).to include('mean', 'median')
    end

    it 'returns empty array for very different strings' do
      similar = described_class.find_similar_commands('xyz', commands)
      expect(similar).to be_empty
    end

    it 'sorts by distance and limits to 3' do
      commands_extended = %w[mean median mode sum min max map]
      similar = described_class.find_similar_commands('ma', commands_extended)
      expect(similar.length).to be <= 3
      expect(similar).to include('max', 'map')
    end
  end

  describe '.print_error_and_exit' do
    context 'with CLIError' do
      it 'prints user message to stderr and exits with appropriate code' do
        error = Numana::CLI::ErrorHandler::CLIError.new(
          'Test error',
          command: 'test',
          suggestion: 'Try this instead',
          code: :unknown_command
        )

        expect { described_class.print_error_and_exit(error) }
          .to output("#{error.user_message}\n").to_stderr
          .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end

      it 'exits with code 2 for non-unknown_command errors' do
        error = Numana::CLI::ErrorHandler::CLIError.new(
          'Test error',
          code: :invalid_option
        )

        expect { described_class.print_error_and_exit(error) }
          .to output("#{error.user_message}\n").to_stderr
          .and raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
      end
    end

    context 'with standard error' do
      it 'prints simple error message and exits with 1' do
        error = StandardError.new('Generic error')

        expect { described_class.print_error_and_exit(error) }
          .to output("Error: Generic error\n").to_stderr
          .and raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
      end
    end
  end

  describe 'CLIError' do
    it 'formats user message correctly' do
      error = Numana::CLI::ErrorHandler::CLIError.new(
        'Main error message',
        command: 'test-command',
        context: 'Additional context',
        suggestion: 'Try this instead',
        code: :test_error
      )

      expected_message = <<~MSG.chomp
        Error: Main error message
        Command: test-command
        Context: Additional context
        Suggestion: Try this instead
      MSG

      expect(error.user_message).to eq(expected_message)
    end

    it 'omits nil fields from user message' do
      error = Numana::CLI::ErrorHandler::CLIError.new(
        'Main error message',
        command: 'test-command'
      )

      expected_message = <<~MSG.chomp
        Error: Main error message
        Command: test-command
      MSG

      expect(error.user_message).to eq(expected_message)
    end
  end
end
