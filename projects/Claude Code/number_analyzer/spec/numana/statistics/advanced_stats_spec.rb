# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/numana/statistics/advanced_stats'
require_relative '../../../lib/numana/statistics/basic_stats'

RSpec.describe AdvancedStats do
  # Create a test class that includes both BasicStats and AdvancedStats
  let(:test_class) do
    Class.new do
      include BasicStats
      include AdvancedStats

      def initialize(numbers)
        @numbers = numbers
      end
    end
  end

  let(:analyzer) { test_class.new(numbers) }

  describe '#percentile' do
    context 'with normal data' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'calculates 50th percentile (median)' do
        expect(analyzer.percentile(50)).to eq(3)
      end

      it 'calculates 25th percentile' do
        expect(analyzer.percentile(25)).to eq(2)
      end

      it 'calculates 75th percentile' do
        expect(analyzer.percentile(75)).to eq(4)
      end

      it 'calculates 0th percentile' do
        expect(analyzer.percentile(0)).to eq(1)
      end

      it 'calculates 100th percentile' do
        expect(analyzer.percentile(100)).to eq(5)
      end
    end

    context 'with interpolation needed' do
      let(:numbers) { [1, 2, 3, 4] }

      it 'interpolates for 50th percentile' do
        expect(analyzer.percentile(50)).to eq(2.5)
      end

      it 'interpolates for 25th percentile' do
        expect(analyzer.percentile(25)).to eq(1.75)
      end
    end

    context 'with single element' do
      let(:numbers) { [42] }

      it 'returns the single element' do
        expect(analyzer.percentile(50)).to eq(42)
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns nil' do
        expect(analyzer.percentile(50)).to be_nil
      end
    end
  end

  describe '#quartiles' do
    context 'with normal data' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'returns all three quartiles' do
        expect(analyzer.quartiles).to eq({
                                           q1: 2,
                                           q2: 3,
                                           q3: 4
                                         })
      end
    end

    context 'with even number of elements' do
      let(:numbers) { [1, 2, 3, 4] }

      it 'returns interpolated quartiles' do
        expect(analyzer.quartiles).to eq({
                                           q1: 1.75,
                                           q2: 2.5,
                                           q3: 3.25
                                         })
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns nil values' do
        expect(analyzer.quartiles).to eq({
                                           q1: nil,
                                           q2: nil,
                                           q3: nil
                                         })
      end
    end
  end

  describe '#interquartile_range' do
    context 'with normal data' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'calculates IQR correctly' do
        expect(analyzer.interquartile_range).to eq(2)
      end
    end

    context 'with outliers' do
      let(:numbers) { [1, 2, 3, 4, 5, 100] }

      it 'calculates IQR correctly' do
        expect(analyzer.interquartile_range).to eq(2.5)
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns nil' do
        expect(analyzer.interquartile_range).to be_nil
      end
    end

    context 'with all same values' do
      let(:numbers) { [5, 5, 5, 5] }

      it 'returns 0' do
        expect(analyzer.interquartile_range).to eq(0)
      end
    end
  end

  describe '#outliers' do
    context 'with clear outliers' do
      let(:numbers) { [1, 2, 3, 4, 5, 100] }

      it 'identifies outliers' do
        expect(analyzer.outliers).to eq([100])
      end
    end

    context 'with multiple outliers' do
      let(:numbers) { [-50, 1, 2, 3, 4, 5, 100, 200] }

      it 'identifies all outliers' do
        expect(analyzer.outliers).to match_array([-50, 100, 200])
      end
    end

    context 'with no outliers' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'returns empty array' do
        expect(analyzer.outliers).to eq([])
      end
    end

    context 'with all same values' do
      let(:numbers) { [5, 5, 5, 5, 5] }

      it 'returns empty array' do
        expect(analyzer.outliers).to eq([])
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns empty array' do
        expect(analyzer.outliers).to eq([])
      end
    end

    context 'with too few elements' do
      let(:numbers) { [1, 2] }

      it 'returns empty array' do
        expect(analyzer.outliers).to eq([])
      end
    end
  end

  describe '#deviation_scores' do
    context 'with normal distribution' do
      let(:numbers) { [70, 80, 90, 100, 110] }

      it 'calculates deviation scores' do
        scores = analyzer.deviation_scores
        expect(scores.length).to eq(5)
        expect(scores[0]).to be < 50 # Below mean
        expect(scores[2]).to be_within(0.1).of(50) # At mean
        expect(scores[4]).to be > 50 # Above mean
      end
    end

    context 'with all same values' do
      let(:numbers) { [100, 100, 100, 100] }

      it 'returns all 50.0' do
        expect(analyzer.deviation_scores).to eq([50.0, 50.0, 50.0, 50.0])
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns empty array' do
        expect(analyzer.deviation_scores).to eq([])
      end
    end

    context 'with precise calculation' do
      let(:numbers) { [85, 90, 95, 100, 105, 110, 115] }

      it 'calculates accurate deviation scores' do
        scores = analyzer.deviation_scores
        # Mean = 100, StdDev = 12.247 (population)
        # The scores follow a linear pattern: 35, 40, 45, 50, 55, 60, 65
        expect(scores.first).to eq(35.0)
        expect(scores[3]).to eq(50.0)
        expect(scores.last).to eq(65.0)
        # Verify the pattern
        expect(scores).to eq([35.0, 40.0, 45.0, 50.0, 55.0, 60.0, 65.0])
      end
    end
  end
end
