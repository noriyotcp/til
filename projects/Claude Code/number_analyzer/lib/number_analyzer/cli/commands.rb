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

# Extend the Commands module with registration functionality
module NumberAnalyzer::Commands
  # Register all basic commands
  def self.register_all
    CommandRegistry.register(MedianCommand)
    CommandRegistry.register(MeanCommand)
    CommandRegistry.register(SumCommand)
    CommandRegistry.register(MinCommand)
    CommandRegistry.register(MaxCommand)
    CommandRegistry.register(ModeCommand)
    CommandRegistry.register(HistogramCommand)
    CommandRegistry.register(OutliersCommand)
    CommandRegistry.register(PercentileCommand)
    CommandRegistry.register(QuartilesCommand)
    CommandRegistry.register(VarianceCommand)
    CommandRegistry.register(StdCommand)
    CommandRegistry.register(DeviationScoresCommand)
    CommandRegistry.register(CorrelationCommand)
    CommandRegistry.register(TrendCommand)
  end
end

# Auto-register when loaded
NumberAnalyzer::Commands.register_all
