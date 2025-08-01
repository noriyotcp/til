# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Numana::Presenters::TrendPresenter do
  let(:valid_trend_data) do
    {
      slope: 1.234567,
      intercept: 0.987654,
      r_squared: 0.876543,
      direction: '上昇'
    }
  end
  let(:nil_trend_data) { nil }
  let(:default_options) { {} }
  let(:json_options) { { format: 'json' } }
  let(:quiet_options) { { format: 'quiet' } }
  let(:precision_options) { { precision: 2 } }
  let(:dataset_size_options) { { dataset_size: 10 } }

  describe '#format' do
    context 'when format is default (verbose)' do
      context 'with valid trend data' do
        it 'formats trend analysis results correctly' do
          presenter = described_class.new(valid_trend_data, default_options)
          result = presenter.format

          expect(result).to include('トレンド分析結果:')
          expect(result).to include('傾き: 1.234567')
          expect(result).to include('切片: 0.987654')
          expect(result).to include('決定係数(R²): 0.876543')
          expect(result).to include('方向性: 上昇')
        end

        it 'applies precision formatting when specified' do
          presenter = described_class.new(valid_trend_data, precision_options)
          result = presenter.format

          expect(result).to include('傾き: 1.23')
          expect(result).to include('切片: 0.99')
          expect(result).to include('決定係数(R²): 0.88')
        end
      end

      context 'with nil trend data' do
        it 'returns error message' do
          presenter = described_class.new(nil_trend_data, default_options)
          result = presenter.format

          expect(result).to eq('エラー: データが不十分です（2つ以上の値が必要）')
        end
      end
    end

    context 'when format is JSON' do
      context 'with valid trend data' do
        it 'formats as JSON with trend data' do
          presenter = described_class.new(valid_trend_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('trend')
          expect(parsed_result['trend']).to have_key('slope')
          expect(parsed_result['trend']).to have_key('intercept')
          expect(parsed_result['trend']).to have_key('r_squared')
          expect(parsed_result['trend']).to have_key('direction')
          expect(parsed_result['trend']['direction']).to eq('上昇')
        end

        it 'applies precision formatting in JSON' do
          presenter = described_class.new(valid_trend_data, json_options.merge(precision: 2))
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result['trend']['slope']).to eq(1.23)
          expect(parsed_result['trend']['intercept']).to eq(0.99)
          expect(parsed_result['trend']['r_squared']).to eq(0.88)
        end

        it 'includes dataset metadata when provided' do
          presenter = described_class.new(valid_trend_data, json_options.merge(dataset_size_options))
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('dataset_size')
          expect(parsed_result['dataset_size']).to eq(10)
        end
      end

      context 'with nil trend data' do
        it 'returns JSON with null trend' do
          presenter = described_class.new(nil_trend_data, json_options)
          result = presenter.format
          parsed_result = JSON.parse(result)

          expect(parsed_result).to have_key('trend')
          expect(parsed_result['trend']).to be_nil
        end
      end
    end

    context 'when format is quiet' do
      context 'with valid trend data' do
        it 'formats as space-separated values' do
          presenter = described_class.new(valid_trend_data, quiet_options)
          result = presenter.format

          expect(result).to eq('1.234567 0.987654 0.876543')
        end

        it 'applies precision formatting in quiet mode' do
          presenter = described_class.new(valid_trend_data, quiet_options.merge(precision: 2))
          result = presenter.format

          expect(result).to eq('1.23 0.99 0.88')
        end
      end

      context 'with nil trend data' do
        it 'returns empty string' do
          presenter = described_class.new(nil_trend_data, quiet_options)
          result = presenter.format

          expect(result).to eq('')
        end
      end
    end
  end

  describe 'edge cases' do
    it 'handles zero values correctly' do
      zero_trend_data = {
        slope: 0.0,
        intercept: 0.0,
        r_squared: 0.0,
        direction: '横ばい'
      }
      presenter = described_class.new(zero_trend_data, default_options)
      result = presenter.format

      expect(result).to include('傾き: 0.0')
      expect(result).to include('切片: 0.0')
      expect(result).to include('決定係数(R²): 0.0')
      expect(result).to include('方向性: 横ばい')
    end

    it 'handles negative values correctly' do
      negative_trend_data = {
        slope: -1.5,
        intercept: 10.0,
        r_squared: 0.75,
        direction: '下降'
      }
      presenter = described_class.new(negative_trend_data, default_options)
      result = presenter.format

      expect(result).to include('傾き: -1.5')
      expect(result).to include('切片: 10.0')
      expect(result).to include('方向性: 下降')
    end

    it 'handles very small numbers with high precision' do
      small_trend_data = {
        slope: 0.000123456,
        intercept: 0.000987654,
        r_squared: 0.000876543,
        direction: '微増'
      }
      presenter = described_class.new(small_trend_data, precision: 6)
      result = presenter.format

      expect(result).to include('傾き: 0.000123')
      expect(result).to include('切片: 0.000988')
      expect(result).to include('決定係数(R²): 0.000877')
    end
  end

  describe 'integration with BaseStatisticalPresenter' do
    it 'inherits precision handling from base class' do
      presenter = described_class.new(valid_trend_data, precision: 2)

      # Test that round_value method is available (takes only one argument)
      expect(presenter.send(:round_value, 1.23456)).to eq(1.23)
    end

    it 'follows Template Method Pattern correctly' do
      presenter = described_class.new(valid_trend_data, default_options)

      # Test that format method delegates to format_verbose
      expect(presenter).to respond_to(:format)
      expect(presenter.format).to include('トレンド分析結果:')
    end
  end
end
