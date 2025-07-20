# frozen_string_literal: true

require_relative '../lib/numana/plugin_interface'

# VisualizationPlugin - Advanced ASCII visualization capabilities
# Demonstrates output format plugin implementation with comprehensive chart generation
module VisualizationPlugin
  include Numana::StatisticsPlugin

  # Plugin metadata
  plugin_name 'visualization'
  plugin_version '1.0.0'
  plugin_description 'Comprehensive ASCII visualization plugin supporting histograms, box plots, scatter plots, and statistical charts'
  plugin_author 'NumberAnalyzer Visualization Team'
  plugin_dependencies ['basic_stats']

  # Register plugin methods
  register_method :ascii_histogram, 'Generate ASCII histogram with customizable bins'
  register_method :box_plot, 'Create ASCII box plot showing quartiles and outliers'
  register_method :scatter_plot, 'Generate ASCII scatter plot for paired data'
  register_method :line_chart, 'Create ASCII line chart for trend visualization'
  register_method :bar_chart, 'Generate ASCII bar chart for categorical data'
  register_method :distribution_plot, 'Create ASCII normal distribution overlay'
  register_method :summary_dashboard, 'Generate comprehensive statistical dashboard'

  # Define CLI commands mapping
  def self.plugin_commands
    {
      'histogram' => :ascii_histogram,
      'boxplot' => :box_plot,
      'scatter' => :scatter_plot,
      'line-chart' => :line_chart,
      'bar-chart' => :bar_chart,
      'distribution' => :distribution_plot,
      'dashboard' => :summary_dashboard
    }
  end

  # Generate ASCII histogram with customizable bins
  def ascii_histogram(bins = nil, options = {})
    validate_numbers!

    bins ||= calculate_optimal_bins
    min_val, max_val = @numbers.minmax
    bin_width = (max_val - min_val).to_f / bins

    # Create bins
    bin_counts = Array.new(bins, 0)
    bin_labels = []

    bins.times do |i|
      bin_start = min_val + (i * bin_width)
      bin_end = min_val + ((i + 1) * bin_width)
      bin_labels << "#{bin_start.round(2)}-#{bin_end.round(2)}"

      @numbers.each do |num|
        if i == bins - 1 # Last bin includes the maximum
          bin_counts[i] += 1 if num.between?(bin_start, bin_end)
        elsif num >= bin_start && num < bin_end
          bin_counts[i] += 1
        end
      end
    end

    # Generate ASCII histogram
    max_count = bin_counts.max
    chart_width = options[:width] || 50
    scale_factor = chart_width.to_f / max_count

    histogram_lines = []
    histogram_lines << "ASCII Histogram (#{@numbers.length} values, #{bins} bins)"
    histogram_lines << ('=' * 60)

    bin_counts.each_with_index do |count, i|
      bar_length = (count * scale_factor).round
      bar = options[:char] || '█'
      percentage = (count.to_f / @numbers.length * 100).round(1)

      histogram_lines << format('%-15<label>s |%<bar>s %<count>d (%<percentage>.1f%%)',
                                label: bin_labels[i],
                                bar: bar * bar_length,
                                count: count,
                                percentage: percentage)
    end

    histogram_lines << ''
    histogram_lines << generate_histogram_stats(bin_counts, bins)

    {
      chart: histogram_lines.join("\n"),
      bins: bins,
      bin_counts: bin_counts,
      bin_labels: bin_labels,
      statistics: {
        max_frequency: max_count,
        modal_bin: bin_labels[bin_counts.index(max_count)],
        total_values: @numbers.length
      },
      interpretation: "Histogram shows distribution across #{bins} bins with #{max_count} max frequency"
    }
  end

  # Create ASCII box plot showing quartiles and outliers
  def box_plot(options = {})
    validate_numbers!

    q1, median, q3 = calculate_quartiles
    iqr = q3 - q1
    min_val, max_val = @numbers.minmax

    # Calculate whiskers and outliers
    lower_whisker = q1 - (1.5 * iqr)
    upper_whisker = q3 + (1.5 * iqr)

    # Find actual whisker positions (farthest non-outlier points)
    lower_fence = @numbers.select { |x| x >= lower_whisker }.min
    upper_fence = @numbers.select { |x| x <= upper_whisker }.max

    outliers = @numbers.select { |x| x < lower_whisker || x > upper_whisker }

    # Create scale
    chart_width = options[:width] || 60
    data_range = max_val - min_val
    scale_factor = chart_width.to_f / data_range

    # Position calculations
    positions = {
      min: ((min_val - min_val) * scale_factor).round,
      lower_fence: ((lower_fence - min_val) * scale_factor).round,
      q1: ((q1 - min_val) * scale_factor).round,
      median: ((median - min_val) * scale_factor).round,
      q3: ((q3 - min_val) * scale_factor).round,
      upper_fence: ((upper_fence - min_val) * scale_factor).round,
      max: ((max_val - min_val) * scale_factor).round
    }

    box_plot_lines = []
    box_plot_lines << 'ASCII Box Plot'
    box_plot_lines << ('=' * 30)
    box_plot_lines << ''

    # Create the box plot
    box_line = ' ' * chart_width
    whisker_line = ' ' * chart_width

    # Draw whiskers
    (positions[:lower_fence]..positions[:upper_fence]).each do |pos|
      next if pos.negative? || pos >= chart_width

      whisker_line[pos] = '─'
    end

    # Draw box
    (positions[:q1]..positions[:q3]).each do |pos|
      next if pos.negative? || pos >= chart_width

      box_line[pos] = '█'
    end

    # Mark special points
    whisker_line[positions[:lower_fence]] = '├' if positions[:lower_fence] >= 0 && positions[:lower_fence] < chart_width
    whisker_line[positions[:upper_fence]] = '┤' if positions[:upper_fence] >= 0 && positions[:upper_fence] < chart_width
    box_line[positions[:median]] = '│' if positions[:median] >= 0 && positions[:median] < chart_width

    # Mark outliers
    outlier_line = ' ' * chart_width
    outliers.each do |outlier|
      pos = ((outlier - min_val) * scale_factor).round
      outlier_line[pos] = 'o' if pos >= 0 && pos < chart_width
    end

    box_plot_lines << outlier_line if outliers.any?
    box_plot_lines << whisker_line
    box_plot_lines << box_line
    box_plot_lines << ''

    # Add scale
    scale_line = ''
    [min_val, q1, median, q3, max_val].each do |value|
      pos = ((value - min_val) * scale_factor).round
      scale_line += format('%-8.2<value>f', value: value) if (pos % 15).zero?
    end
    box_plot_lines << scale_line
    box_plot_lines << ''

    # Add statistics
    box_plot_lines << generate_boxplot_stats(q1, median, q3, iqr, outliers)

    {
      chart: box_plot_lines.join("\n"),
      quartiles: [q1, median, q3],
      whiskers: [lower_fence, upper_fence],
      outliers: outliers.sort,
      statistics: {
        iqr: iqr,
        outlier_count: outliers.length,
        whisker_range: upper_fence - lower_fence
      },
      interpretation: "Box plot shows median #{median.round(2)}, IQR #{iqr.round(2)}, #{outliers.length} outliers"
    }
  end

  # Generate ASCII scatter plot for paired data
  def scatter_plot(y_data = nil, options = {})
    validate_numbers!

    x_data = @numbers
    y_data ||= (1..@numbers.length).to_a

    raise ArgumentError, 'X and Y data must have same length' unless x_data.length == y_data.length

    chart_width = options[:width] || 50
    chart_height = options[:height] || 20

    x_min, x_max = x_data.minmax
    y_min, y_max = y_data.minmax

    x_range = x_max - x_min
    y_range = y_max - y_min

    # Avoid division by zero
    x_range = 1 if x_range.zero?
    y_range = 1 if y_range.zero?

    # Create grid
    grid = Array.new(chart_height) { Array.new(chart_width, ' ') }

    # Plot points
    x_data.zip(y_data).each do |x, y|
      x_pos = ((x - x_min) * (chart_width - 1) / x_range).round
      y_pos = chart_height - 1 - ((y - y_min) * (chart_height - 1) / y_range).round

      if x_pos >= 0 && x_pos < chart_width && y_pos >= 0 && y_pos < chart_height
        grid[y_pos][x_pos] = grid[y_pos][x_pos] == ' ' ? '*' : '#'
      end
    end

    scatter_lines = []
    scatter_lines << "ASCII Scatter Plot (#{x_data.length} points)"
    scatter_lines << ('=' * 40)
    scatter_lines << ''

    # Y-axis labels and grid
    grid.each_with_index do |row, i|
      y_value = y_max - (i * y_range / (chart_height - 1))
      scatter_lines << format('%8.2<y_value>f |%<row>s|', y_value: y_value, row: row.join)
    end

    # X-axis
    x_axis = "#{' ' * 10}+#{'-' * chart_width}+"
    scatter_lines << x_axis

    # X-axis labels
    x_labels = ' ' * 11
    (0...chart_width).step(10) do |i|
      x_value = x_min + (i * x_range / (chart_width - 1))
      x_labels += format('%-10.1<x_value>f', x_value: x_value)
    end
    scatter_lines << x_labels
    scatter_lines << ''

    # Calculate correlation
    correlation = calculate_correlation(x_data, y_data)

    scatter_lines << generate_scatter_stats(x_data, y_data, correlation)

    # Prepare interpretation components for better readability
    strength = interpret_correlation_strength(correlation.abs)
    direction = correlation >= 0 ? 'positive' : 'negative'
    r_value = correlation.round(3)

    {
      chart: scatter_lines.join("\n"),
      correlation: correlation,
      data_points: x_data.length,
      x_range: [x_min, x_max],
      y_range: [y_min, y_max],
      interpretation: <<~INTERPRETATION.strip
        Scatter plot shows #{strength} #{direction} correlation (r=#{r_value})
      INTERPRETATION
    }
  end

  # Create ASCII line chart for trend visualization
  def line_chart(options = {})
    validate_numbers!

    chart_width = options[:width] || 60
    chart_height = options[:height] || 15

    min_val, max_val = @numbers.minmax
    value_range = max_val - min_val
    value_range = 1 if value_range.zero?

    # Create grid
    grid = Array.new(chart_height) { Array.new(chart_width, ' ') }

    # Plot line
    x_step = (chart_width - 1).to_f / (@numbers.length - 1)

    @numbers.each_with_index do |value, i|
      x_pos = (i * x_step).round
      y_pos = chart_height - 1 - ((value - min_val) * (chart_height - 1) / value_range).round

      next unless x_pos >= 0 && x_pos < chart_width && y_pos >= 0 && y_pos < chart_height

      grid[y_pos][x_pos] = '*'

      # Connect points with lines
      next unless i.positive?

      prev_x = ((i - 1) * x_step).round
      prev_y = chart_height - 1 - ((@numbers[i - 1] - min_val) * (chart_height - 1) / value_range).round

      # Simple line drawing
      draw_line(grid, prev_x, prev_y, x_pos, y_pos, chart_width, chart_height)
    end

    line_chart_lines = []
    line_chart_lines << "ASCII Line Chart (#{@numbers.length} points)"
    line_chart_lines << ('=' * 40)
    line_chart_lines << ''

    # Y-axis and grid
    grid.each_with_index do |row, i|
      y_value = max_val - (i * value_range / (chart_height - 1))
      line_chart_lines << format('%8.2<y_value>f |%<row>s|', y_value: y_value, row: row.join)
    end

    # X-axis
    x_axis = "#{' ' * 10}+#{'-' * chart_width}+"
    line_chart_lines << x_axis
    line_chart_lines << ''

    # Calculate trend
    trend = calculate_trend

    line_chart_lines << generate_line_chart_stats(trend)

    {
      chart: line_chart_lines.join("\n"),
      trend: trend,
      data_points: @numbers.length,
      value_range: [min_val, max_val],
      interpretation: "Line chart shows #{trend[:direction]} trend with slope #{trend[:slope].round(4)}"
    }
  end

  # Generate ASCII bar chart for categorical data
  def bar_chart(options = {})
    validate_numbers!

    # Create frequency distribution
    frequency = @numbers.tally.sort_by { |value, _| value }

    chart_width = options[:width] || 40
    max_count = frequency.map { |_, count| count }.max

    bar_chart_lines = []
    bar_chart_lines << 'ASCII Bar Chart (Frequency Distribution)'
    bar_chart_lines << ('=' * 50)
    bar_chart_lines << ''

    frequency.each do |value, count|
      bar_length = (count * chart_width / max_count).round
      bar = options[:char] || '█'
      percentage = (count.to_f / @numbers.length * 100).round(1)

      bar_chart_lines << format('%-8<value>s |%<bar>s %<count>d (%<percentage>.1f%%)',
                                value: value.to_s,
                                bar: bar * bar_length,
                                count: count,
                                percentage: percentage)
    end

    bar_chart_lines << ''
    bar_chart_lines << generate_bar_chart_stats(frequency)

    {
      chart: bar_chart_lines.join("\n"),
      frequency_distribution: frequency.to_h,
      unique_values: frequency.length,
      max_frequency: max_count,
      interpretation: "Bar chart shows #{frequency.length} unique values with max frequency #{max_count}"
    }
  end

  # Create ASCII normal distribution overlay
  def distribution_plot(options = {})
    validate_numbers!

    mean = @numbers.sum.to_f / @numbers.length
    std_dev = Math.sqrt(@numbers.map { |x| (x - mean)**2 }.sum / (@numbers.length - 1))

    chart_width = options[:width] || 60
    chart_height = options[:height] || 20

    # Create range around mean ± 3 standard deviations
    x_min = mean - (3 * std_dev)
    x_max = mean + (3 * std_dev)
    x_range = x_max - x_min

    # Generate normal curve
    normal_points = []
    (0...chart_width).each do |i|
      x = x_min + (i * x_range / (chart_width - 1))
      y = normal_pdf(x, mean, std_dev)
      normal_points << [x, y]
    end

    # Scale to chart height
    max_y = normal_points.map { |_, y| y }.max

    grid = Array.new(chart_height) { Array.new(chart_width, ' ') }

    # Plot normal curve
    normal_points.each_with_index do |(_x, y), i|
      y_pos = chart_height - 1 - ((y / max_y) * (chart_height - 1)).round
      grid[y_pos][i] = '─' if y_pos >= 0 && y_pos < chart_height
    end

    # Add actual data points
    @numbers.each do |value|
      next unless value.between?(x_min, x_max)

      x_pos = ((value - x_min) * (chart_width - 1) / x_range).round
      y_expected = normal_pdf(value, mean, std_dev)
      y_pos = chart_height - 1 - ((y_expected / max_y) * (chart_height - 1)).round

      grid[y_pos][x_pos] = '*' if x_pos >= 0 && x_pos < chart_width && y_pos >= 0 && y_pos < chart_height
    end

    distribution_lines = []
    distribution_lines << 'ASCII Distribution Plot (Normal Overlay)'
    distribution_lines << ('=' * 45)
    distribution_lines << '* = actual data, ─ = normal curve'
    distribution_lines << ''

    grid.each { |row| distribution_lines << "  #{row.join}" }
    distribution_lines << ''

    # Calculate normality indicators
    skewness = calculate_skewness
    kurtosis = calculate_kurtosis

    distribution_lines << generate_distribution_stats(mean, std_dev, skewness, kurtosis)

    {
      chart: distribution_lines.join("\n"),
      mean: mean,
      std_dev: std_dev,
      skewness: skewness,
      kurtosis: kurtosis,
      normality_score: calculate_normality_score(skewness, kurtosis),
      interpretation: "Distribution plot shows #{interpret_normality(skewness, kurtosis)} with mean #{mean.round(2)}"
    }
  end

  # Generate comprehensive statistical dashboard
  def summary_dashboard(_options = {})
    validate_numbers!

    dashboard_lines = []
    dashboard_lines << ('=' * 80)
    dashboard_lines << 'STATISTICAL ANALYSIS DASHBOARD'
    dashboard_lines << ('=' * 80)
    dashboard_lines << "Dataset: #{@numbers.length} observations"
    dashboard_lines << "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    dashboard_lines << ''

    # Basic statistics
    stats = calculate_comprehensive_stats
    dashboard_lines << 'DESCRIPTIVE STATISTICS'
    dashboard_lines << ('-' * 30)
    dashboard_lines << format('Mean: %10.3<mean>f    Median: %10.3<median>f    Mode: %<mode>s',
                              mean: stats[:mean], median: stats[:median], mode: stats[:mode].join(', '))
    dashboard_lines << format('Min:  %10.3<min>f    Max:    %10.3<max>f    Range: %10.3<range>f',
                              min: stats[:min], max: stats[:max], range: stats[:range])
    dashboard_lines << format('Std:  %10.3<std_dev>f    Var:    %10.3<variance>f    CV: %7.1<cv>f%%',
                              std_dev: stats[:std_dev], variance: stats[:variance], cv: stats[:cv])
    dashboard_lines << ''

    # Mini histogram
    mini_hist = ascii_histogram(10, { width: 30, char: '▆' })
    dashboard_lines << 'DISTRIBUTION OVERVIEW'
    dashboard_lines << ('-' * 30)
    mini_hist[:chart].lines[2..-3].each { |line| dashboard_lines << line.chomp }
    dashboard_lines << ''

    # Mini box plot
    mini_box = box_plot({ width: 50 })
    dashboard_lines << 'QUARTILE ANALYSIS'
    dashboard_lines << ('-' * 30)
    dashboard_lines << format('Q1: %<q1>.3f  |  Q2 (Median): %<median>.3f  |  Q3: %<q3>.3f',
                              q1: stats[:q1], median: stats[:median], q3: stats[:q3])
    dashboard_lines << format('IQR: %<iqr>.3f  |  Outliers: %<outliers>d', iqr: stats[:iqr], outliers: stats[:outliers])
    mini_box[:chart].lines[4..6].each { |line| dashboard_lines << line.chomp }
    dashboard_lines << ''

    # Distribution characteristics
    dashboard_lines << 'DISTRIBUTION CHARACTERISTICS'
    dashboard_lines << ('-' * 30)
    dashboard_lines << format('Skewness: %8.3<skewness>f (%<interpretation>s)', skewness: stats[:skewness],
                                                                                interpretation: interpret_skewness(stats[:skewness]))
    dashboard_lines << format('Kurtosis: %8.3<kurtosis>f (%<interpretation>s)', kurtosis: stats[:kurtosis],
                                                                                interpretation: interpret_kurtosis(stats[:kurtosis]))
    dashboard_lines << format('Normality Score: %<score>.1f%% (%<interpretation>s)',
                              score: stats[:normality_score],
                              interpretation: stats[:normality_score] > 80 ? 'Likely Normal' : 'Non-Normal')
    dashboard_lines << ''

    # Recommendations
    dashboard_lines << 'ANALYSIS RECOMMENDATIONS'
    dashboard_lines << ('-' * 30)
    recommendations = generate_analysis_recommendations(stats)
    recommendations.each { |rec| dashboard_lines << "• #{rec}" }
    dashboard_lines << ''
    dashboard_lines << ('=' * 80)

    {
      chart: dashboard_lines.join("\n"),
      statistics: stats,
      sections: %w[descriptive distribution quartile characteristics recommendations],
      interpretation: "Comprehensive dashboard with #{recommendations.length} recommendations for #{@numbers.length} data points"
    }
  end

  private

  # Helper methods
  def validate_numbers!
    raise ArgumentError, 'Numbers array cannot be empty' if @numbers.empty?
  end

  def calculate_optimal_bins
    # Sturges' rule
    [1, Math.log2(@numbers.length).ceil + 1].max
  end

  def calculate_quartiles
    sorted = @numbers.sort
    n = sorted.length

    q1_index = (n + 1) / 4.0
    q3_index = 3 * (n + 1) / 4.0

    q1 = interpolate_percentile(sorted, q1_index)
    q2 = interpolate_percentile(sorted, (n + 1) / 2.0)
    q3 = interpolate_percentile(sorted, q3_index)

    [q1, q2, q3]
  end

  def interpolate_percentile(sorted_data, index)
    if index == index.to_i
      sorted_data[index.to_i - 1].to_f
    else
      lower = sorted_data[index.floor - 1]
      upper = sorted_data[index.ceil - 1]
      lower + ((index - index.floor) * (upper - lower))
    end
  end

  def calculate_correlation(x_data, y_data)
    n = x_data.length
    sum_x = x_data.sum.to_f
    sum_y = y_data.sum.to_f
    sum_xy = x_data.zip(y_data).map { |x, y| x * y }.sum
    sum_x_sq = x_data.map { |x| x**2 }.sum
    sum_y_sq = y_data.map { |y| y**2 }.sum

    numerator = (n * sum_xy) - (sum_x * sum_y)
    denominator = Math.sqrt(((n * sum_x_sq) - (sum_x**2)) * ((n * sum_y_sq) - (sum_y**2)))

    denominator.zero? ? 0.0 : numerator / denominator
  end

  def calculate_trend
    x_values = (1..@numbers.length).to_a
    correlation = calculate_correlation(x_values, @numbers)

    # Calculate slope and intercept
    n = @numbers.length
    sum_x = x_values.sum
    sum_y = @numbers.sum
    sum_xy = x_values.zip(@numbers).map { |x, y| x * y }.sum
    sum_x_sq = x_values.map { |x| x**2 }.sum

    slope = ((n * sum_xy) - (sum_x * sum_y)).to_f / ((n * sum_x_sq) - (sum_x**2))
    intercept = (sum_y - (slope * sum_x)) / n

    {
      slope: slope,
      intercept: intercept,
      correlation: correlation,
      direction: if slope.positive?
                   'upward'
                 else
                   slope.negative? ? 'downward' : 'flat'
                 end,
      strength: interpret_correlation_strength(correlation.abs)
    }
  end

  def calculate_skewness
    mean = @numbers.sum.to_f / @numbers.length
    std_dev = Math.sqrt(@numbers.map { |x| (x - mean)**2 }.sum / (@numbers.length - 1))
    n = @numbers.length

    skew_sum = @numbers.map { |x| ((x - mean) / std_dev)**3 }.sum
    (n / ((n - 1.0) * (n - 2.0))) * skew_sum
  end

  def calculate_kurtosis
    mean = @numbers.sum.to_f / @numbers.length
    std_dev = Math.sqrt(@numbers.map { |x| (x - mean)**2 }.sum / (@numbers.length - 1))
    n = @numbers.length

    kurt_sum = @numbers.map { |x| ((x - mean) / std_dev)**4 }.sum
    (((n * (n + 1)) / ((n - 1.0) * (n - 2.0) * (n - 3.0))) * kurt_sum) -
      ((3 * ((n - 1)**2)) / ((n - 2.0) * (n - 3.0)))
  end

  def normal_pdf(x, mean, std_dev)
    (1.0 / (std_dev * Math.sqrt(2 * Math::PI))) *
      Math.exp(-0.5 * (((x - mean) / std_dev)**2))
  end

  def calculate_normality_score(skewness, kurtosis)
    skew_score = [100 - (skewness.abs * 50), 0].max
    kurt_score = [100 - (kurtosis.abs * 25), 0].max
    ((skew_score + kurt_score) / 2).round(1)
  end

  def draw_line(grid, x1, y1, x2, y2, width, height)
    # Simple line drawing using Bresenham-like algorithm
    dx = (x2 - x1).abs
    dy = (y2 - y1).abs

    steps = [dx, dy].max
    return if steps.zero?

    x_step = (x2 - x1).to_f / steps
    y_step = (y2 - y1).to_f / steps

    (0..steps).each do |i|
      x = (x1 + (i * x_step)).round
      y = (y1 + (i * y_step)).round

      grid[y][x] = '─' if x >= 0 && x < width && y >= 0 && y < height && (grid[y][x] == ' ')
    end
  end

  def interpret_correlation_strength(abs_correlation)
    case abs_correlation
    when 0.0..0.1 then 'negligible'
    when 0.1..0.3 then 'weak'
    when 0.3..0.5 then 'moderate'
    when 0.5..0.7 then 'strong'
    when 0.7..0.9 then 'very strong'
    else 'extremely strong'
    end
  end

  def interpret_skewness(skewness)
    case skewness
    when -Float::INFINITY..-1 then 'highly left-skewed'
    when -1..-0.5 then 'moderately left-skewed'
    when -0.5..0.5 then 'approximately symmetric'
    when 0.5..1 then 'moderately right-skewed'
    else 'highly right-skewed'
    end
  end

  def interpret_kurtosis(kurtosis)
    case kurtosis
    when -Float::INFINITY..-1 then 'platykurtic (flatter)'
    when -1..1 then 'mesokurtic (normal-like)'
    else 'leptokurtic (peakier)'
    end
  end

  def interpret_normality(skewness, kurtosis)
    if skewness.abs < 0.5 && kurtosis.abs < 1
      'approximately normal distribution'
    elsif skewness.abs < 1 && kurtosis.abs < 2
      'moderately non-normal distribution'
    else
      'highly non-normal distribution'
    end
  end

  def calculate_comprehensive_stats
    mean = @numbers.sum.to_f / @numbers.length
    variance = @numbers.map { |x| (x - mean)**2 }.sum / (@numbers.length - 1)
    std_dev = Math.sqrt(variance)
    q1, median, q3 = calculate_quartiles
    iqr = q3 - q1
    outliers = identify_outliers.length
    skewness = calculate_skewness
    kurtosis = calculate_kurtosis

    {
      mean: mean,
      median: median,
      mode: @numbers.tally.select { |_, count| count == @numbers.tally.values.max }.keys,
      min: @numbers.min,
      max: @numbers.max,
      range: @numbers.max - @numbers.min,
      std_dev: std_dev,
      variance: variance,
      cv: (std_dev / mean * 100),
      q1: q1,
      q3: q3,
      iqr: iqr,
      outliers: outliers,
      skewness: skewness,
      kurtosis: kurtosis,
      normality_score: calculate_normality_score(skewness, kurtosis)
    }
  end

  def identify_outliers
    q1, _, q3 = calculate_quartiles
    iqr = q3 - q1
    lower_bound = q1 - (1.5 * iqr)
    upper_bound = q3 + (1.5 * iqr)

    @numbers.select { |x| x < lower_bound || x > upper_bound }
  end

  def generate_histogram_stats(bin_counts, bins)
    modal_bin_index = bin_counts.index(bin_counts.max)

    "Statistics: #{bins} bins, max frequency: #{bin_counts.max}, " \
      "modal bin: #{modal_bin_index + 1}, total: #{@numbers.length} values"
  end

  def generate_boxplot_stats(q1, median, q3, iqr, outliers)
    [
      'Box Plot Statistics:',
      format('Q1: %<q1>.3f  |  Median: %<median>.3f  |  Q3: %<q3>.3f', q1: q1, median: median, q3: q3),
      format('IQR: %<iqr>.3f  |  Outliers: %<outliers>d', iqr: iqr, outliers: outliers.length),
      outliers.empty? ? 'No outliers detected' : "Outliers: #{outliers.map { |x| x.round(2) }.join(', ')}"
    ].join("\n")
  end

  def generate_scatter_stats(x_data, y_data, correlation)
    x_mean = x_data.sum.to_f / x_data.length
    y_mean = y_data.sum.to_f / y_data.length

    [
      'Scatter Plot Statistics:',
      format('Points: %<points>d  |  Correlation: %<correlation>.4f (%<strength>s)',
             points: x_data.length, correlation: correlation, strength: interpret_correlation_strength(correlation.abs)),
      format('X: mean=%<mean>.3f, range=[%<min>.3f, %<max>.3f]', mean: x_mean, min: x_data.min, max: x_data.max),
      format('Y: mean=%<mean>.3f, range=[%<min>.3f, %<max>.3f]', mean: y_mean, min: y_data.min, max: y_data.max)
    ].join("\n")
  end

  def generate_line_chart_stats(trend)
    [
      'Line Chart Statistics:',
      format('Trend: %<direction>s (slope: %<slope>.4f)', direction: trend[:direction], slope: trend[:slope]),
      format('Correlation: %<correlation>.4f (%<strength>s %<sign>s)',
             correlation: trend[:correlation],
             strength: trend[:strength],
             sign: trend[:correlation] >= 0 ? 'positive' : 'negative'),
      format('Equation: y = %<slope>.4fx + %<intercept>.4f', slope: trend[:slope], intercept: trend[:intercept])
    ].join("\n")
  end

  def generate_bar_chart_stats(frequency)
    total = frequency.map { |_, count| count }.sum
    max_freq = frequency.map { |_, count| count }.max
    modal_value = frequency.find { |_, count| count == max_freq }[0]

    [
      'Bar Chart Statistics:',
      format('Unique values: %<unique>d  |  Total observations: %<total>d', unique: frequency.length, total: total),
      format('Most frequent: %<value>s (count: %<count>d, %<percentage>.1f%%)',
             value: modal_value, count: max_freq, percentage: max_freq.to_f / total * 100),
      format('Distribution entropy: %<entropy>.3f', entropy: calculate_entropy(frequency))
    ].join("\n")
  end

  def generate_distribution_stats(mean, std_dev, skewness, kurtosis)
    normality_score = calculate_normality_score(skewness, kurtosis)

    [
      'Distribution Statistics:',
      format('Mean: %<mean>.4f  |  Std Dev: %<std_dev>.4f', mean: mean, std_dev: std_dev),
      format('Skewness: %<skewness>.4f (%<interpretation>s)', skewness: skewness,
                                                              interpretation: interpret_skewness(skewness)),
      format('Kurtosis: %<kurtosis>.4f (%<interpretation>s)', kurtosis: kurtosis,
                                                              interpretation: interpret_kurtosis(kurtosis)),
      format('Normality Score: %<score>.1f%% (%<interpretation>s)',
             score: normality_score,
             interpretation: normality_score > 80 ? 'Likely Normal' : 'Non-Normal')
    ].join("\n")
  end

  def calculate_entropy(frequency)
    total = frequency.map { |_, count| count }.sum
    entropy = 0.0

    frequency.each_value do |count|
      p = count.to_f / total
      entropy -= p * Math.log2(p) if p.positive?
    end

    entropy
  end

  def generate_analysis_recommendations(stats)
    recommendations = []

    # Sample size
    recommendations << "Consider larger sample size (n=#{@numbers.length} < 30)" if @numbers.length < 30

    # Distribution shape
    recommendations << 'Data is highly skewed - consider transformation' if stats[:skewness].abs > 1

    # Outliers
    recommendations << "#{stats[:outliers]} outliers detected - investigate or use robust methods" if stats[:outliers].positive?

    # Variability
    recommendations << "High variability (CV=#{stats[:cv].round(1)}%) - consider stratification" if stats[:cv] > 50

    # Normality
    recommendations << 'Non-normal distribution - consider non-parametric tests' if stats[:normality_score] < 70

    recommendations << 'Data suitable for standard analysis' if recommendations.empty?

    recommendations
  end
end
