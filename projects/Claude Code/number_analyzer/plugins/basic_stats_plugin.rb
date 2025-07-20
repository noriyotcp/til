# frozen_string_literal: true

require_relative '../lib/numana/plugin_interface'

# BasicStatsPlugin - Plugin implementation of basic statistical functions
# Provides fundamental statistical calculations as a plugin
module BasicStatsPlugin
  include Numana::StatisticsPlugin

  # Plugin metadata
  plugin_name 'basic_stats'
  plugin_version '1.0.0'
  plugin_description 'basic statistical functions including sum, mean, mode, variance, and standard deviation'
  plugin_author 'NumberAnalyzer Team'
  plugin_dependencies []

  # Register plugin methods
  register_method :sum, 'Calculate sum of all numbers'
  register_method :mean, 'Calculate arithmetic mean (average)'
  register_method :mode, 'Find the most frequently occurring value(s)'
  register_method :variance, 'Calculate population variance'
  register_method :standard_deviation, 'Calculate standard deviation'

  # Define CLI commands mapping
  def self.plugin_commands
    {
      'sum' => :sum,
      'mean' => :mean,
      'mode' => :mode,
      'variance' => :variance,
      'std-dev' => :standard_deviation
    }
  end

  # Calculate sum of all numbers
  # 全数値の合計を計算
  def sum
    @numbers.sum
  end

  # Calculate arithmetic mean (average)
  # 算術平均を計算
  def mean
    average_value
  end

  # Find the most frequently occurring value(s)
  # 最頻値を計算
  def mode
    frequency = @numbers.tally
    max_frequency = frequency.values.max

    return [] if max_frequency == 1

    frequency.select { |_, count| count == max_frequency }.keys
  end

  # Calculate population variance
  # 母分散を計算
  def variance
    return 0.0 if @numbers.length <= 1

    mean = average_value
    @numbers.sum { |num| (num - mean)**2 } / @numbers.length
  end

  # Calculate standard deviation
  # 標準偏差を計算
  def standard_deviation
    Math.sqrt(variance)
  end

  private

  # Calculate average value (mean)
  # 平均値を計算
  def average_value
    return 0.0 if @numbers.empty?

    @numbers.sum.to_f / @numbers.length
  end
end
