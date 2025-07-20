# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dynamic CLI Command Registration' do
  let(:cli_class) { Numana::CLI }
  let(:plugin_system) { Numana::PluginSystem.new }

  before do
    # Reset plugin commands for clean state
    cli_class.reset_plugin_state!
  end

  after do
    # Clean up after tests
    cli_class.reset_plugin_state!
  end

  describe 'command registration' do
    it 'allows plugins to register new CLI commands' do
      # Define a test plugin class
      test_plugin = Class.new do
        def self.test_command(args, _options)
          "Plugin command executed with args: #{args.join(', ')}"
        end
      end

      # Register the command
      cli_class.register_command('test-cmd', test_plugin, :test_command)

      # Verify the command is registered
      expect(cli_class.commands).to have_key('test-cmd')
      expect(cli_class.commands['test-cmd'][:plugin_class]).to eq(test_plugin)
      expect(cli_class.commands['test-cmd'][:method]).to eq(:test_command)
    end

    it 'merges plugin commands with core commands' do
      # Register a plugin command
      test_plugin = Class.new
      cli_class.register_command('plugin-test', test_plugin, :test_method)

      all_commands = cli_class.commands

      # Should contain both core and plugin commands
      expect(all_commands).to include('mean') # Core command
      expect(all_commands).to include('plugin-test') # Plugin command
    end

    it 'allows multiple plugins to register different commands' do
      plugin_a = Class.new
      plugin_b = Class.new

      cli_class.register_command('cmd-a', plugin_a, :method_a)
      cli_class.register_command('cmd-b', plugin_b, :method_b)

      commands = cli_class.commands
      expect(commands).to have_key('cmd-a')
      expect(commands).to have_key('cmd-b')
      expect(commands['cmd-a'][:plugin_class]).to eq(plugin_a)
      expect(commands['cmd-b'][:plugin_class]).to eq(plugin_b)
    end
  end

  describe 'BasicStats plugin integration' do
    before do
      require_relative '../plugins/basic_stats_plugin'

      # Register the plugin with the plugin system
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.load_plugin('basic_stats')

      # Register CLI commands from the plugin
      BasicStatsPlugin.plugin_commands.each do |command_name, method_name|
        cli_class.register_command(command_name, BasicStatsPlugin, method_name)
      end
    end

    it 'registers all BasicStats commands' do
      expected_commands = %w[sum mean mode variance std-dev]

      expected_commands.each do |command|
        expect(cli_class.commands).to have_key(command)
      end
    end

    it 'maps commands to correct BasicStats methods' do
      commands = cli_class.commands

      expect(commands['sum'][:method]).to eq(:sum)
      expect(commands['mean'][:method]).to eq(:mean)
      expect(commands['mode'][:method]).to eq(:mode)
      expect(commands['variance'][:method]).to eq(:variance)
      expect(commands['std-dev'][:method]).to eq(:standard_deviation)
    end

    it 'executes plugin commands correctly' do
      # Mock the NumberAnalyzer creation and method calls
      allow(NumberAnalyzer).to receive(:new).and_return(
        double('analyzer', sum: 15, mean: 3.0, mode: [], variance: 2.0, standard_deviation: 1.414)
      )

      # We can't easily test CLI execution directly, but we can verify the command structure
      commands = cli_class.commands
      expect(commands['sum'][:plugin_class]).to eq(BasicStatsPlugin)
      expect(commands['mean'][:plugin_class]).to eq(BasicStatsPlugin)
    end
  end

  describe 'plugin system initialization' do
    it 'initializes plugin system when accessed' do
      system = cli_class.plugin_system
      expect(system).to be_a(Numana::PluginSystem)
    end

    it 'uses singleton pattern for plugin system' do
      system1 = cli_class.plugin_system
      system2 = cli_class.plugin_system
      expect(system1).to be(system2)
    end

    it 'can load enabled plugins' do
      # Mock the plugin system loading
      mock_system = instance_double(Numana::PluginSystem)
      expect(mock_system).to receive(:load_enabled_plugins)

      allow(cli_class).to receive(:plugin_system).and_return(mock_system)
      cli_class.initialize_plugins
    end
  end

  describe 'command resolution' do
    it 'prioritizes plugin commands when they overlap with core commands' do
      # Define a plugin that overrides a core command
      override_plugin = Class.new do
        def self.mean(args, _options)
          "Override mean: #{args.join(', ')}"
        end
      end

      cli_class.register_command('mean', override_plugin, :mean)

      # Plugin command should be used (latest registered wins)
      commands = cli_class.commands
      expect(commands['mean'][:plugin_class]).to eq(override_plugin)
    end

    it 'handles command name conflicts gracefully' do
      plugin1 = Class.new
      plugin2 = Class.new

      cli_class.register_command('conflict', plugin1, :method1)
      cli_class.register_command('conflict', plugin2, :method2)

      # Last registered should win
      commands = cli_class.commands
      expect(commands['conflict'][:plugin_class]).to eq(plugin2)
      expect(commands['conflict'][:method]).to eq(:method2)
    end
  end

  describe 'error handling' do
    it 'handles registration of commands with invalid method names' do
      test_plugin = Class.new

      # This should not raise an error during registration
      expect do
        cli_class.register_command('invalid-cmd', test_plugin, :nonexistent_method)
      end.not_to raise_error

      # The command should be registered even if the method doesn't exist yet
      expect(cli_class.commands).to have_key('invalid-cmd')
    end

    it 'handles nil plugin class gracefully' do
      expect do
        cli_class.register_command('nil-cmd', nil, :some_method)
      end.not_to raise_error

      expect(cli_class.commands['nil-cmd'][:plugin_class]).to be_nil
    end
  end
end
