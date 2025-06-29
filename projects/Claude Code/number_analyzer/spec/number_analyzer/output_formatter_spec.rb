# frozen_string_literal: true

require_relative '../../lib/number_analyzer/output_formatter'

RSpec.describe NumberAnalyzer::OutputFormatter do
  describe '.format_value' do
    context 'with default options' do
      it 'returns string representation of value' do
        result = described_class.format_value(3.14159)
        expect(result).to eq('3.14159')
      end
    end

    context 'with precision option' do
      it 'rounds to specified decimal places' do
        result = described_class.format_value(3.14159, precision: 2)
        expect(result).to eq('3.14')
      end
    end

    context 'with JSON format' do
      it 'returns JSON with value and metadata' do
        result = described_class.format_value(3.5, format: 'json', dataset_size: 5)
        parsed = JSON.parse(result)
        expect(parsed).to eq({ 'value' => 3.5, 'dataset_size' => 5 })
      end
    end

    context 'with JSON format and precision' do
      it 'returns JSON with rounded value' do
        result = described_class.format_value(3.14159, format: 'json', precision: 2, dataset_size: 3)
        parsed = JSON.parse(result)
        expect(parsed).to eq({ 'value' => 3.14, 'dataset_size' => 3 })
      end
    end
  end

  describe '.format_array' do
    let(:values) { [1.1111, 2.2222, 3.3333] }

    context 'with default options' do
      it 'returns comma-separated string' do
        result = described_class.format_array(values)
        expect(result).to eq('1.1111, 2.2222, 3.3333')
      end
    end

    context 'with precision option' do
      it 'rounds values to specified decimal places' do
        result = described_class.format_array(values, precision: 2)
        expect(result).to eq('1.11, 2.22, 3.33')
      end
    end

    context 'with quiet format' do
      it 'returns space-separated string' do
        result = described_class.format_array(values, format: 'quiet')
        expect(result).to eq('1.1111 2.2222 3.3333')
      end
    end

    context 'with JSON format' do
      it 'returns JSON with values array and metadata' do
        result = described_class.format_array(values, format: 'json', dataset_size: 3)
        parsed = JSON.parse(result)
        expect(parsed).to eq({ 'values' => values, 'dataset_size' => 3 })
      end
    end
  end

  describe '.format_quartiles' do
    let(:quartiles) { { q1: 2.5, q2: 5.0, q3: 7.5 } }

    context 'with default options' do
      it 'returns formatted quartiles string' do
        result = described_class.format_quartiles(quartiles)
        expect(result).to eq("Q1: 2.5\nQ2: 5.0\nQ3: 7.5")
      end
    end

    context 'with precision option' do
      it 'rounds quartiles to specified decimal places' do
        quartiles_with_decimals = { q1: 2.5555, q2: 5.1111, q3: 7.7777 }
        result = described_class.format_quartiles(quartiles_with_decimals, precision: 2)
        expect(result).to eq("Q1: 2.56\nQ2: 5.11\nQ3: 7.78")
      end
    end

    context 'with quiet format' do
      it 'returns space-separated quartile values' do
        result = described_class.format_quartiles(quartiles, format: 'quiet')
        expect(result).to eq('2.5 5.0 7.5')
      end
    end

    context 'with JSON format' do
      it 'returns JSON with quartiles and metadata' do
        result = described_class.format_quartiles(quartiles, format: 'json', dataset_size: 10)
        parsed = JSON.parse(result)
        expected = { 'q1' => 2.5, 'q2' => 5.0, 'q3' => 7.5, 'dataset_size' => 10 }
        expect(parsed).to eq(expected)
      end
    end
  end

  describe '.format_mode' do
    context 'with mode values' do
      let(:mode_values) { [2, 5] }

      it 'returns comma-separated string' do
        result = described_class.format_mode(mode_values)
        expect(result).to eq('2, 5')
      end

      context 'with quiet format' do
        it 'returns space-separated string' do
          result = described_class.format_mode(mode_values, format: 'quiet')
          expect(result).to eq('2 5')
        end
      end

      context 'with JSON format' do
        it 'returns JSON with mode array' do
          result = described_class.format_mode(mode_values, format: 'json', dataset_size: 8)
          parsed = JSON.parse(result)
          expect(parsed).to eq({ 'mode' => [2, 5], 'dataset_size' => 8 })
        end
      end
    end

    context 'with empty mode values' do
      let(:mode_values) { [] }

      it 'returns Japanese "no mode" message' do
        result = described_class.format_mode(mode_values)
        expect(result).to eq('モードなし')
      end

      context 'with quiet format' do
        it 'returns empty string' do
          result = described_class.format_mode(mode_values, format: 'quiet')
          expect(result).to eq('')
        end
      end

      context 'with JSON format' do
        it 'returns JSON with null mode' do
          result = described_class.format_mode(mode_values, format: 'json', dataset_size: 5)
          parsed = JSON.parse(result)
          expect(parsed).to eq({ 'mode' => nil, 'dataset_size' => 5 })
        end
      end
    end
  end

  describe '.format_outliers' do
    context 'with outlier values' do
      let(:outlier_values) { [100.0, 200.0] }

      it 'returns comma-separated string' do
        result = described_class.format_outliers(outlier_values)
        expect(result).to eq('100.0, 200.0')
      end

      context 'with precision option' do
        it 'rounds outliers to specified decimal places' do
          outliers_with_decimals = [100.5555, 200.7777]
          result = described_class.format_outliers(outliers_with_decimals, precision: 1)
          expect(result).to eq('100.6, 200.8')
        end
      end

      context 'with quiet format' do
        it 'returns space-separated string' do
          result = described_class.format_outliers(outlier_values, format: 'quiet')
          expect(result).to eq('100.0 200.0')
        end
      end

      context 'with JSON format' do
        it 'returns JSON with outliers array' do
          result = described_class.format_outliers(outlier_values, format: 'json', dataset_size: 12)
          parsed = JSON.parse(result)
          expect(parsed).to eq({ 'outliers' => [100.0, 200.0], 'dataset_size' => 12 })
        end
      end
    end

    context 'with empty outlier values' do
      let(:outlier_values) { [] }

      it 'returns Japanese "no outliers" message' do
        result = described_class.format_outliers(outlier_values)
        expect(result).to eq('なし')
      end

      context 'with quiet format' do
        it 'returns empty string' do
          result = described_class.format_outliers(outlier_values, format: 'quiet')
          expect(result).to eq('')
        end
      end

      context 'with JSON format' do
        it 'returns JSON with empty outliers array' do
          result = described_class.format_outliers(outlier_values, format: 'json', dataset_size: 8)
          parsed = JSON.parse(result)
          expect(parsed).to eq({ 'outliers' => [], 'dataset_size' => 8 })
        end
      end
    end
  end

  describe '.format_trend' do
    let(:trend_data) do
      {
        slope: 1.5,
        intercept: 2.0,
        r_squared: 0.95,
        direction: '上昇'
      }
    end

    context 'with default format' do
      it 'formats trend data with Japanese labels' do
        result = described_class.format_trend(trend_data)
        expected = "トレンド分析結果:\n傾き: 1.5\n切片: 2.0\n決定係数(R²): 0.95\n方向性: 上昇"
        expect(result).to eq(expected)
      end
    end

    context 'with precision option' do
      it 'applies precision to numeric values' do
        result = described_class.format_trend(trend_data, precision: 1)
        expected = "トレンド分析結果:\n傾き: 1.5\n切片: 2.0\n決定係数(R²): 1.0\n方向性: 上昇"
        expect(result).to eq(expected)
      end
    end

    context 'with JSON format' do
      it 'returns JSON with trend data and metadata' do
        result = described_class.format_trend(trend_data, format: 'json', dataset_size: 5)
        parsed = JSON.parse(result)
        expected = {
          'trend' => {
            'slope' => 1.5,
            'intercept' => 2.0,
            'r_squared' => 0.95,
            'direction' => '上昇'
          },
          'dataset_size' => 5
        }
        expect(parsed).to eq(expected)
      end
    end

    context 'with quiet format' do
      it 'returns space-separated numeric values' do
        result = described_class.format_trend(trend_data, format: 'quiet')
        expect(result).to eq('1.5 2.0 0.95')
      end
    end

    context 'with nil trend data' do
      it 'returns error message for default format' do
        result = described_class.format_trend(nil)
        expect(result).to eq('エラー: データが不十分です（2つ以上の値が必要）')
      end

      it 'returns JSON with null trend for JSON format' do
        result = described_class.format_trend(nil, format: 'json', dataset_size: 1)
        parsed = JSON.parse(result)
        expect(parsed).to eq({ 'trend' => nil, 'dataset_size' => 1 })
      end

      it 'returns empty string for quiet format' do
        result = described_class.format_trend(nil, format: 'quiet')
        expect(result).to eq('')
      end
    end
  end

  describe '.format_moving_average' do
    context 'with valid moving average data' do
      let(:moving_avg_data) { [2.0, 3.0, 4.0, 5.0] }

      it 'formats default output with window size' do
        result = described_class.format_moving_average(moving_avg_data, window_size: 3)
        expect(result).to eq("移動平均（ウィンドウサイズ: 3）:\n2.0, 3.0, 4.0, 5.0")
      end

      it 'applies precision formatting' do
        result = described_class.format_moving_average([2.1234, 3.5678], precision: 2, window_size: 3)
        expect(result).to eq("移動平均（ウィンドウサイズ: 3）:\n2.12, 3.57")
      end

      it 'formats JSON output' do
        result = described_class.format_moving_average(moving_avg_data, format: 'json', window_size: 3, dataset_size: 6)
        parsed = JSON.parse(result)
        expect(parsed).to eq({
                               'moving_average' => [2.0, 3.0, 4.0, 5.0],
                               'window_size' => 3,
                               'dataset_size' => 6
                             })
      end

      it 'formats JSON output with precision' do
        result = described_class.format_moving_average([2.1234, 3.5678], format: 'json', precision: 1, window_size: 3, dataset_size: 5)
        parsed = JSON.parse(result)
        expect(parsed['moving_average']).to eq([2.1, 3.6])
        expect(parsed['window_size']).to eq(3)
        expect(parsed['dataset_size']).to eq(5)
      end

      it 'formats quiet output' do
        result = described_class.format_moving_average(moving_avg_data, format: 'quiet')
        expect(result).to eq('2.0 3.0 4.0 5.0')
      end

      it 'formats quiet output with precision' do
        result = described_class.format_moving_average([2.1234, 3.5678], format: 'quiet', precision: 2)
        expect(result).to eq('2.12 3.57')
      end
    end

    context 'with nil moving average data (error cases)' do
      it 'formats default error message' do
        result = described_class.format_moving_average(nil)
        expect(result).to eq('エラー: データが不十分です（ウィンドウサイズがデータ長を超えています）')
      end

      it 'formats JSON error output' do
        result = described_class.format_moving_average(nil, format: 'json', dataset_size: 2)
        parsed = JSON.parse(result)
        expect(parsed).to eq({
                               'moving_average' => nil,
                               'error' => 'データが不十分です',
                               'dataset_size' => 2
                             })
      end

      it 'formats quiet error output' do
        result = described_class.format_moving_average(nil, format: 'quiet')
        expect(result).to eq('')
      end
    end
  end

  describe '.format_growth_rate' do
    let(:growth_data) do
      {
        growth_rates: [10.0, 10.0, 9.9173553719],
        compound_annual_growth_rate: 9.9724448886,
        average_growth_rate: 9.9724517906
      }
    end

    context 'default format' do
      it 'formats growth rate analysis correctly' do
        result = described_class.format_growth_rate(growth_data)

        expect(result).to include('成長率分析:')
        expect(result).to include('期間別成長率: +10%, +10%, +9.92%')
        expect(result).to include('複合年間成長率 (CAGR): +9.97%')
        expect(result).to include('平均成長率: +9.97%')
      end

      it 'handles infinite growth rates' do
        infinite_data = {
          growth_rates: [Float::INFINITY, -100.0],
          compound_annual_growth_rate: nil,
          average_growth_rate: -100.0
        }

        result = described_class.format_growth_rate(infinite_data)

        expect(result).to include('期間別成長率: +∞%, -100%')
        expect(result).to include('複合年間成長率 (CAGR): 計算不可（負の初期値）')
        expect(result).to include('平均成長率: -100%')
      end

      it 'handles nil CAGR appropriately' do
        nil_cagr_data = {
          growth_rates: [10.0],
          compound_annual_growth_rate: nil,
          average_growth_rate: 10.0
        }

        result = described_class.format_growth_rate(nil_cagr_data)

        expect(result).to include('複合年間成長率 (CAGR): 計算不可（負の初期値）')
      end

      it 'handles empty growth rates' do
        empty_data = {
          growth_rates: [],
          compound_annual_growth_rate: nil,
          average_growth_rate: nil
        }

        result = described_class.format_growth_rate(empty_data)

        expect(result).to eq('エラー: データが不十分です（2つ以上の値が必要）')
      end
    end

    context 'JSON format' do
      it 'formats JSON output correctly' do
        result = described_class.format_growth_rate(growth_data, format: 'json')
        parsed = JSON.parse(result)

        expect(parsed).to have_key('growth_rate_analysis')
        analysis = parsed['growth_rate_analysis']

        expect(analysis['period_growth_rates']).to eq([10.0, 10.0, 9.9173553719])
        expect(analysis['compound_annual_growth_rate']).to be_within(0.0001).of(9.9724448886)
        expect(analysis['average_growth_rate']).to be_within(0.0001).of(9.9724517906)
      end

      it 'handles infinite values in JSON' do
        infinite_data = {
          growth_rates: [Float::INFINITY, -Float::INFINITY, 10.0],
          compound_annual_growth_rate: 5.0,
          average_growth_rate: 10.0
        }

        result = described_class.format_growth_rate(infinite_data, format: 'json')
        parsed = JSON.parse(result)

        rates = parsed['growth_rate_analysis']['period_growth_rates']
        expect(rates[0]).to eq('Infinity')
        expect(rates[1]).to eq('-Infinity')
        expect(rates[2]).to eq(10.0)
      end

      it 'includes dataset metadata' do
        result = described_class.format_growth_rate(growth_data, format: 'json', dataset_size: 4)
        parsed = JSON.parse(result)

        expect(parsed['dataset_size']).to eq(4)
      end
    end

    context 'quiet format' do
      it 'outputs CAGR and average growth only' do
        result = described_class.format_growth_rate(growth_data, format: 'quiet')
        values = result.strip.split

        expect(values.length).to eq(2)
        expect(values[0].to_f).to be_within(0.0001).of(9.9724448886)
        expect(values[1].to_f).to be_within(0.0001).of(9.9724517906)
      end

      it 'handles nil values in quiet mode' do
        nil_data = {
          growth_rates: [10.0],
          compound_annual_growth_rate: nil,
          average_growth_rate: nil
        }

        result = described_class.format_growth_rate(nil_data, format: 'quiet')
        expect(result.strip).to eq('')
      end

      it 'handles partial nil values' do
        partial_nil_data = {
          growth_rates: [10.0],
          compound_annual_growth_rate: 5.0,
          average_growth_rate: nil
        }

        result = described_class.format_growth_rate(partial_nil_data, format: 'quiet')
        expect(result.strip).to eq('5.0')
      end
    end

    context 'precision control' do
      it 'applies precision to default format' do
        result = described_class.format_growth_rate(growth_data, precision: 1)

        expect(result).to include('+10%')
        expect(result).to include('+9.9%')
      end

      it 'applies precision to JSON format' do
        result = described_class.format_growth_rate(growth_data, format: 'json', precision: 1)
        parsed = JSON.parse(result)

        analysis = parsed['growth_rate_analysis']
        expect(analysis['period_growth_rates']).to eq([10.0, 10.0, 9.9])
        expect(analysis['compound_annual_growth_rate']).to eq(10.0)
        expect(analysis['average_growth_rate']).to eq(10.0)
      end

      it 'applies precision to quiet format' do
        result = described_class.format_growth_rate(growth_data, format: 'quiet', precision: 1)
        values = result.strip.split

        expect(values[0]).to eq('10.0')
        expect(values[1]).to eq('10.0')
      end
    end
  end

  describe '.format_seasonal' do
    let(:seasonal_data) do
      {
        period: 4,
        seasonal_indices: [11.0, 21.0, 16.0, 26.0],
        seasonal_strength: 0.2751,
        has_seasonality: true
      }
    end

    context 'with default format' do
      it 'formats seasonal analysis with Japanese labels' do
        result = described_class.format_seasonal(seasonal_data)

        expect(result).to include('季節性分析結果:')
        expect(result).to include('検出周期: 4')
        expect(result).to include('季節指数: 11.0, 21.0, 16.0, 26.0')
        expect(result).to include('季節性強度: 0.2751')
        expect(result).to include('季節性判定: 季節性あり')
      end

      it 'formats seasonal analysis without seasonality' do
        no_seasonal_data = seasonal_data.merge(has_seasonality: false)
        result = described_class.format_seasonal(no_seasonal_data)

        expect(result).to include('季節性分析結果:')
        expect(result).to include('季節性判定: 季節性なし')
      end

      it 'handles nil data with error message' do
        result = described_class.format_seasonal(nil)

        expect(result).to eq('エラー: データが不十分です（季節性分析には最低4つの値が必要）')
      end
    end

    context 'with JSON format' do
      it 'formats seasonal analysis as structured JSON' do
        result = described_class.format_seasonal(seasonal_data, format: 'json', dataset_size: 8)
        parsed = JSON.parse(result)

        expect(parsed).to have_key('seasonal_analysis')
        analysis = parsed['seasonal_analysis']
        expect(analysis['period']).to eq(4)
        expect(analysis['seasonal_indices']).to eq([11.0, 21.0, 16.0, 26.0])
        expect(analysis['seasonal_strength']).to be_within(0.0001).of(0.2751)
        expect(analysis['has_seasonality']).to be true
        expect(parsed['dataset_size']).to eq(8)
      end

      it 'handles nil data with JSON error structure' do
        result = described_class.format_seasonal(nil, format: 'json', dataset_size: 3)
        parsed = JSON.parse(result)

        expect(parsed['seasonal_analysis']).to be_nil
        expect(parsed['error']).to eq('データが不十分です')
        expect(parsed['dataset_size']).to eq(3)
      end

      it 'includes metadata in JSON output' do
        result = described_class.format_seasonal(seasonal_data, format: 'json', dataset_size: 12)
        parsed = JSON.parse(result)

        expect(parsed).to have_key('dataset_size')
        expect(parsed['dataset_size']).to eq(12)
      end
    end

    context 'with quiet format' do
      it 'formats seasonal analysis as space-separated values' do
        result = described_class.format_seasonal(seasonal_data, format: 'quiet')
        values = result.strip.split

        expect(values.length).to eq(3)
        expect(values[0]).to eq('4') # period
        expect(values[1]).to eq('0.2751')   # strength
        expect(values[2]).to eq('true')     # has_seasonality
      end

      it 'handles seasonality false case' do
        no_seasonal_data = seasonal_data.merge(has_seasonality: false)
        result = described_class.format_seasonal(no_seasonal_data, format: 'quiet')
        values = result.strip.split

        expect(values[2]).to eq('false')
      end

      it 'handles nil data with empty output' do
        result = described_class.format_seasonal(nil, format: 'quiet')

        expect(result).to eq('')
      end
    end

    context 'with precision option' do
      it 'applies precision to default format' do
        result = described_class.format_seasonal(seasonal_data, precision: 2)

        expect(result).to include('季節指数: 11.0, 21.0, 16.0, 26.0')
        expect(result).to include('季節性強度: 0.28')
      end

      it 'applies precision to JSON format' do
        result = described_class.format_seasonal(seasonal_data, format: 'json', precision: 1)
        parsed = JSON.parse(result)

        analysis = parsed['seasonal_analysis']
        expect(analysis['seasonal_indices']).to eq([11.0, 21.0, 16.0, 26.0])
        expect(analysis['seasonal_strength']).to eq(0.3)
      end

      it 'applies precision to quiet format' do
        result = described_class.format_seasonal(seasonal_data, format: 'quiet', precision: 2)
        values = result.strip.split

        expect(values[0]).to eq('4')
        expect(values[1]).to eq('0.28')
        expect(values[2]).to eq('true')
      end
    end

    context 'with edge cases' do
      it 'handles zero seasonal strength' do
        zero_strength_data = seasonal_data.merge(seasonal_strength: 0.0, has_seasonality: false)
        result = described_class.format_seasonal(zero_strength_data)

        expect(result).to include('季節性強度: 0.0')
        expect(result).to include('季節性判定: 季節性なし')
      end

      it 'handles single seasonal index' do
        single_index_data = seasonal_data.merge(seasonal_indices: [15.0])
        result = described_class.format_seasonal(single_index_data)

        expect(result).to include('季節指数: 15.0')
      end

      it 'handles high precision values' do
        precise_data = seasonal_data.merge(seasonal_strength: 0.123456789)
        result = described_class.format_seasonal(precise_data, precision: 3)

        expect(result).to include('季節性強度: 0.123')
      end
    end
  end
end
