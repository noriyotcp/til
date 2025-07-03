# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/dependency_resolver'

RSpec.describe NumberAnalyzer::DependencyResolver do
  let(:plugin_registry) { {} }
  let(:resolver) { described_class.new(plugin_registry) }

  def create_plugin(name, dependencies = [], version = '1.0.0')
    {
      metadata: {
        name: name,
        version: version,
        dependencies: dependencies
      }
    }
  end

  describe '#resolve' do
    context 'with simple dependencies' do
      before do
        plugin_registry['plugin_a'] = create_plugin('plugin_a')
        plugin_registry['plugin_b'] = create_plugin('plugin_b', ['plugin_a'])
        plugin_registry['plugin_c'] = create_plugin('plugin_c', ['plugin_b'])
      end

      it 'resolves dependencies in correct order' do
        resolution = resolver.resolve('plugin_c')
        expect(resolution).to eq(%w[plugin_a plugin_b plugin_c])
      end

      it 'returns single plugin for no dependencies' do
        resolution = resolver.resolve('plugin_a')
        expect(resolution).to eq(['plugin_a'])
      end

      it 'caches resolution results' do
        first_call = resolver.resolve('plugin_c')
        second_call = resolver.resolve('plugin_c')
        expect(first_call).to equal(second_call) # Same object reference
      end
    end

    context 'with circular dependencies' do
      before do
        plugin_registry['plugin_a'] = create_plugin('plugin_a', ['plugin_b'])
        plugin_registry['plugin_b'] = create_plugin('plugin_b', ['plugin_c'])
        plugin_registry['plugin_c'] = create_plugin('plugin_c', ['plugin_a'])
      end

      it 'detects circular dependencies' do
        expect { resolver.resolve('plugin_a') }
          .to raise_error(NumberAnalyzer::DependencyResolver::CircularDependencyError) do |error|
            expect(error.cycle).to include('plugin_a', 'plugin_b', 'plugin_c')
          end
      end
    end

    context 'with missing dependencies' do
      before do
        plugin_registry['plugin_a'] = create_plugin('plugin_a', ['missing_plugin'])
      end

      it 'raises error for unresolved dependencies' do
        expect { resolver.resolve('plugin_a') }
          .to raise_error(NumberAnalyzer::DependencyResolver::UnresolvedDependencyError) do |error|
            expect(error.plugin).to eq('plugin_a')
            expect(error.missing_dependencies).to eq(['missing_plugin'])
          end
      end
    end

    context 'with version requirements' do
      before do
        plugin_registry['plugin_a'] = create_plugin('plugin_a', [], '2.0.0')
        plugin_registry['plugin_b'] = create_plugin('plugin_b', { 'plugin_a' => '~> 1.0' })
      end

      it 'detects version conflicts' do
        expect { resolver.resolve('plugin_b', check_versions: true) }
          .to raise_error(NumberAnalyzer::DependencyResolver::VersionConflictError) do |error|
            expect(error.plugin).to eq('plugin_b')
            expect(error.dependency).to eq('plugin_a')
            expect(error.required_version).to eq('~> 1.0')
            expect(error.available_version).to eq('2.0.0')
          end
      end
    end

    context 'with complex dependency tree' do
      before do
        # Create a diamond dependency structure
        #     A
        #    / \
        #   B   C
        #    \ /
        #     D
        plugin_registry['plugin_a'] = create_plugin('plugin_a')
        plugin_registry['plugin_b'] = create_plugin('plugin_b', ['plugin_a'])
        plugin_registry['plugin_c'] = create_plugin('plugin_c', ['plugin_a'])
        plugin_registry['plugin_d'] = create_plugin('plugin_d', %w[plugin_b plugin_c])
      end

      it 'handles diamond dependencies correctly' do
        resolution = resolver.resolve('plugin_d')
        expect(resolution).to eq(%w[plugin_a plugin_b plugin_c plugin_d])
      end
    end

    it 'raises error for non-existent plugin' do
      expect { resolver.resolve('non_existent') }
        .to raise_error(ArgumentError, /Plugin 'non_existent' not found/)
    end
  end

  describe '#resolve_multiple' do
    before do
      plugin_registry['plugin_a'] = create_plugin('plugin_a')
      plugin_registry['plugin_b'] = create_plugin('plugin_b', ['plugin_a'])
      plugin_registry['plugin_c'] = create_plugin('plugin_c')
      plugin_registry['plugin_d'] = create_plugin('plugin_d', ['plugin_c'])
    end

    it 'resolves multiple plugins with their dependencies' do
      resolution = resolver.resolve_multiple(%w[plugin_b plugin_d])
      expect(resolution).to eq(%w[plugin_a plugin_b plugin_c plugin_d])
    end

    it 'handles overlapping dependencies' do
      plugin_registry['plugin_e'] = create_plugin('plugin_e', %w[plugin_a plugin_c])
      resolution = resolver.resolve_multiple(%w[plugin_b plugin_d plugin_e])
      expect(resolution).to eq(%w[plugin_a plugin_b plugin_c plugin_d plugin_e])
    end
  end

  describe '#dependencies_satisfied?' do
    before do
      plugin_registry['plugin_a'] = create_plugin('plugin_a')
      plugin_registry['plugin_b'] = create_plugin('plugin_b', ['plugin_a'])
      plugin_registry['plugin_c'] = create_plugin('plugin_c', ['missing_plugin'])
    end

    it 'returns true when all dependencies are available' do
      expect(resolver.dependencies_satisfied?('plugin_b')).to be true
    end

    it 'returns false when dependencies are missing' do
      expect(resolver.dependencies_satisfied?('plugin_c')).to be false
    end

    it 'returns false for non-existent plugin' do
      expect(resolver.dependencies_satisfied?('non_existent')).to be false
    end
  end

  describe '#missing_dependencies' do
    before do
      plugin_registry['plugin_a'] = create_plugin('plugin_a')
      plugin_registry['plugin_b'] = create_plugin('plugin_b', %w[plugin_a missing1 missing2])
    end

    it 'returns list of missing dependencies' do
      missing = resolver.missing_dependencies('plugin_b')
      expect(missing).to contain_exactly('missing1', 'missing2')
    end

    it 'returns empty array when all dependencies are satisfied' do
      plugin_registry['plugin_c'] = create_plugin('plugin_c', ['plugin_a'])
      expect(resolver.missing_dependencies('plugin_c')).to be_empty
    end

    it 'returns empty array for non-existent plugin' do
      expect(resolver.missing_dependencies('non_existent')).to be_empty
    end
  end

  describe '#validate_version_compatibility' do
    before do
      plugin_registry['plugin_a'] = create_plugin('plugin_a', [], '1.2.3')
    end

    context 'with pessimistic version constraint (~>)' do
      it 'accepts compatible versions' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '~> 1.2')).to be true
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '~> 1.2.0')).to be true
      end

      it 'rejects incompatible versions' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '~> 2.0')).to be false
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '~> 1.3')).to be false
      end
    end

    context 'with comparison operators' do
      it 'handles >= correctly' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '>= 1.0.0')).to be true
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '>= 2.0.0')).to be false
      end

      it 'handles > correctly' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '> 1.2.2')).to be true
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '> 1.2.3')).to be false
      end

      it 'handles <= correctly' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '<= 2.0.0')).to be true
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '<= 1.0.0')).to be false
      end

      it 'handles < correctly' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '< 1.2.4')).to be true
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '< 1.2.3')).to be false
      end

      it 'handles = correctly' do
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '= 1.2.3')).to be true
        expect(resolver.validate_version_compatibility('test', 'plugin_a', '= 1.2.4')).to be false
      end
    end

    it 'returns true for wildcard version' do
      expect(resolver.validate_version_compatibility('test', 'plugin_a', '*')).to be true
    end

    it 'returns true when no version requirement specified' do
      expect(resolver.validate_version_compatibility('test', 'plugin_a', nil)).to be true
    end
  end

  describe 'version comparison' do
    it 'compares versions correctly' do
      # Testing internal version comparison through public API
      plugin_registry['v1'] = create_plugin('v1', [], '1.0.0')
      plugin_registry['v2'] = create_plugin('v2', [], '1.0.1')
      plugin_registry['v3'] = create_plugin('v3', [], '2.0.0')

      expect(resolver.validate_version_compatibility('test', 'v1', '>= 1.0.0')).to be true
      expect(resolver.validate_version_compatibility('test', 'v2', '> 1.0.0')).to be true
      expect(resolver.validate_version_compatibility('test', 'v3', '> 1.9.9')).to be true
    end
  end
end
