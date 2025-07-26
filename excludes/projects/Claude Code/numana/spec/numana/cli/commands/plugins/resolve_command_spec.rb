# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/commands/plugins/resolve_command'
require 'numana/plugin_system'

RSpec.describe Numana::Commands::Plugins::ResolveCommand do
  let(:command) { described_class.new }
  let(:plugin_system) { instance_double(Numana::PluginSystem) }
  let(:mock_plugins) do
    {
      'test_plugin' => { class: double('TestPlugin', commands: { 'test-command' => :run }) },
      'another_plugin' => { class: double('AnotherPlugin', commands: { 'test-command' => :run }) }
    }
  end

  before do
    allow(command).to receive(:loaded_plugins).and_return(mock_plugins)
    allow($stdin).to receive(:gets).and_return("n\n") # Default to 'no' for interactive prompts
  end

  it 'requires plugin name' do
    expect { command.execute([], {}) }.to raise_error(SystemExit)
  end

  it 'validates plugin exists' do
    expect { command.execute(['nonexistent'], {}) }.to raise_error(SystemExit)
  end

  it 'detects conflicts for specified plugin' do
    allow(command).to receive(:detect_plugin_conflicts).and_return(['command conflict with another_plugin: test-command'])
    output = capture_stdout { command.execute(['test_plugin'], {}) }
    expect(output).to include("Conflicts for plugin 'test_plugin':")
  end

  it 'shows no conflicts message when plugin has none' do
    allow(command).to receive(:find_plugin_conflicts).and_return([])
    output = capture_stdout { command.execute(['test_plugin'], {}) }
    expect(output).to include("No conflicts found for plugin 'test_plugin'.")
  end
end
