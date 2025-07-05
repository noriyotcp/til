# frozen_string_literal: true

# Auto-loader for all command classes
# This file ensures all command classes are loaded and registered

require_relative '../../number_analyzer'
require_relative 'command_registry'
require_relative 'commands/median_command'
require_relative 'commands/mean_command'
require_relative 'commands/sum_command'
require_relative 'commands/min_command'
require_relative 'commands/max_command'
require_relative 'commands/mode_command'

class NumberAnalyzer
  # Command registration and management
  module Commands
    # Register all basic commands
    def self.register_all
      CommandRegistry.register(MedianCommand)
      CommandRegistry.register(MeanCommand)
      CommandRegistry.register(SumCommand)
      CommandRegistry.register(MinCommand)
      CommandRegistry.register(MaxCommand)
      CommandRegistry.register(ModeCommand)
    end
  end
end

# Auto-register when loaded
NumberAnalyzer::Commands.register_all
