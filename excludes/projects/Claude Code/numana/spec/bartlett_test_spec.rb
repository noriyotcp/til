# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/numana'

RSpec.describe Numana do
  describe 'Bartlett Test for Variance Homogeneity' do
    describe '#bartlett_test' do
      context 'when groups have equal variances' do
        # Groups with approximately equal variances
        let(:group1) { [1, 2, 3, 4, 5] }        # variance ≈ 2.5
        let(:group2) { [2, 3, 4, 5, 6] }        # variance ≈ 2.5
        let(:group3) { [3, 4, 5, 6, 7] }        # variance ≈ 2.5
        let(:analyzer) { Numana.new([]) }

        it 'returns correct test structure' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result).to be_a(Hash)
          expect(result).to have_key(:test_type)
          expect(result).to have_key(:chi_square_statistic)
          expect(result).to have_key(:p_value)
          expect(result).to have_key(:degrees_of_freedom)
          expect(result).to have_key(:significant)
          expect(result).to have_key(:interpretation)
          expect(result).to have_key(:correction_factor)
          expect(result).to have_key(:pooled_variance)
        end

        it 'identifies equal variances correctly' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Bartlett Test')
          expect(result[:significant]).to be false
          expect(result[:p_value]).to be > 0.05
          expect(result[:degrees_of_freedom]).to eq(2) # k-1 = 3-1 = 2
        end

        it 'calculates chi-square statistic correctly' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:chi_square_statistic]).to be_a(Numeric)
          expect(result[:chi_square_statistic]).to be >= 0
        end

        it 'calculates correction factor correctly' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:correction_factor]).to be_a(Numeric)
          expect(result[:correction_factor]).to be > 1.0 # Should be greater than 1
        end

        it 'calculates pooled variance correctly' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:pooled_variance]).to be_a(Numeric)
          expect(result[:pooled_variance]).to be > 0
          expect(result[:pooled_variance]).to be_within(0.5).of(2.5) # Expected around 2.5
        end
      end

      context 'when groups have unequal variances' do
        # Groups with clearly different variances
        let(:group1) { [1, 1, 1, 1, 1] }        # variance = 0 (constant)
        let(:group2) { [1, 5, 9, 13, 17] }      # variance = 40 (high variability)
        let(:group3) { [10, 10.1, 9.9, 10.2, 9.8] } # variance ≈ 0.025 (low variability)
        let(:analyzer) { Numana.new([]) }

        it 'detects variance heterogeneity' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:significant]).to be true
          expect(result[:p_value]).to be < 0.05
          expect(result[:chi_square_statistic]).to be > 0
        end

        it 'provides correct interpretation for unequal variances' do
          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:interpretation]).to include('group variances are not equal')
        end
      end

      context 'with two groups' do
        let(:group1) { [1, 2, 3, 4, 5] }
        let(:group2) { [6, 7, 8, 9, 10] }
        let(:analyzer) { Numana.new([]) }

        it 'works with minimum number of groups' do
          result = analyzer.bartlett_test(group1, group2)

          expect(result).not_to be_nil
          expect(result[:degrees_of_freedom]).to eq(1) # k-1 = 2-1 = 1
        end
      end

      context 'with mathematical precision verification' do
        # Test case with known statistical properties
        let(:group1) { [1, 2, 3] }    # n=3, mean=2, variance=1
        let(:group2) { [4, 5, 6] }    # n=3, mean=5, variance=1
        let(:analyzer) { Numana.new([]) }

        it 'calculates statistics with mathematical accuracy' do
          result = analyzer.bartlett_test(group1, group2)

          # Pooled variance should be 1.0 since both groups have variance = 1
          expect(result[:pooled_variance]).to be_within(0.001).of(1.0)

          # For equal variances, chi-square should be small
          expect(result[:chi_square_statistic]).to be < 1.0
          expect(result[:p_value]).to be > 0.05
        end
      end

      context 'edge cases and error handling' do
        let(:analyzer) { Numana.new([]) }

        it 'returns nil for empty groups' do
          result = analyzer.bartlett_test([], [])
          expect(result).to be_nil
        end

        it 'returns nil for single group' do
          result = analyzer.bartlett_test([1, 2, 3])
          expect(result).to be_nil
        end

        it 'returns nil for nil input' do
          result = analyzer.bartlett_test(nil, nil)
          expect(result).to be_nil
        end

        it 'handles groups with single values' do
          # Groups with single values have undefined variance
          result = analyzer.bartlett_test([1], [2], [3])
          expect(result).not_to be_nil
          expect(result[:pooled_variance]).to eq(0.0)
        end

        it 'filters out empty groups correctly' do
          result = analyzer.bartlett_test([1, 2, 3], [], [4, 5, 6])
          expect(result).not_to be_nil
          expect(result[:degrees_of_freedom]).to eq(1) # Only 2 non-empty groups
        end
      end

      context 'statistical distributions and p-value accuracy' do
        let(:analyzer) { Numana.new([]) }

        it 'produces valid p-values between 0 and 1' do
          group1 = [1, 2, 3, 4, 5]
          group2 = [6, 7, 8, 9, 10]
          group3 = [11, 12, 13, 14, 15]

          result = analyzer.bartlett_test(group1, group2, group3)

          expect(result[:p_value]).to be >= 0.0
          expect(result[:p_value]).to be <= 1.0
        end

        it 'handles extreme variance differences' do
          group1 = [0.001, 0.001, 0.001]  # Very small variance
          group2 = [100, 200, 300]        # Large variance

          result = analyzer.bartlett_test(group1, group2)

          expect(result).not_to be_nil
          expect(result[:significant]).to be true
          expect(result[:p_value]).to be < 0.01 # Should be highly significant
        end
      end
    end
  end
end
