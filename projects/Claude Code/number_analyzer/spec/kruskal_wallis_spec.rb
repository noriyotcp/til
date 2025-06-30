# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer'

RSpec.describe NumberAnalyzer do
  describe 'Kruskal-Wallis H Test' do
    describe '#kruskal_wallis_test' do
      context 'when groups have different medians' do
        # Groups with clearly different medians
        let(:group1) { [1, 2, 3, 4, 5] }        # median = 3
        let(:group2) { [6, 7, 8, 9, 10] }       # median = 8
        let(:group3) { [11, 12, 13, 14, 15] }   # median = 13
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'returns correct test structure' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          expect(result).to be_a(Hash)
          expect(result).to have_key(:test_type)
          expect(result).to have_key(:h_statistic)
          expect(result).to have_key(:p_value)
          expect(result).to have_key(:degrees_of_freedom)
          expect(result).to have_key(:significant)
          expect(result).to have_key(:interpretation)
          expect(result).to have_key(:group_sizes)
          expect(result).to have_key(:total_n)
        end

        it 'identifies different medians correctly' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
          expect(result[:h_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:degrees_of_freedom]).to eq(2)
          expect(result[:significant]).to be true
          expect(result[:group_sizes]).to eq([5, 5, 5])
          expect(result[:total_n]).to eq(15)
        end

        it 'calculates high H statistic for clearly different groups' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          # With perfectly separated groups, H should be very high
          expect(result[:h_statistic]).to be > 10
          expect(result[:p_value]).to be < 0.01
        end
      end

      context 'when groups have similar medians' do
        # Groups with similar medians (overlapping distributions)
        let(:group1) { [4, 5, 6, 7, 8] }        # median = 6
        let(:group2) { [5, 6, 7, 8, 9] }        # median = 7
        let(:group3) { [6, 7, 8, 9, 10] }       # median = 8
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'identifies similar medians correctly' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
          expect(result[:h_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:degrees_of_freedom]).to eq(2)
          # With overlapping groups, should not be significant
          expect(result[:significant]).to be false
          expect(result[:p_value]).to be > 0.05
        end

        it 'calculates low H statistic for similar groups' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          # With overlapping groups, H should be relatively low
          expect(result[:h_statistic]).to be < 5
        end
      end

      context 'with tied values' do
        # Groups with identical values (ties)
        let(:group1) { [1, 2, 2, 3, 4] }
        let(:group2) { [2, 3, 3, 4, 5] }
        let(:group3) { [3, 4, 4, 5, 6] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles tied values correctly' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
          expect(result[:h_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:degrees_of_freedom]).to eq(2)
          expect(result[:group_sizes]).to eq([5, 5, 5])
          expect(result[:total_n]).to eq(15)
        end

        it 'applies tie correction when necessary' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          # The result should still be mathematically valid
          expect(result[:h_statistic]).to be_finite
          expect(result[:p_value]).to be_finite
          expect(result[:p_value]).to be >= 0
          expect(result[:p_value]).to be <= 1
        end
      end

      context 'with unequal group sizes' do
        let(:group1) { [1, 2, 3] }              # n = 3
        let(:group2) { [4, 5, 6, 7] }           # n = 4
        let(:group3) { [8, 9, 10, 11, 12] }     # n = 5
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles unequal group sizes correctly' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
          expect(result[:h_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:degrees_of_freedom]).to eq(2)
          expect(result[:group_sizes]).to eq([3, 4, 5])
          expect(result[:total_n]).to eq(12)
          expect(result[:significant]).to be true # Clear separation should be significant
        end
      end

      context 'with exactly two groups' do
        let(:group1) { [1, 2, 3, 4, 5] }
        let(:group2) { [6, 7, 8, 9, 10] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'works with minimum number of groups' do
          result = analyzer.kruskal_wallis_test(group1, group2)

          expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
          expect(result[:h_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:degrees_of_freedom]).to eq(1)
          expect(result[:group_sizes]).to eq([5, 5])
          expect(result[:total_n]).to eq(10)
          expect(result[:significant]).to be true
        end
      end

      context 'with single values per group' do
        let(:group1) { [1] }
        let(:group2) { [5] }
        let(:group3) { [10] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles single values correctly' do
          result = analyzer.kruskal_wallis_test(group1, group2, group3)

          expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
          expect(result[:h_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:degrees_of_freedom]).to eq(2)
          expect(result[:group_sizes]).to eq([1, 1, 1])
          expect(result[:total_n]).to eq(3)
        end
      end

      context 'with error conditions' do
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'returns nil for single group' do
          result = analyzer.kruskal_wallis_test([1, 2, 3])
          expect(result).to be_nil
        end

        it 'returns nil for empty groups' do
          result = analyzer.kruskal_wallis_test([], [])
          expect(result).to be_nil
        end

        it 'returns nil for nil input' do
          result = analyzer.kruskal_wallis_test(nil)
          expect(result).to be_nil
        end

        it 'returns nil for non-array input' do
          result = analyzer.kruskal_wallis_test('not_an_array')
          expect(result).to be_nil
        end

        it 'handles mixed valid and empty groups' do
          # Empty arrays should be filtered out, leaving only valid groups
          result = analyzer.kruskal_wallis_test([1, 2, 3], [], [4, 5, 6])
          # After filtering empty arrays, we have 2 valid groups, so test should proceed
          expect(result).not_to be_nil
          expect(result[:group_sizes]).to eq([3, 3])
        end
      end

      context 'mathematical accuracy verification' do
        # Known test case for verification
        let(:group1) { [1, 2, 3] }
        let(:group2) { [4, 5, 6] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'produces mathematically accurate results' do
          result = analyzer.kruskal_wallis_test(group1, group2)

          # Manual calculation verification:
          # Ranks: [1, 2, 3] -> [1, 2, 3], [4, 5, 6] -> [4, 5, 6]
          # R1 = 1+2+3 = 6, R2 = 4+5+6 = 15
          # H = (12/(6*7)) * ((6²/3) + (15²/3)) - 3*7
          # H = (12/42) * (12 + 75) - 21 = (12/42) * 87 - 21
          # H ≈ 24.857 - 21 = 3.857

          expect(result[:h_statistic]).to be_within(0.001).of(3.857)
          expect(result[:degrees_of_freedom]).to eq(1)
        end
      end
    end
  end
end
