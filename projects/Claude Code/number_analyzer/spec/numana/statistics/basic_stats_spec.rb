# frozen_string_literal: true

require_relative '../../../lib/numana/statistics/basic_stats'

# Test helper class to include BasicStats module
class TestAnalyzer
  include BasicStats

  def initialize(numbers)
    @numbers = numbers
  end
end

RSpec.describe BasicStats do
  let(:analyzer) { TestAnalyzer.new(numbers) }

  describe '#sum' do
    context 'with positive numbers' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'returns the correct sum' do
        expect(analyzer.sum).to eq(15)
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-1, -2, -3] }

      it 'returns the correct negative sum' do
        expect(analyzer.sum).to eq(-6)
      end
    end

    context 'with mixed positive and negative numbers' do
      let(:numbers) { [-5, 10, -3, 8] }

      it 'returns the correct sum' do
        expect(analyzer.sum).to eq(10)
      end
    end

    context 'with single value' do
      let(:numbers) { [42] }

      it 'returns the single value' do
        expect(analyzer.sum).to eq(42)
      end
    end

    context 'with zeros' do
      let(:numbers) { [0, 0, 0] }

      it 'returns zero' do
        expect(analyzer.sum).to eq(0)
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns zero' do
        expect(analyzer.sum).to eq(0)
      end
    end
  end

  describe '#mean' do
    context 'with positive numbers' do
      let(:numbers) { [2, 4, 6, 8] }

      it 'returns the correct mean' do
        expect(analyzer.mean).to eq(5.0)
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-2, -4, -6] }

      it 'returns the correct negative mean' do
        expect(analyzer.mean).to eq(-4.0)
      end
    end

    context 'with mixed numbers' do
      let(:numbers) { [-10, 0, 10] }

      it 'returns the correct mean' do
        expect(analyzer.mean).to eq(0.0)
      end
    end

    context 'with single value' do
      let(:numbers) { [7] }

      it 'returns the single value as mean' do
        expect(analyzer.mean).to eq(7.0)
      end
    end

    context 'with decimal result' do
      let(:numbers) { [1, 2, 3] }

      it 'returns floating point result' do
        expect(analyzer.mean).to eq(2.0)
      end
    end
  end

  describe '#mode' do
    context 'with single mode' do
      let(:numbers) { [1, 2, 2, 3, 4] }

      it 'returns array with single mode' do
        expect(analyzer.mode).to eq([2])
      end
    end

    context 'with multiple modes' do
      let(:numbers) { [1, 1, 2, 2, 3] }

      it 'returns array with multiple modes' do
        expect(analyzer.mode).to contain_exactly(1, 2)
      end
    end

    context 'with no mode (all unique)' do
      let(:numbers) { [1, 2, 3, 4] }

      it 'returns empty array' do
        expect(analyzer.mode).to eq([])
      end
    end

    context 'with all same values' do
      let(:numbers) { [5, 5, 5] }

      it 'returns single mode' do
        expect(analyzer.mode).to eq([5])
      end
    end

    context 'with single value' do
      let(:numbers) { [42] }

      it 'returns empty array (no frequency > 1)' do
        expect(analyzer.mode).to eq([])
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns empty array' do
        expect(analyzer.mode).to eq([])
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-1, -1, -2, -3] }

      it 'returns correct negative mode' do
        expect(analyzer.mode).to eq([-1])
      end
    end
  end

  describe '#variance' do
    context 'with known values' do
      let(:numbers) { [2, 4, 4, 4, 5, 5, 7, 9] }

      it 'calculates variance correctly' do
        expect(analyzer.variance).to be_within(0.01).of(4.0)
      end
    end

    context 'with simple values' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'calculates variance correctly' do
        expect(analyzer.variance).to be_within(0.01).of(2.0)
      end
    end

    context 'with identical values' do
      let(:numbers) { [3, 3, 3, 3] }

      it 'returns zero variance' do
        expect(analyzer.variance).to eq(0.0)
      end
    end

    context 'with single value' do
      let(:numbers) { [5] }

      it 'returns zero variance' do
        expect(analyzer.variance).to eq(0.0)
      end
    end

    context 'with empty array' do
      let(:numbers) { [] }

      it 'returns zero variance' do
        expect(analyzer.variance).to eq(0.0)
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-2, -1, 0, 1, 2] }

      it 'calculates variance correctly' do
        expect(analyzer.variance).to be_within(0.01).of(2.0)
      end
    end

    context 'with large numbers' do
      let(:numbers) { [100, 200, 300] }

      it 'handles large numbers correctly' do
        expect(analyzer.variance).to be_within(0.01).of(6666.67)
      end
    end
  end

  describe '#standard_deviation' do
    context 'with known values' do
      let(:numbers) { [2, 4, 4, 4, 5, 5, 7, 9] }

      it 'calculates standard deviation correctly' do
        expect(analyzer.standard_deviation).to be_within(0.01).of(2.0)
      end
    end

    context 'with simple values' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'calculates standard deviation correctly' do
        expect(analyzer.standard_deviation).to be_within(0.01).of(1.41)
      end
    end

    context 'with identical values' do
      let(:numbers) { [3, 3, 3, 3] }

      it 'returns zero standard deviation' do
        expect(analyzer.standard_deviation).to eq(0.0)
      end
    end

    context 'with single value' do
      let(:numbers) { [5] }

      it 'returns zero standard deviation' do
        expect(analyzer.standard_deviation).to eq(0.0)
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-2, -1, 0, 1, 2] }

      it 'calculates standard deviation correctly' do
        expect(analyzer.standard_deviation).to be_within(0.01).of(1.41)
      end
    end
  end

  describe 'mathematical relationships' do
    let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }

    it 'standard deviation equals square root of variance' do
      expect(analyzer.standard_deviation).to be_within(0.001).of(Math.sqrt(analyzer.variance))
    end

    it 'mean equals sum divided by count' do
      expect(analyzer.mean).to be_within(0.001).of(analyzer.sum.to_f / numbers.length)
    end
  end
end
