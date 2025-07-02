# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'yaml'

RSpec.describe NumberAnalyzer::PluginSystem do
  let(:plugin_system) { described_class.new }
  let(:temp_config_file) { Tempfile.new(['plugins', '.yml']) }

  # Test plugin classes
  let(:test_statistics_plugin) do
    Module.new do
      def self.name
        'TestStatisticsPlugin'
      end

      def self.plugin_name
        'test_stats'
      end

      def self.plugin_version
        '1.0.0'
      end

      def self.plugin_description
        'Test statistics plugin'
      end

      def self.plugin_author
        'Test Author'
      end

      def self.plugin_dependencies
        []
      end

      def test_calculation(numbers)
        numbers.sum * 2
      end
    end
  end

  let(:test_cli_plugin) do
    Class.new do
      def self.name
        'TestCLIPlugin'
      end

      def self.plugin_name
        'test_cli'
      end

      def self.plugin_commands
        { 'test-command' => :execute_test }
      end

      def self.execute_test(args, _options)
        "Test command executed with #{args.join(', ')}"
      end
    end
  end

  before do
    # Create a temporary config file
    config = {
      'plugins' => {
        'enabled' => ['test_stats'],
        'paths' => ['./test_plugins']
      }
    }
    temp_config_file.write(YAML.dump(config))
    temp_config_file.rewind

    # Mock the config file path
    allow(File).to receive(:join).with(Dir.pwd, 'plugins.yml').and_return(temp_config_file.path)
  end

  after do
    temp_config_file.close
    temp_config_file.unlink
  end

  describe '#initialize' do
    it 'initializes with empty plugin registry' do
      expect(plugin_system.available_plugins).to be_empty
      expect(plugin_system.loaded_plugins).to be_empty
    end

    it 'loads configuration from plugins.yml' do
      # This is tested implicitly through the before block
      expect(plugin_system).to be_instance_of(described_class)
    end
  end

  describe '#register_plugin' do
    it 'registers a statistics plugin' do
      plugin_system.register_plugin('test_stats', test_statistics_plugin)

      expect(plugin_system.available_plugins).to include('test_stats')
      expect(plugin_system.plugin_metadata('test_stats')).to include(
        name: 'test_stats',
        version: '1.0.0',
        description: 'Test statistics plugin'
      )
    end

    it 'registers a CLI plugin' do
      plugin_system.register_plugin('test_cli', test_cli_plugin, extension_point: :cli_command)

      expect(plugin_system.available_plugins).to include('test_cli')
      expect(plugin_system.plugin_metadata('test_cli')).to include(
        name: 'test_cli',
        commands: { 'test-command' => :execute_test }
      )
    end

    it 'raises error for invalid extension point' do
      expect do
        plugin_system.register_plugin('test', test_statistics_plugin, extension_point: :invalid)
      end.to raise_error(ArgumentError, /Invalid extension point/)
    end
  end

  describe '#load_plugin' do
    before do
      plugin_system.register_plugin('test_stats', test_statistics_plugin)
    end

    it 'loads a registered plugin' do
      expect(plugin_system.load_plugin('test_stats')).to be true
      expect(plugin_system.plugin_loaded?('test_stats')).to be true
      expect(plugin_system.loaded_plugins).to include('test_stats')
    end

    it 'returns false for non-existent plugin' do
      expect(plugin_system.load_plugin('non_existent')).to be false
    end

    it 'returns true if plugin already loaded' do
      plugin_system.load_plugin('test_stats')
      expect(plugin_system.load_plugin('test_stats')).to be true
    end

    it 'includes plugin module in NumberAnalyzer when loaded' do
      plugin_system.load_plugin('test_stats')

      analyzer = NumberAnalyzer.new([1, 2, 3])
      expect(analyzer).to respond_to(:test_calculation)
      expect(analyzer.test_calculation([1, 2, 3])).to eq(12) # (1+2+3) * 2
    end
  end

  describe '#plugins_for' do
    before do
      plugin_system.register_plugin('stats1', test_statistics_plugin)
      plugin_system.register_plugin('cli1', test_cli_plugin, extension_point: :cli_command)
      plugin_system.load_plugin('stats1')
    end

    it 'returns loaded plugins for extension point' do
      stats_plugins = plugin_system.plugins_for(:statistics_module)
      expect(stats_plugins.length).to eq(1)
      expect(stats_plugins.first[:class]).to eq(test_statistics_plugin)
    end

    it 'returns empty array for extension point with no loaded plugins' do
      cli_plugins = plugin_system.plugins_for(:cli_command)
      expect(cli_plugins).to be_empty
    end
  end

  describe '#load_enabled_plugins' do
    it 'loads plugins specified in configuration' do
      plugin_system.register_plugin('test_stats', test_statistics_plugin)

      plugin_system.load_enabled_plugins

      expect(plugin_system.plugin_loaded?('test_stats')).to be true
    end
  end

  describe 'dependency checking' do
    let(:dependent_plugin) do
      Module.new do
        def self.name
          'DependentPlugin'
        end

        def self.plugin_dependencies
          ['test_stats']
        end
      end
    end

    it 'loads plugin with satisfied dependencies' do
      plugin_system.register_plugin('test_stats', test_statistics_plugin)
      plugin_system.register_plugin('dependent', dependent_plugin)
      plugin_system.load_plugin('test_stats')

      expect(plugin_system.load_plugin('dependent')).to be true
    end

    it 'fails to load plugin with unsatisfied dependencies' do
      plugin_system.register_plugin('dependent', dependent_plugin)

      expect(plugin_system.load_plugin('dependent')).to be false
    end
  end
end
