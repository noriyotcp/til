# frozen_string_literal: true

require_relative '../../../lib/number_analyzer/plugin_interface'

# Safe example plugin for testing
module SafeStatsPlugin
  include Numana::StatisticsPlugin

  plugin_name 'safe_stats'
  plugin_version '1.0.0'
  plugin_description 'Safe statistics plugin'
  plugin_author 'Test Author'
  plugin_dependencies []

  register_method :safe_mean, 'Calculate mean safely'

  def self.plugin_commands
    {
      'safe-mean' => :safe_mean
    }
  end

  def safe_mean
    validate_numbers!
    result = @numbers.sum.to_f / @numbers.length

    {
      result: result,
      data: @numbers,
      interpretation: "The mean is #{result}"
    }
  end

  private

  def validate_numbers!
    raise ArgumentError, 'Numbers array cannot be empty' if @numbers.empty?
  end
end
