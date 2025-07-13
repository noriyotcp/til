# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/number_analyzer/presenters/seasonal_presenter'

RSpec.describe NumberAnalyzer::Presenters::SeasonalPresenter do
  let(:valid_seasonal_data) do
    {
      period: 4,
      seasonal_indices: [0.95, 1.05, 1.02, 0.98],
      seasonal_strength: 0.15,
      has_seasonality: true
    }
  end

  let(:non_seasonal_data) do
    {
      period: 4,
      seasonal_indices: [1.0, 1.0, 1.0, 1.0],
      seasonal_strength: 0.05,
      has_seasonality: false
    }
  end

  let(:default_options) { {} }
  let(:json_options) { { format: 'json' } }
  let(:quiet_options) { { quiet: true } }
  let(:precision_options) { { precision: 2 } }

  describe '#format' do
    context 'with valid seasonal data' do
      context 'default format' do
        let(:presenter) { described_class.new(valid_seasonal_data, default_options) }

        it 'returns verbose seasonal analysis format' do
          result = presenter.format

          expect(result).to include('季節性分析結果:')
          expect(result).to include('検出周期: 4')
          expect(result).to include('季節指数: 0.95, 1.05, 1.02, 0.98')
          expect(result).to include('季節性強度: 0.15')
          expect(result).to include('季節性判定: 季節性あり')
        end

        it 'formats seasonal indices with proper precision' do
          result = presenter.format

          expect(result).to include('季節指数: 0.95, 1.05, 1.02, 0.98')
        end

        it 'includes seasonality judgment' do
          result = presenter.format

          expect(result).to include('季節性判定: 季節性あり')
        end
      end

      context 'with non-seasonal data' do
        let(:presenter) { described_class.new(non_seasonal_data, default_options) }

        it 'shows no seasonality judgment' do
          result = presenter.format

          expect(result).to include('季節性判定: 季節性なし')
        end
      end

      context 'with precision option' do
        let(:presenter) { described_class.new(valid_seasonal_data, precision_options) }

        it 'applies precision to seasonal strength' do
          result = presenter.format

          expect(result).to include('季節性強度: 0.15')
        end

        it 'applies precision to seasonal indices' do
          result = presenter.format

          expect(result).to include('季節指数: 0.95, 1.05, 1.02, 0.98')
        end
      end
    end

    context 'with nil data' do
      let(:presenter) { described_class.new(nil, default_options) }

      it 'returns error message' do
        result = presenter.format

        expect(result).to eq('エラー: データが不十分です（季節性分析には最低4つの値が必要）')
      end
    end
  end

  describe '#format for JSON output' do
    context 'with valid seasonal data' do
      let(:presenter) { described_class.new(valid_seasonal_data, json_options) }

      it 'returns valid JSON structure' do
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed).to have_key('seasonal_analysis')
        expect(parsed['seasonal_analysis']).to have_key('period')
        expect(parsed['seasonal_analysis']).to have_key('seasonal_indices')
        expect(parsed['seasonal_analysis']).to have_key('seasonal_strength')
        expect(parsed['seasonal_analysis']).to have_key('has_seasonality')
      end

      it 'includes correct seasonal data' do
        result = presenter.format
        parsed = JSON.parse(result)
        seasonal_analysis = parsed['seasonal_analysis']

        expect(seasonal_analysis['period']).to eq(4)
        expect(seasonal_analysis['seasonal_indices']).to eq([0.95, 1.05, 1.02, 0.98])
        expect(seasonal_analysis['seasonal_strength']).to eq(0.15)
        expect(seasonal_analysis['has_seasonality']).to be true
      end

      it 'applies precision to numerical values' do
        presenter = described_class.new(valid_seasonal_data, json_options.merge(precision: 1))
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['seasonal_analysis']['seasonal_strength']).to eq(0.2)
        expect(parsed['seasonal_analysis']['seasonal_indices']).to eq([1.0, 1.1, 1.0, 1.0])
      end
    end

    context 'with nil data' do
      let(:presenter) { described_class.new(nil, json_options) }

      it 'returns JSON error structure' do
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['seasonal_analysis']).to be_nil
        expect(parsed['error']).to eq('データが不十分です')
      end
    end

    context 'with dataset size metadata' do
      let(:options_with_dataset) { json_options.merge(dataset_size: 12) }
      let(:presenter) { described_class.new(valid_seasonal_data, options_with_dataset) }

      it 'includes dataset size in metadata' do
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['dataset_size']).to eq(12)
      end
    end
  end

  describe '#format for quiet output' do
    context 'with valid seasonal data' do
      let(:presenter) { described_class.new(valid_seasonal_data, quiet_options) }

      it 'returns compact format with key values' do
        result = presenter.format

        expect(result).to eq('4 0.15 true')
      end

      it 'shows false for non-seasonal data' do
        presenter = described_class.new(non_seasonal_data, quiet_options)
        result = presenter.format

        expect(result).to eq('4 0.05 false')
      end

      it 'applies precision to seasonal strength' do
        presenter = described_class.new(valid_seasonal_data, quiet_options.merge(precision: 1))
        result = presenter.format

        expect(result).to eq('4 0.2 true')
      end
    end

    context 'with nil data' do
      let(:presenter) { described_class.new(nil, quiet_options) }

      it 'returns empty string' do
        result = presenter.format

        expect(result).to eq('')
      end
    end
  end

  describe 'edge cases' do
    context 'with high precision seasonal strength' do
      let(:high_precision_data) do
        {
          period: 12,
          seasonal_indices: [0.8333, 0.9167, 1.0833, 1.1667, 1.0, 0.9167, 0.8333, 0.9167, 1.0833, 1.1667, 1.0, 0.9167],
          seasonal_strength: 0.234567,
          has_seasonality: true
        }
      end

      let(:presenter) { described_class.new(high_precision_data, precision_options.merge(precision: 3)) }

      it 'handles high precision values correctly' do
        result = presenter.format

        expect(result).to include('季節性強度: 0.235')
      end
    end

    context 'with single seasonal index' do
      let(:minimal_data) do
        {
          period: 1,
          seasonal_indices: [1.0],
          seasonal_strength: 0.0,
          has_seasonality: false
        }
      end

      let(:presenter) { described_class.new(minimal_data, default_options) }

      it 'handles minimal seasonal data' do
        result = presenter.format

        expect(result).to include('検出周期: 1')
        expect(result).to include('季節指数: 1.0')
        expect(result).to include('季節性判定: 季節性なし')
      end
    end

    context 'with zero seasonal strength' do
      let(:zero_strength_data) do
        {
          period: 4,
          seasonal_indices: [1.0, 1.0, 1.0, 1.0],
          seasonal_strength: 0.0,
          has_seasonality: false
        }
      end

      let(:presenter) { described_class.new(zero_strength_data, default_options) }

      it 'handles zero seasonal strength' do
        result = presenter.format

        expect(result).to include('季節性強度: 0.0')
        expect(result).to include('季節性判定: 季節性なし')
      end
    end
  end
end
