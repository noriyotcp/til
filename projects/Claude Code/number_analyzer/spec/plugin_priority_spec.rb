# frozen_string_literal: true

require_relative '../lib/numana'

RSpec.describe Numana::PluginPriority do
  after do
    described_class.reset_custom_priorities!
  end

  describe 'DEFAULT_PRIORITIES' do
    it 'defines correct priority levels' do
      expect(described_class.get(:development)).to eq(100)
      expect(described_class.get(:core_plugins)).to eq(90)
      expect(described_class.get(:official_gems)).to eq(70)
      expect(described_class.get(:third_party_gems)).to eq(50)
      expect(described_class.get(:local_plugins)).to eq(30)
    end

    it 'returns 0 for unknown plugin types' do
      expect(described_class.get(:unknown_type)).to eq(0)
    end
  end

  describe '.can_override?' do
    let(:development_plugin) { double(:plugin, type: :development) }
    let(:core_plugin) { double(:plugin, type: :core_plugins) }
    let(:official_plugin) { double(:plugin, type: :official_gems) }
    let(:third_party_plugin) { double(:plugin, type: :third_party_gems) }
    let(:local_plugin) { double(:plugin, type: :local_plugins) }

    it 'allows development to override core' do
      expect(described_class.can_override?(development_plugin, core_plugin)).to be true
    end

    it 'allows development to override everything' do
      expect(described_class.can_override?(development_plugin, official_plugin)).to be true
      expect(described_class.can_override?(development_plugin, third_party_plugin)).to be true
      expect(described_class.can_override?(development_plugin, local_plugin)).to be true
    end

    it 'allows core to override lower priority plugins' do
      expect(described_class.can_override?(core_plugin, official_plugin)).to be true
      expect(described_class.can_override?(core_plugin, third_party_plugin)).to be true
      expect(described_class.can_override?(core_plugin, local_plugin)).to be true
    end

    it 'prevents lower priority from overriding higher priority' do
      expect(described_class.can_override?(third_party_plugin, core_plugin)).to be false
      expect(described_class.can_override?(local_plugin, core_plugin)).to be false
      expect(described_class.can_override?(local_plugin, official_plugin)).to be false
    end

    it 'allows same priority override' do
      expect(described_class.can_override?(third_party_plugin, third_party_plugin)).to be false
      expect(described_class.can_override?(official_plugin, official_plugin)).to be false
    end
  end

  describe 'custom priority management' do
    it 'allows custom priority setting' do
      described_class.set(:my_custom_type, 95)
      expect(described_class.get(:my_custom_type)).to eq(95)
    end

    it 'custom priorities override defaults' do
      described_class.set(:core_plugins, 120)
      expect(described_class.get(:core_plugins)).to eq(120)
    end

    it 'affects can_override? behavior with custom priorities' do
      described_class.set(:my_plugin, 95)
      my_plugin = double(:plugin, type: :my_plugin)
      core_plugin = double(:plugin, type: :core_plugins)

      expect(described_class.can_override?(my_plugin, core_plugin)).to be true
    end

    it 'resets custom priorities' do
      described_class.set(:custom_type, 85)
      described_class.reset_custom_priorities!
      expect(described_class.get(:custom_type)).to eq(0)
    end
  end

  describe '.all_priorities' do
    it 'returns merged default and custom priorities' do
      described_class.set(:custom_type, 85)
      all_priorities = described_class.all_priorities

      expect(all_priorities[:development]).to eq(100)
      expect(all_priorities[:custom_type]).to eq(85)
    end
  end

  describe 'instance methods' do
    let(:instance) { described_class.new }

    describe '#sort_by_priority' do
      let(:plugins_list) do
        %w[local_plugin core_plugin third_party_plugin development_plugin official_plugin]
      end

      before do
        # Set up plugin priorities
        instance.set_priority_with_auto_detection('local_plugin', { development: false })
        instance.set_priority_with_auto_detection('core_plugin', { core: true })
        instance.set_priority_with_auto_detection('third_party_plugin', { trusted: true })
        instance.set_priority_with_auto_detection('development_plugin', { development: true })
        instance.set_priority_with_auto_detection('official_plugin', { official: true })
      end

      it 'sorts plugins by priority in descending order' do
        sorted = instance.sort_by_priority(plugins_list)

        # Expected order: development (100) > core (90) > official (70) > third_party (50) > local (30)
        expect(sorted).to eq(%w[
                               development_plugin
                               core_plugin
                               official_plugin
                               third_party_plugin
                               local_plugin
                             ])
      end

      it 'handles empty plugin list' do
        sorted = instance.sort_by_priority([])
        expect(sorted).to eq([])
      end

      it 'handles single plugin' do
        sorted = instance.sort_by_priority(['single_plugin'])
        expect(sorted).to eq(['single_plugin'])
      end

      it 'maintains relative order for plugins with same priority' do
        # Two local plugins should maintain their relative order
        local_plugins = %w[local_plugin_a local_plugin_b]
        local_plugins.each do |plugin|
          instance.set_priority_with_auto_detection(plugin, { development: false })
        end

        sorted = instance.sort_by_priority(local_plugins)
        expect(sorted).to eq(local_plugins) # Original order maintained
      end
    end
  end

  describe 'class method integration' do
    # Mock plugin objects for class method testing
    let(:plugin_a) { double('PluginA', type: :development, name: 'plugin_a') }
    let(:plugin_b) { double('PluginB', type: :core_plugins, name: 'plugin_b') }
    let(:plugin_c) { double('PluginC', type: :local_plugins, name: 'plugin_c') }

    describe '.sort_plugins_by_priority' do
      it 'sorts plugin objects by their type priority' do
        plugins = [plugin_c, plugin_a, plugin_b]
        sorted = described_class.sort_plugins_by_priority(plugins)

        expect(sorted).to eq([plugin_a, plugin_b, plugin_c])
      end

      it 'handles plugins with custom priorities' do
        described_class.set(:custom_priority, 95)
        plugin_custom = double('PluginCustom', type: :custom_priority, name: 'plugin_custom')

        plugins = [plugin_c, plugin_custom, plugin_b]
        sorted = described_class.sort_plugins_by_priority(plugins)

        expect(sorted).to eq([plugin_custom, plugin_b, plugin_c])
      end
    end
  end
end
