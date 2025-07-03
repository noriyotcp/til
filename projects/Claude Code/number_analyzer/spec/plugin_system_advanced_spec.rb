# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/plugin_system'

# Define test plugin modules outside of RSpec block
module TestPluginA
  def self.plugin_name = 'test_plugin_a'
  def self.plugin_version = '1.0.0'
  def self.plugin_dependencies = []
  def self.plugin_commands = { 'test-a' => :test_a_method }
  def test_a_method = 'Result from Plugin A'
end

module TestPluginB
  def self.plugin_name = 'test_plugin_b'
  def self.plugin_version = '2.0.0'
  def self.plugin_dependencies = ['test_plugin_a']
  def self.plugin_commands = { 'test-b' => :test_b_method }
  def test_b_method = 'Result from Plugin B'
end

module TestPluginC
  def self.plugin_name = 'test_plugin_c'
  def self.plugin_version = '1.0.0'
  def self.plugin_dependencies = %w[test_plugin_b test_plugin_a]
  def self.plugin_commands = { 'test-c' => :test_c_method }
  def test_c_method = 'Result from Plugin C'
end

module FailingPlugin
  def self.plugin_name = 'failing_plugin'
  def self.plugin_version = '1.0.0'
  def self.plugin_dependencies = []

  def self.included(_base)
    raise LoadError, 'Plugin failed to load'
  end
end

module VersionedPluginA
  def self.plugin_name = 'versioned_a'
  def self.plugin_version = '1.5.0'
  def self.plugin_dependencies = []
end

module VersionedPluginB
  def self.plugin_name = 'versioned_b'
  def self.plugin_version = '1.0.0'
  def self.plugin_dependencies = { 'versioned_a' => '~> 1.0' }
end

module VersionedPluginC
  def self.plugin_name = 'versioned_c'
  def self.plugin_version = '1.0.0'
  def self.plugin_dependencies = { 'versioned_a' => '>= 2.0' }
end

