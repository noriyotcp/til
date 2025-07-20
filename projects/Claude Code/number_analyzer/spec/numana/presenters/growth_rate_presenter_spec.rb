# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NumberAnalyzer::Presenters::GrowthRatePresenter do
  let(:valid_growth_rate_data) do
    {
      growth_rates: [0.1, 0.2, 0.15, -0.05],
      compound_annual_growth_rate: 0.125,
      average_growth_rate: 0.15,
      dataset_size: 5
    }
  end
  let(:nil_growth_rate_data) { nil }
  let(:empty_growth_rate_data) do
    {
      growth_rates: [],
      compound_annual_growth_rate: nil,
      average_growth_rate: nil,
      dataset_size: 1
    }
  end
  let(:infinite_growth_data) do
    {
      growth_rates: [Float::INFINITY, -Float::INFINITY, 0.1],
      compound_annual_growth_rate: 0.2,
      average_growth_rate: nil,
      dataset_size: 3
    }
  end
  let(:negative_cagr_data) do
    {
      growth_rates: [0.1, 0.2],
      compound_annual_growth_rate: nil, # CAGR calculation failed due to negative initial value
      average_growth_rate: 0.15,
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
      context 'with valid growth rate data' do
        it 'formats growth rate analysis correctly' do
          presenter = described_class.new(valid_growth_rate_data, default_options)
          result = presenter.format

          expect(result).to include('成長率分析:')
          expect(result).to include('期間別成長率: +10%, +20%, +15%, -5%')
          expect(result).to include('複合年間成長率 (CAGR): +12.5%')
          expect(result).to include('平均成長率: +15%')
        end

        it 'applies precision formatting when specified' do
          presenter = described_class.new(valid_growth_rate_data, precision_options)
          result = presenter.format

          expect(result).to include('+10%, +20%, +15%, -5%')
          expect(result).to include('+12.5%')
        end

        it 'handles infinite values correctly' do
          presenter = described_class.new(infinite_growth_data, default_options)
          result = presenter.format

          expect(result).to include('期間別成長率: +∞%, -∞%, +10%')
          expect(result).to include('複合年間成長率 (CAGR): +20%')
        end

        it 'handles null CAGR correctly' do
          presenter = described_class.new(negative_cagr_data, default_options)
          result = presenter.format

          expect(result).to include('複合年間成長率 (CAGR): 計算不可（負の初期値）')
          expect(result).to include('平均成長率: +15%')
        end
      end

      context 'with invalid growth rate data' do
        it 'returns error message for nil data' do
          presenter = described_class.new(nil_growth_rate_data, default_options)
          result = presenter.format

          expect(result).to eq('エラー: データが不十分です（2つ以上の値が必要）')
        end

        it 'returns error message for empty growth rates' do
          presenter = described_class.new(empty_growth_rate_data, default_options)
          result = presenter.format

          expect(result).to eq('エラー: データが不十分です（2つ以上の値が必要）')
        end
      end
    end

    context 'when format is JSON' do
      context 'with valid growth rate data' do
        it 'formats as JSON with growth rate data' do
          presenter = described_class.new(valid_growth_rate_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('growth_rate_analysis')
          analysis = parsed_result['growth_rate_analysis']
          expect(analysis).to have_key('period_growth_rates')
          expect(analysis).to have_key('compound_annual_growth_rate')
          expect(analysis).to have_key('average_growth_rate')
          expect(analysis['period_growth_rates']).to be_an(Array)
          expect(analysis['compound_annual_growth_rate']).to eq(0.125)
          expect(analysis['average_growth_rate']).to eq(0.15)
        end

        it 'applies precision formatting in JSON' do
          presenter = described_class.new(valid_growth_rate_data, json_options.merge(precision: 2))
          result = presenter.format
          parsed_result = JSON.parse(result)

          analysis = parsed_result['growth_rate_analysis']
          expect(analysis['compound_annual_growth_rate']).to eq(0.13)
          expect(analysis['average_growth_rate']).to eq(0.15)
        end

        it 'handles infinite values in JSON' do
          presenter = described_class.new(infinite_growth_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          analysis = parsed_result['growth_rate_analysis']
          expect(analysis['period_growth_rates']).to include('Infinity', '-Infinity')
        end

        it 'handles null values in JSON' do
          presenter = described_class.new(negative_cagr_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          analysis = parsed_result['growth_rate_analysis']
          expect(analysis['compound_annual_growth_rate']).to be_nil
          expect(analysis['average_growth_rate']).to eq(0.15)
        end

        it 'includes dataset metadata when provided' do
          presenter = described_class.new(valid_growth_rate_data, json_options.merge(dataset_size_options))
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('dataset_size')
          expect(parsed_result['dataset_size']).to eq(10)
        end
      end

      context 'with invalid growth rate data' do
        it 'returns JSON with null analysis for nil data' do
          presenter = described_class.new(nil_growth_rate_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('growth_rate_analysis')
          expect(parsed_result['growth_rate_analysis']).to be_nil
          expect(parsed_result).to have_key('error')
          expect(parsed_result['error']).to eq('データが不十分です')
        end

        it 'returns JSON with error for empty growth rates' do
          presenter = described_class.new(empty_growth_rate_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('growth_rate_analysis')
          expect(parsed_result['growth_rate_analysis']).to be_nil
          expect(parsed_result).to have_key('error')
        end
      end
    end

    context 'when format is quiet' do
      context 'with valid growth rate data' do
        it 'formats as space-separated CAGR and average' do
          presenter = described_class.new(valid_growth_rate_data, quiet_options)
          result = presenter.format

          expect(result).to eq('0.125 0.15')
        end

        it 'applies precision formatting in quiet mode' do
          presenter = described_class.new(valid_growth_rate_data, quiet_options.merge(precision: 2))
          result = presenter.format

          expect(result).to eq('0.13 0.15')
        end

        it 'handles null CAGR in quiet mode' do
          presenter = described_class.new(negative_cagr_data, quiet_options)
          result = presenter.format

          expect(result).to eq('0.15')
        end

        it 'handles both null values in quiet mode' do
          data_with_nulls = {
            growth_rates: [0.1],
            compound_annual_growth_rate: nil,
            average_growth_rate: nil,
            dataset_size: 2
          }
          presenter = described_class.new(data_with_nulls, quiet_options)
          result = presenter.format

          expect(result).to eq('')
        end
      end

      context 'with invalid growth rate data' do
        it 'returns empty string for nil data' do
          presenter = described_class.new(nil_growth_rate_data, quiet_options)
          result = presenter.format

          expect(result).to eq('')
        end

        it 'returns empty string for empty growth rates' do
          presenter = described_class.new(empty_growth_rate_data, quiet_options)
          result = presenter.format

          expect(result).to eq('')
        end
      end
    end
  end

  describe 'edge cases' do
    it 'handles zero growth rates correctly' do
      zero_growth_data = {
        growth_rates: [0.0, 0.0, 0.0],
        compound_annual_growth_rate: 0.0,
        average_growth_rate: 0.0,
        dataset_size: 4
      }
      presenter = described_class.new(zero_growth_data, default_options)
      result = presenter.format

      expect(result).to include('期間別成長率: +0%, +0%, +0%')
      expect(result).to include('複合年間成長率 (CAGR): +0%')
      expect(result).to include('平均成長率: +0%')
    end

    it 'handles very small numbers with high precision' do
      small_growth_data = {
        growth_rates: [0.000123, 0.000456],
        compound_annual_growth_rate: 0.000289,
        average_growth_rate: 0.000289,
        dataset_size: 3
      }
      presenter = described_class.new(small_growth_data, precision: 6)
      result = presenter.format

      # With precision: 6, 0.000123 * 100 = 0.0123 → rounded to 6 decimals and formatted as percentage
      expect(result).to include('+0.012300%') # precision 6 maintains trailing zeros
      expect(result).to include('+0.045600%')
      expect(result).to include('+0.028900%')
    end

    it 'handles large growth rates correctly' do
      large_growth_data = {
        growth_rates: [5.0, 10.0, 2.5],
        compound_annual_growth_rate: 5.8,
        average_growth_rate: 5.83,
        dataset_size: 4
      }
      presenter = described_class.new(large_growth_data, default_options)
      result = presenter.format

      expect(result).to include('+500%, +1000%, +250%')
      expect(result).to include('+580%')
      expect(result).to include('+583%')
    end

    it 'handles negative growth rates correctly' do
      negative_growth_data = {
        growth_rates: [-0.1, -0.2, -0.05],
        compound_annual_growth_rate: -0.115,
        average_growth_rate: -0.116,
        dataset_size: 4
      }
      presenter = described_class.new(negative_growth_data, default_options)
      result = presenter.format

      expect(result).to include('-10%, -20%, -5%')
      expect(result).to include('-11.5%')
      expect(result).to include('-11.6%')
    end
  end

  describe 'integration with BaseStatisticalPresenter' do
    it 'inherits precision handling from base class' do
      presenter = described_class.new(valid_growth_rate_data, precision: 2)

      # Test that round_value method is available
      expect(presenter.send(:round_value, 1.23456)).to eq(1.23)
    end

    it 'follows Template Method Pattern correctly' do
      presenter = described_class.new(valid_growth_rate_data, default_options)

      # Test that format method delegates to format_verbose
      expect(presenter).to respond_to(:format)
      expect(presenter.format).to include('成長率分析:')
    end

    it 'properly handles dataset metadata' do
      presenter = described_class.new(valid_growth_rate_data, dataset_size_options)
      metadata = presenter.send(:dataset_metadata)

      expect(metadata).to have_key(:dataset_size)
      expect(metadata[:dataset_size]).to eq(10)
    end
  end

  describe 'percentage formatting' do
    it 'formats whole number percentages correctly' do
      presenter = described_class.new(valid_growth_rate_data, default_options)

      formatted = presenter.send(:format_percentage_sign, 10.0)
      expect(formatted).to eq('+10%')
    end

    it 'formats decimal percentages correctly' do
      presenter = described_class.new(valid_growth_rate_data, default_options)

      formatted = presenter.send(:format_percentage_sign, 12.34)
      expect(formatted).to eq('+12.34%')
    end

    it 'removes trailing zeros from percentages' do
      presenter = described_class.new(valid_growth_rate_data, default_options)

      formatted = presenter.send(:format_percentage_sign, 12.50)
      expect(formatted).to eq('+12.5%')
    end

    it 'handles negative percentages correctly' do
      presenter = described_class.new(valid_growth_rate_data, default_options)

      formatted = presenter.send(:format_percentage_sign, -5.0)
      expect(formatted).to eq('-5%')
    end
  end
end
