# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli'
require 'numana/plugin_system'
require 'numana/plugin_interface'

RSpec.describe 'Plugins CLI Commands' do
  before do
    # Reset plugin state for each test
    Numana::CLI.reset_plugin_state!
    allow(Numana::CLI).to receive(:plugin_system).and_return(plugin_system)
    allow(Numana::CLI).to receive(:initialize_plugins) # Skip plugin initialization
  end

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

      def self.provided_methods
        %i[test_method another_method]
      end
    end
  end

  let(:another_plugin_class) do
    Class.new do
      def self.commands
        { 'test-command' => :run_test, 'unique-command' => :run_unique }
      end

      def self.provided_methods
        %i[test_method unique_method]
      end
    end
  end

  describe 'plugins help' do
    it 'shows help when no subcommand is provided' do
      expect { Numana::CLI.run(['plugins']) }.to output(/Usage: bundle exec numana plugins/).to_stdout
    end

    it 'shows help with --help flag' do
      expect { Numana::CLI.run(['plugins', '--help']) }.to output(/Subcommands:/).to_stdout
    end

    it 'shows help with help subcommand' do
      expect { Numana::CLI.run(%w[plugins help]) }.to output(/list \[--show-conflicts\]/).to_stdout
    end
  end

  describe 'plugins list' do
    it 'dispatches to ListCommand' do
      list_command_instance = instance_double(Numana::Commands::Plugins::ListCommand)
      allow(Numana::Commands::Plugins::ListCommand).to receive(:new).and_return(list_command_instance)
      expect(list_command_instance).to receive(:execute)

      Numana::CLI.run(%w[plugins list])
    end
  end

  describe 'plugins conflicts' do
    it 'dispatches to ConflictsCommand' do
      conflicts_command_instance = instance_double(Numana::Commands::Plugins::ConflictsCommand)
      allow(Numana::Commands::Plugins::ConflictsCommand).to receive(:new).and_return(conflicts_command_instance)
      expect(conflicts_command_instance).to receive(:execute)

      Numana::CLI.run(%w[plugins conflicts])
    end
  end

  describe 'plugins resolve' do
    it 'dispatches to ResolveCommand' do
      resolve_command_instance = instance_double(Numana::Commands::Plugins::ResolveCommand)
      allow(Numana::Commands::Plugins::ResolveCommand).to receive(:new).and_return(resolve_command_instance)
      expect(resolve_command_instance).to receive(:execute)

      Numana::CLI.run(%w[plugins resolve test_plugin])
    end
  end

  describe 'unknown subcommand' do
    it 'shows error for unknown subcommand' do
      expect { Numana::CLI.run(%w[plugins unknown]) }
        .to output(/エラー: 不明なpluginsサブコマンド: unknown/)
        .to_stdout.and raise_error(SystemExit)
    end
  end
end
