# frozen_string_literal: true

require 'json'
require_relative 'presenters'

# Handles the presentation and formatting of statistical results
# Formats and displays statistical analysis results in various output formats
#
# Provides comprehensive formatting for statistical test results including
# basic statistics, histograms, and advanced statistical tests (ANOVA, t-tests,
# non-parametric tests, etc.). Supports multiple output formats including
# verbose, JSON, and quiet modes with customizable precision.
class Numana::StatisticsPresenter
  def self.display_results(stats)
    puts <<~RESULTS
      Total: #{stats[:total]}
      Average: #{stats[:average]}
      Maximum: #{stats[:maximum]}
      Minimum: #{stats[:minimum]}
      Median: #{stats[:median_value]}
      Variance: #{stats[:variance].round(2)}
      Mode: #{format_mode(stats[:mode_values])}
      Standard Deviation: #{stats[:std_dev].round(2)}
      Interquartile Range (IQR): #{stats[:iqr]&.round(2) || 'None'}
      Outliers: #{format_outliers(stats[:outlier_values])}
      Deviation Scores: #{format_deviation_scores(stats[:deviation_scores])}

    RESULTS
    display_histogram(stats[:frequency_distribution])
  end

  def self.display_histogram(frequency_distribution)
    puts 'Frequency Distribution Histogram:'

    if frequency_distribution.nil? || frequency_distribution.empty?
      puts '(No data available)'
      return
    end

    frequency_distribution.sort.each do |value, count|
      bar = '■' * count
      puts "#{value}: #{bar} (#{count})"
    end
  end

  def self.format_mode(mode_values)
    return 'None' if mode_values.empty?

    mode_values.join(', ')
  end

  def self.format_outliers(outlier_values)
    return 'None' if outlier_values.empty?

    outlier_values.join(', ')
  end

  def self.format_deviation_scores(deviation_scores)
    return 'None' if deviation_scores.empty?

    deviation_scores.join(', ')
  end

  def self.format_levene_test(result, options = {})
    Numana::Presenters::LeveneTestPresenter.new(result, options).format
  end

  def self.format_bartlett_test(result, options = {})
    Numana::Presenters::BartlettTestPresenter.new(result, options).format
  end

  def self.format_kruskal_wallis_test(result, options = {})
    Numana::Presenters::KruskalWallisTestPresenter.new(result, options).format
  end

  def self.format_mann_whitney_test(result, options = {})
    Numana::Presenters::MannWhitneyTestPresenter.new(result, options).format
  end

  def self.format_wilcoxon_test(result, options = {})
    Numana::Presenters::WilcoxonTestPresenter.new(result, options).format
  end

  def self.format_friedman_test(result, options = {})
    Numana::Presenters::FriedmanTestPresenter.new(result, options).format
  end

  private_class_method :format_mode, :format_outliers, :format_deviation_scores, :display_histogram
end
