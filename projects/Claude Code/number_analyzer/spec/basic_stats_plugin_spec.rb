# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'BasicStatsPlugin' do
  let(:plugin_system) { NumberAnalyzer::PluginSystem.new }
  let(:sample_data) { [1, 2, 3, 4, 5] }

  before do
    # Ensure clean state for each test
    plugin_system.instance_variable_set(:@plugins, {})
    plugin_system.instance_variable_set(:@loaded_plugins, Set.new)
  end

  describe 'plugin registration and loading' do
    context 'when BasicStatsPlugin exists' do
      it 'can be registered as a statistics plugin' do
        # This should fail initially since BasicStatsPlugin doesn't exist yet
        expect { require_relative '../plugins/basic_stats_plugin' }.not_to raise_error
        expect(defined?(BasicStatsPlugin)).to be_truthy
      end

      it 'implements the StatisticsPlugin interface correctly' do
        require_relative '../plugins/basic_stats_plugin'

        expect(BasicStatsPlugin).to respond_to(:plugin_name)
        expect(BasicStatsPlugin).to respond_to(:plugin_version)
        expect(BasicStatsPlugin).to respond_to(:plugin_description)
        expect(BasicStatsPlugin).to respond_to(:plugin_author)
        expect(BasicStatsPlugin).to respond_to(:plugin_dependencies)
        expect(BasicStatsPlugin.plugin_name).to eq('basic_stats')
      end

      it 'provides correct plugin metadata' do
        require_relative '../plugins/basic_stats_plugin'

        expect(BasicStatsPlugin.plugin_name).to eq('basic_stats')
        expect(BasicStatsPlugin.plugin_version).to match(/\d+\.\d+\.\d+/)
        expect(BasicStatsPlugin.plugin_description).to include('basic')
        expect(BasicStatsPlugin.plugin_dependencies).to be_an(Array)
      end
    end
  end

  describe 'plugin functionality' do
    before do
      require_relative '../plugins/basic_stats_plugin'
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
    end

    it 'can be loaded by the plugin system' do
      expect(plugin_system.load_plugin('basic_stats')).to be true
      expect(plugin_system.plugin_loaded?('basic_stats')).to be true
    end

    it 'extends NumberAnalyzer with basic statistics methods' do
      plugin_system.load_plugin('basic_stats')
      analyzer = NumberAnalyzer.new(sample_data)

      expect(analyzer).to respond_to(:sum)
      expect(analyzer).to respond_to(:mean)
      expect(analyzer).to respond_to(:mode)
      expect(analyzer).to respond_to(:variance)
      expect(analyzer).to respond_to(:standard_deviation)
    end

    it 'provides correct statistical calculations' do
      plugin_system.load_plugin('basic_stats')
      analyzer = NumberAnalyzer.new(sample_data)

      expect(analyzer.sum).to eq(15)
      expect(analyzer.mean).to eq(3.0)
      expect(analyzer.mode).to eq([]) # No mode for unique values
      expect(analyzer.variance).to eq(2.0)
      expect(analyzer.standard_deviation).to be_within(0.001).of(1.414)
    end
  end

  describe 'CLI command registration' do
    before do
      require_relative '../plugins/basic_stats_plugin'
    end

    it 'registers CLI commands for basic statistics' do
      expected_commands = %w[sum mean mode variance std-dev]
      plugin_commands = BasicStatsPlugin.plugin_commands

      expected_commands.each do |command|
        expect(plugin_commands).to have_key(command)
      end
    end

    it 'maps commands to correct method names' do
      plugin_commands = BasicStatsPlugin.plugin_commands

      expect(plugin_commands['sum']).to eq(:sum)
      expect(plugin_commands['mean']).to eq(:mean)
      expect(plugin_commands['mode']).to eq(:mode)
      expect(plugin_commands['variance']).to eq(:variance)
      expect(plugin_commands['std-dev']).to eq(:standard_deviation)
    end
  end

  describe 'backward compatibility' do
    it 'maintains compatibility with existing BasicStats module behavior' do
      # Load both the plugin and original module for comparison
      require_relative '../plugins/basic_stats_plugin'

      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.load_plugin('basic_stats')

      plugin_analyzer = NumberAnalyzer.new(sample_data)
      legacy_analyzer = NumberAnalyzer.new(sample_data)
      legacy_analyzer.extend(BasicStats)

      # Compare results
      expect(plugin_analyzer.sum).to eq(legacy_analyzer.sum)
      expect(plugin_analyzer.mean).to eq(legacy_analyzer.mean)
      expect(plugin_analyzer.mode).to eq(legacy_analyzer.mode)
      expect(plugin_analyzer.variance).to eq(legacy_analyzer.variance)
      expect(plugin_analyzer.standard_deviation).to eq(legacy_analyzer.standard_deviation)
    end
  end

  describe 'error handling' do
    it 'handles empty data gracefully' do
      require_relative '../plugins/basic_stats_plugin'
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.load_plugin('basic_stats')

      analyzer = NumberAnalyzer.new([])

      expect(analyzer.sum).to eq(0)
      expect(analyzer.variance).to eq(0.0)
      expect(analyzer.standard_deviation).to eq(0.0)
    end

    it 'handles single value data' do
      require_relative '../plugins/basic_stats_plugin'
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.load_plugin('basic_stats')

      analyzer = NumberAnalyzer.new([42])

      expect(analyzer.sum).to eq(42)
      expect(analyzer.mean).to eq(42.0)
      expect(analyzer.variance).to eq(0.0)
      expect(analyzer.standard_deviation).to eq(0.0)
    end
  end
end
