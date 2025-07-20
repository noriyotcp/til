# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/plugin_router'

RSpec.describe Numana::CLI::PluginRouter do
  describe '.route_command' do
    let(:args) { %w[1 2 3] }
    let(:options) { { format: 'json' } }

    context 'when command exists in CommandRegistry' do
      before do
        registry = double('CommandRegistry')
        allow(registry).to receive(:exists?).with('mean').and_return(true)
        allow(registry).to receive(:execute_command).with('mean', args, options)
        stub_const('Numana::Commands::CommandRegistry', registry)
      end

      it 'executes command through registry' do
        expect(Numana::Commands::CommandRegistry).to receive(:execute_command)
          .with('mean', args, options)
        described_class.route_command('mean', args, options)
      end
    end

    context 'when command is a core command' do
      before do
        stub_const('Numana::CLI::CORE_COMMANDS', { 'test' => :run_test })
        allow(Numana::CLI).to receive(:respond_to?).and_return(true)
        allow(Numana::CLI).to receive(:send).with(:run_test, args, options)
      end

      it 'executes core command' do
        expect(Numana::CLI).to receive(:send).with(:run_test, args, options)
        described_class.route_command('test', args, options)
      end
    end

    context 'when command is a plugin command' do
      let(:plugin_class) { double('PluginClass') }
      let(:plugin_info) { { plugin_class: plugin_class, method: :execute } }

      before do
        allow(Numana::CLI).to receive(:respond_to?).and_return(true)
        allow(Numana::CLI).to receive(:send).with(:plugin_commands).and_return({ 'custom' => plugin_info })
      end

      it 'executes plugin command on class' do
        allow(plugin_class).to receive(:respond_to?).with(:execute).and_return(true)
        allow(plugin_class).to receive(:execute).with(args, options).and_return('Result')

        expect { described_class.route_command('custom', args, options) }
          .to output("Result\n").to_stdout
      end

      it 'executes plugin command on instance' do
        instance = double('PluginInstance')
        allow(plugin_class).to receive(:respond_to?).with(:execute).and_return(false)
        allow(plugin_class).to receive(:new).and_return(instance)
        allow(instance).to receive(:execute).with(args, options).and_return('Result')

        expect { described_class.route_command('custom', args, options) }
          .to output("Result\n").to_stdout
      end
    end

    context 'when command not found' do
      before do
        error_handler = Module.new do
          def self.handle_unknown_command(command, available_commands)
            # Mock implementation
          end
        end
        stub_const('Numana::CLI::ErrorHandler', error_handler)
      end

      it 'calls error handler with available commands' do
        expect(Numana::CLI::ErrorHandler).to receive(:handle_unknown_command)
          .with('unknown', instance_of(Array))
        described_class.route_command('unknown', args, options)
      end
    end
  end

  describe '.command_registry_exists?' do
    context 'when CommandRegistry is defined' do
      before do
        registry = double('CommandRegistry')
        allow(registry).to receive(:exists?).with('test').and_return(true)
        stub_const('Numana::Commands::CommandRegistry', registry)
      end

      it 'returns true for existing command' do
        expect(described_class.command_registry_exists?('test')).to be true
      end
    end

    context 'when CommandRegistry is not defined' do
      before do
        hide_const('Numana::Commands::CommandRegistry')
      end

      it 'returns false' do
        expect(described_class.command_registry_exists?('test')).to be false
      end
    end
  end

  describe '.handle_conflicts' do
    let(:options) { { conflict_strategy: :interactive } }

    context 'when PluginConflictResolver is available' do
      let(:resolver) { double('PluginConflictResolver') }

      before do
        stub_const('Numana::PluginConflictResolver', Class.new)
        allow(resolver).to receive(:respond_to?).with(:has_conflicts?).and_return(true)
        allow(resolver).to receive(:has_conflicts?).with('test').and_return(true)
        allow(resolver).to receive(:resolve_conflict).with('test', strategy: :interactive)
                                                     .and_return('resolved_command')
        allow(Numana::PluginConflictResolver).to receive(:new).and_return(resolver)
      end

      it 'resolves conflicts using specified strategy' do
        result = described_class.handle_conflicts('test', [], options)
        expect(result).to eq('resolved_command')
      end
    end

    context 'when PluginConflictResolver is not available' do
      before do
        hide_const('Numana::PluginConflictResolver')
      end

      it 'returns nil' do
        result = described_class.handle_conflicts('test', [], options)
        expect(result).to be_nil
      end
    end
  end

  describe 'private methods' do
    describe '#all_available_commands' do
      it 'collects commands from all sources' do
        # Mock CommandRegistry
        registry = double('CommandRegistry')
        allow(registry).to receive(:all).and_return(%w[registry1 registry2])
        stub_const('Numana::Commands::CommandRegistry', registry)

        # Mock CORE_COMMANDS
        stub_const('Numana::CLI::CORE_COMMANDS', { 'core1' => :run, 'core2' => :run })

        # Mock plugin commands
        allow(Numana::CLI).to receive(:respond_to?).and_return(true)
        allow(Numana::CLI).to receive(:send).with(:plugin_commands)
                                                    .and_return({ 'plugin1' => {}, 'plugin2' => {} })

        commands = described_class.send(:all_available_commands)
        expect(commands).to contain_exactly('registry1', 'registry2', 'core1', 'core2', 'plugin1', 'plugin2')
      end
    end
  end
end
