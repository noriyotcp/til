# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer/plugin_priority'

RSpec.describe NumberAnalyzer::PluginPriority do
  let(:priority_system) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty plugin priorities' do
      expect(priority_system.priority_statistics[:total_plugins]).to eq(0)
    end

    it 'has all priority levels defined' do
      expect(described_class::PRIORITY_LEVELS.keys).to contain_exactly(
        :development, :core, :official, :third_party, :local
      )
    end
  end

  describe '#set_priority' do
    it 'sets priority for a plugin' do
      priority_system.set_priority('test_plugin', :core)
      expect(priority_system.get_priority('test_plugin')).to eq(:core)
    end

    it 'raises error for invalid priority level' do
      expect do
        priority_system.set_priority('test_plugin', :invalid)
      end.to raise_error(ArgumentError, /Invalid priority level/)
    end

    it 'updates priority groups correctly' do
      priority_system.set_priority('plugin1', :core)
      priority_system.set_priority('plugin2', :core)

      expect(priority_system.plugins_at_priority(:core)).to contain_exactly('plugin1', 'plugin2')
    end

    it 'removes plugin from previous group when priority changes' do
      priority_system.set_priority('test_plugin', :core)
      priority_system.set_priority('test_plugin', :official)

      expect(priority_system.plugins_at_priority(:core)).to be_empty
      expect(priority_system.plugins_at_priority(:official)).to contain_exactly('test_plugin')
    end
  end

  describe '#get_priority' do
    it 'returns set priority for a plugin' do
      priority_system.set_priority('test_plugin', :development)
      expect(priority_system.get_priority('test_plugin')).to eq(:development)
    end

    it 'returns default priority for unknown plugin' do
      expect(priority_system.get_priority('unknown_plugin')).to eq(:local)
    end
  end

  describe '#get_priority_value' do
    it 'returns numeric value for priority' do
      priority_system.set_priority('test_plugin', :development)
      expect(priority_system.get_priority_value('test_plugin')).to eq(100)
    end

    it 'returns default priority value for unknown plugin' do
      expect(priority_system.get_priority_value('unknown_plugin')).to eq(30)
    end
  end

  describe '#auto_detect_priority' do
    it 'detects core plugin from name' do
      metadata = { author: 'Test', name: 'Test Plugin' }
      priority = priority_system.auto_detect_priority('NumberAnalyzer::BasicStats', metadata)
      expect(priority).to eq(:core)
    end

    it 'detects official plugin from author' do
      metadata = { author: 'NumberAnalyzer Team', name: 'Test Plugin' }
      priority = priority_system.auto_detect_priority('test_plugin', metadata)
      expect(priority).to eq(:official)
    end

    it 'detects development plugin from metadata' do
      metadata = { author: 'Test', development: true }
      priority = priority_system.auto_detect_priority('test_plugin', metadata)
      expect(priority).to eq(:development)
    end

    it 'detects third-party plugin from trusted author' do
      metadata = { author: 'statistical-ruby maintainer', name: 'Test Plugin' }
      priority = priority_system.auto_detect_priority('test_plugin', metadata)
      expect(priority).to eq(:third_party)
    end

    it 'defaults to local priority' do
      metadata = { author: 'Unknown', name: 'Test Plugin' }
      priority = priority_system.auto_detect_priority('test_plugin', metadata)
      expect(priority).to eq(:local)
    end
  end

  describe '#set_priority_with_auto_detection' do
    it 'sets priority based on auto-detection' do
      metadata = { author: 'NumberAnalyzer Team', name: 'Test Plugin' }
      detected = priority_system.set_priority_with_auto_detection('test_plugin', metadata)

      expect(detected).to eq(:official)
      expect(priority_system.get_priority('test_plugin')).to eq(:official)
    end
  end

  describe '#compare_priority' do
    before do
      priority_system.set_priority('high_plugin', :development)
      priority_system.set_priority('low_plugin', :local)
    end

    it 'returns negative when first plugin has higher priority' do
      result = priority_system.compare_priority('high_plugin', 'low_plugin')
      expect(result).to be < 0
    end

    it 'returns positive when first plugin has lower priority' do
      result = priority_system.compare_priority('low_plugin', 'high_plugin')
      expect(result).to be > 0
    end

    it 'returns zero when plugins have same priority' do
      priority_system.set_priority('same_plugin', :development)
      result = priority_system.compare_priority('high_plugin', 'same_plugin')
      expect(result).to eq(0)
    end
  end

  describe '#sort_by_priority' do
    before do
      priority_system.set_priority('plugin_a', :local)        # 30
      priority_system.set_priority('plugin_b', :development)  # 100
      priority_system.set_priority('plugin_c', :official)     # 70
    end

    it 'sorts plugins by priority (highest first)' do
      plugins = %w[plugin_a plugin_b plugin_c]
      sorted = priority_system.sort_by_priority(plugins)
      expect(sorted).to eq(%w[plugin_b plugin_c plugin_a])
    end
  end

  describe '#higher_priority_plugins' do
    before do
      priority_system.set_priority('high1', :development)  # 100
      priority_system.set_priority('high2', :core)         # 90
      priority_system.set_priority('target', :official)    # 70
      priority_system.set_priority('low1', :third_party)   # 50
      priority_system.set_priority('low2', :local)         # 30
    end

    it 'returns plugins with higher priority' do
      higher = priority_system.higher_priority_plugins('target')
      expect(higher).to contain_exactly('high1', 'high2')
    end
  end

  describe '#lower_priority_plugins' do
    before do
      priority_system.set_priority('high1', :development)  # 100
      priority_system.set_priority('target', :official)    # 70
      priority_system.set_priority('low1', :third_party)   # 50
      priority_system.set_priority('low2', :local)         # 30
    end

    it 'returns plugins with lower priority' do
      lower = priority_system.lower_priority_plugins('target')
      expect(lower).to contain_exactly('low1', 'low2')
    end
  end

  describe '#higher_priority?' do
    before do
      priority_system.set_priority('high_plugin', :development)
      priority_system.set_priority('low_plugin', :local)
    end

    it 'returns true when first plugin has higher priority' do
      expect(priority_system.higher_priority?('high_plugin', 'low_plugin')).to be true
    end

    it 'returns false when first plugin has lower priority' do
      expect(priority_system.higher_priority?('low_plugin', 'high_plugin')).to be false
    end
  end

  describe '#priority_distribution' do
    before do
      priority_system.set_priority('plugin1', :development)
      priority_system.set_priority('plugin2', :development)
      priority_system.set_priority('plugin3', :core)
      priority_system.set_priority('plugin4', :local)
    end

    it 'returns distribution of plugins across priority levels' do
      distribution = priority_system.priority_distribution

      expect(distribution[:development]).to eq(2)
      expect(distribution[:core]).to eq(1)
      expect(distribution[:official]).to eq(0)
      expect(distribution[:third_party]).to eq(0)
      expect(distribution[:local]).to eq(1)
    end
  end

  describe '#priority_statistics' do
    before do
      priority_system.set_priority('plugin1', :development)
      priority_system.set_priority('plugin2', :core)
      priority_system.set_priority('plugin3', :local)
    end

    it 'returns comprehensive priority statistics' do
      stats = priority_system.priority_statistics

      expect(stats[:total_plugins]).to eq(3)
      expect(stats[:highest_priority]).to contain_exactly('plugin1')
      expect(stats[:lowest_priority]).to contain_exactly('plugin3')
      expect(stats[:priority_distribution][:development]).to eq(1)
    end
  end

  describe '#remove_plugin' do
    before do
      priority_system.set_priority('test_plugin', :core)
    end

    it 'removes plugin from priority system' do
      priority_system.remove_plugin('test_plugin')

      expect(priority_system.get_priority('test_plugin')).to eq(:local)
      expect(priority_system.plugins_at_priority(:core)).to be_empty
    end

    it 'handles removal of non-existent plugin gracefully' do
      expect { priority_system.remove_plugin('non_existent') }.not_to raise_error
    end
  end

  describe '#reset_priorities' do
    before do
      priority_system.set_priority('plugin1', :development)
      priority_system.set_priority('plugin2', :core)
    end

    it 'resets all priorities' do
      priority_system.reset_priorities

      expect(priority_system.priority_statistics[:total_plugins]).to eq(0)
      expect(priority_system.plugins_at_priority(:development)).to be_empty
      expect(priority_system.plugins_at_priority(:core)).to be_empty
    end
  end

  describe '#generate_priority_report' do
    before do
      priority_system.set_priority('plugin1', :development)
      priority_system.set_priority('plugin2', :core)
      priority_system.set_priority('plugin3', :local)
    end

    it 'generates comprehensive priority report' do
      report = priority_system.generate_priority_report

      expect(report[:title]).to eq('Plugin Priority Report')
      expect(report[:total_plugins]).to eq(3)
      expect(report[:priority_levels]).to have_key(:development)
      expect(report[:priority_levels][:development][:plugin_count]).to eq(1)
      expect(report[:priority_levels][:development][:plugins]).to contain_exactly('plugin1')
    end

    it 'includes timestamp in report' do
      report = priority_system.generate_priority_report
      expect(report[:generated_at]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
    end
  end

  describe 'priority level constants' do
    it 'has correct priority values' do
      expect(described_class::PRIORITY_LEVELS[:development]).to eq(100)
      expect(described_class::PRIORITY_LEVELS[:core]).to eq(90)
      expect(described_class::PRIORITY_LEVELS[:official]).to eq(70)
      expect(described_class::PRIORITY_LEVELS[:third_party]).to eq(50)
      expect(described_class::PRIORITY_LEVELS[:local]).to eq(30)
    end

    it 'has descriptions for all priority levels' do
      described_class::PRIORITY_LEVELS.each_key do |level|
        expect(described_class::PRIORITY_DESCRIPTIONS).to have_key(level)
        expect(priority_system.priority_description(level)).to be_a(String)
      end
    end
  end

  describe 'edge cases' do
    it 'handles empty plugin list gracefully' do
      expect(priority_system.highest_priority_plugins).to be_empty
      expect(priority_system.lowest_priority_plugins).to be_empty
      expect(priority_system.sort_by_priority([])).to eq([])
    end

    it 'handles single plugin gracefully' do
      priority_system.set_priority('single_plugin', :core)

      expect(priority_system.highest_priority_plugins).to contain_exactly('single_plugin')
      expect(priority_system.lowest_priority_plugins).to contain_exactly('single_plugin')
    end
  end
end
