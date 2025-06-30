# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/number_analyzer/statistics/time_series_stats'

# Test class that includes TimeSeriesStats module
class TestTimeSeriesStats
  include TimeSeriesStats

  def initialize(numbers)
    @numbers = numbers
  end

  # Include required methods from other modules for testing
  def variance
    mean = @numbers.sum.to_f / @numbers.length
    @numbers.sum { |num| (num - mean)**2 } / @numbers.length
  end
end

RSpec.describe TimeSeriesStats do
  subject { TestTimeSeriesStats.new(numbers) }

  describe '#linear_trend' do
    context 'with valid ascending data' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'calculates correct linear trend' do
        result = subject.linear_trend
        expect(result).to be_a(Hash)
        expect(result[:slope]).to eq(1.0)
        expect(result[:intercept]).to eq(1.0)
        expect(result[:r_squared]).to eq(1.0)
        expect(result[:direction]).to eq('上昇トレンド')
      end
    end

    context 'with valid descending data' do
      let(:numbers) { [5, 4, 3, 2, 1] }

      it 'calculates correct descending trend' do
        result = subject.linear_trend
        expect(result[:slope]).to eq(-1.0)
        expect(result[:direction]).to eq('下降トレンド')
      end
    end

    context 'with flat data' do
      let(:numbers) { [3, 3, 3, 3, 3] }

      it 'identifies flat trend' do
        result = subject.linear_trend
        expect(result[:slope]).to eq(0.0)
        expect(result[:direction]).to eq('横ばい')
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [1] }

      it 'returns nil for single value' do
        expect(subject.linear_trend).to be_nil
      end
    end

    context 'with empty data' do
      let(:numbers) { [] }

      it 'returns nil for empty array' do
        expect(subject.linear_trend).to be_nil
      end
    end
  end

  describe '#moving_average' do
    let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }

    context 'with valid window size' do
      it 'calculates 3-period moving average correctly' do
        result = subject.moving_average(3)
        expected = [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
        expect(result).to eq(expected)
      end

      it 'calculates 5-period moving average correctly' do
        result = subject.moving_average(5)
        expected = [3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
        expect(result).to eq(expected)
      end
    end

    context 'with invalid window size' do
      it 'returns nil for zero window size' do
        expect(subject.moving_average(0)).to be_nil
      end

      it 'returns nil for negative window size' do
        expect(subject.moving_average(-1)).to be_nil
      end

      it 'returns nil for window size larger than data' do
        expect(subject.moving_average(15)).to be_nil
      end
    end

    context 'with empty data' do
      let(:numbers) { [] }

      it 'returns nil' do
        expect(subject.moving_average(3)).to be_nil
      end
    end
  end

  describe '#growth_rates' do
    context 'with positive growth' do
      let(:numbers) { [100, 110, 121, 133.1] }

      it 'calculates growth rates correctly' do
        result = subject.growth_rates
        expect(result.length).to eq(3)
        expect(result[0]).to eq(10.0)
        expect(result[1]).to eq(10.0)
        expect(result[2]).to eq(10.0)
      end
    end

    context 'with negative growth' do
      let(:numbers) { [100, 90, 81] }

      it 'calculates negative growth rates' do
        result = subject.growth_rates
        expect(result[0]).to eq(-10.0)
        expect(result[1]).to eq(-10.0)
      end
    end

    context 'with zero values' do
      let(:numbers) { [0, 10, 0] }

      it 'handles division by zero' do
        result = subject.growth_rates
        expect(result[0]).to eq(Float::INFINITY)
        expect(result[1]).to eq(-100.0)
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [100] }

      it 'returns empty array for single value' do
        expect(subject.growth_rates).to eq([])
      end
    end

    context 'with empty data' do
      let(:numbers) { [] }

      it 'returns empty array' do
        expect(subject.growth_rates).to eq([])
      end
    end
  end

  describe '#compound_annual_growth_rate' do
    context 'with positive growth' do
      let(:numbers) { [100, 110, 121, 133.1] }

      it 'calculates CAGR correctly' do
        result = subject.compound_annual_growth_rate
        expect(result).to be_within(0.1).of(10.0)
      end
    end

    context 'with negative growth' do
      let(:numbers) { [100, 50] }

      it 'calculates negative CAGR' do
        result = subject.compound_annual_growth_rate
        expect(result).to eq(-50.0)
      end
    end

    context 'with zero initial value' do
      let(:numbers) { [0, 100] }

      it 'returns nil' do
        expect(subject.compound_annual_growth_rate).to be_nil
      end
    end

    context 'with zero final value' do
      let(:numbers) { [100, 0] }

      it 'returns -100%' do
        expect(subject.compound_annual_growth_rate).to eq(-100.0)
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [100] }

      it 'returns nil' do
        expect(subject.compound_annual_growth_rate).to be_nil
      end
    end
  end

  describe '#average_growth_rate' do
    context 'with valid data' do
      let(:numbers) { [100, 110, 121, 133.1] }

      it 'calculates average growth rate' do
        result = subject.average_growth_rate
        expect(result).to eq(10.0)
      end
    end

    context 'with infinite values' do
      let(:numbers) { [0, 10, 20] }

      it 'excludes infinite values from calculation' do
        result = subject.average_growth_rate
        expect(result).to eq(100.0)
      end
    end

    context 'with all infinite values' do
      let(:numbers) { [0, 0, 0] }

      it 'returns 0.0 when all growth rates are 0' do
        expect(subject.average_growth_rate).to eq(0.0)
      end
    end
  end

  describe '#seasonal_decomposition' do
    context 'with seasonal data' do
      let(:numbers) { [10, 20, 15, 25, 12, 22, 17, 27, 14, 24, 19, 29] }

      it 'detects seasonal pattern with period 4' do
        result = subject.seasonal_decomposition(4)
        expect(result).to be_a(Hash)
        expect(result[:period]).to eq(4)
        expect(result[:seasonal_indices]).to be_an(Array)
        expect(result[:seasonal_indices].length).to eq(4)
        expect(result[:has_seasonality]).to be_truthy
      end
    end

    context 'with auto-detection' do
      let(:numbers) { [10, 20, 10, 20, 10, 20, 10, 20] }

      it 'automatically detects period' do
        result = subject.seasonal_decomposition
        expect(result).to be_a(Hash)
        expect(result[:period]).to eq(2)
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [1, 2, 3] }

      it 'returns nil for insufficient data' do
        expect(subject.seasonal_decomposition).to be_nil
      end
    end

    context 'with non-seasonal data' do
      let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8] }

      it 'returns nil for non-seasonal data' do
        expect(subject.seasonal_decomposition).to be_nil
      end
    end
  end

  describe '#detect_seasonal_period' do
    context 'with clear seasonal pattern' do
      let(:numbers) { [10, 20, 10, 20, 10, 20, 10, 20] }

      it 'detects period 2' do
        expect(subject.detect_seasonal_period).to eq(2)
      end
    end

    context 'with quarterly pattern' do
      let(:numbers) { [10, 15, 20, 25, 12, 17, 22, 27, 14, 19, 24, 29] }

      it 'detects seasonal period (may be 4 or 6 depending on algorithm)' do
        result = subject.detect_seasonal_period
        expect([4, 6]).to include(result)
      end
    end

    context 'with no seasonal pattern' do
      let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8] }

      it 'returns nil' do
        expect(subject.detect_seasonal_period).to be_nil
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [1, 2, 3] }

      it 'returns nil' do
        expect(subject.detect_seasonal_period).to be_nil
      end
    end
  end

  describe '#seasonal_strength' do
    context 'with seasonal data' do
      let(:numbers) { [10, 20, 10, 20, 10, 20, 10, 20] }

      it 'returns seasonal strength > 0' do
        result = subject.seasonal_strength
        expect(result).to be > 0.0
      end
    end

    context 'with non-seasonal data' do
      let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8] }

      it 'returns 0.0' do
        expect(subject.seasonal_strength).to eq(0.0)
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [1, 2, 3] }

      it 'returns 0.0' do
        expect(subject.seasonal_strength).to eq(0.0)
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'with very large numbers' do
      let(:numbers) { [1_000_000, 2_000_000, 3_000_000] }

      it 'handles large numbers correctly' do
        trend = subject.linear_trend
        expect(trend[:slope]).to eq(1_000_000.0)
        expect(trend[:direction]).to eq('上昇トレンド')
      end
    end

    context 'with decimal numbers' do
      let(:numbers) { [1.5, 2.5, 3.5, 4.5] }

      it 'handles decimal numbers correctly' do
        result = subject.moving_average(2)
        expect(result).to eq([2.0, 3.0, 4.0])
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-5, -3, -1, 1, 3] }

      it 'handles negative numbers correctly' do
        growth_rates = subject.growth_rates
        expect(growth_rates.length).to eq(4)
        expect(growth_rates[0]).to eq(-40.0)  # (-3 - (-5)) / -5 * 100 = -40%
      end
    end
  end
end