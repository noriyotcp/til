# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/commands/plugins/list_command'
require 'numana/plugin_system'

RSpec.describe Numana::Commands::Plugins::ListCommand do
  let(:command) { described_class.new }
  let(:plugin_system) { instance_double(Numana::PluginSystem) }
  let(:mock_plugins) do
    {
      'test_plugin' => {
        class: test_plugin_class,
        priority: :local
      },
      'another_plugin' => {
        class: another_plugin_class,
        priority: :official
      }
    }
  end

  let(:test_plugin_class) do
    Class.new do
      def self.commands
        { 'test-command' => :run_test }
      end
    end
  end

  let(:another_plugin_class) do
    Class.new do
      def self.commands
        { 'test-command' => :run_test, 'unique-command' => :run_unique }
      end
    end
  end

  before do
    allow(command).to receive(:loaded_plugins).and_return(mock_plugins)
  end

  it 'lists all loaded plugins' do
    output = capture_stdout { command.execute([], {}) }

    expect(output).to include('Loaded plugins (2):')
    expect(output).to include('test_plugin:')
    expect(output).to include('another_plugin:')
    expect(output).to include('Priority: local')
    expect(output).to include('Priority: official')
  end

  it 'shows message when no plugins are loaded' do
    allow(command).to receive(:loaded_plugins).and_return({})

    output = capture_stdout { command.execute([], {}) }
    expect(output).to include('No plugins loaded.')
  end

  it 'detects and shows conflicts with --show-conflicts flag' do
    allow(command).to receive(:detect_all_conflicts).and_return({ command: { 'test-command' => %w[test_plugin another_plugin] } })
    allow(command).to receive(:detect_plugin_conflicts).and_return(['command conflict with another_plugin: test-command'])

    output = capture_stdout { command.execute(['--show-conflicts'], {}) }

    expect(output).to include('⚠️  Conflicts: command conflict with another_plugin: test-command')
    expect(output).to include('Conflict summary:')
  end
end
