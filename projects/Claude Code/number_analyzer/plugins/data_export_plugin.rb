# frozen_string_literal: true

require_relative '../lib/number_analyzer/plugin_interface'
require 'csv'
require 'json'

# DataExportPlugin - Advanced data export capabilities with multiple formats
# Demonstrates output format plugin implementation with comprehensive export options
module DataExportPlugin
  include NumberAnalyzer::StatisticsPlugin

  # Plugin metadata
  plugin_name 'data_export'
  plugin_version '1.0.0'
  plugin_description 'Comprehensive data export plugin supporting CSV, JSON, XML, YAML, and TSV formats with statistical analysis'
  plugin_author 'NumberAnalyzer Data Team'
  plugin_dependencies ['basic_stats']

  # Register plugin methods
  register_method :export_csv, 'Export data and statistics to CSV format'
  register_method :export_json, 'Export data and statistics to JSON format'
  register_method :export_xml, 'Export data and statistics to XML format'
  register_method :export_yaml, 'Export data and statistics to YAML format'
  register_method :export_tsv, 'Export data and statistics to TSV format'
  register_method :export_summary_report, 'Generate comprehensive summary report'
  register_method :export_statistical_profile, 'Export detailed statistical profile'

  # Define CLI commands mapping
  def self.plugin_commands
    {
      'export-csv' => :export_csv,
      'export-json' => :export_json,
      'export-xml' => :export_xml,
      'export-yaml' => :export_yaml,
      'export-tsv' => :export_tsv,
      'export-report' => :export_summary_report,
      'export-profile' => :export_statistical_profile
    }
  end

  # Export data and statistics to CSV format
  def export_csv(filename = nil, options = {})
    validate_numbers!

    filename ||= "number_analysis_#{timestamp}.csv"
    stats = calculate_comprehensive_statistics

    csv_content = generate_csv_content(stats, options)

    if options[:return_content]
      csv_content
    else
      write_file(filename, csv_content)
      {
        format: 'CSV',
        filename: filename,
        size: csv_content.length,
        rows: csv_content.lines.count,
        interpretation: "Data exported to CSV format with #{stats.keys.count} statistical measures"
      }
    end
  end

  # Export data and statistics to JSON format
  def export_json(filename = nil, options = {})
    validate_numbers!

    filename ||= "number_analysis_#{timestamp}.json"
    stats = calculate_comprehensive_statistics

    json_data = {
      metadata: {
        export_timestamp: Time.now.iso8601,
        data_count: @numbers.length,
        plugin: 'data_export',
        version: '1.0.0'
      },
      raw_data: @numbers,
      statistics: stats,
      summary: generate_data_summary(stats)
    }

    json_content = JSON.pretty_generate(json_data)

    if options[:return_content]
      json_content
    else
      write_file(filename, json_content)
      {
        format: 'JSON',
        filename: filename,
        size: json_content.length,
        objects: count_json_objects(json_data),
        interpretation: 'Data exported to JSON format with complete statistical analysis'
      }
    end
  end

  # Export data and statistics to XML format
  def export_xml(filename = nil, options = {})
    validate_numbers!

    filename ||= "number_analysis_#{timestamp}.xml"
    stats = calculate_comprehensive_statistics

    xml_content = generate_xml_content(stats, options)

    if options[:return_content]
      xml_content
    else
      write_file(filename, xml_content)
      {
        format: 'XML',
        filename: filename,
        size: xml_content.length,
        elements: count_xml_elements(xml_content),
        interpretation: 'Data exported to XML format with structured statistical analysis'
      }
    end
  end

  # Export data and statistics to YAML format
  def export_yaml(filename = nil, options = {})
    validate_numbers!

    filename ||= "number_analysis_#{timestamp}.yaml"
    stats = calculate_comprehensive_statistics

    yaml_data = {
      'metadata' => {
        'export_timestamp' => Time.now.iso8601,
        'data_count' => @numbers.length,
        'plugin' => 'data_export',
        'version' => '1.0.0'
      },
      'raw_data' => @numbers,
      'statistics' => convert_symbols_to_strings(stats),
      'summary' => convert_symbols_to_strings(generate_data_summary(stats))
    }

    yaml_content = generate_yaml_content(yaml_data)

    if options[:return_content]
      yaml_content
    else
      write_file(filename, yaml_content)
      {
        format: 'YAML',
        filename: filename,
        size: yaml_content.length,
        sections: yaml_data.keys.count,
        interpretation: 'Data exported to YAML format with human-readable structure'
      }
    end
  end

  # Export data and statistics to TSV format
  def export_tsv(filename = nil, options = {})
    validate_numbers!

    filename ||= "number_analysis_#{timestamp}.tsv"
    stats = calculate_comprehensive_statistics

    tsv_content = generate_tsv_content(stats, options)

    if options[:return_content]
      tsv_content
    else
      write_file(filename, tsv_content)
      {
        format: 'TSV',
        filename: filename,
        size: tsv_content.length,
        rows: tsv_content.lines.count,
        interpretation: 'Data exported to TSV format optimized for spreadsheet applications'
      }
    end
  end

  # Generate comprehensive summary report
  def export_summary_report(filename = nil, options = {})
    validate_numbers!

    filename ||= "statistical_summary_#{timestamp}.txt"
    stats = calculate_comprehensive_statistics

    report_content = generate_summary_report_content(stats, options)

    if options[:return_content]
      report_content
    else
      write_file(filename, report_content)
      {
        format: 'Summary Report',
        filename: filename,
        size: report_content.length,
        lines: report_content.lines.count,
        interpretation: 'Comprehensive statistical summary report generated'
      }
    end
  end

  # Export detailed statistical profile
  def export_statistical_profile(filename = nil, options = {})
    validate_numbers!

    filename ||= "statistical_profile_#{timestamp}.json"

    profile = {
      dataset_info: {
        size: @numbers.length,
        data_type: determine_data_type,
        range: @numbers.max - @numbers.min,
        unique_values: @numbers.uniq.length,
        duplicates: @numbers.length - @numbers.uniq.length
      },
      descriptive_statistics: calculate_comprehensive_statistics,
      distribution_analysis: analyze_distribution,
      outlier_analysis: analyze_outliers_detailed,
      data_quality: assess_data_quality,
      recommendations: generate_analysis_recommendations
    }

    json_content = JSON.pretty_generate(profile)

    if options[:return_content]
      json_content
    else
      write_file(filename, json_content)
      {
        format: 'Statistical Profile',
        filename: filename,
        size: json_content.length,
        analysis_sections: profile.keys.count,
        interpretation: 'Detailed statistical profile with quality assessment and recommendations'
      }
    end
  end

  private

  # Helper methods
  def validate_numbers!
    raise ArgumentError, 'Numbers array cannot be empty' if @numbers.empty?
  end

  def timestamp
    Time.now.strftime('%Y%m%d_%H%M%S')
  end

  def calculate_comprehensive_statistics
    {
      count: @numbers.length,
      sum: @numbers.sum,
      mean: @numbers.sum.to_f / @numbers.length,
      median: calculate_median,
      mode: calculate_mode,
      min: @numbers.min,
      max: @numbers.max,
      range: @numbers.max - @numbers.min,
      variance: calculate_variance,
      standard_deviation: Math.sqrt(calculate_variance),
      skewness: calculate_skewness,
      kurtosis: calculate_kurtosis,
      quartiles: calculate_quartiles,
      iqr: calculate_iqr,
      outliers: identify_outliers.length,
      coefficient_of_variation: (Math.sqrt(calculate_variance) / (@numbers.sum.to_f / @numbers.length)) * 100
    }
  end

  def calculate_median
    sorted = @numbers.sort
    mid = sorted.length / 2
    if sorted.length.even?
      (sorted[mid - 1] + sorted[mid]) / 2.0
    else
      sorted[mid].to_f
    end
  end

  def calculate_mode
    frequency = @numbers.tally
    max_frequency = frequency.values.max
    modes = frequency.select { |_, count| count == max_frequency }.keys
    modes.length == @numbers.uniq.length ? [] : modes
  end

  def calculate_variance
    mean = @numbers.sum.to_f / @numbers.length
    @numbers.map { |x| (x - mean)**2 }.sum / (@numbers.length - 1)
  end

  def calculate_skewness
    mean = @numbers.sum.to_f / @numbers.length
    std_dev = Math.sqrt(calculate_variance)
    n = @numbers.length

    skew_sum = @numbers.map { |x| ((x - mean) / std_dev)**3 }.sum
    (n / ((n - 1.0) * (n - 2.0))) * skew_sum
  end

  def calculate_kurtosis
    mean = @numbers.sum.to_f / @numbers.length
    std_dev = Math.sqrt(calculate_variance)
    n = @numbers.length

    kurt_sum = @numbers.map { |x| ((x - mean) / std_dev)**4 }.sum
    (((n * (n + 1)) / ((n - 1.0) * (n - 2.0) * (n - 3.0))) * kurt_sum) -
      ((3 * ((n - 1)**2)) / ((n - 2.0) * (n - 3.0)))
  end

  def calculate_quartiles
    sorted = @numbers.sort
    n = sorted.length

    q1_index = (n + 1) / 4.0
    q3_index = 3 * (n + 1) / 4.0

    q1 = interpolate_percentile(sorted, q1_index)
    q3 = interpolate_percentile(sorted, q3_index)

    [q1, calculate_median, q3]
  end

  def calculate_iqr
    q1, _, q3 = calculate_quartiles
    q3 - q1
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

  def identify_outliers
    q1, _, q3 = calculate_quartiles
    iqr = q3 - q1
    lower_bound = q1 - (1.5 * iqr)
    upper_bound = q3 + (1.5 * iqr)

    @numbers.select { |x| x < lower_bound || x > upper_bound }
  end

  def generate_data_summary(stats)
    {
      data_shape: "#{stats[:count]} observations",
      central_tendency: "Mean: #{stats[:mean].round(2)}, Median: #{stats[:median].round(2)}",
      variability: "Std Dev: #{stats[:standard_deviation].round(2)}, CV: #{stats[:coefficient_of_variation].round(1)}%",
      distribution: interpret_distribution_shape(stats[:skewness], stats[:kurtosis]),
      data_quality: stats[:outliers].positive? ? "#{stats[:outliers]} outliers detected" : 'No outliers detected'
    }
  end

  def interpret_distribution_shape(skewness, kurtosis)
    skew_desc = case skewness
                when -Float::INFINITY..-1 then 'highly left-skewed'
                when -1..-0.5 then 'moderately left-skewed'
                when -0.5..0.5 then 'approximately symmetric'
                when 0.5..1 then 'moderately right-skewed'
                when 1..Float::INFINITY then 'highly right-skewed'
                end

    kurt_desc = case kurtosis
                when -Float::INFINITY..-1 then 'platykurtic (flatter than normal)'
                when -1..1 then 'mesokurtic (normal-like)'
                when 1..Float::INFINITY then 'leptokurtic (peakier than normal)'
                end

    "#{skew_desc}, #{kurt_desc}"
  end

  def generate_csv_content(stats, options = {})
    CSV.generate do |csv|
      # Header
      csv << %w[Statistic Value Description]

      # Data rows
      csv << ['Count', stats[:count], 'Number of observations']
      csv << ['Sum', stats[:sum], 'Sum of all values']
      csv << ['Mean', stats[:mean].round(6), 'Arithmetic mean']
      csv << ['Median', stats[:median].round(6), 'Middle value']
      csv << ['Mode', stats[:mode].empty? ? 'No mode' : stats[:mode].join(', '), 'Most frequent value(s)']
      csv << ['Minimum', stats[:min], 'Smallest value']
      csv << ['Maximum', stats[:max], 'Largest value']
      csv << ['Range', stats[:range], 'Difference between max and min']
      csv << ['Variance', stats[:variance].round(6), 'Population variance']
      csv << ['Standard Deviation', stats[:standard_deviation].round(6), 'Measure of spread']
      csv << ['Skewness', stats[:skewness].round(6), 'Measure of asymmetry']
      csv << ['Kurtosis', stats[:kurtosis].round(6), 'Measure of tail heaviness']
      csv << ['Q1', stats[:quartiles][0].round(6), 'First quartile (25th percentile)']
      csv << ['Q3', stats[:quartiles][2].round(6), 'Third quartile (75th percentile)']
      csv << ['IQR', stats[:iqr].round(6), 'Interquartile range']
      csv << ['Outliers', stats[:outliers], 'Number of outliers']
      csv << ['CV', "#{stats[:coefficient_of_variation].round(2)}%", 'Coefficient of variation']

      # Raw data section if requested
      if options[:include_raw_data]
        csv << []
        csv << ['Raw Data']
        @numbers.each_with_index { |value, index| csv << ["Data Point #{index + 1}", value, ''] }
      end
    end
  end

  def generate_xml_content(stats, _options = {})
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <statistical_analysis>
        <metadata>
          <export_timestamp>#{Time.now.iso8601}</export_timestamp>
          <data_count>#{@numbers.length}</data_count>
          <plugin>data_export</plugin>
          <version>1.0.0</version>
        </metadata>
      #{'  '}
        <raw_data>
          #{@numbers.map.with_index { |value, index| "<data_point index=\"#{index + 1}\">#{value}</data_point>" }.join("\n          ")}
        </raw_data>
      #{'  '}
        <descriptive_statistics>
          <count>#{stats[:count]}</count>
          <sum>#{stats[:sum]}</sum>
          <mean>#{stats[:mean].round(6)}</mean>
          <median>#{stats[:median].round(6)}</median>
          <mode>#{stats[:mode].empty? ? 'none' : stats[:mode].join(',')}</mode>
          <minimum>#{stats[:min]}</minimum>
          <maximum>#{stats[:max]}</maximum>
          <range>#{stats[:range]}</range>
          <variance>#{stats[:variance].round(6)}</variance>
          <standard_deviation>#{stats[:standard_deviation].round(6)}</standard_deviation>
          <skewness>#{stats[:skewness].round(6)}</skewness>
          <kurtosis>#{stats[:kurtosis].round(6)}</kurtosis>
          <coefficient_of_variation unit="percent">#{stats[:coefficient_of_variation].round(2)}</coefficient_of_variation>
        </descriptive_statistics>
      #{'  '}
        <quartiles>
          <q1>#{stats[:quartiles][0].round(6)}</q1>
          <q2>#{stats[:quartiles][1].round(6)}</q2>
          <q3>#{stats[:quartiles][2].round(6)}</q3>
          <iqr>#{stats[:iqr].round(6)}</iqr>
        </quartiles>
      #{'  '}
        <outlier_analysis>
          <outlier_count>#{stats[:outliers]}</outlier_count>
          <outlier_percentage>#{(stats[:outliers].to_f / @numbers.length * 100).round(2)}</outlier_percentage>
        </outlier_analysis>
      #{'  '}
        <summary>
          #{generate_data_summary(stats).map { |key, value| "<#{key}>#{value}</#{key}>" }.join("\n          ")}
        </summary>
      </statistical_analysis>
    XML
  end

  def generate_yaml_content(data)
    # Simple YAML generation without external dependencies
    yaml_lines = []

    data.each do |key, value|
      yaml_lines << "#{key}:"
      case value
      when Hash
        value.each { |k, v| yaml_lines << "  #{k}: #{format_yaml_value(v)}" }
      when Array
        if value.all? { |item| item.is_a?(Numeric) }
          yaml_lines << "  #{value.inspect}"
        else
          value.each { |item| yaml_lines << "  - #{format_yaml_value(item)}" }
        end
      else
        yaml_lines << "  #{format_yaml_value(value)}"
      end
    end

    yaml_lines.join("\n")
  end

  def format_yaml_value(value)
    case value
    when String
      value.include?(' ') ? "\"#{value}\"" : value
    when Numeric
      value
    when Array
      "[#{value.join(', ')}]"
    when Hash
      "{#{value.map { |k, v| "#{k}: #{v}" }.join(', ')}}"
    else
      value.to_s
    end
  end

  def generate_tsv_content(stats, _options = {})
    lines = []
    lines << "Statistic\tValue\tDescription"
    lines << "Count\t#{stats[:count]}\tNumber of observations"
    lines << "Sum\t#{stats[:sum]}\tSum of all values"
    lines << "Mean\t#{stats[:mean].round(6)}\tArithmetic mean"
    lines << "Median\t#{stats[:median].round(6)}\tMiddle value"
    lines << "Mode\t#{stats[:mode].empty? ? 'No mode' : stats[:mode].join(', ')}\tMost frequent value(s)"
    lines << "Minimum\t#{stats[:min]}\tSmallest value"
    lines << "Maximum\t#{stats[:max]}\tLargest value"
    lines << "Range\t#{stats[:range]}\tDifference between max and min"
    lines << "Variance\t#{stats[:variance].round(6)}\tPopulation variance"
    lines << "Standard Deviation\t#{stats[:standard_deviation].round(6)}\tMeasure of spread"
    lines << "Skewness\t#{stats[:skewness].round(6)}\tMeasure of asymmetry"
    lines << "Kurtosis\t#{stats[:kurtosis].round(6)}\tMeasure of tail heaviness"
    lines << "Q1\t#{stats[:quartiles][0].round(6)}\tFirst quartile (25th percentile)"
    lines << "Q3\t#{stats[:quartiles][2].round(6)}\tThird quartile (75th percentile)"
    lines << "IQR\t#{stats[:iqr].round(6)}\tInterquartile range"
    lines << "Outliers\t#{stats[:outliers]}\tNumber of outliers"
    lines << "CV\t#{stats[:coefficient_of_variation].round(2)}%\tCoefficient of variation"

    lines.join("\n")
  end

  def generate_summary_report_content(stats, options = {})
    report = []
    report << 'STATISTICAL ANALYSIS SUMMARY REPORT'
    report << ('=' * 50)
    report << ''
    report << "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    report << 'Plugin: DataExportPlugin v1.0.0'
    report << "Dataset Size: #{@numbers.length} observations"
    report << ''

    report << 'DESCRIPTIVE STATISTICS'
    report << ('-' * 30)
    report << format('%<label>-20s: %<value>15.6f', label: 'Mean', value: stats[:mean])
    report << format('%<label>-20s: %<value>15.6f', label: 'Median', value: stats[:median])
    report << format('%<label>-20s: %<value>15s', label: 'Mode',
                                                  value: stats[:mode].empty? ? 'No mode' : stats[:mode].join(', '))
    report << format('%<label>-20s: %<value>15.6f', label: 'Standard Deviation', value: stats[:standard_deviation])
    report << format('%<label>-20s: %<value>15.6f', label: 'Variance', value: stats[:variance])
    report << format('%<label>-20s: %<value>15.2f%%', label: 'Coeff. of Variation',
                                                      value: stats[:coefficient_of_variation])
    report << ''

    report << 'DATA RANGE'
    report << ('-' * 30)
    report << format('%<label>-20s: %<value>15.6f', label: 'Minimum', value: stats[:min])
    report << format('%<label>-20s: %<value>15.6f', label: 'Maximum', value: stats[:max])
    report << format('%<label>-20s: %<value>15.6f', label: 'Range', value: stats[:range])
    report << format('%<label>-20s: %<value>15.6f', label: 'Q1 (25th percentile)', value: stats[:quartiles][0])
    report << format('%<label>-20s: %<value>15.6f', label: 'Q3 (75th percentile)', value: stats[:quartiles][2])
    report << format('%<label>-20s: %<value>15.6f', label: 'IQR', value: stats[:iqr])
    report << ''

    report << 'DISTRIBUTION CHARACTERISTICS'
    report << ('-' * 30)
    report << format('%<label>-20s: %<value>15.6f', label: 'Skewness', value: stats[:skewness])
    report << format('%<label>-20s: %<value>15.6f', label: 'Kurtosis', value: stats[:kurtosis])
    report << format('%<label>-20s: %<value>15d', label: 'Outliers', value: stats[:outliers])
    report << ''

    summary = generate_data_summary(stats)
    report << 'INTERPRETATION'
    report << ('-' * 30)
    summary.each { |key, value| report << "#{key.to_s.capitalize.tr('_', ' ')}: #{value}" }
    report << ''

    if options[:include_raw_data]
      report << 'RAW DATA'
      report << ('-' * 30)
      @numbers.each_slice(10).with_index do |slice, index|
        start_index = (index * 10) + 1
        report << "#{start_index}-#{start_index + slice.length - 1}: #{slice.join(', ')}"
      end
    end

    report.join("\n")
  end

  def count_json_objects(data, count = 0)
    case data
    when Hash
      count += 1
      data.each_value { |value| count = count_json_objects(value, count) }
    when Array
      data.each { |item| count = count_json_objects(item, count) }
    end
    count
  end

  def count_xml_elements(xml_content)
    xml_content.scan(%r{<[^/!?][^>]*>}).length
  end

  def convert_symbols_to_strings(obj)
    case obj
    when Hash
      obj.transform_keys(&:to_s).transform_values { |v| convert_symbols_to_strings(v) }
    when Array
      obj.map { |item| convert_symbols_to_strings(item) }
    when Symbol
      obj.to_s
    else
      obj
    end
  end

  def determine_data_type
    return 'integer' if @numbers.all? { |n| n.is_a?(Integer) }
    return 'float' if @numbers.all? { |n| n.is_a?(Numeric) }

    'mixed'
  end

  def analyze_distribution
    stats = calculate_comprehensive_statistics
    {
      shape: interpret_distribution_shape(stats[:skewness], stats[:kurtosis]),
      normality_indicators: {
        skewness_near_zero: stats[:skewness].abs < 0.5,
        kurtosis_near_zero: stats[:kurtosis].abs < 1,
        likely_normal: stats[:skewness].abs < 0.5 && stats[:kurtosis].abs < 1
      },
      spread_analysis: {
        cv_category: categorize_cv(stats[:coefficient_of_variation]),
        outlier_impact: stats[:outliers].positive? ? 'outliers_present' : 'no_outliers'
      }
    }
  end

  def categorize_cv(cv)
    case cv
    when 0..10 then 'low_variability'
    when 10..25 then 'moderate_variability'
    when 25..50 then 'high_variability'
    else 'very_high_variability'
    end
  end

  def analyze_outliers_detailed
    outliers = identify_outliers
    q1, _, q3 = calculate_quartiles
    iqr = q3 - q1

    {
      count: outliers.length,
      percentage: (outliers.length.to_f / @numbers.length * 100).round(2),
      values: outliers.sort,
      extreme_outliers: outliers.select { |x| x < q1 - (3 * iqr) || x > q3 + (3 * iqr) },
      impact_on_mean: outliers.empty? ? 0 : calculate_outlier_impact,
      recommendations: generate_outlier_recommendations(outliers.length)
    }
  end

  def calculate_outlier_impact
    mean_with_outliers = @numbers.sum.to_f / @numbers.length
    outliers = identify_outliers
    data_without_outliers = @numbers - outliers

    return 0 if data_without_outliers.empty?

    mean_without_outliers = data_without_outliers.sum.to_f / data_without_outliers.length
    ((mean_with_outliers - mean_without_outliers).abs / mean_without_outliers * 100).round(2)
  end

  def generate_outlier_recommendations(outlier_count)
    if outlier_count.zero?
      ['No outliers detected - data appears clean']
    elsif outlier_count < @numbers.length * 0.05
      ['Few outliers detected - investigate individual cases', 'Consider robust statistical methods']
    else
      ['Many outliers detected - review data collection process', 'Consider data transformation',
       'Use robust statistical methods']
    end
  end

  def assess_data_quality
    {
      completeness: 100.0, # Assuming no missing values in this context
      consistency: assess_consistency,
      outlier_ratio: (identify_outliers.length.to_f / @numbers.length * 100).round(2),
      data_range_reasonableness: assess_range_reasonableness,
      overall_score: calculate_overall_quality_score
    }
  end

  def assess_consistency
    range = @numbers.max - @numbers.min
    iqr = calculate_iqr

    case iqr / range.to_f
    when 0..0.1 then 'low_consistency'
    when 0.1..0.3 then 'moderate_consistency'
    else 'high_consistency'
    end
  end

  def assess_range_reasonableness
    stats = calculate_comprehensive_statistics
    cv = stats[:coefficient_of_variation]

    case cv
    when 0..50 then 'reasonable_range'
    when 50..100 then 'wide_range'
    else 'very_wide_range'
    end
  end

  def calculate_overall_quality_score
    outlier_penalty = [identify_outliers.length.to_f / @numbers.length * 100, 20].min
    cv_penalty = [calculate_comprehensive_statistics[:coefficient_of_variation] / 10, 10].min

    base_score = 100
    quality_score = base_score - outlier_penalty - cv_penalty
    [quality_score, 0].max.round(1)
  end

  def generate_analysis_recommendations
    stats = calculate_comprehensive_statistics
    recommendations = []

    # Sample size recommendations
    recommendations << 'Consider collecting more data for robust statistical inference (n < 30)' if @numbers.length < 30

    # Distribution recommendations
    recommendations << 'Data is highly skewed - consider data transformation' if stats[:skewness].abs > 1

    # Outlier recommendations
    recommendations << 'Outliers detected - investigate and consider robust methods' if stats[:outliers].positive?

    # Variability recommendations
    recommendations << 'High variability detected - consider segmentation analysis' if stats[:coefficient_of_variation] > 50

    recommendations << 'Data appears suitable for standard statistical analysis' if recommendations.empty?

    recommendations
  end

  def write_file(filename, content)
    File.write(filename, content)
  rescue StandardError => e
    raise "Failed to write file #{filename}: #{e.message}"
  end
end
