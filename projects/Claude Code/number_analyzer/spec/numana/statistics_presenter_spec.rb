# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/statistics_presenter'

RSpec.describe Numana::StatisticsPresenter do
  describe '.display_results' do
    let(:stats) do
      {
        total: 15,
        average: 3.0,
        maximum: 5,
        minimum: 1,
        median_value: 3.0,
        variance: 2.5,
        mode_values: [2, 3],
        std_dev: 1.58,
        iqr: 2.0,
        outlier_values: [10],
        deviation_scores: [31.65, 43.29, 50.0, 56.71, 68.35],
        frequency_distribution: { 1 => 1, 2 => 2, 3 => 1, 5 => 1 }
      }
    end

    it 'displays all statistical results correctly' do
      expected_output = [
        'Total: 15',
        'Average: 3.0',
        'Maximum: 5',
        'Minimum: 1',
        'Median: 3.0',
        'Variance: 2.5',
        'Mode: 2, 3',
        'Standard Deviation: 1.58',
        'Interquartile Range (IQR): 2.0',
        'Outliers: 10',
        'Deviation Scores: 31.65, 43.29, 50.0, 56.71, 68.35',
        '',
        'Frequency Distribution Histogram:',
        '1: ■ (1)',
        '2: ■■ (2)',
        '3: ■ (1)',
        '5: ■ (1)'
      ].join("\n")
      expected_output = "#{expected_output}\n"

      expect { described_class.display_results(stats) }.to output(expected_output).to_stdout
    end

    context 'when IQR is nil' do
      it 'displays "None" for IQR' do
        stats_with_nil_iqr = stats.merge(iqr: nil)

        expect { described_class.display_results(stats_with_nil_iqr) }.to output(/Interquartile Range \(IQR\): None/).to_stdout
      end
    end

    context 'when frequency_distribution is nil' do
      it 'displays empty data message for histogram' do
        stats_with_nil_freq = stats.merge(frequency_distribution: nil)

        expect { described_class.display_results(stats_with_nil_freq) }.to output(/\(No data available\)/).to_stdout
      end
    end

    context 'when frequency_distribution is empty' do
      it 'displays empty data message for histogram' do
        stats_with_empty_freq = stats.merge(frequency_distribution: {})

        expect { described_class.display_results(stats_with_empty_freq) }.to output(/\(No data available\)/).to_stdout
      end
    end
  end

  describe '.format_mode' do
    it 'returns "None" for empty mode values' do
      expect(described_class.send(:format_mode, [])).to eq('None')
    end

    it 'formats single mode value' do
      expect(described_class.send(:format_mode, [5])).to eq('5')
    end

    it 'formats multiple mode values with comma separation' do
      expect(described_class.send(:format_mode, [2, 3, 5])).to eq('2, 3, 5')
    end
  end

  describe '.format_outliers' do
    it 'returns "None" for empty outlier values' do
      expect(described_class.send(:format_outliers, [])).to eq('None')
    end

    it 'formats single outlier value' do
      expect(described_class.send(:format_outliers, [10])).to eq('10')
    end

    it 'formats multiple outlier values with comma separation' do
      expect(described_class.send(:format_outliers, [1, 10, 15])).to eq('1, 10, 15')
    end
  end

  describe '.format_deviation_scores' do
    it 'returns "None" for empty deviation scores' do
      expect(described_class.send(:format_deviation_scores, [])).to eq('None')
    end

    it 'formats single deviation score' do
      expect(described_class.send(:format_deviation_scores, [50.0])).to eq('50.0')
    end

    it 'formats multiple deviation scores with comma separation' do
      expect(described_class.send(:format_deviation_scores, [31.65, 50.0, 68.35])).to eq('31.65, 50.0, 68.35')
    end
  end
end
