# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/number_analyzer/statistics/hypothesis_testing'

# Test class that includes HypothesisTesting module
class TestHypothesisTesting
  include HypothesisTesting

  def initialize(numbers)
    @numbers = numbers
  end

  # Include required methods from other modules for testing
  def average_value
    return 0.0 if @numbers.empty?

    @numbers.sum.to_f / @numbers.length
  end

  def standard_normal_cdf(z)
    # Simple approximation for standard normal CDF
    return 0.0 if z <= -6
    return 1.0 if z >= 6

    # Abramowitz and Stegun approximation
    t = 1.0 / (1.0 + (0.2316419 * z.abs))
    d = 0.3989423 * Math.exp(-z * z / 2.0)
    prob = d * t * (0.3193815 + (t * (-0.3565638 + (t * (1.781478 + (t * (-1.821256 + (t * 1.330274))))))))

    z >= 0 ? 1.0 - prob : prob
  end
end

RSpec.describe HypothesisTesting do
  subject { TestHypothesisTesting.new(numbers) }

  describe '#t_test' do
    context 'with independent samples' do
      let(:numbers) { [1, 2, 3, 4, 5] }
      let(:other_data) { [6, 7, 8, 9, 10] }

      it 'performs independent t-test' do
        result = subject.t_test(other_data, type: :independent)
        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('independent')
        expect(result[:t_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect([true, false]).to include(result[:significant])
      end
    end

    context 'with paired samples' do
      let(:numbers) { [1, 2, 3, 4, 5] }
      let(:other_data) { [2, 4, 3, 6, 5] }

      it 'performs paired t-test' do
        result = subject.t_test(other_data, type: :paired)
        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('paired')
        expect(result[:t_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect([true, false]).to include(result[:significant])
      end
    end

    context 'with one sample' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'performs one-sample t-test' do
        result = subject.t_test(nil, type: :one_sample, population_mean: 2.5)
        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('one_sample')
        expect(result[:t_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect(result[:sample_mean]).to eq(3.0)
        expect(result[:population_mean]).to eq(2.5)
      end
    end

    context 'with invalid test type' do
      let(:numbers) { [1, 2, 3, 4, 5] }

      it 'raises ArgumentError for invalid type' do
        expect { subject.t_test([], type: :invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'with empty data' do
      let(:numbers) { [] }

      it 'returns nil for empty data' do
        expect(subject.t_test([1, 2, 3])).to be_nil
      end
    end
  end

  describe '#confidence_interval' do
    let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }

    context 'with valid confidence level' do
      it 'calculates 95% confidence interval' do
        result = subject.confidence_interval(95)
        expect(result).to be_a(Hash)
        expect(result[:confidence_level]).to eq(95)
        expect(result[:point_estimate]).to be_a(Numeric)
        expect(result[:lower_bound]).to be_a(Numeric)
        expect(result[:upper_bound]).to be_a(Numeric)
        expect(result[:lower_bound]).to be < result[:upper_bound]
      end

      it 'calculates 99% confidence interval' do
        result = subject.confidence_interval(99)
        expect(result[:confidence_level]).to eq(99)
        expect(result[:margin_of_error]).to be > 0
      end
    end

    context 'with invalid confidence level' do
      it 'raises ArgumentError for confidence level > 99' do
        expect { subject.confidence_interval(100) }.to raise_error(ArgumentError)
      end

      it 'raises ArgumentError for confidence level < 1' do
        expect { subject.confidence_interval(0) }.to raise_error(ArgumentError)
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [1] }

      it 'returns nil for single value' do
        expect(subject.confidence_interval(95)).to be_nil
      end
    end

    context 'with empty data' do
      let(:numbers) { [] }

      it 'returns nil for empty array' do
        expect(subject.confidence_interval(95)).to be_nil
      end
    end
  end

  describe '#chi_square_test' do
    context 'independence test with 2x2 contingency table' do
      let(:numbers) { [10, 20, 30, 40] }
      let(:contingency_table) { [[10, 20], [30, 40]] }

      it 'performs chi-square independence test' do
        result = subject.chi_square_test(contingency_table, type: :independence)
        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('independence')
        expect(result[:chi_square_statistic]).to be_a(Numeric)
        expect(result[:degrees_of_freedom]).to eq(1)
        expect(result[:p_value]).to be_a(Numeric)
        expect([true, false]).to include(result[:significant])
        expect(result[:cramers_v]).to be_a(Numeric)
      end
    end

    context 'goodness of fit test' do
      let(:numbers) { [8, 12, 10, 15, 9, 6] }
      let(:expected) { [10, 10, 10, 10, 10, 10] }

      it 'performs chi-square goodness of fit test' do
        result = subject.chi_square_test(expected, type: :goodness_of_fit)
        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('goodness_of_fit')
        expect(result[:chi_square_statistic]).to be_a(Numeric)
        expect(result[:degrees_of_freedom]).to eq(5)
        expect(result[:p_value]).to be_a(Numeric)
      end
    end

    context 'goodness of fit with uniform distribution' do
      let(:numbers) { [8, 12, 10, 15, 9, 6] }

      it 'assumes uniform distribution when expected is nil' do
        result = subject.chi_square_test(nil, type: :goodness_of_fit)
        expect(result[:expected_frequencies]).to all(eq(10.0))
      end
    end

    context 'with invalid test type' do
      let(:numbers) { [1, 2, 3, 4] }

      it 'raises ArgumentError for invalid type' do
        expect { subject.chi_square_test([], type: :invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'with insufficient data' do
      let(:numbers) { [1] }

      it 'returns nil for single value' do
        expect(subject.chi_square_test([[1]], type: :independence)).to be_nil
      end
    end
  end

  describe 'private helper methods' do
    let(:numbers) { [1, 2, 3, 4, 5] }

    describe '#calculate_sample_statistics' do
      it 'calculates correct sample statistics' do
        stats = subject.send(:calculate_sample_statistics, numbers)
        expect(stats[:n]).to eq(5)
        expect(stats[:mean]).to eq(3.0)
        expect(stats[:variance]).to eq(2.5)
      end
    end

    describe '#calculate_paired_differences' do
      it 'calculates paired differences correctly' do
        other_data = [2, 3, 4, 5, 6]
        differences = subject.send(:calculate_paired_differences, other_data)
        expect(differences).to eq([-1, -1, -1, -1, -1])
      end
    end

    describe '#invalid_data_for_independent_test?' do
      it 'returns true for nil data' do
        expect(subject.send(:invalid_data_for_independent_test?, nil)).to be true
      end

      it 'returns true for empty data' do
        expect(subject.send(:invalid_data_for_independent_test?, [])).to be true
      end

      it 'returns false for valid data' do
        expect(subject.send(:invalid_data_for_independent_test?, [1, 2, 3])).to be false
      end
    end

    describe '#invalid_data_for_paired_test?' do
      it 'returns true for mismatched lengths' do
        expect(subject.send(:invalid_data_for_paired_test?, [1, 2])).to be true
      end

      it 'returns false for matched lengths' do
        expect(subject.send(:invalid_data_for_paired_test?, [1, 2, 3, 4, 5])).to be false
      end
    end

    describe '#validate_expected_frequencies?' do
      it 'returns true when all frequencies >= 5' do
        frequencies = [5, 6, 7, 8, 9]
        expect(subject.send(:validate_expected_frequencies?, frequencies)).to be true
      end

      it 'returns false when frequencies < 5 and rule violation' do
        frequencies = [1, 2, 3, 4, 4]
        expect(subject.send(:validate_expected_frequencies?, frequencies)).to be false
      end

      it 'returns true when 80% >= 5 and min >= 1' do
        frequencies = [1, 5, 6, 7, 8] # 80% >= 5, min = 1
        expect(subject.send(:validate_expected_frequencies?, frequencies)).to be true
      end
    end

    describe '#calculate_chi_square_statistic' do
      it 'calculates chi-square statistic correctly' do
        observed = [10, 20, 30]
        expected = [15, 15, 30]
        chi_square = subject.send(:calculate_chi_square_statistic, observed, expected)
        expect(chi_square).to be_within(0.01).of(3.33)
      end

      it 'handles zero expected values' do
        observed = [10, 20]
        expected = [0, 20]
        chi_square = subject.send(:calculate_chi_square_statistic, observed, expected)
        expect(chi_square).to eq(0.0)
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'with very large numbers' do
      let(:numbers) { [1_000_000, 2_000_000, 3_000_000] }

      it 'handles large numbers correctly' do
        ci = subject.confidence_interval(95)
        expect(ci[:point_estimate]).to eq(2_000_000.0)
        expect(ci[:margin_of_error]).to be > 0
      end
    end

    context 'with decimal numbers' do
      let(:numbers) { [1.5, 2.5, 3.5, 4.5, 5.5] }

      it 'handles decimal numbers correctly' do
        result = subject.t_test([2.0, 4.0, 3.0, 6.0, 5.0], type: :paired)
        expect(result[:test_type]).to eq('paired')
        expect(result[:mean_difference]).to be_a(Numeric)
      end
    end

    context 'with negative numbers' do
      let(:numbers) { [-5, -3, -1, 1, 3] }

      it 'handles negative numbers correctly' do
        ci = subject.confidence_interval(95)
        expect(ci[:point_estimate]).to eq(-1.0)
        expect(ci[:lower_bound]).to be < ci[:upper_bound]
      end
    end

    context 'with identical values' do
      let(:numbers) { [5, 5, 5, 5, 5] }

      it 'handles identical values (zero variance)' do
        result = subject.t_test([6, 6, 6, 6, 6], type: :independent)
        # Should handle zero variance gracefully
        expect(result).to be_nil
      end
    end
  end
end
