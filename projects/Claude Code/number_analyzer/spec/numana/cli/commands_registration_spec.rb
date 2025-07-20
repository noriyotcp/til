# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/commands'

RSpec.describe 'Command Registration' do
  before do
    # Clear and reload commands
    NumberAnalyzer::Commands::CommandRegistry.clear
    NumberAnalyzer::Commands.register_all
  end

  describe 'CommandRegistry' do
    let(:registry) { NumberAnalyzer::Commands::CommandRegistry }

    it 'registers all basic commands' do
      expected_commands = %w[max mean median min mode sum]
      expect(registry.all).to eq(expected_commands)
    end

    it 'can execute registered commands' do
      expect(registry.exists?('median')).to be true
      expect(registry.exists?('mean')).to be true
      expect(registry.exists?('sum')).to be true
      expect(registry.exists?('min')).to be true
      expect(registry.exists?('max')).to be true
      expect(registry.exists?('mode')).to be true
    end

    describe 'command execution through registry' do
      it 'executes median command' do
        expect { registry.execute_command('median', %w[1 2 3]) }
          .to output("2.0\n").to_stdout
      end

      it 'executes mean command' do
        expect { registry.execute_command('mean', %w[1 2 3]) }
          .to output("2.0\n").to_stdout
      end

      it 'executes sum command' do
        expect { registry.execute_command('sum', %w[1 2 3]) }
          .to output("6.0\n").to_stdout
      end

      it 'executes min command' do
        expect { registry.execute_command('min', %w[1 2 3]) }
          .to output("1.0\n").to_stdout
      end

      it 'executes max command' do
        expect { registry.execute_command('max', %w[1 2 3]) }
          .to output("3.0\n").to_stdout
      end

      it 'executes mode command' do
        expect { registry.execute_command('mode', %w[1 2 2 3]) }
          .to output("2.0\n").to_stdout
      end
    end

    describe 'command execution with options' do
      it 'supports JSON format for all commands' do
        %w[median mean sum min max mode].each do |command|
          expect { registry.execute_command(command, %w[1 2 3], format: 'json') }
            .to output(include('"value":')).to_stdout
        end
      end

      it 'supports precision option for all commands' do
        %w[median mean sum min max mode].each do |command|
          expect { registry.execute_command(command, %w[1 2 3], precision: 1) }
            .to output(/\d+\.\d+/).to_stdout
        end
      end
    end

    describe 'error handling' do
      it 'returns false for unknown commands' do
        result = registry.execute_command('unknown', %w[1 2 3])
        expect(result).to be false
      end

      it 'does not output anything for unknown commands' do
        expect { registry.execute_command('unknown', %w[1 2 3]) }
          .not_to output.to_stdout
      end
    end
  end
end
