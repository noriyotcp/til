# frozen_string_literal: true

require 'json'

# Handles the presentation and formatting of statistical results
# Formats and displays statistical analysis results in various output formats
#
# Provides comprehensive formatting for statistical test results including
# basic statistics, histograms, and advanced statistical tests (ANOVA, t-tests,
# non-parametric tests, etc.). Supports multiple output formats including
# verbose, JSON, and quiet modes with customizable precision.
class NumberAnalyzer::StatisticsPresenter
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
    NumberAnalyzer::Presenters::LeveneTestPresenter.new(result, options).format
  end

  def self.format_bartlett_test(result, options = {})
    if options[:format] == 'json'
      format_bartlett_test_json(result, options)
    elsif options[:quiet]
      format_bartlett_test_quiet(result, options)
    else
      format_bartlett_test_verbose(result, options)
    end
  end

  def self.format_bartlett_test_verbose(result, options = {})
    precision = options[:precision] || 6

    output = []
    output.concat(build_bartlett_header)
    output.concat(build_bartlett_statistics(result, precision))
    output.concat(build_bartlett_interpretation(result))
    output.concat(build_bartlett_notes)

    output.join("\n")
  end

  def self.build_bartlett_header
    ['=== Bartlett Test Results ===', '']
  end

  def self.build_bartlett_statistics(result, precision)
    [
      'Test Statistics:',
      "  Chi-square statistic: #{result[:chi_square_statistic].round(precision)}",
      "  p-value: #{result[:p_value].round(precision)}",
      "  Degrees of Freedom: #{result[:degrees_of_freedom]}",
      "  Correction Factor: #{result[:correction_factor].round(precision)}",
      "  Pooled Variance: #{result[:pooled_variance].round(precision)}",
      ''
    ]
  end

  def self.build_bartlett_interpretation(result)
    output = ['Statistical Decision:']
    if result[:significant]
      output << '  Result: **Significant difference** (p < 0.05)'
      output << '  Conclusion: Group variances are not equal'
    else
      output << '  Result: No significant difference (p ≥ 0.05)'
      output << '  Conclusion: Group variances are considered equal'
    end
    output << ''
    output << 'Interpretation:'
    output << "  #{result[:interpretation]}"
    output << ''
  end

  def self.build_bartlett_notes
    [
      'Notes:',
      '  - Bartlett test assumes normal distribution',
      '  - More precise than Levene test when normality is satisfied',
      '  - This test is used to check ANOVA assumptions'
    ]
  end

  def self.format_bartlett_test_json(result, options = {})
    precision = options[:precision] || 6

    formatted_result = {
      test_type: result[:test_type],
      chi_square_statistic: result[:chi_square_statistic].round(precision),
      p_value: result[:p_value].round(precision),
      degrees_of_freedom: result[:degrees_of_freedom],
      significant: result[:significant],
      interpretation: result[:interpretation],
      correction_factor: result[:correction_factor].round(precision),
      pooled_variance: result[:pooled_variance].round(precision)
    }

    JSON.generate(formatted_result)
  end

  def self.format_bartlett_test_quiet(result, options = {})
    precision = options[:precision] || 6
    chi_square_stat = result[:chi_square_statistic].round(precision)
    p_value = result[:p_value].round(precision)
    "#{chi_square_stat} #{p_value}"
  end

  def self.format_kruskal_wallis_test(result, options = {})
    case options[:format]
    when 'json'
      format_kruskal_wallis_test_json(result, options)
    when 'quiet'
      format_kruskal_wallis_test_quiet(result, options)
    else
      format_kruskal_wallis_test_verbose(result, options)
    end
  end

  def self.format_kruskal_wallis_test_verbose(result, options = {})
    precision = options[:precision] || 6

    output = []
    output << build_kruskal_wallis_header
    output << build_kruskal_wallis_statistics(result, precision)
    output << build_kruskal_wallis_interpretation(result)
    output << build_kruskal_wallis_notes

    output.compact.join("\n")
  end

  def self.format_kruskal_wallis_test_json(result, options = {})
    precision = options[:precision] || 6

    formatted_result = {
      test_type: result[:test_type],
      h_statistic: result[:h_statistic].round(precision),
      p_value: result[:p_value].round(precision),
      degrees_of_freedom: result[:degrees_of_freedom],
      significant: result[:significant],
      interpretation: result[:interpretation],
      group_sizes: result[:group_sizes],
      total_n: result[:total_n]
    }

    JSON.generate(formatted_result)
  end

  def self.format_kruskal_wallis_test_quiet(result, options = {})
    precision = options[:precision] || 6
    h_stat = result[:h_statistic].round(precision)
    p_value = result[:p_value].round(precision)
    "#{h_stat} #{p_value}"
  end

  def self.build_kruskal_wallis_header
    '=== Kruskal-Wallis H Test ==='
  end

  def self.build_kruskal_wallis_statistics(result, precision)
    [
      "H-statistic: #{result[:h_statistic].round(precision)}",
      "Degrees of Freedom: #{result[:degrees_of_freedom]}",
      "p-value: #{result[:p_value].round(precision)}",
      "Total Sample Size: #{result[:total_n]}",
      "Group Sizes: #{result[:group_sizes].join(', ')}"
    ].join("\n")
  end

  def self.build_kruskal_wallis_interpretation(result)
    significance = result[:significant] ? '**Significant**' : 'Not significant'
    [
      "Result: #{significance} (α = 0.05)",
      "Interpretation: #{result[:interpretation]}"
    ].join("\n")
  end

  def self.build_kruskal_wallis_notes
    [
      '',
      'Notes:',
      '• Kruskal-Wallis test is a non-parametric test',
      '• Does not require normal distribution assumption but assumes same distribution shape',
      '• If significant difference is found, consider post-hoc tests (e.g., Dunn test)'
    ].join("\n")
  end

  def self.format_mann_whitney_test(result, options = {})
    case options[:format]
    when 'json'
      format_mann_whitney_test_json(result, options)
    when 'quiet'
      format_mann_whitney_test_quiet(result, options)
    else
      format_mann_whitney_test_verbose(result, options)
    end
  end

  def self.format_mann_whitney_test_verbose(result, options = {})
    precision = options[:precision] || 6

    output = []
    output << build_mann_whitney_header
    output << build_mann_whitney_statistics(result, precision)
    output << build_mann_whitney_interpretation(result)
    output << build_mann_whitney_notes

    output.compact.join("\n")
  end

  def self.format_mann_whitney_test_json(result, options = {})
    precision = options[:precision] || 6

    formatted_result = {
      test_type: result[:test_type],
      u_statistic: result[:u_statistic].round(precision),
      u1: result[:u1].round(precision),
      u2: result[:u2].round(precision),
      z_statistic: result[:z_statistic].round(precision),
      p_value: result[:p_value].round(precision),
      significant: result[:significant],
      interpretation: result[:interpretation],
      effect_size: result[:effect_size].round(precision),
      group_sizes: result[:group_sizes],
      rank_sums: result[:rank_sums],
      total_n: result[:total_n]
    }

    JSON.generate(formatted_result)
  end

  def self.format_mann_whitney_test_quiet(result, options = {})
    precision = options[:precision] || 6
    u_stat = result[:u_statistic].round(precision)
    p_value = result[:p_value].round(precision)
    "#{u_stat} #{p_value}"
  end

  def self.build_mann_whitney_header
    '=== Mann-Whitney U Test ==='
  end

  def self.build_mann_whitney_statistics(result, precision)
    [
      "U-statistic: #{result[:u_statistic].round(precision)}",
      "U1: #{result[:u1].round(precision)}, U2: #{result[:u2].round(precision)}",
      "z-statistic: #{result[:z_statistic].round(precision)}",
      "p-value: #{result[:p_value].round(precision)}",
      "Effect Size (r): #{result[:effect_size].round(precision)}",
      "Group Sizes: #{result[:group_sizes].join(', ')}",
      "Rank Sums: #{result[:rank_sums].join(', ')}"
    ].join("\n")
  end

  def self.build_mann_whitney_interpretation(result)
    significance = result[:significant] ? '**Significant**' : 'Not significant'
    effect_magnitude = case result[:effect_size]
                       when 0.0...0.1
                         'Effect Size: Negligible'
                       when 0.1...0.3
                         'Effect Size: Small'
                       when 0.3...0.5
                         'Effect Size: Medium'
                       else
                         'Effect Size: Large'
                       end

    [
      "Result: #{significance} (α = 0.05)",
      "Interpretation: #{result[:interpretation]}",
      effect_magnitude
    ].join("\n")
  end

  def self.build_mann_whitney_notes
    [
      '',
      'Notes:',
      '• Mann-Whitney U test is a non-parametric test for two-group comparison',
      '• Used as alternative to t-test when normal distribution is not assumed',
      '• Robust against outliers due to rank-based testing',
      '• Assumes same distribution shape but tests for location (median) differences'
    ].join("\n")
  end

  def self.format_wilcoxon_test(result, options = {})
    case options[:format]
    when 'json'
      format_wilcoxon_test_json(result, options)
    when 'quiet'
      format_wilcoxon_test_quiet(result, options)
    else
      format_wilcoxon_test_verbose(result, options)
    end
  end

  def self.format_wilcoxon_test_verbose(result, options = {})
    precision = options[:precision] || 6

    output = []
    output << build_wilcoxon_header
    output << build_wilcoxon_statistics(result, precision)
    output << build_wilcoxon_interpretation(result)
    output << build_wilcoxon_notes

    output.compact.join("\n")
  end

  def self.format_wilcoxon_test_json(result, options = {})
    precision = options[:precision] || 6

    formatted_result = {
      test_type: result[:test_type],
      w_statistic: result[:w_statistic].round(precision),
      w_plus: result[:w_plus].round(precision),
      w_minus: result[:w_minus].round(precision),
      z_statistic: result[:z_statistic].round(precision),
      p_value: result[:p_value].round(precision),
      significant: result[:significant],
      interpretation: result[:interpretation],
      effect_size: result[:effect_size].round(precision),
      n_pairs: result[:n_pairs],
      n_effective: result[:n_effective],
      n_zeros: result[:n_zeros]
    }

    JSON.generate(formatted_result)
  end

  def self.format_wilcoxon_test_quiet(result, options = {})
    precision = options[:precision] || 6
    w_stat = result[:w_statistic].round(precision)
    p_value = result[:p_value].round(precision)
    "#{w_stat} #{p_value}"
  end

  def self.build_wilcoxon_header
    '=== Wilcoxon Signed-Rank Test ==='
  end

  def self.build_wilcoxon_statistics(result, precision)
    [
      "W-statistic: #{result[:w_statistic].round(precision)}",
      "W+ (positive rank sum): #{result[:w_plus].round(precision)}",
      "W- (negative rank sum): #{result[:w_minus].round(precision)}",
      "z-statistic: #{result[:z_statistic].round(precision)}",
      "p-value: #{result[:p_value].round(precision)}",
      "Effect Size (r): #{result[:effect_size].round(precision)}",
      "Number of Pairs: #{result[:n_pairs]}",
      "Effective Pairs: #{result[:n_effective]} (Zero differences excluded: #{result[:n_zeros]})"
    ].join("\n")
  end

  def self.build_wilcoxon_interpretation(result)
    significance = result[:significant] ? '**Significant**' : 'Not significant'
    effect_magnitude = case result[:effect_size]
                       when 0.0...0.1
                         'Effect Size: Negligible'
                       when 0.1...0.3
                         'Effect Size: Small'
                       when 0.3...0.5
                         'Effect Size: Medium'
                       else
                         'Effect Size: Large'
                       end

    [
      "Result: #{significance} (α = 0.05)",
      "Interpretation: #{result[:interpretation]}",
      effect_magnitude
    ].join("\n")
  end

  def self.build_wilcoxon_notes
    [
      '',
      'Notes:',
      '• Wilcoxon signed-rank test is a non-parametric test for paired data',
      '• Used as alternative to paired t-test when normal distribution is not assumed',
      '• Assumes symmetric distribution of differences but normality is not required',
      '• Zero differences are excluded from the test'
    ].join("\n")
  end

  def self.format_friedman_test(result, options = {})
    case options[:format]
    when 'json'
      format_friedman_test_json(result, options)
    when 'quiet'
      format_friedman_test_quiet(result, options)
    else
      format_friedman_test_verbose(result, options)
    end
  end

  def self.format_friedman_test_verbose(result, options = {})
    precision = options[:precision] || 6

    output = []
    output << build_friedman_header
    output << build_friedman_statistics(result, precision)
    output << build_friedman_interpretation(result)
    output << build_friedman_notes

    output.compact.join("\n")
  end

  def self.format_friedman_test_json(result, options = {})
    precision = options[:precision] || 6

    formatted_result = {
      test_type: result[:test_type],
      chi_square_statistic: result[:chi_square_statistic].round(precision),
      p_value: result[:p_value].round(precision),
      degrees_of_freedom: result[:degrees_of_freedom],
      significant: result[:significant],
      interpretation: result[:interpretation],
      rank_sums: result[:rank_sums],
      n_subjects: result[:n_subjects],
      k_conditions: result[:k_conditions],
      total_observations: result[:total_observations]
    }

    JSON.generate(formatted_result)
  end

  def self.format_friedman_test_quiet(result, options = {})
    precision = options[:precision] || 6
    chi_square = result[:chi_square_statistic].round(precision)
    p_value = result[:p_value].round(precision)
    "#{chi_square} #{p_value}"
  end

  def self.build_friedman_header
    '=== Friedman Test ==='
  end

  def self.build_friedman_statistics(result, precision)
    [
      "χ²-statistic: #{result[:chi_square_statistic].round(precision)}",
      "Degrees of Freedom: #{result[:degrees_of_freedom]}",
      "p-value: #{result[:p_value].round(precision)}",
      "Number of Subjects: #{result[:n_subjects]}",
      "Number of Conditions: #{result[:k_conditions]}",
      "Total Observations: #{result[:total_observations]}",
      "Rank Sums: #{result[:rank_sums].join(', ')}"
    ].join("\n")
  end

  def self.build_friedman_interpretation(result)
    significance = result[:significant] ? '**Significant**' : 'Not significant'
    [
      "Result: #{significance} (α = 0.05)",
      "Interpretation: #{result[:interpretation]}"
    ].join("\n")
  end

  def self.build_friedman_notes
    [
      '',
      'Notes:',
      '• Friedman test is a non-parametric test for repeated measures data',
      '• Used as alternative to repeated measures ANOVA when normal distribution is not assumed',
      '• Assumes same subjects are measured under multiple conditions',
      '• If significant difference is found, consider post-hoc tests (e.g., Nemenyi test)'
    ].join("\n")
  end

  private_class_method :format_mode, :format_outliers, :format_deviation_scores, :display_histogram,
                       :format_bartlett_test_verbose, :format_bartlett_test_json, :format_bartlett_test_quiet,
                       :build_bartlett_header, :build_bartlett_statistics,
                       :build_bartlett_interpretation, :build_bartlett_notes,
                       :format_kruskal_wallis_test_verbose, :format_kruskal_wallis_test_json,
                       :format_kruskal_wallis_test_quiet, :build_kruskal_wallis_header,
                       :build_kruskal_wallis_statistics, :build_kruskal_wallis_interpretation,
                       :build_kruskal_wallis_notes,
                       :format_mann_whitney_test_verbose, :format_mann_whitney_test_json,
                       :format_mann_whitney_test_quiet, :build_mann_whitney_header,
                       :build_mann_whitney_statistics, :build_mann_whitney_interpretation,
                       :build_mann_whitney_notes,
                       :format_wilcoxon_test_verbose, :format_wilcoxon_test_json,
                       :format_wilcoxon_test_quiet, :build_wilcoxon_header,
                       :build_wilcoxon_statistics, :build_wilcoxon_interpretation,
                       :build_wilcoxon_notes,
                       :format_friedman_test_verbose, :format_friedman_test_json,
                       :format_friedman_test_quiet, :build_friedman_header,
                       :build_friedman_statistics, :build_friedman_interpretation,
                       :build_friedman_notes
end
