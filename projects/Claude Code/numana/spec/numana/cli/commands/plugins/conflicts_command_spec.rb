# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/commands/plugins/conflicts_command'
require 'numana/plugin_system'

RSpec.describe Numana::Commands::Plugins::ConflictsCommand do
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
  end

  it 'shows all conflicts' do
    allow(command).to receive(:detect_all_conflicts).and_return({ command: { 'test-command' => %w[test_plugin another_plugin] } })
    output = capture_stdout { command.execute([], {}) }

    expect(output).to include('Plugin conflict detection results:')
    expect(output).to include('command conflicts:')
    expect(output).to include("'test-command' conflicts with the following plugins:")
  end

  it 'shows no conflicts message when none exist' do
    allow(command).to receive(:loaded_plugins).and_return({ 'plugin1' => {}, 'plugin2' => {} })
    allow(command).to receive(:detect_all_conflicts).and_return({})
    output = capture_stdout { command.execute([], {}) }
    expect(output).to include('✅ No conflicts detected.')
  end
end
