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
end
