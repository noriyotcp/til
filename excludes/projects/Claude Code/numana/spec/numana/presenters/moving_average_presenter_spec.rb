# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Numana::Presenters::MovingAveragePresenter do
  let(:valid_moving_average_data) do
    {
      moving_average: [1.666667, 2.666667, 3.666667, 4.666667, 5.666667],
      window_size: 3,
      dataset_size: 7
    }
  end
  let(:nil_moving_average_data) { nil }
  let(:empty_moving_average_data) do
    {
      moving_average: [],
      window_size: 5,
      dataset_size: 3
    }
  end
  let(:default_options) { {} }
  let(:json_options) { { format: 'json' } }
  let(:quiet_options) { { format: 'quiet' } }
  let(:precision_options) { { precision: 2 } }
  let(:dataset_size_options) { { dataset_size: 10 } }

  describe '#format' do
    context 'when format is default (verbose)' do
      context 'with valid moving average data' do
        it 'formats moving average results correctly' do
          presenter = described_class.new(valid_moving_average_data, default_options)
          result = presenter.format

          expect(result).to include('Moving Average (Window Size: 3):')
          expect(result).to include('1.666667, 2.666667, 3.666667, 4.666667, 5.666667')
          expect(result).to include('Original data size: 7, Moving average count: 5')
        end

        it 'applies precision formatting when specified' do
          presenter = described_class.new(valid_moving_average_data, precision_options)
          result = presenter.format

          expect(result).to include('1.67, 2.67, 3.67, 4.67, 5.67')
        end

        it 'handles window size correctly' do
          data_with_window_five = valid_moving_average_data.merge(window_size: 5)
          presenter = described_class.new(data_with_window_five, default_options)
          result = presenter.format

          expect(result).to include('Moving Average (Window Size: 5):')
        end
      end

      context 'with invalid moving average data' do
        it 'returns error message for nil data' do
          presenter = described_class.new(nil_moving_average_data, default_options)
          result = presenter.format

          expect(result).to eq('Error: Insufficient data (window size exceeds data length)')
        end

        it 'returns error message for empty moving average' do
          presenter = described_class.new(empty_moving_average_data, default_options)
          result = presenter.format

          expect(result).to eq('Error: Insufficient data (window size exceeds data length)')
        end
      end
    end

    context 'when format is JSON' do
      context 'with valid moving average data' do
        it 'formats as JSON with moving average data' do
          presenter = described_class.new(valid_moving_average_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('moving_average')
          expect(parsed_result).to have_key('window_size')
          expect(parsed_result).to have_key('dataset_size')
          expect(parsed_result['moving_average']).to be_an(Array)
          expect(parsed_result['window_size']).to eq(3)
          expect(parsed_result['dataset_size']).to eq(7)
        end

        it 'applies precision formatting in JSON' do
          presenter = described_class.new(valid_moving_average_data, json_options.merge(precision: 2))
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result['moving_average'][0]).to eq(1.67)
          expect(parsed_result['moving_average'][1]).to eq(2.67)
        end

        it 'includes dataset metadata when provided' do
          presenter = described_class.new(valid_moving_average_data, json_options.merge(dataset_size_options))
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('dataset_size')
          expect(parsed_result['dataset_size']).to eq(10)
        end
      end

      context 'with invalid moving average data' do
        it 'returns JSON with null moving average for nil data' do
          presenter = described_class.new(nil_moving_average_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('moving_average')
          expect(parsed_result['moving_average']).to be_nil
          expect(parsed_result).to have_key('error')
          expect(parsed_result['error']).to eq('Insufficient data')
        end

        it 'returns JSON with error for empty moving average' do
          presenter = described_class.new(empty_moving_average_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('moving_average')
          expect(parsed_result['moving_average']).to be_nil
          expect(parsed_result).to have_key('error')
        end
      end
    end

    context 'when format is quiet' do
      context 'with valid moving average data' do
        it 'formats as space-separated values' do
          presenter = described_class.new(valid_moving_average_data, quiet_options)
          result = presenter.format

          expect(result).to eq('1.666667 2.666667 3.666667 4.666667 5.666667')
        end

        it 'applies precision formatting in quiet mode' do
          presenter = described_class.new(valid_moving_average_data, quiet_options.merge(precision: 2))
          result = presenter.format

          expect(result).to eq('1.67 2.67 3.67 4.67 5.67')
        end
      end

      context 'with invalid moving average data' do
        it 'returns empty string for nil data' do
          presenter = described_class.new(nil_moving_average_data, quiet_options)
          result = presenter.format

          expect(result).to eq('')
        end

        it 'returns empty string for empty moving average' do
          presenter = described_class.new(empty_moving_average_data, quiet_options)
          result = presenter.format

          expect(result).to eq('')
        end
      end
    end
  end

  describe 'edge cases' do
    it 'handles single value moving average correctly' do
      single_value_data = {
        moving_average: [5.0],
        window_size: 1,
        dataset_size: 1
      }
      presenter = described_class.new(single_value_data, default_options)
      result = presenter.format

      expect(result).to include('Moving Average (Window Size: 1):')
      expect(result).to include('5.0')
      expect(result).to include('Original data size: 1, Moving average count: 1')
    end

    it 'handles very small numbers with high precision' do
      small_data = {
        moving_average: [0.000123456, 0.000234567, 0.000345678],
        window_size: 2,
        dataset_size: 4
      }
      presenter = described_class.new(small_data, precision: 6)
      result = presenter.format

      expect(result).to include('0.000123, 0.000235, 0.000346')
    end

    it 'handles negative values correctly' do
      negative_data = {
        moving_average: [-1.5, -2.5, -3.5],
        window_size: 3,
        dataset_size: 5
      }
      presenter = described_class.new(negative_data, default_options)
      result = presenter.format

      expect(result).to include('-1.5, -2.5, -3.5')
    end

    it 'handles large datasets correctly' do
      large_data = {
        moving_average: Array.new(100) { |i| i * 1.5 },
        window_size: 10,
        dataset_size: 109
      }
      presenter = described_class.new(large_data, default_options)
      result = presenter.format

      expect(result).to include('Moving Average (Window Size: 10):')
      expect(result).to include('Original data size: 109, Moving average count: 100')
    end
  end

  describe 'integration with BaseStatisticalPresenter' do
    it 'inherits precision handling from base class' do
      presenter = described_class.new(valid_moving_average_data, precision: 2)

      # Test that round_value method is available
      expect(presenter.send(:round_value, 1.23456)).to eq(1.23)
    end

    it 'follows Template Method Pattern correctly' do
      presenter = described_class.new(valid_moving_average_data, default_options)

      # Test that format method delegates to format_verbose
      expect(presenter).to respond_to(:format)
      expect(presenter.format).to include('Moving Average')
    end

    it 'properly handles dataset metadata' do
      presenter = described_class.new(valid_moving_average_data, dataset_size_options)
      metadata = presenter.send(:dataset_metadata)

      expect(metadata).to have_key(:dataset_size)
      expect(metadata[:dataset_size]).to eq(10)
    end
  end

  describe 'format_value integration' do
    it 'uses format_value method from base class' do
      presenter = described_class.new(valid_moving_average_data, precision: 3)

      formatted = presenter.send(:format_value, 1.23456789)
      expect(formatted).to eq('1.235')
    end
  end
end
