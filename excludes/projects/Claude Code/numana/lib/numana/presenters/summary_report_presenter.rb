# frozen_string_literal: true

# Generates a human-readable text summary report from statistical data.
class Numana::Presenters::SummaryReportPresenter
  def initialize(stats, numbers, options = {})
    @stats = stats
    @numbers = numbers
    @options = options
  end

  def generate
    report = generate_report_header
    report << generate_descriptive_stats_section
    report << generate_data_range_section
    report << generate_distribution_section
    report << generate_interpretation_section
    report << generate_raw_data_section if @options[:include_raw_data]

    report.flatten.compact.join("\n")
  end

  private

  def generate_report_header
    [
      'STATISTICAL ANALYSIS SUMMARY REPORT',
      '=' * 50,
      '',
      "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
      'Plugin: DataExportPlugin v1.0.0',
      "Dataset Size: #{@numbers.length} observations",
      ''
    ]
  end

  def generate_descriptive_stats_section
    [
      'DESCRIPTIVE STATISTICS',
      '-' * 30,
      format('%<label>-20s: %<value>15.6f', label: 'Mean', value: @stats[:mean]),
      format('%<label>-20s: %<value>15.6f', label: 'Median', value: @stats[:median]),
      format('%<label>-20s: %<value>15s', label: 'Mode', value: @stats[:mode].empty? ? 'No mode' : @stats[:mode].join(', ')),
      format('%<label>-20s: %<value>15.6f', label: 'Standard Deviation', value: @stats[:standard_deviation]),
      format('%<label>-20s: %<value>15.6f', label: 'Variance', value: @stats[:variance]),
      format('%<label>-20s: %<value>15.2f%%', label: 'Coeff. of Variation', value: @stats[:coefficient_of_variation]),
      ''
    ]
  end

  def generate_data_range_section
    [
      'DATA RANGE',
      '-' * 30,
      format('%<label>-20s: %<value>15.6f', label: 'Minimum', value: @stats[:min]),
      format('%<label>-20s: %<value>15.6f', label: 'Maximum', value: @stats[:max]),
      format('%<label>-20s: %<value>15.6f', label: 'Range', value: @stats[:range]),
      format('%<label>-20s: %<value>15.6f', label: 'Q1 (25th percentile)', value: @stats[:quartiles][0]),
      format('%<label>-20s: %<value>15.6f', label: 'Q3 (75th percentile)', value: @stats[:quartiles][2]),
      format('%<label>-20s: %<value>15.6f', label: 'IQR', value: @stats[:iqr]),
      ''
    ]
  end

  def generate_distribution_section
    [
      'DISTRIBUTION CHARACTERISTICS',
      '-' * 30,
      format('%<label>-20s: %<value>15.6f', label: 'Skewness', value: @stats[:skewness]),
      format('%<label>-20s: %<value>15.6f', label: 'Kurtosis', value: @stats[:kurtosis]),
      format('%<label>-20s: %<value>15d', label: 'Outliers', value: @stats[:outliers]),
      ''
    ]
  end

  def generate_interpretation_section
    summary = generate_data_summary
    [
      'INTERPRETATION',
      '-' * 30,
      *summary.map { |key, value| "#{key.to_s.capitalize.tr('_', ' ')}: #{value}" },
      ''
    ]
  end

  def generate_raw_data_section
    report = [
      'RAW DATA',
      '-' * 30
    ]
    @numbers.each_slice(10).with_index do |slice, index|
      start_index = (index * 10) + 1
      report << "#{start_index}-#{start_index + slice.length - 1}: #{slice.join(', ')}"
    end
    report
  end

  def generate_data_summary
    {
      data_shape: "#{@stats[:count]} observations",
      central_tendency: "Mean: #{@stats[:mean].round(2)}, Median: #{@stats[:median].round(2)}",
      variability: "Std Dev: #{@stats[:standard_deviation].round(2)}, CV: #{@stats[:coefficient_of_variation].round(1)}%",
      distribution: interpret_distribution_shape(@stats[:skewness], @stats[:kurtosis]),
      data_quality: @stats[:outliers].positive? ? "#{@stats[:outliers]} outliers detected" : 'No outliers detected'
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
end