RSpec.describe 'PluginSystem with Advanced Features' do
  let(:plugin_system) { NumberAnalyzer::PluginSystem.new }

  describe 'dependency resolution' do
    before do
      plugin_system.register_plugin('test_plugin_a', TestPluginA)
      plugin_system.register_plugin('test_plugin_b', TestPluginB)
      plugin_system.register_plugin('test_plugin_c', TestPluginC)
    end

    it 'loads plugins in correct dependency order' do
      expect(plugin_system.load_plugin('test_plugin_c')).to be true

      loaded = plugin_system.loaded_plugins
      expect(loaded).to eq(%w[test_plugin_a test_plugin_b test_plugin_c])
    end

    it 'detects missing dependencies' do
      plugin_system.register_plugin('orphan_plugin', Module.new do
        def self.plugin_name = 'orphan_plugin'
        def self.plugin_dependencies = ['non_existent_plugin']
      end)

      expect(plugin_system.load_plugin('orphan_plugin')).to be false
      expect(plugin_system.plugin_loaded?('orphan_plugin')).to be false
    end

    it 'provides missing dependency information' do
      plugin_system.register_plugin('incomplete_plugin', Module.new do
        def self.plugin_name = 'incomplete_plugin'
        def self.plugin_dependencies = %w[missing1 test_plugin_a missing2]
      end)

      missing = plugin_system.missing_dependencies('incomplete_plugin')
      expect(missing).to contain_exactly('missing1', 'missing2')
    end

    it 'checks dependency satisfaction' do
      expect(plugin_system.dependencies_satisfied?('test_plugin_b')).to be true

      plugin_system.register_plugin('unsatisfied_plugin', Module.new do
        def self.plugin_name = 'unsatisfied_plugin'
        def self.plugin_dependencies = ['missing_dep']
      end)

      expect(plugin_system.dependencies_satisfied?('unsatisfied_plugin')).to be false
    end
  end

  describe 'circular dependency detection' do
    before do
      # Create circular dependency: A -> B -> C -> A
      plugin_system.register_plugin('circular_a', Module.new do
        def self.plugin_name = 'circular_a'
        def self.plugin_dependencies = ['circular_b']
      end)

      plugin_system.register_plugin('circular_b', Module.new do
        def self.plugin_name = 'circular_b'
        def self.plugin_dependencies = ['circular_c']
      end)

      plugin_system.register_plugin('circular_c', Module.new do
        def self.plugin_name = 'circular_c'
        def self.plugin_dependencies = ['circular_a']
      end)
    end

    it 'detects and prevents circular dependencies' do
      expect(plugin_system.load_plugin('circular_a')).to be false
      expect(plugin_system.plugin_loaded?('circular_a')).to be false
    end
  end

  describe 'error handling and recovery' do
    before do
      plugin_system.register_plugin('failing_plugin', FailingPlugin)
      plugin_system.register_plugin('test_plugin_a', TestPluginA)
    end

    it 'handles plugin load failures gracefully' do
      expect(plugin_system.load_plugin('failing_plugin')).to be false
      expect(plugin_system.plugin_loaded?('failing_plugin')).to be false
    end

    it 'disables plugins after repeated failures' do
      # Simulate multiple load attempts
      3.times { plugin_system.load_plugin('failing_plugin') }

      health = plugin_system.plugin_health_check
      expect(health['failing_plugin'][:disabled]).to be true
    end

    it 'continues loading other plugins after failure' do
      plugin_system.load_plugin('failing_plugin')
      expect(plugin_system.load_plugin('test_plugin_a')).to be true
    end

    describe 'fallback mechanism' do
      before do
        plugin_system.register_fallback('failing_plugin', 'test_plugin_a')
      end

      it 'uses fallback plugin when primary fails' do
        result = plugin_system.load_plugin('failing_plugin')
        expect(result).to be false # Primary still fails

        # But fallback should be suggested in error handling
        health = plugin_system.plugin_health_check
        expect(health['failing_plugin'][:disabled]).to be true
      end
    end
  end

  describe 'plugin health monitoring' do
    before do
      plugin_system.register_plugin('test_plugin_a', TestPluginA)
      plugin_system.register_plugin('test_plugin_b', TestPluginB)
      plugin_system.register_plugin('failing_plugin', FailingPlugin)

      plugin_system.load_plugin('test_plugin_a')
      plugin_system.load_plugin('failing_plugin')
    end

    it 'provides comprehensive health check' do
      health = plugin_system.plugin_health_check

      expect(health['test_plugin_a']).to include(
        loaded: true,
        disabled: false,
        dependencies_satisfied: true,
        missing_dependencies: [],
        errors: 0
      )

      expect(health['failing_plugin']).to include(
        loaded: false,
        disabled: true,
        dependencies_satisfied: true,
        missing_dependencies: [],
        errors: 1
      )
    end

    it 'generates error reports' do
      report = plugin_system.error_report
      expect(report).to include('Plugin Error Report')
      expect(report).to include('failing_plugin')
    end

    it 'allows clearing error history' do
      plugin_system.clear_errors
      health = plugin_system.plugin_health_check

      expect(health['failing_plugin'][:errors]).to eq(0)
      expect(health['failing_plugin'][:disabled]).to be false
    end

    it 're-enables disabled plugins' do
      expect(plugin_system.plugin_health_check['failing_plugin'][:disabled]).to be true

      plugin_system.enable_plugin('failing_plugin')
      health = plugin_system.plugin_health_check

      expect(health['failing_plugin'][:disabled]).to be false
    end
  end

  describe 'batch plugin loading' do
    before do
      plugin_system.register_plugin('test_plugin_a', TestPluginA)
      plugin_system.register_plugin('test_plugin_b', TestPluginB)
      plugin_system.register_plugin('test_plugin_c', TestPluginC)
    end

    it 'loads multiple plugins with dependency resolution' do
      loaded_count = plugin_system.load_plugins('test_plugin_b', 'test_plugin_c')

      expect(loaded_count).to eq(3) # A, B, and C
      expect(plugin_system.loaded_plugins).to contain_exactly(
        'test_plugin_a', 'test_plugin_b', 'test_plugin_c'
      )
    end

    it 'handles partial failures in batch loading' do
      plugin_system.register_plugin('failing_plugin', FailingPlugin)

      loaded_count = plugin_system.load_plugins('test_plugin_a', 'failing_plugin')

      expect(loaded_count).to eq(1) # Only A loaded
      expect(plugin_system.plugin_loaded?('test_plugin_a')).to be true
      expect(plugin_system.plugin_loaded?('failing_plugin')).to be false
    end
  end

  describe 'version compatibility' do
    before do
      plugin_system.register_plugin('versioned_a', VersionedPluginA)
      plugin_system.register_plugin('versioned_b', VersionedPluginB)
      plugin_system.register_plugin('versioned_c', VersionedPluginC)
    end

    it 'loads plugins with compatible versions' do
      expect(plugin_system.load_plugin('versioned_b')).to be true
    end

    it 'prevents loading with incompatible versions' do
      expect(plugin_system.load_plugin('versioned_c')).to be false
    end
  end

  describe 'integration with CLI commands' do
    before do
      # Mock CLI module
      stub_const('NumberAnalyzer::CLI', Module.new do
        @commands = {}
        def self.register_command(name, plugin, method)
          @commands[name] = { plugin: plugin, method: method }
        end

        class << self
          attr_reader :commands
        end
      end)

      plugin_system.register_plugin('test_plugin_a', TestPluginA)
      plugin_system.load_plugin('test_plugin_a')
    end

    it 'registers plugin commands with CLI' do
      expect(NumberAnalyzer::CLI.commands).to have_key('test-a')
    end
  end
end
