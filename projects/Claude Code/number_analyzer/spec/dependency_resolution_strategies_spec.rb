# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/dependency_resolution_strategies'
require 'number_analyzer/dependency_resolver'

RSpec.describe NumberAnalyzer::DependencyResolutionStrategies do
  describe NumberAnalyzer::DependencyResolutionStrategies::BaseStrategy do
    subject { described_class.new }

    describe '#resolve' do
      it 'raises NotImplementedError' do
        resolver = instance_double('DependencyResolver')
        expect { subject.resolve(resolver, 'plugin') }
          .to raise_error(NotImplementedError, /must implement #resolve/)
      end
    end

    describe '#select_version' do
      it 'raises NotImplementedError' do
        expect { subject.select_version(['1.0.0'], '>= 1.0.0') }
          .to raise_error(NotImplementedError, /must implement #select_version/)
      end
    end
  end

  describe NumberAnalyzer::DependencyResolutionStrategies::ConservativeStrategy do
    subject { described_class.new }

    describe '#resolve' do
      it 'delegates to resolver.standard_resolve' do
        resolver = instance_double('DependencyResolver')
        expect(resolver).to receive(:standard_resolve).with('plugin_name')
        subject.resolve(resolver, 'plugin_name')
      end
    end

    describe '#select_version' do
      it 'selects oldest version that satisfies requirement' do
        versions = ['1.0.0', '1.1.0', '1.2.0', '2.0.0']
        result = subject.select_version(versions, '>= 1.1.0')
        expect(result).to eq('1.1.0')
      end

      it 'returns nil when no version satisfies requirement' do
        versions = ['1.0.0', '1.1.0']
        result = subject.select_version(versions, '>= 2.0.0')
        expect(result).to be_nil
      end

      it 'handles complex version numbers correctly' do
        versions = ['1.10.0', '1.2.0', '1.9.0']
        result = subject.select_version(versions, '~> 1.2')
        expect(result).to eq('1.2.0')
      end
    end
  end

  describe NumberAnalyzer::DependencyResolutionStrategies::AggressiveStrategy do
    subject { described_class.new }

    describe '#resolve' do
      it 'delegates to resolver.standard_resolve with prefer_newer option' do
        resolver = instance_double('DependencyResolver')
        expect(resolver).to receive(:standard_resolve).with('plugin_name', prefer_newer: true)
        subject.resolve(resolver, 'plugin_name')
      end
    end

    describe '#select_version' do
      it 'selects newest version that satisfies requirement' do
        versions = ['1.0.0', '1.1.0', '1.2.0', '2.0.0']
        result = subject.select_version(versions, '~> 1.0')
        expect(result).to eq('1.2.0')
      end

      it 'returns nil when no version satisfies requirement' do
        versions = ['1.0.0', '1.1.0']
        result = subject.select_version(versions, '>= 2.0.0')
        expect(result).to be_nil
      end

      it 'respects upper bounds in requirements' do
        versions = ['1.0.0', '1.1.0', '1.2.0', '2.0.0']
        result = subject.select_version(versions, '< 1.2.0')
        expect(result).to eq('1.1.0')
      end
    end
  end

  describe NumberAnalyzer::DependencyResolutionStrategies::MinimalStrategy do
    subject { described_class.new }

    describe '#resolve' do
      it 'delegates to resolver.standard_resolve with skip_optional option' do
        resolver = instance_double('DependencyResolver')
        expect(resolver).to receive(:standard_resolve).with('plugin_name', skip_optional: true)
        subject.resolve(resolver, 'plugin_name')
      end
    end

    describe '#select_version' do
      it 'returns exact match when available' do
        versions = ['1.0.0', '1.1.0', '1.2.0']
        result = subject.select_version(versions, '1.1.0')
        expect(result).to eq('1.1.0')
      end

      it 'falls back to conservative strategy when no exact match' do
        versions = ['1.0.0', '1.1.0', '1.2.0']
        result = subject.select_version(versions, '>= 1.1.0')
        expect(result).to eq('1.1.0') # Conservative picks oldest
      end
    end
  end

  # Integration test with real DependencyResolver
  describe 'Integration with DependencyResolver' do
    let(:plugin_registry) do
      {
        'plugin_a' => {
          metadata: {
            dependencies: ['plugin_b'],
            version: '1.0.0'
          }
        },
        'plugin_b' => {
          metadata: {
            dependencies: [],
            version: '2.0.0'
          }
        }
      }
    end

    describe 'with different strategies' do
      it 'works with conservative strategy' do
        resolver = NumberAnalyzer::DependencyResolver.new(plugin_registry, strategy: :conservative)
        result = resolver.resolve('plugin_a')
        expect(result).to eq(%w[plugin_b plugin_a])
      end

      it 'works with aggressive strategy' do
        resolver = NumberAnalyzer::DependencyResolver.new(plugin_registry, strategy: :aggressive)
        result = resolver.resolve('plugin_a')
        expect(result).to eq(%w[plugin_b plugin_a])
      end

      it 'works with minimal strategy' do
        resolver = NumberAnalyzer::DependencyResolver.new(plugin_registry, strategy: :minimal)
        result = resolver.resolve('plugin_a')
        expect(result).to eq(%w[plugin_b plugin_a])
      end

      it 'defaults to conservative strategy when none specified' do
        resolver = NumberAnalyzer::DependencyResolver.new(plugin_registry)
        result = resolver.resolve('plugin_a')
        expect(result).to eq(%w[plugin_b plugin_a])
      end
    end
  end
end
