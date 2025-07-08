# frozen_string_literal: true

# Auto-loader for all command classes
# This file ensures all command classes are loaded and registered

require_relative '../../number_analyzer'

# Command registration and management
module NumberAnalyzer::Commands
end

require_relative 'command_registry'
require_relative 'base_command'
require_relative 'commands/median_command'
require_relative 'commands/mean_command'
require_relative 'commands/sum_command'
require_relative 'commands/min_command'
require_relative 'commands/max_command'
require_relative 'commands/mode_command'
require_relative 'commands/histogram_command'
require_relative 'commands/outliers_command'
require_relative 'commands/percentile_command'
require_relative 'commands/quartiles_command'
require_relative 'commands/variance_command'
require_relative 'commands/std_command'
require_relative 'commands/deviation_scores_command'
require_relative 'commands/correlation_command'
require_relative 'commands/trend_command'
require_relative 'commands/moving_average_command'
require_relative 'commands/growth_rate_command'
require_relative 'commands/seasonal_command'
require_relative 'commands/t_test_command'
require_relative 'commands/confidence_interval_command'
require_relative 'commands/chi_square_command'
require_relative 'commands/anova_command'
require_relative 'commands/two_way_anova_command'
require_relative 'commands/levene_command'
require_relative 'commands/bartlett_command'
require_relative 'commands/kruskal_wallis_command'
require_relative 'commands/mann_whitney_command'
require_relative 'commands/wilcoxon_command'
require_relative 'commands/friedman_command'
require_relative 'commands/plugins_command'
require_relative 'commands/help_command'

# Extend the Commands module with registration functionality
module NumberAnalyzer::Commands
  # Register all commands by category
  def self.register_all
    register_basic_commands
    register_advanced_commands
    register_analysis_commands
    register_specialized_commands
  end

  # Register basic statistical commands
  def self.register_basic_commands
    CommandRegistry.register(MedianCommand)
    CommandRegistry.register(MeanCommand)
    CommandRegistry.register(SumCommand)
    CommandRegistry.register(MinCommand)
    CommandRegistry.register(MaxCommand)
    CommandRegistry.register(ModeCommand)
    CommandRegistry.register(HistogramCommand)
    CommandRegistry.register(HelpCommand)
  end

  # Register advanced statistical commands
  def self.register_advanced_commands
    CommandRegistry.register(OutliersCommand)
    CommandRegistry.register(PercentileCommand)
    CommandRegistry.register(QuartilesCommand)
    CommandRegistry.register(VarianceCommand)
    CommandRegistry.register(StdCommand)
    CommandRegistry.register(DeviationScoresCommand)
  end

  # Register correlation and time series analysis commands
  def self.register_analysis_commands
    CommandRegistry.register(CorrelationCommand)
    CommandRegistry.register(TrendCommand)
    CommandRegistry.register(MovingAverageCommand)
    CommandRegistry.register(GrowthRateCommand)
    CommandRegistry.register(SeasonalCommand)
    CommandRegistry.register(TTestCommand)
    CommandRegistry.register(ConfidenceIntervalCommand)
    CommandRegistry.register(ChiSquareCommand)
  end

  # Register specialized statistical commands (ANOVA, non-parametric, plugins)
  def self.register_specialized_commands
    CommandRegistry.register(AnovaCommand)
    CommandRegistry.register(TwoWayAnovaCommand)
    CommandRegistry.register(LeveneCommand)
    CommandRegistry.register(BartlettCommand)
    CommandRegistry.register(KruskalWallisCommand)
    CommandRegistry.register(MannWhitneyCommand)
    CommandRegistry.register(WilcoxonCommand)
    CommandRegistry.register(FriedmanCommand)
    CommandRegistry.register(PluginsCommand)
  end
end

# Auto-register when loaded
NumberAnalyzer::Commands.register_all
