# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer'

RSpec.describe NumberAnalyzer do
  describe 'Mann-Whitney U Test' do
    describe '#mann_whitney_u_test' do
      context 'when groups have clear differences' do
        # Groups with clearly different distributions
        let(:group1) { [1, 2, 3, 4, 5] }        # lower values
        let(:group2) { [6, 7, 8, 9, 10] }       # higher values
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'returns correct test structure' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result).to be_a(Hash)
          expect(result).to have_key(:test_type)
          expect(result).to have_key(:u_statistic)
          expect(result).to have_key(:u1)
          expect(result).to have_key(:u2)
          expect(result).to have_key(:z_statistic)
          expect(result).to have_key(:p_value)
          expect(result).to have_key(:significant)
          expect(result).to have_key(:interpretation)
          expect(result).to have_key(:effect_size)
          expect(result).to have_key(:group_sizes)
          expect(result).to have_key(:rank_sums)
          expect(result).to have_key(:total_n)
        end

        it 'identifies clear differences correctly' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result[:test_type]).to eq('Mann-Whitney U Test')
          expect(result[:u_statistic]).to eq(0.0) # Perfect separation should give U=0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:significant]).to be true
          expect(result[:group_sizes]).to eq([5, 5])
          expect(result[:total_n]).to eq(10)
        end

        it 'calculates correct U statistics for perfect separation' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # With perfect separation: group1 gets ranks 1-5, group2 gets ranks 6-10
          # R1 = 1+2+3+4+5 = 15, R2 = 6+7+8+9+10 = 40
          # U1 = 5*5 + 5*6/2 - 15 = 25 + 15 - 15 = 25
          # U2 = 5*5 + 5*6/2 - 40 = 25 + 15 - 40 = 0
          # U = min(25, 0) = 0

          expect(result[:u_statistic]).to eq(0.0)
          expect(result[:u1]).to eq(25.0)
          expect(result[:u2]).to eq(0.0)
          expect(result[:rank_sums]).to eq([15.0, 40.0])
          expect(result[:significant]).to be true
        end
      end

      context 'when groups have similar distributions' do
        # Groups with overlapping distributions
        let(:group1) { [4, 5, 6, 7, 8] }        # overlapping values
        let(:group2) { [5, 6, 7, 8, 9] }        # overlapping values
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'identifies similar distributions correctly' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result[:test_type]).to eq('Mann-Whitney U Test')
          expect(result[:u_statistic]).to be > 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:group_sizes]).to eq([5, 5])
          expect(result[:total_n]).to eq(10)
          # With overlapping groups, should not be significant
          expect(result[:significant]).to be false
        end

        it 'calculates reasonable U statistic for overlapping groups' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # U should be closer to the expected value under null hypothesis
          expected_u = (5 * 5) / 2.0 # = 12.5
          expect(result[:u_statistic]).to be_within(5).of(expected_u)
        end
      end

      context 'with tied values' do
        # Groups with identical values (ties)
        let(:group1) { [1, 2, 2, 3, 4] }
        let(:group2) { [2, 3, 3, 4, 5] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles tied values correctly' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result[:test_type]).to eq('Mann-Whitney U Test')
          expect(result[:u_statistic]).to be >= 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:group_sizes]).to eq([5, 5])
          expect(result[:total_n]).to eq(10)
        end

        it 'applies tie correction when necessary' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # The result should still be mathematically valid
          expect(result[:u_statistic]).to be_finite
          expect(result[:z_statistic]).to be_finite
          expect(result[:p_value]).to be_finite
          expect(result[:p_value]).to be >= 0
          expect(result[:p_value]).to be <= 1
        end
      end

      context 'with unequal group sizes' do
        let(:group1) { [1, 2, 3] }              # n = 3
        let(:group2) { [4, 5, 6, 7, 8] }        # n = 5
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles unequal group sizes correctly' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result[:test_type]).to eq('Mann-Whitney U Test')
          expect(result[:u_statistic]).to be >= 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:group_sizes]).to eq([3, 5])
          expect(result[:total_n]).to eq(8)
          expect(result[:significant]).to be true # Clear separation should be significant
        end

        it 'calculates correct U statistics for unequal sizes' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # With clear separation: group1 gets ranks 1-3, group2 gets ranks 4-8
          # R1 = 1+2+3 = 6, R2 = 4+5+6+7+8 = 30
          # U1 = 3*5 + 3*4/2 - 6 = 15 + 6 - 6 = 15
          # U2 = 3*5 + 5*6/2 - 30 = 15 + 15 - 30 = 0
          # U = min(15, 0) = 0

          expect(result[:u_statistic]).to eq(0.0)
          expect(result[:rank_sums]).to eq([6.0, 30.0])
        end
      end

      context 'with small sample sizes' do
        let(:group1) { [1, 2] }
        let(:group2) { [4, 5] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles small samples correctly' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result[:test_type]).to eq('Mann-Whitney U Test')
          expect(result[:u_statistic]).to be >= 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:group_sizes]).to eq([2, 2])
          expect(result[:total_n]).to eq(4)
          # Uses exact test approximation for small samples
        end
      end

      context 'with single values per group' do
        let(:group1) { [1] }
        let(:group2) { [5] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'handles single values correctly' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          expect(result[:test_type]).to eq('Mann-Whitney U Test')
          expect(result[:u_statistic]).to be >= 0
          expect(result[:p_value]).to be_between(0, 1)
          expect(result[:group_sizes]).to eq([1, 1])
          expect(result[:total_n]).to eq(2)
        end
      end

      context 'with error conditions' do
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'returns nil for nil groups' do
          result = analyzer.mann_whitney_u_test(nil, [1, 2, 3])
          expect(result).to be_nil

          result = analyzer.mann_whitney_u_test([1, 2, 3], nil)
          expect(result).to be_nil

          result = analyzer.mann_whitney_u_test(nil, nil)
          expect(result).to be_nil
        end

        it 'returns nil for empty groups' do
          result = analyzer.mann_whitney_u_test([], [1, 2, 3])
          expect(result).to be_nil

          result = analyzer.mann_whitney_u_test([1, 2, 3], [])
          expect(result).to be_nil

          result = analyzer.mann_whitney_u_test([], [])
          expect(result).to be_nil
        end

        it 'returns nil for non-array input' do
          result = analyzer.mann_whitney_u_test('not_an_array', [1, 2, 3])
          expect(result).to be_nil

          result = analyzer.mann_whitney_u_test([1, 2, 3], 'not_an_array')
          expect(result).to be_nil
        end
      end

      context 'mathematical accuracy verification' do
        # Known test case for verification
        let(:group1) { [1, 2, 3, 4] }
        let(:group2) { [5, 6, 7, 8] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'produces mathematically accurate results' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # Manual calculation verification:
          # Ranks: [1, 2, 3, 4] -> [1, 2, 3, 4], [5, 6, 7, 8] -> [5, 6, 7, 8]
          # R1 = 1+2+3+4 = 10, R2 = 5+6+7+8 = 26
          # U1 = 4*4 + 4*5/2 - 10 = 16 + 10 - 10 = 16
          # U2 = 4*4 + 4*5/2 - 26 = 16 + 10 - 26 = 0
          # U = min(16, 0) = 0

          expect(result[:u_statistic]).to eq(0.0)
          expect(result[:u1]).to eq(16.0)
          expect(result[:u2]).to eq(0.0)
          expect(result[:rank_sums]).to eq([10.0, 26.0])
        end

        it 'calculates correct effect size' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # Effect size r = |z| / sqrt(N)
          # With perfect separation, effect size should be large
          expect(result[:effect_size]).to be > 0.5 # Large effect
        end
      end

      context 'with identical distributions' do
        let(:group1) { [1, 2, 3, 4, 5] }
        let(:group2) { [1, 2, 3, 4, 5] }
        let(:analyzer) { NumberAnalyzer.new([]) }

        it 'correctly identifies no difference' do
          result = analyzer.mann_whitney_u_test(group1, group2)

          # With identical distributions, U should be close to expected value
          expected_u = (5 * 5) / 2.0 # = 12.5
          expect(result[:u_statistic]).to be_within(2).of(expected_u)
          expect(result[:significant]).to be false
          expect(result[:p_value]).to be > 0.05
        end
      end
    end
  end
end
