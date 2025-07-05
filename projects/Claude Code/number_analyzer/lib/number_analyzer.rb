# frozen_string_literal: true

require_relative 'number_analyzer/statistics/basic_stats'
require_relative 'number_analyzer/statistics/math_utils'
require_relative 'number_analyzer/statistics/advanced_stats'
require_relative 'number_analyzer/statistics/correlation_stats'
require_relative 'number_analyzer/statistics/time_series_stats'
require_relative 'number_analyzer/statistics/hypothesis_testing'
require_relative 'number_analyzer/statistics/anova_stats'
require_relative 'number_analyzer/statistics/non_parametric_stats'

# 数値配列の統計を計算するプログラム
class NumberAnalyzer
  include BasicStats
  include AdvancedStats
  include CorrelationStats
  include TimeSeriesStats
  include HypothesisTesting
  include ANOVAStats
  include NonParametricStats

  def initialize(numbers)
    @numbers = numbers
  end

  def calculate_statistics
    stats = {
      total: @numbers.sum,
      average: average_value,
      maximum: @numbers.max,
      minimum: @numbers.min,
      median_value: median,
      variance: variance,
      mode_values: mode,
      std_dev: standard_deviation,
      iqr: interquartile_range,
      outlier_values: outliers,
      deviation_scores: deviation_scores,
      frequency_distribution: frequency_distribution
    }

    StatisticsPresenter.display_results(stats)
  end

  def median = percentile(50)

  def frequency_distribution = @numbers.tally

  def display_histogram
    puts '度数分布ヒストグラム:'

    freq_dist = frequency_distribution

    if freq_dist.empty?
      puts '(データが空です)'
      return
    end

    freq_dist.sort.each do |value, count|
      bar = '■' * count
      puts "#{value}: #{bar} (#{count})"
    end
  end
end

# Load StatisticsPresenter after NumberAnalyzer class is defined
require_relative 'number_analyzer/statistics_presenter'
