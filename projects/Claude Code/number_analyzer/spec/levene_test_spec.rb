# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer'

RSpec.describe Numana do
  describe 'Levene Test for Variance Homogeneity' do
    describe '#levene_test' do
      context 'when groups have equal variances' do
        # Groups with approximately equal variances
        let(:group1) { [1, 2, 3, 4, 5] }        # variance ≈ 2.5
        let(:group2) { [2, 3, 4, 5, 6] }        # variance ≈ 2.5
        let(:group3) { [3, 4, 5, 6, 7] }        # variance ≈ 2.5
        let(:analyzer) { Numana.new([]) }

        it 'returns correct test structure' do
          result = analyzer.levene_test(group1, group2, group3)

          expect(result).to be_a(Hash)
          expect(result).to have_key(:test_type)
          expect(result).to have_key(:f_statistic)
          expect(result).to have_key(:p_value)
          expect(result).to have_key(:degrees_of_freedom)
          expect(result).to have_key(:significant)
          expect(result).to have_key(:interpretation)
        end

        it 'identifies equal variances correctly' do
          result = analyzer.levene_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Levene Test (Brown-Forsythe)')
          expect(result[:significant]).to be false
          expect(result[:p_value]).to be > 0.05
          expect(result[:degrees_of_freedom]).to eq([2, 12]) # k-1=2, N-k=15-3=12
        end

        it 'calculates F-statistic correctly' do
          result = analyzer.levene_test(group1, group2, group3)

          expect(result[:f_statistic]).to be_a(Numeric)
          expect(result[:f_statistic]).to be >= 0
        end
      end

      context 'when groups have unequal variances' do
        # Groups with clearly different variances
        let(:group1) { [1, 1, 1, 1, 1] }        # variance = 0 (constant)
        let(:group2) { [1, 5, 9, 13, 17] }      # variance = 40 (high variability)
        let(:group3) { [10, 10.1, 9.9, 10.2, 9.8] } # variance ≈ 0.025 (low variability)
        let(:analyzer) { Numana.new([]) }

        it 'detects unequal variances' do
          result = analyzer.levene_test(group1, group2, group3)

          expect(result[:significant]).to be true
          expect(result[:p_value]).to be < 0.05
          expect(result[:f_statistic]).to be > 1
        end

        it 'provides appropriate interpretation' do
          result = analyzer.levene_test(group1, group2, group3)

          expect(result[:interpretation]).to include('Homogeneity of variance hypothesis is rejected')
        end
      end

      context 'with edge cases' do
        let(:analyzer) { Numana.new([]) }

        it 'handles minimum valid input (2 groups)' do
          group1 = [1, 2, 3]
          group2 = [4, 5, 6]

          result = analyzer.levene_test(group1, group2)

          expect(result).not_to be_nil
          expect(result[:degrees_of_freedom]).to eq([1, 4]) # k-1=1, N-k=6-2=4
        end

        it 'returns nil for insufficient groups' do
          group1 = [1, 2, 3]

          result = analyzer.levene_test(group1)

          expect(result).to be_nil
        end

        it 'returns nil for empty groups' do
          result = analyzer.levene_test([], [])

          expect(result).to be_nil
        end

        it 'handles groups with single values' do
          group1 = [5]
          group2 = [10]
          group3 = [15]

          result = analyzer.levene_test(group1, group2, group3)

          expect(result).not_to be_nil
          # With single values, all deviations are 0, so F should be 0/0 -> handled appropriately
        end

        it 'handles identical groups' do
          group1 = [5, 5, 5]
          group2 = [5, 5, 5]
          group3 = [5, 5, 5]

          result = analyzer.levene_test(group1, group2, group3)

          expect(result).not_to be_nil
          expect(result[:f_statistic]).to eq(0.0) # No variance in any group
        end
      end

      context 'with realistic data scenarios' do
        let(:analyzer) { Numana.new([]) }

        it 'handles small effect sizes (borderline significance)' do
          # Groups with slightly different variances
          group1 = [10, 12, 14, 16, 18]       # variance = 10
          group2 = [10, 11, 15, 19, 20]       # variance ≈ 20
          group3 = [10, 13, 16, 17, 19]       # variance ≈ 12

          result = analyzer.levene_test(group1, group2, group3)

          expect(result[:p_value]).to be_between(0.001, 0.50)
          expect(result[:f_statistic]).to be_between(0.1, 10.0)
        end

        it 'handles outliers robustly (Brown-Forsythe advantage)' do
          # Groups where mean-based Levene would be affected by outliers
          group1 = [1, 2, 3, 4, 5]
          group2 = [2, 3, 4, 5, 6]
          group3 = [3, 4, 5, 6, 100] # outlier in group3

          result = analyzer.levene_test(group1, group2, group3)

          # Brown-Forsythe should be more robust than mean-based
          expect(result).not_to be_nil
          expect(result[:p_value]).to be_a(Numeric)
        end
      end

      context 'mathematical accuracy validation' do
        let(:analyzer) { Numana.new([]) }

        it 'calculates degrees of freedom correctly' do
          # 4 groups, total 20 observations
          group1 = [1, 2, 3, 4, 5]          # n1 = 5
          group2 = [6, 7, 8, 9]             # n2 = 4
          group3 = [10, 11, 12, 13, 14, 15] # n3 = 6
          group4 = [16, 17, 18, 19, 20]     # n4 = 5

          result = analyzer.levene_test(group1, group2, group3, group4)

          expect(result[:degrees_of_freedom]).to eq([3, 16]) # k-1=3, N-k=20-4=16
        end

        it 'ensures p-value is within valid range' do
          group1 = [1, 2, 3, 4, 5]
          group2 = [6, 7, 8, 9, 10]

          result = analyzer.levene_test(group1, group2)

          expect(result[:p_value]).to be_between(0.0, 1.0)
        end

        it 'ensures F-statistic is non-negative' do
          group1 = [1, 2, 3, 4, 5]
          group2 = [6, 7, 8, 9, 10]
          group3 = [11, 12, 13, 14, 15]

          result = analyzer.levene_test(group1, group2, group3)

          expect(result[:f_statistic]).to be >= 0
        end
      end
    end
  end
end
