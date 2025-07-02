# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Plugin System Integration' do
  let(:plugin_system) { NumberAnalyzer::PluginSystem.new }
  let(:cli_class) { NumberAnalyzer::CLI }
  let(:sample_data) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }

  before do
    # Reset plugin state for clean tests
    cli_class.class_variable_set(:@@plugin_commands, {})
    cli_class.class_variable_set(:@@plugin_system, nil)
  end

  after do
    # Clean up
    cli_class.class_variable_set(:@@plugin_commands, {})
  end

  describe 'Single plugin integration' do
    describe 'automatic CLI command registration' do
      it 'automatically registers CLI commands when loading statistics plugins' do
        require_relative '../plugins/basic_stats_plugin'

        # Register and load the plugin
        plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
        plugin_system.load_plugin('basic_stats')

        # CLI commands should be automatically registered
        expected_commands = %w[sum mean mode variance std-dev]

        expected_commands.each do |command|
          expect(cli_class.commands).to have_key(command)
          expect(cli_class.commands[command][:plugin_class]).to eq(BasicStatsPlugin)
        end
      end

      it 'makes plugin methods available in NumberAnalyzer instances' do
        require_relative '../plugins/basic_stats_plugin'

        plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
        plugin_system.load_plugin('basic_stats')

        # Create a NumberAnalyzer instance
        analyzer = NumberAnalyzer.new([1, 2, 3, 4, 5])

        # Plugin methods should be available
        expect(analyzer).to respond_to(:sum)
        expect(analyzer).to respond_to(:mean)
        expect(analyzer).to respond_to(:mode)
        expect(analyzer).to respond_to(:variance)
        expect(analyzer).to respond_to(:standard_deviation)

        # And they should work correctly
        expect(analyzer.sum).to eq(15)
        expect(analyzer.mean).to eq(3.0)
      end

      it 'handles plugins that do not provide CLI commands' do
        require_relative '../plugins/math_utils_plugin'

        plugin_system.register_plugin('math_utils', MathUtilsPlugin, extension_point: :statistics_module)

        # This should not raise an error
        expect do
          plugin_system.load_plugin('math_utils')
        end.not_to raise_error

        # And the plugin should still be loaded
        expect(plugin_system.plugin_loaded?('math_utils')).to be true
      end
    end

    describe 'complete plugin lifecycle' do
      it 'supports the full plugin lifecycle for BasicStats' do
        require_relative '../plugins/basic_stats_plugin'

        # 1. Register plugin
        plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)

        # 2. Verify plugin is registered
        expect(plugin_system.available_plugins).to include('basic_stats')
        expect(plugin_system.plugin_loaded?('basic_stats')).to be false

        # 3. Load plugin
        result = plugin_system.load_plugin('basic_stats')
        expect(result).to be true
        expect(plugin_system.plugin_loaded?('basic_stats')).to be true

        # 4. Verify CLI commands are registered
        expect(cli_class.commands).to include('sum', 'mean', 'mode', 'variance', 'std-dev')

        # 5. Verify NumberAnalyzer has the methods
        analyzer = NumberAnalyzer.new([10, 20, 30])
        expect(analyzer.sum).to eq(60)
        expect(analyzer.mean).to eq(20.0)

        # 6. Verify plugin metadata
        metadata = plugin_system.plugin_metadata('basic_stats')
        expect(metadata[:name]).to eq('basic_stats')
        expect(metadata[:version]).to eq('1.0.0')
        expect(metadata[:description]).to include('basic statistical functions')
      end

      it 'prevents loading the same plugin twice' do
        require_relative '../plugins/basic_stats_plugin'

        plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)

        # Load plugin first time
        result1 = plugin_system.load_plugin('basic_stats')
        expect(result1).to be true

        # Load plugin second time should return true but not reload
        result2 = plugin_system.load_plugin('basic_stats')
        expect(result2).to be true

        # Should only be loaded once
        expect(plugin_system.loaded_plugins.count('basic_stats')).to eq(1)
      end
    end
  end

  describe 'Multiple plugin integration' do
    it 'loads and coordinates multiple plugins successfully' do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'
      require_relative '../plugins/math_utils_plugin'

      # Register plugins
      plugin_system.register_plugin('math_utils', MathUtilsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)

      # Load plugins
      expect(plugin_system.load_plugin('math_utils')).to be true
      expect(plugin_system.load_plugin('basic_stats')).to be true
      expect(plugin_system.load_plugin('advanced_stats')).to be true

      # Verify all plugins are loaded
      expect(plugin_system.loaded_plugins).to include('math_utils', 'basic_stats', 'advanced_stats')
    end

    it 'registers CLI commands from multiple plugins' do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'
      require_relative '../plugins/math_utils_plugin'

      # Register and load plugins
      plugin_system.register_plugin('math_utils', MathUtilsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)

      plugin_system.load_plugin('math_utils')
      plugin_system.load_plugin('basic_stats')
      plugin_system.load_plugin('advanced_stats')

      # Check BasicStats commands
      expect(cli_class.commands).to include('sum', 'mean', 'mode', 'variance', 'std-dev')

      # Check AdvancedStats commands
      expect(cli_class.commands).to include('percentile', 'quartiles', 'outliers', 'deviation-scores')

      # MathUtils doesn't register CLI commands
      math_utils_commands = MathUtilsPlugin.plugin_commands
      expect(math_utils_commands).to be_empty
    end

    it 'provides coordinated statistical functionality' do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'
      require_relative '../plugins/math_utils_plugin'

      plugin_system.register_plugin('math_utils', MathUtilsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)

      plugin_system.load_plugin('math_utils')
      plugin_system.load_plugin('basic_stats')
      plugin_system.load_plugin('advanced_stats')

      analyzer = NumberAnalyzer.new(sample_data)

      # BasicStats methods
      expect(analyzer).to respond_to(:sum, :mean, :mode, :variance, :standard_deviation)

      # AdvancedStats methods
      expect(analyzer).to respond_to(:percentile, :quartiles, :interquartile_range, :outliers, :deviation_scores)

      # Verify calculations work correctly
      expect(analyzer.sum).to eq(55)
      expect(analyzer.mean).to eq(5.5)
      expect(analyzer.percentile(50)).to eq(5.5) # Median
      expect(analyzer.outliers).to be_empty # No outliers in this dataset
    end

    it 'handles plugin dependency relationships correctly' do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'

      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)

      plugin_system.load_plugin('basic_stats')
      plugin_system.load_plugin('advanced_stats')

      # AdvancedStats depends on BasicStats methods (mean, standard_deviation)
      analyzer = NumberAnalyzer.new([1, 1, 1, 1, 1]) # All same values

      # This should work because BasicStats provides mean and standard_deviation
      deviation_scores = analyzer.deviation_scores
      expect(deviation_scores).to all(eq(50.0)) # All values should be 50 when std_dev is 0
    end
  end

  describe 'CLI system integration' do
    before do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'
      require_relative '../plugins/math_utils_plugin'

      plugin_system.register_plugin('math_utils', MathUtilsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)

      plugin_system.load_plugin('math_utils')
      plugin_system.load_plugin('basic_stats')
      plugin_system.load_plugin('advanced_stats')
    end

    it 'supports mixed core and plugin commands' do
      all_commands = cli_class.commands

      # Core commands should still be present
      expect(all_commands).to include('median') # Core command from CORE_COMMANDS
      expect(all_commands['median']).to be_a(Symbol) # Core commands map to symbols

      # Plugin commands should be present
      expect(all_commands).to include('sum', 'mean') # Plugin commands
      expect(all_commands['sum']).to be_a(Hash) # Plugin commands map to hashes
      expect(all_commands['sum'][:plugin_class]).to eq(BasicStatsPlugin)

      # Advanced plugin commands
      expect(all_commands).to include('percentile', 'quartiles')
      expect(all_commands['percentile'][:plugin_class]).to eq(AdvancedStatsPlugin)
    end

    it 'handles command name conflicts appropriately' do
      # The CLI should handle cases where plugin commands might conflict with core commands
      commands = cli_class.commands

      # If there's a conflict, the plugin command should win (last registered)
      # This test verifies the merge behavior works correctly
      expect(commands.keys).to include('sum', 'mean', 'mode', 'variance')

      # Verify command mapping is correct
      expect(commands['sum'][:method]).to eq(:sum)
      expect(commands['mean'][:method]).to eq(:mean)
    end

    it 'maintains proper separation between core and plugin commands' do
      commands = cli_class.commands

      # Core commands should still exist
      expect(commands).to have_key('median') # Core command
      expect(commands['median']).to be_a(Symbol) # Core commands map to symbols

      # Plugin commands should be present
      expect(commands).to have_key('sum') # Plugin command
      expect(commands['sum']).to be_a(Hash) # Plugin commands map to hashes
    end

    it 'initializes plugin system correctly through CLI' do
      # Mock the enabled plugins configuration
      allow_any_instance_of(NumberAnalyzer::PluginSystem).to receive(:load_enabled_plugins)

      # Initialize plugins through CLI
      expect_any_instance_of(NumberAnalyzer::PluginSystem).to receive(:load_enabled_plugins)
      cli_class.initialize_plugins
    end

    it 'creates and maintains plugin system singleton' do
      system1 = cli_class.plugin_system
      system2 = cli_class.plugin_system

      expect(system1).to be_a(NumberAnalyzer::PluginSystem)
      expect(system1).to be(system2) # Same instance
    end
  end

  describe 'Backward compatibility' do
    it 'maintains compatibility with original module behavior' do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'

      # Load plugins
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)
      plugin_system.load_plugin('basic_stats')
      plugin_system.load_plugin('advanced_stats')

      # Plugin-based analyzer
      plugin_analyzer = NumberAnalyzer.new(sample_data)

      # Legacy analyzer using original modules
      legacy_analyzer = NumberAnalyzer.new(sample_data)
      legacy_analyzer.extend(BasicStats)
      legacy_analyzer.extend(AdvancedStats)

      # Compare results - they should be identical
      expect(plugin_analyzer.sum).to eq(legacy_analyzer.sum)
      expect(plugin_analyzer.mean).to eq(legacy_analyzer.mean)
      expect(plugin_analyzer.variance).to eq(legacy_analyzer.variance)
      expect(plugin_analyzer.percentile(75)).to eq(legacy_analyzer.percentile(75))
      expect(plugin_analyzer.outliers).to eq(legacy_analyzer.outliers)
    end

    it 'maintains existing NumberAnalyzer API without plugins' do
      # Even without loading plugins, core NumberAnalyzer functionality should work
      analyzer = NumberAnalyzer.new(sample_data)

      # These methods should be available from the original implementation
      expect(analyzer).to respond_to(:calculate_statistics)
      expect(analyzer).to respond_to(:median)
      expect(analyzer).to respond_to(:frequency_distribution)
      expect(analyzer).to respond_to(:display_histogram)
    end
  end

  describe 'Plugin metadata and introspection' do
    before do
      require_relative '../plugins/basic_stats_plugin'
      require_relative '../plugins/advanced_stats_plugin'
      require_relative '../plugins/math_utils_plugin'

      plugin_system.register_plugin('math_utils', MathUtilsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('basic_stats', BasicStatsPlugin, extension_point: :statistics_module)
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)
    end

    it 'provides correct plugin metadata' do
      basic_stats_metadata = plugin_system.plugin_metadata('basic_stats')
      expect(basic_stats_metadata[:name]).to eq('basic_stats')
      expect(basic_stats_metadata[:version]).to eq('1.0.0')
      expect(basic_stats_metadata[:dependencies]).to eq([])

      advanced_stats_metadata = plugin_system.plugin_metadata('advanced_stats')
      expect(advanced_stats_metadata[:name]).to eq('advanced_stats')
      expect(advanced_stats_metadata[:dependencies]).to eq(['basic_stats'])
    end

    it 'tracks loaded plugins correctly' do
      expect(plugin_system.loaded_plugins).to be_empty

      plugin_system.load_plugin('basic_stats')
      expect(plugin_system.loaded_plugins).to eq(['basic_stats'])

      plugin_system.load_plugin('advanced_stats')
      expect(plugin_system.loaded_plugins).to include('basic_stats', 'advanced_stats')
    end

    it 'provides plugin introspection capabilities' do
      expect(plugin_system.available_plugins).to include('basic_stats', 'advanced_stats', 'math_utils')
      expect(plugin_system.plugin_loaded?('basic_stats')).to be false

      plugin_system.load_plugin('basic_stats')
      expect(plugin_system.plugin_loaded?('basic_stats')).to be true
    end
  end

  describe 'Error handling and robustness' do
    it 'handles plugin loading failures gracefully' do
      # Try to load a plugin that doesn't exist
      result = plugin_system.load_plugin('nonexistent_plugin')
      expect(result).to be false

      # System should remain stable
      expect { plugin_system.available_plugins }.not_to raise_error
      expect(plugin_system.loaded_plugins).not_to include('nonexistent_plugin')
    end

    it 'handles missing dependencies gracefully' do
      require_relative '../plugins/advanced_stats_plugin'

      # Try to load AdvancedStats without BasicStats dependency
      plugin_system.register_plugin('advanced_stats', AdvancedStatsPlugin, extension_point: :statistics_module)

      # This should fail due to missing dependency
      result = plugin_system.load_plugin('advanced_stats')
      expect(result).to be false
    end

    it 'handles plugins without CLI commands gracefully' do
      # Create a plugin without CLI commands
      test_plugin = Module.new do
        def test_method
          'test result'
        end
      end

      # This should not raise an error
      expect do
        plugin_system.register_plugin('no_cli', test_plugin, extension_point: :statistics_module)
        plugin_system.load_plugin('no_cli')
      end.not_to raise_error

      # And the plugin should still be loaded
      expect(plugin_system.plugin_loaded?('no_cli')).to be true
    end
  end
end
