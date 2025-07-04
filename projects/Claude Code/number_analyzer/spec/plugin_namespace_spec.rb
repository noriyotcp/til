# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer/plugin_namespace'
require_relative '../lib/number_analyzer/plugin_priority'

RSpec.describe NumberAnalyzer::PluginNamespace do
  let(:priority_system) { NumberAnalyzer::PluginPriority.new }
  let(:namespace_system) { described_class.new(priority_system) }

  # Mock plugin metadata for testing
  let(:plugin_metadata_a) do
    {
      name: 'machine_learning_plugin',
      version: '1.0.0',
      author: 'ML Team',
      priority_type: :official_gems
    }
  end

  let(:plugin_metadata_b) do
    {
      name: 'machine_learning_stats',
      version: '2.1.0',
      author: 'Stats Team',
      priority_type: :third_party_gems
    }
  end

  let(:plugin_metadata_c) do
    {
      name: 'core_statistics',
      version: '1.0.0',
      author: 'Core Team',
      priority_type: :core_plugins
    }
  end

  describe '#initialize' do
    it 'initializes with priority system' do
      expect(namespace_system).to be_a(described_class)
    end

    it 'creates default priority system if none provided' do
      default_namespace = described_class.new
      expect(default_namespace).to be_a(described_class)
    end
  end

  describe '#generate_namespace' do
    context 'basic namespace generation' do
      it 'generates unique namespace for plugin' do
        namespace = namespace_system.generate_namespace(plugin_metadata_a)

        expect(namespace).to be_a(String)
        expect(namespace).not_to be_empty
        expect(namespace).to match(/^[a-z0-9_]+$/) # Valid identifier format
      end

      it 'includes priority prefix in namespace' do
        namespace = namespace_system.generate_namespace(plugin_metadata_a)

        # Official gems should get 'of' prefix (official = 70)
        expect(namespace).to start_with('of_')
      end

      it 'sanitizes plugin name for namespace' do
        special_metadata = plugin_metadata_a.merge(name: 'special-plugin.name@1')
        namespace = namespace_system.generate_namespace(special_metadata)

        expect(namespace).to match(/^[a-z0-9_]+$/)
        expect(namespace).to include('special_plugin_name_1')
      end
    end

    context 'priority-based namespace prefixes' do
      it 'generates correct prefix for development priority' do
        dev_metadata = plugin_metadata_a.merge(priority_type: :development)
        namespace = namespace_system.generate_namespace(dev_metadata)

        expect(namespace).to start_with('de_') # development = 100
      end

      it 'generates correct prefix for core plugins' do
        namespace = namespace_system.generate_namespace(plugin_metadata_c)

        expect(namespace).to start_with('co_') # core_plugins = 90
      end

      it 'generates correct prefix for third party gems' do
        namespace = namespace_system.generate_namespace(plugin_metadata_b)

        expect(namespace).to start_with('th_') # third_party_gems = 50
      end

      it 'generates correct prefix for local plugins' do
        local_metadata = plugin_metadata_a.merge(priority_type: :local_plugins)
        namespace = namespace_system.generate_namespace(local_metadata)

        expect(namespace).to start_with('lo_') # local_plugins = 30
      end
    end

    context 'namespace uniqueness' do
      it 'generates different namespaces for different plugins' do
        namespace_a = namespace_system.generate_namespace(plugin_metadata_a)
        namespace_b = namespace_system.generate_namespace(plugin_metadata_b)

        expect(namespace_a).not_to eq(namespace_b)
      end

      it 'generates same namespace for same plugin' do
        namespace_first = namespace_system.generate_namespace(plugin_metadata_a)
        namespace_second = namespace_system.generate_namespace(plugin_metadata_a)

        expect(namespace_first).to eq(namespace_second)
      end
    end
  end

  describe '#detect_naming_conflicts' do
    let(:plugins_list) do
      [
        plugin_metadata_a,
        plugin_metadata_b,
        plugin_metadata_c
      ]
    end

    it 'detects similar plugin names' do
      conflicts = namespace_system.detect_naming_conflicts(plugins_list)

      expect(conflicts).to be_an(Array)
      # machine_learning_plugin vs machine_learning_stats should be detected
      ml_conflict = conflicts.find do |conflict|
        conflict[:plugins].include?(plugin_metadata_a[:name]) &&
          conflict[:plugins].include?(plugin_metadata_b[:name])
      end
      expect(ml_conflict).not_to be_nil
      expect(ml_conflict[:similarity]).to be > 0.7
    end

    it 'returns empty array when no conflicts' do
      unique_plugins = [
        plugin_metadata_a.merge(name: 'completely_different'),
        plugin_metadata_c.merge(name: 'totally_unique')
      ]

      conflicts = namespace_system.detect_naming_conflicts(unique_plugins)
      expect(conflicts).to be_empty
    end

    it 'includes conflict metadata' do
      conflicts = namespace_system.detect_naming_conflicts(plugins_list)

      conflicts.each do |conflict|
        expect(conflict).to have_key(:plugins)
        expect(conflict).to have_key(:similarity)
        expect(conflict).to have_key(:recommended_resolution)
        expect(conflict[:plugins]).to be_an(Array)
        expect(conflict[:similarity]).to be_a(Numeric)
      end
    end
  end

  describe '#resolve_naming_conflict' do
    let(:conflicting_plugins) { [plugin_metadata_a, plugin_metadata_b] }

    it 'creates namespaced versions of conflicting plugins' do
      resolution = namespace_system.resolve_naming_conflict(conflicting_plugins)

      expect(resolution).to have_key(:success)
      expect(resolution[:success]).to be true
      expect(resolution).to have_key(:namespaced_plugins)
      expect(resolution[:namespaced_plugins]).to be_a(Hash)
      expect(resolution[:namespaced_plugins]).to have_key(plugin_metadata_a[:name])
      expect(resolution[:namespaced_plugins]).to have_key(plugin_metadata_b[:name])
    end

    it 'preserves original plugin metadata' do
      resolution = namespace_system.resolve_naming_conflict(conflicting_plugins)

      namespaced_a = resolution[:namespaced_plugins][plugin_metadata_a[:name]]
      expect(namespaced_a[:original_metadata]).to eq(plugin_metadata_a)
      expect(namespaced_a[:namespace]).to be_a(String)
    end

    it 'prioritizes higher priority plugins in namespace ordering' do
      resolution = namespace_system.resolve_naming_conflict(conflicting_plugins)

      namespaced_a = resolution[:namespaced_plugins][plugin_metadata_a[:name]]
      namespaced_b = resolution[:namespaced_plugins][plugin_metadata_b[:name]]

      # Official gems (70) should have shorter/simpler namespace than third party (50)
      expect(namespaced_a[:namespace].length).to be <= namespaced_b[:namespace].length
    end
  end

  describe '#namespace_mappings' do
    it 'returns empty hash initially' do
      mappings = namespace_system.namespace_mappings
      expect(mappings).to be_a(Hash)
      expect(mappings).to be_empty
    end

    it 'tracks namespaces after conflict resolution' do
      conflicting_plugins = [plugin_metadata_a, plugin_metadata_b]
      namespace_system.resolve_naming_conflict(conflicting_plugins)

      mappings = namespace_system.namespace_mappings
      expect(mappings).to have_key(plugin_metadata_a[:name])
      expect(mappings).to have_key(plugin_metadata_b[:name])
    end
  end

  describe '#clear_namespace_cache' do
    it 'clears all cached namespaces' do
      conflicting_plugins = [plugin_metadata_a, plugin_metadata_b]
      namespace_system.resolve_naming_conflict(conflicting_plugins)

      expect(namespace_system.namespace_mappings).not_to be_empty

      namespace_system.clear_namespace_cache
      expect(namespace_system.namespace_mappings).to be_empty
    end
  end

  describe '#calculate_name_similarity' do
    it 'calculates similarity between plugin names correctly' do
      similarity = namespace_system.calculate_name_similarity(
        'machine_learning_plugin',
        'machine_learning_stats'
      )

      expect(similarity).to be_between(0.7, 1.0)
    end

    it 'returns 1.0 for identical names' do
      similarity = namespace_system.calculate_name_similarity(
        'same_plugin_name',
        'same_plugin_name'
      )

      expect(similarity).to eq(1.0)
    end

    it 'returns low similarity for completely different names' do
      similarity = namespace_system.calculate_name_similarity(
        'statistics_plugin',
        'visualization_tool'
      )

      expect(similarity).to be < 0.5
    end

    it 'handles empty strings gracefully' do
      similarity = namespace_system.calculate_name_similarity('', 'test')
      expect(similarity).to eq(0.0)

      similarity = namespace_system.calculate_name_similarity('test', '')
      expect(similarity).to eq(0.0)
    end
  end

  describe 'integration with priority system' do
    it 'uses priority system for namespace generation' do
      # Mock priority system to return specific values
      allow(priority_system).to receive(:get_priority)
        .with(plugin_metadata_a[:name])
        .and_return(:official_gems)

      namespace = namespace_system.generate_namespace(plugin_metadata_a)
      expect(namespace).to start_with('of_')
    end

    it 'handles custom priority types' do
      custom_metadata = plugin_metadata_a.merge(priority_type: :custom_priority)

      # Should fall back to local_plugins for unknown priority
      namespace = namespace_system.generate_namespace(custom_metadata)
      expect(namespace).to start_with('lo_')
    end
  end
end
