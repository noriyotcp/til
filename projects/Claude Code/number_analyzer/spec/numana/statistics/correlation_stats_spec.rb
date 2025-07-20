# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/numana/statistics/correlation_stats'

# Simple test class
class TestCorrelationClass
  include CorrelationStats

  def initialize(numbers)
    @numbers = numbers
  end
end

RSpec.describe CorrelationStats do
  let(:test_instance) { TestCorrelationClass.new([1, 2, 3, 4, 5]) }

  describe '#correlation' do
    context 'with valid datasets' do
      it 'calculates perfect positive correlation' do
        other_dataset = [2, 4, 6, 8, 10]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(1.0)
      end

      it 'calculates perfect negative correlation' do
        other_dataset = [10, 8, 6, 4, 2]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(-1.0)
      end

      it 'calculates no correlation' do
        other_dataset = [3, 3, 3, 3, 3]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(0.0)
      end

      it 'calculates moderate positive correlation' do
        other_dataset = [1, 3, 2, 5, 4]
        result = test_instance.correlation(other_dataset)
        expect(result).to be_between(0.5, 0.9)
      end

      it 'calculates correlation with decimal values' do
        test_instance = TestCorrelationClass.new([1.1, 2.2, 3.3, 4.4, 5.5])
        other_dataset = [2.2, 4.4, 6.6, 8.8, 11.0]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(1.0)
      end

      it 'handles identical datasets' do
        other_dataset = [1, 2, 3, 4, 5]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(1.0)
      end

      it 'calculates correlation with negative values' do
        test_instance = TestCorrelationClass.new([-1, -2, -3, -4, -5])
        other_dataset = [-2, -4, -6, -8, -10]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(1.0)
      end

      it 'handles mixed positive and negative values' do
        test_instance = TestCorrelationClass.new([-2, -1, 0, 1, 2])
        other_dataset = [-4, -2, 0, 2, 4]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(1.0)
      end
    end

    context 'with edge cases' do
      it 'returns nil for empty current dataset' do
        test_instance = TestCorrelationClass.new([])
        other_dataset = [1, 2, 3]
        result = test_instance.correlation(other_dataset)
        expect(result).to be_nil
      end

      it 'returns nil for empty other dataset' do
        other_dataset = []
        result = test_instance.correlation(other_dataset)
        expect(result).to be_nil
      end

      it 'returns nil for mismatched dataset lengths' do
        other_dataset = [1, 2, 3]
        result = test_instance.correlation(other_dataset)
        expect(result).to be_nil
      end

      it 'returns 0.0 when one dataset has zero variance' do
        other_dataset = [2, 2, 2, 2, 2]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(0.0)
      end

      it 'handles single value datasets' do
        test_instance = TestCorrelationClass.new([5])
        other_dataset = [10]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(0.0)
      end

      it 'handles datasets with duplicate values' do
        test_instance = TestCorrelationClass.new([1, 1, 2, 2, 3])
        other_dataset = [2, 2, 4, 4, 6]
        result = test_instance.correlation(other_dataset)
        expect(result).to eq(1.0)
      end
    end

    context 'with precision' do
      it 'rounds result to 10 decimal places' do
        test_instance = TestCorrelationClass.new([1, 2, 3])
        other_dataset = [1.1, 2.1, 2.9]
        result = test_instance.correlation(other_dataset)
        expect(result.to_s.split('.')[1]&.length).to be <= 10
      end
    end
  end

  describe '#interpret_correlation' do
    context 'with strong correlations' do
      it 'interprets strong positive correlation' do
        result = test_instance.interpret_correlation(0.9)
        expect(result).to eq('Strong positive correlation')
      end

      it 'interprets strong negative correlation' do
        result = test_instance.interpret_correlation(-0.85)
        expect(result).to eq('Strong negative correlation')
      end

      it 'interprets perfect positive correlation' do
        result = test_instance.interpret_correlation(1.0)
        expect(result).to eq('Strong positive correlation')
      end

      it 'interprets perfect negative correlation' do
        result = test_instance.interpret_correlation(-1.0)
        expect(result).to eq('Strong negative correlation')
      end
    end

    context 'with moderate correlations' do
      it 'interprets moderate positive correlation' do
        result = test_instance.interpret_correlation(0.6)
        expect(result).to eq('Moderate positive correlation')
      end

      it 'interprets moderate negative correlation' do
        result = test_instance.interpret_correlation(-0.7)
        expect(result).to eq('Moderate negative correlation')
      end

      it 'interprets boundary values' do
        result = test_instance.interpret_correlation(0.5)
        expect(result).to eq('Moderate positive correlation')
      end
    end

    context 'with weak correlations' do
      it 'interprets weak positive correlation' do
        result = test_instance.interpret_correlation(0.4)
        expect(result).to eq('Weak positive correlation')
      end

      it 'interprets weak negative correlation' do
        result = test_instance.interpret_correlation(-0.35)
        expect(result).to eq('Weak negative correlation')
      end

      it 'interprets boundary values' do
        result = test_instance.interpret_correlation(0.3)
        expect(result).to eq('Weak positive correlation')
      end
    end

    context 'with no correlation' do
      it 'interprets no correlation' do
        result = test_instance.interpret_correlation(0.0)
        expect(result).to eq('Very weak correlation')
      end

      it 'interprets very weak positive correlation' do
        result = test_instance.interpret_correlation(0.1)
        expect(result).to eq('Very weak correlation')
      end

      it 'interprets very weak negative correlation' do
        result = test_instance.interpret_correlation(-0.2)
        expect(result).to eq('Very weak correlation')
      end
    end
  end
end
