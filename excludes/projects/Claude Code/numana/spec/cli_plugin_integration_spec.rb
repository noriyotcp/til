# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Numana::CLI, 'Plugin Integration' do
  let(:test_plugin_class) do
    Class.new do
      def self.name
        'TestPlugin'
      end

      def self.plugin_name
        'test_plugin'
      end

      def self.plugin_commands
        { 'test-sum' => :calculate_sum }
      end

      def self.calculate_sum(args, options)
        numbers = args.map(&:to_f)
        result = numbers.sum

        if options[:format] == 'json'
          { result: result, count: numbers.length }.to_json
        else
          "Sum: #{result}"
        end
      end
    end
  end

  before do
    # Reset plugin state
    described_class.reset_plugin_state!

    # Mock plugin system initialization
    allow(described_class).to receive(:initialize_plugins)
  end

  describe '.register_command' do
    it 'registers a new command from plugin' do
      described_class.register_command('test-sum', test_plugin_class, :calculate_sum)

      commands = described_class.commands
      expect(commands).to have_key('test-sum')
      expect(commands['test-sum']).to eq({
                                           plugin_class: test_plugin_class,
                                           method: :calculate_sum
                                         })
    end
  end

  describe '.commands' do
    it 'includes both core and plugin commands' do
      described_class.register_command('test-sum', test_plugin_class, :calculate_sum)

      commands = described_class.commands

      # Should include core commands
      expect(commands).to have_key('mean')
      expect(commands).to have_key('median')

      # Should include plugin commands
      expect(commands).to have_key('test-sum')
    end
  end

  describe 'plugin command execution' do
    before do
      described_class.register_command('test-sum', test_plugin_class, :calculate_sum)
    end

    it 'executes plugin command with numeric arguments' do
      expect do
        described_class.run(%w[test-sum 1 2 3])
      end.to output("Sum: 6.0\n").to_stdout
    end

    it 'executes plugin command with JSON format option' do
      expect do
        described_class.run(['test-sum', '--format=json', '1', '2', '3'])
      end.to output(/"result":6.0,"count":3/).to_stdout
    end

    it 'handles unknown commands gracefully' do
      expect do
        expect do
          described_class.run(['unknown-command'])
        end.to raise_error(SystemExit)
      end.to output(/Unknown command: unknown-command/).to_stderr
    end
  end

  describe 'plugin system integration' do
    before do
      # Reset plugin state to ensure clean state
      described_class.reset_plugin_state!
    end

    it 'initializes plugin system on CLI run' do
      allow(described_class).to receive(:initialize_plugins).and_call_original

      described_class.run([])

      expect(described_class).to have_received(:initialize_plugins)
    end

    it 'loads enabled plugins on initialization' do
      # Test that the initialization method can be called without errors
      # The actual functionality is tested in plugin_system_spec.rb
      expect { described_class.initialize_plugins }.not_to raise_error

      # Verify that a plugin system instance is created
      plugin_system = described_class.plugin_system
      expect(plugin_system).to be_an_instance_of(Numana::PluginSystem)
    end
  end
end
