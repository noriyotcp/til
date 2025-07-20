# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/commands/help_command'

RSpec.describe Numana::Commands::HelpCommand do
  let(:command) { described_class.new }

  describe '#execute' do
    context 'with no arguments' do
      it 'shows general help' do
        expect { command.execute([]) }.to output(/NumberAnalyzer - Statistical Analysis Tool/).to_stdout
      end

      it 'shows available commands' do
        expect { command.execute([]) }.to output(/Basic Statistics:/).to_stdout
      end

      it 'shows usage examples' do
        expect { command.execute([]) }.to output(/bundle exec number_analyzer mean 1 2 3 4 5/).to_stdout
      end
    end

    context 'with specific command argument' do
      before do
        # Ensure commands are registered
        Numana::Commands.register_all
      end

      it 'shows help for valid command' do
        expect { command.execute(['mean']) }.to output(/mean - Calculate the arithmetic mean/).to_stdout
      end

      it 'shows error for invalid command' do
        expect { command.execute(['invalid_command']) }.to output(/Unknown command: invalid_command/).to_stdout
      end
    end

    context 'with help option' do
      it 'shows help for help command itself' do
        output = capture_output { command.execute([], help: true) }
        expect(output).to include('help - Display help information for commands')
        expect(output).to include('Usage: number_analyzer help [COMMAND]')
      end
    end

    context 'with too many arguments' do
      it 'raises ArgumentError' do
        expect { command.execute(%w[mean median]) }.to output(/Error: Help command takes at most one argument/).to_stdout
      end
    end
  end

  describe '#show_help' do
    it 'shows help-specific help message' do
      output = capture_output { command.show_help }
      expect(output).to include('help - Display help information for commands')
      expect(output).to include('Usage: number_analyzer help [COMMAND]')
      expect(output).to include('number_analyzer help mean')
    end
  end

  private

  def capture_output
    output = StringIO.new
    original_stdout = $stdout
    $stdout = output
    yield
    output.string
  ensure
    $stdout = original_stdout
  end
end
