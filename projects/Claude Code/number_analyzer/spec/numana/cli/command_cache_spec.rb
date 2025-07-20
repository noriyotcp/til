# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/command_cache'

RSpec.describe Numana::CLI::CommandCache do
  before do
    # Clear cache before each test
    described_class.invalidate!
  end

  describe '.commands' do
    let(:mock_commands) { { 'mean' => :run_mean, 'median' => :run_median } }

    before do
      allow(described_class).to receive(:build_command_list).and_return(mock_commands)
    end

    it 'builds command list on first call' do
      expect(described_class).to receive(:build_command_list).once
      described_class.commands
    end

    it 'returns cached commands on subsequent calls' do
      described_class.commands # First call
      expect(described_class).not_to receive(:build_command_list)
      result = described_class.get_commands # Second call
      expect(result).to eq(mock_commands)
    end

    it 'rebuilds cache after TTL expires' do
      described_class.commands # First call
      allow(Time).to receive(:now).and_return(Time.now + described_class::CACHE_TTL + 1)
      expect(described_class).to receive(:build_command_list).once
      described_class.commands
    end
  end

  describe '.invalidate!' do
    it 'clears the cache' do
      allow(described_class).to receive(:build_command_list).and_return({ 'test' => :run_test })
      described_class.commands # Build cache
      described_class.invalidate!

      # Should rebuild on next call
      expect(described_class).to receive(:build_command_list).once
      described_class.commands
    end
  end

  describe '.plugin_system_available?' do
    context 'when CLI has plugin_system method' do
      before do
        allow(Numana::CLI).to receive(:respond_to?).and_return(true)
      end

      it 'returns true when plugin system exists' do
        allow(Numana::CLI).to receive(:plugin_system).and_return(double('PluginSystem'))
        expect(described_class.plugin_system_available?).to be true
      end

      it 'returns false when plugin system is nil' do
        allow(Numana::CLI).to receive(:plugin_system).and_return(nil)
        expect(described_class.plugin_system_available?).to be false
      end
    end

    context 'when CLI does not have plugin_system method' do
      before do
        allow(Numana::CLI).to receive(:respond_to?).and_return(false)
      end

      it 'returns false' do
        expect(described_class.plugin_system_available?).to be false
      end
    end
  end

  describe '.plugin_commands' do
    context 'when plugin system is available' do
      before do
        allow(described_class).to receive(:plugin_system_available?).and_return(true)
      end

      it 'returns plugin commands from CLI' do
        plugin_cmds = { 'custom' => { plugin_class: 'CustomPlugin', method: :run } }
        allow(Numana::CLI).to receive(:instance_variable_get)
          .with(:@plugin_commands).and_return(plugin_cmds)

        expect(described_class.plugin_commands).to eq(plugin_cmds)
      end

      it 'returns empty hash when no plugin commands exist' do
        allow(Numana::CLI).to receive(:instance_variable_get)
          .with(:@plugin_commands).and_return(nil)

        expect(described_class.plugin_commands).to eq({})
      end

      it 'returns empty hash on error' do
        allow(Numana::CLI).to receive(:instance_variable_get)
          .and_raise(StandardError.new('Test error'))

        expect(described_class.plugin_commands).to eq({})
      end
    end

    context 'when plugin system is not available' do
      before do
        allow(described_class).to receive(:plugin_system_available?).and_return(false)
      end

      it 'returns empty hash' do
        expect(described_class.plugin_commands).to eq({})
      end
    end
  end

  describe 'private methods' do
    describe '#build_command_list' do
      it 'merges commands from all sources' do
        # Mock CORE_COMMANDS
        stub_const('Numana::CLI::CORE_COMMANDS', { 'core' => :run_core })

        # Mock CommandRegistry
        registry = double('CommandRegistry')
        allow(registry).to receive(:all).and_return(['registry_cmd'])
        stub_const('Numana::Commands::CommandRegistry', registry)

        # Mock plugin commands
        allow(described_class).to receive(:plugin_commands).and_return({ 'plugin' => :run_plugin })

        commands = described_class.send(:build_command_list)

        expect(commands).to include(
          'core' => :run_core,
          'registry_cmd' => :run_from_registry,
          'plugin' => :run_plugin
        )
      end

      it 'handles missing constants gracefully' do
        # Remove constants if they exist
        Numana::CLI.send(:remove_const, :CORE_COMMANDS) if defined?(Numana::CLI::CORE_COMMANDS)
        Numana::Commands.send(:remove_const, :CommandRegistry) if defined?(Numana::Commands::CommandRegistry)

        allow(described_class).to receive(:plugin_commands).and_return({})

        commands = described_class.send(:build_command_list)
        expect(commands).to eq({})
      end
    end
  end
end
