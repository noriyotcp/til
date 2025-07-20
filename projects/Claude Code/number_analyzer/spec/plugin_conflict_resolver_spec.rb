# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer/plugin_conflict_resolver'
require_relative '../lib/number_analyzer/plugin_priority'

RSpec.describe Numana::PluginConflictResolver do
  let(:priority_system) { Numana::PluginPriority.new }
  let(:resolver) { described_class.new(priority_system) }

  # Mock plugin classes for testing
  let(:plugin_a_class) do
    Class.new do
      def self.plugin_name = 'PluginA'
      def self.plugin_commands = { 'command1' => :method1, 'shared' => :shared_method }
      def self.public_instance_methods(_) = %i[method1 shared_method]
    end
  end

  let(:plugin_b_class) do
    Class.new do
      def self.plugin_name = 'PluginB'
      def self.plugin_commands = { 'command2' => :method2, 'shared' => :different_shared }
      def self.public_instance_methods(_) = %i[method2 shared_method]
    end
  end

  let(:plugins_registry) do
    {
      'plugin_a' => {
        class: plugin_a_class,
        extension_point: :statistics_module,
        metadata: {
          commands: { 'command1' => :method1, 'shared' => :shared_method },
          author: 'Test Author A'
        }
      },
      'plugin_b' => {
        class: plugin_b_class,
        extension_point: :statistics_module,
        metadata: {
          commands: { 'command2' => :method2, 'shared' => :different_shared },
          author: 'Test Author B'
        }
      }
    }
  end

  before do
    # Set up priority system using auto-detection
    priority_system.set_priority_with_auto_detection('plugin_a', { core: true })
    priority_system.set_priority_with_auto_detection('plugin_b', { development: false })
  end

  describe '#initialize' do
    it 'initializes with empty conflict log' do
      expect(resolver.generate_conflict_report[:total_conflicts]).to eq(0)
    end

    it 'uses provided priority system' do
      custom_priority = Numana::PluginPriority.new
      custom_resolver = described_class.new(custom_priority)
      expect(custom_resolver).to be_a(described_class)
    end

    it 'creates default priority system if none provided' do
      default_resolver = described_class.new
      expect(default_resolver).to be_a(described_class)
    end
  end

  describe '#detect_conflicts' do
    context 'command conflicts' do
      it 'detects command name conflicts' do
        conflicts = resolver.detect_conflicts(plugins_registry)

        command_conflicts = conflicts[:command_conflicts]
        expect(command_conflicts).not_to be_empty

        shared_conflict = command_conflicts.find { |c| c[:name] == 'shared' }
        expect(shared_conflict).not_to be_nil
        expect(shared_conflict[:plugins]).to contain_exactly('plugin_a', 'plugin_b')
      end

      it 'ignores unique commands' do
        conflicts = resolver.detect_conflicts(plugins_registry)

        command_conflicts = conflicts[:command_conflicts]
        unique_commands = command_conflicts.select { |c| %w[command1 command2].include?(c[:name]) }
        expect(unique_commands).to be_empty
      end
    end

    context 'method conflicts' do
      it 'detects method name conflicts' do
        conflicts = resolver.detect_conflicts(plugins_registry)

        method_conflicts = conflicts[:method_conflicts]
        shared_method_conflict = method_conflicts.find { |c| c[:name] == :shared_method }
        expect(shared_method_conflict).not_to be_nil
        expect(shared_method_conflict[:plugins]).to contain_exactly('plugin_a', 'plugin_b')
      end
    end

    context 'namespace conflicts' do
      let(:similar_plugins_registry) do
        {
          'plugin_stats' => {
            class: plugin_a_class,
            metadata: { commands: {}, author: 'Test' }
          },
          'plugin_statistics' => {
            class: plugin_b_class,
            metadata: { commands: {}, author: 'Test' }
          }
        }
      end

      it 'detects similar plugin names' do
        conflicts = resolver.detect_conflicts(similar_plugins_registry)

        namespace_conflicts = conflicts[:namespace_conflicts]
        expect(namespace_conflicts).not_to be_empty

        similarity_conflict = namespace_conflicts.first
        expect(similarity_conflict[:plugins]).to contain_exactly('plugin_stats', 'plugin_statistics')
        expect(similarity_conflict[:similarity]).to be > 0.7
      end
    end
  end

  describe '#resolve_conflict' do
    let(:conflicting_plugins) { %w[plugin_a plugin_b] }

    context 'strict strategy' do
      it 'fails on any conflict' do
        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :strict)

        expect(resolution[:success]).to be false
        expect(resolution[:strategy]).to eq(:strict)
        expect(resolution[:error]).to include('Conflict detected')
      end
    end

    context 'warn_override strategy' do
      it 'resolves using priority with warning' do
        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :warn_override)

        expect(resolution[:success]).to be true
        expect(resolution[:strategy]).to eq(:warn_override)
        expect(resolution[:winner]).to eq('plugin_a') # Higher priority (core)
        expect(resolution[:losers]).to contain_exactly('plugin_b')
        expect(resolution[:warnings]).not_to be_empty
      end
    end

    context 'silent_override strategy' do
      it 'resolves using priority silently' do
        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :silent_override)

        expect(resolution[:success]).to be true
        expect(resolution[:strategy]).to eq(:silent_override)
        expect(resolution[:winner]).to eq('plugin_a')
        expect(resolution[:warnings]).to be_nil
      end
    end

    context 'namespace strategy' do
      it 'creates namespaces for all plugins' do
        resolution = resolver.resolve_conflict(:statistics_method, conflicting_plugins, :namespace)

        expect(resolution[:success]).to be true
        expect(resolution[:strategy]).to eq(:namespace)
        expect(resolution[:winner]).to be_nil # All coexist
        expect(resolution[:namespaced_plugins]).to have_key('plugin_a')
        expect(resolution[:namespaced_plugins]).to have_key('plugin_b')
      end

      it 'generates unique namespaces' do
        resolution = resolver.resolve_conflict(:statistics_method, conflicting_plugins, :namespace)

        namespaces = resolution[:namespaced_plugins].values
        expect(namespaces.uniq.size).to eq(namespaces.size) # All unique
      end
    end

    context 'interactive strategy' do
      it 'falls back to auto when no interactive response' do
        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :interactive)

        expect(resolution[:success]).to be true
        expect(resolution[:strategy]).to eq(:interactive)
        expect(resolution[:message]).to include('automatic fallback')
      end

      it 'uses cached interactive response when available' do
        # Set up interactive response
        resolver.set_interactive_response(:command_name, conflicting_plugins, {
                                            action: :select_plugin,
                                            plugin: 'plugin_b'
                                          })

        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :interactive)

        expect(resolution[:success]).to be true
        expect(resolution[:winner]).to eq('plugin_b')
        expect(resolution[:user_choice]).to be true
      end

      it 'handles namespace_all interactive response' do
        resolver.set_interactive_response(:command_name, conflicting_plugins, {
                                            action: :namespace_all
                                          })

        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :interactive)

        expect(resolution[:success]).to be true
        expect(resolution[:namespaced_plugins]).to be_a(Hash)
        expect(resolution[:user_choice]).to be true
      end

      it 'handles cancel interactive response' do
        resolver.set_interactive_response(:command_name, conflicting_plugins, {
                                            action: :cancel
                                          })

        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :interactive)

        expect(resolution[:success]).to be false
        expect(resolution[:error]).to include('cancelled')
      end
    end

    context 'auto strategy' do
      it 'uses warn_override for command conflicts' do
        resolution = resolver.resolve_conflict(:command_name, conflicting_plugins, :auto)

        expect(resolution[:success]).to be true
        expect(resolution[:winner]).to eq('plugin_a')
        expect(resolution[:warnings]).not_to be_empty
      end

      it 'uses namespace for statistics method conflicts' do
        resolution = resolver.resolve_conflict(:statistics_method, conflicting_plugins, :auto)

        expect(resolution[:success]).to be true
        expect(resolution[:namespaced_plugins]).to be_a(Hash)
      end

      it 'uses silent_override for file format conflicts' do
        resolution = resolver.resolve_conflict(:file_format, conflicting_plugins, :auto)

        expect(resolution[:success]).to be true
        expect(resolution[:winner]).to eq('plugin_a')
        expect(resolution[:warnings]).to be_nil
      end

      it 'chains validators for validator conflicts' do
        resolution = resolver.resolve_conflict(:validator, conflicting_plugins, :auto)

        expect(resolution[:success]).to be true
        expect(resolution[:chain_order]).to eq(%w[plugin_a plugin_b]) # Priority order
        expect(resolution[:message]).to include('Chained validators')
      end
    end

    it 'raises error for invalid strategy' do
      expect do
        resolver.resolve_conflict(:command_name, conflicting_plugins, :invalid_strategy)
      end.to raise_error(ArgumentError, /Invalid resolution strategy/)
    end
  end

  describe '#resolve_all_conflicts' do
    let(:conflicts) do
      {
        command_conflicts: [
          { name: 'shared', type: :command, plugins: %w[plugin_a plugin_b] }
        ],
        method_conflicts: [
          { name: :shared_method, type: :method, plugins: %w[plugin_a plugin_b] }
        ]
      }
    end

    it 'resolves all conflicts with default strategies' do
      resolutions = resolver.resolve_all_conflicts(conflicts)

      expect(resolutions).to have_key('shared')
      expect(resolutions).to have_key(:shared_method)
      expect(resolutions.values.all? { |r| r[:success] }).to be true
    end

    it 'applies strategy overrides' do
      strategy_overrides = { command_conflicts: :strict, method_conflicts: :namespace }
      resolutions = resolver.resolve_all_conflicts(conflicts, strategy_overrides)

      # Command conflict should fail with strict
      expect(resolutions['shared'][:success]).to be false
      expect(resolutions['shared'][:strategy]).to eq(:strict)

      # Method conflict should succeed with namespace
      expect(resolutions[:shared_method][:success]).to be true
      expect(resolutions[:shared_method][:namespaced_plugins]).to be_a(Hash)
    end

    it 'applies global strategy override' do
      strategy_overrides = { global: :namespace }
      resolutions = resolver.resolve_all_conflicts(conflicts, strategy_overrides)

      resolutions.each_value do |resolution|
        expect(resolution[:namespaced_plugins]).to be_a(Hash)
      end
    end
  end

  describe '#generate_conflict_report' do
    before do
      # Generate some conflicts and resolutions
      conflicts = resolver.detect_conflicts(plugins_registry)
      resolver.resolve_all_conflicts(conflicts)
    end

    it 'generates comprehensive conflict report' do
      report = resolver.generate_conflict_report

      expect(report[:title]).to eq('Plugin Conflict Resolution Report')
      expect(report[:generated_at]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
      expect(report[:total_conflicts]).to be > 0
      expect(report[:conflicts_by_type]).to be_a(Hash)
      expect(report[:resolutions]).to be_a(Hash)
      expect(report[:recommendations]).to be_an(Array)
    end

    it 'includes namespace mappings' do
      # Create a namespace conflict resolution
      resolver.resolve_conflict(:statistics_method, %w[plugin_a plugin_b], :namespace)

      report = resolver.generate_conflict_report
      expect(report[:namespace_mappings]).to be_a(Hash)
    end
  end

  describe '#simulate_resolution' do
    let(:conflicts) do
      {
        command_conflicts: [
          { name: 'shared', type: :command, plugins: %w[plugin_a plugin_b] }
        ]
      }
    end

    it 'simulates resolution without persisting state' do
      original_cache_size = resolver.instance_variable_get(:@resolution_cache).size

      simulation = resolver.simulate_resolution(conflicts, { command: :namespace })

      expect(simulation[:resolutions]).to have_key('shared')
      expect(simulation[:would_succeed]).to be true
      expect(simulation[:conflicts_resolved]).to eq(1)

      # State should not be persisted
      final_cache_size = resolver.instance_variable_get(:@resolution_cache).size
      expect(final_cache_size).to eq(original_cache_size)
    end
  end

  describe '#conflict_exists?' do
    before do
      conflicts = resolver.detect_conflicts(plugins_registry)
      resolver.resolve_all_conflicts(conflicts)
    end

    it 'detects existing conflicts between plugins' do
      expect(resolver.conflict_exists?('plugin_a', 'plugin_b')).to be true
    end

    it 'returns false for non-conflicting plugins' do
      expect(resolver.conflict_exists?('plugin_a', 'plugin_c')).to be false
    end

    it 'filters by conflict type when specified' do
      expect(resolver.conflict_exists?('plugin_a', 'plugin_b', :command_conflicts)).to be true
      expect(resolver.conflict_exists?('plugin_a', 'plugin_b', :nonexistent_type)).to be false
    end
  end

  describe '#get_conflicting_plugins' do
    before do
      conflicts = resolver.detect_conflicts(plugins_registry)
      resolver.resolve_all_conflicts(conflicts)
    end

    it 'returns plugins that conflict with given plugin' do
      conflicting = resolver.get_conflicting_plugins('plugin_a')
      expect(conflicting).to include('plugin_b')
    end

    it 'returns empty array for non-conflicting plugin' do
      conflicting = resolver.get_conflicting_plugins('plugin_c')
      expect(conflicting).to be_empty
    end
  end

  describe '#clear_conflict_history' do
    before do
      conflicts = resolver.detect_conflicts(plugins_registry)
      resolver.resolve_all_conflicts(conflicts)
    end

    it 'clears all conflict history' do
      expect(resolver.generate_conflict_report[:total_conflicts]).to be > 0

      resolver.clear_conflict_history

      expect(resolver.generate_conflict_report[:total_conflicts]).to eq(0)
    end
  end

  describe '#set_default_strategy' do
    it 'sets default strategy for conflict type' do
      resolver.set_default_strategy(:command_name, :strict)

      resolution = resolver.resolve_conflict(:command_name, %w[plugin_a plugin_b])
      expect(resolution[:strategy]).to eq(:strict)
    end

    it 'validates strategy' do
      expect do
        resolver.set_default_strategy(:command_name, :invalid)
      end.to raise_error(ArgumentError, /Invalid resolution strategy/)
    end
  end

  describe '#get_cached_resolution' do
    it 'returns nil for uncached resolution' do
      cached = resolver.get_cached_resolution(:command_name, %w[plugin_a plugin_b])
      expect(cached).to be_nil
    end

    it 'returns cached resolution after resolving' do
      resolution = resolver.resolve_conflict(:command_name, %w[plugin_a plugin_b], :namespace)
      cached = resolver.get_cached_resolution(:command_name, %w[plugin_a plugin_b])

      expect(cached).to eq(resolution)
    end
  end

  describe 'private methods' do
    describe 'similarity calculation' do
      it 'calculates string similarity correctly' do
        # Access private method for testing
        similarity = resolver.send(:calculate_name_similarity, 'plugin_stats', 'plugin_statistics')
        expect(similarity).to be > 0.7

        similarity = resolver.send(:calculate_name_similarity, 'completely', 'different')
        expect(similarity).to be < 0.5
      end

      it 'handles edge cases' do
        expect(resolver.send(:calculate_name_similarity, '', 'test')).to eq(0.0)
        expect(resolver.send(:calculate_name_similarity, 'same', 'same')).to eq(1.0)
      end
    end

    describe 'namespace generation' do
      it 'generates unique namespaces based on priority' do
        namespace_a = resolver.send(:generate_namespace, 'plugin_a')
        namespace_b = resolver.send(:generate_namespace, 'plugin_b')

        expect(namespace_a).to start_with('core_') # core priority
        expect(namespace_b).to start_with('local_') # local priority
        expect(namespace_a).not_to eq(namespace_b)
      end
    end

    describe 'levenshtein distance' do
      it 'calculates edit distance correctly' do
        distance = resolver.send(:levenshtein_distance, 'kitten', 'sitting')
        expect(distance).to eq(3)

        distance = resolver.send(:levenshtein_distance, 'same', 'same')
        expect(distance).to eq(0)
      end
    end
  end

  describe 'resolution strategies constants' do
    it 'has all required strategy definitions' do
      expect(described_class::RESOLUTION_STRATEGIES).to include(
        :strict, :warn_override, :silent_override, :namespace, :interactive, :auto
      )
    end

    it 'has default strategies for conflict types' do
      expect(described_class::DEFAULT_STRATEGIES).to include(
        :command_name, :statistics_method, :file_format, :output_format, :validator
      )
    end
  end
end
