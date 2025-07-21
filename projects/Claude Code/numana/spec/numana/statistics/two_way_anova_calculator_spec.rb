# frozen_string_literal: true

require 'spec_helper'
require 'numana/statistics/two_way_anova_calculator'

RSpec.describe Numana::Statistics::TwoWayAnovaCalculator do
  describe '#perform' do
    context 'with invalid input' do
      it 'returns nil if factor_a_levels is not an array' do
        calculator = described_class.new('not an array', [1, 2], [1, 2])
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if factor_b_levels is not an array' do
        calculator = described_class.new([1, 2], 'not an array', [1, 2])
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if values is not an array' do
        calculator = described_class.new([1, 2], [1, 2], 'not an array')
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if array lengths do not match' do
        calculator = described_class.new([1, 2, 3], [1, 2], [1, 2, 3])
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if arrays are empty' do
        calculator = described_class.new([], [], [])
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if there are less than two levels for factor A' do
        calculator = described_class.new([1, 1], [1, 2], [1, 2])
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if there are less than two levels for factor B' do
        calculator = described_class.new([1, 2], [1, 1], [1, 2])
        expect(calculator.perform).to be_nil
      end

      it 'returns nil if values are not numeric' do
        calculator = described_class.new([1, 2], [1, 2], [1, 'a'])
        expect(calculator.perform).to be_nil
      end
    end

    context 'with valid input' do
      let(:factor_a) { %w[A1 A1 A1 A2 A2 A2] }
      let(:factor_b) { %w[B1 B1 B2 B2 B1 B1] }
      let(:values) { [10, 12, 15, 17, 20, 22] }

      it 'calculates the two-way ANOVA correctly' do
        calculator = described_class.new(factor_a, factor_b, values)
        result = calculator.perform

        expect(result).to be_a(Hash)
        expect(result[:main_effects][:factor_a][:f_statistic]).to be_within(0.001).of(40.333)
        expect(result[:main_effects][:factor_b][:p_value]).to be_within(0.001).of(1.0)
        expect(result[:interaction][:significant]).to be(true)
      end
    end
  end
end
