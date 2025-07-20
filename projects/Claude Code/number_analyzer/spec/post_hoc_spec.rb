# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/number_analyzer'

RSpec.describe Numana do
  describe 'Post-hoc analysis' do
    # Three groups with different means for testing
    let(:group1) { [1, 2, 3, 4, 5] }        # mean = 3
    let(:group2) { [6, 7, 8, 9, 10] }       # mean = 8
    let(:group3) { [11, 12, 13, 14, 15] }   # mean = 13

    describe '#post_hoc_analysis' do
      context 'when ANOVA shows significant differences' do
        let(:groups) { [group1, group2, group3] }

        it 'performs Tukey HSD test for all pairwise comparisons' do
          analyzer = Numana.new([])
          anova_result = analyzer.one_way_anova(*groups)

          # ANOVA should be significant
          expect(anova_result[:significant]).to be true

          # Perform post-hoc analysis
          post_hoc_result = analyzer.post_hoc_analysis(groups, method: :tukey)

          # Should have results for all pairwise comparisons
          expect(post_hoc_result[:method]).to eq('Tukey HSD')
          expect(post_hoc_result[:pairwise_comparisons]).to be_an(Array)
          expect(post_hoc_result[:pairwise_comparisons].length).to eq(3) # C(3,2) = 3

          # Each comparison should have required fields
          post_hoc_result[:pairwise_comparisons].each do |comparison|
            expect(comparison).to have_key(:groups)
            expect(comparison).to have_key(:mean_difference)
            expect(comparison).to have_key(:q_statistic)
            expect(comparison).to have_key(:p_value)
            expect(comparison).to have_key(:significant)

            # All comparisons should be significant for these clearly different groups
            expect(comparison[:significant]).to be true
          end
        end

        it 'performs Bonferroni correction for multiple comparisons' do
          analyzer = Numana.new([])
          post_hoc_result = analyzer.post_hoc_analysis([group1, group2, group3], method: :bonferroni)

          expect(post_hoc_result[:method]).to eq('Bonferroni')
          expect(post_hoc_result[:adjusted_alpha]).to eq(0.05 / 3) # alpha / number of comparisons

          # Each comparison should use adjusted p-value threshold
          post_hoc_result[:pairwise_comparisons].each do |comparison|
            expect(comparison).to have_key(:t_statistic)
            expect(comparison).to have_key(:p_value)
            expect(comparison).to have_key(:adjusted_p_value)
            expect(comparison).to have_key(:significant)
          end
        end
      end

      context 'with no significant ANOVA results' do
        # Three groups with very similar means and higher variance
        let(:similar_group1) { [4, 5, 6, 5, 4, 5, 6, 5] }     # mean = 5
        let(:similar_group2) { [5, 4, 6, 5, 5, 4, 6, 5] }     # mean = 5
        let(:similar_group3) { [4, 6, 5, 5, 5, 5, 5, 5] }     # mean = 5

        it 'still performs post-hoc analysis when requested' do
          analyzer = Numana.new([])
          post_hoc_result = analyzer.post_hoc_analysis([similar_group1, similar_group2, similar_group3], method: :tukey)

          expect(post_hoc_result[:warning]).to include('ANOVA was not significant')
          expect(post_hoc_result[:pairwise_comparisons]).to be_an(Array)

          # Most comparisons should not be significant
          significant_count = post_hoc_result[:pairwise_comparisons].count { |c| c[:significant] }
          expect(significant_count).to be <= 1
        end
      end

      context 'with invalid input' do
        it 'returns nil for less than 2 groups' do
          analyzer = Numana.new([])
          expect(analyzer.post_hoc_analysis([group1], method: :tukey)).to be_nil
        end

        it 'returns nil for invalid method' do
          analyzer = Numana.new([])
          expect(analyzer.post_hoc_analysis([group1, group2], method: :invalid)).to be_nil
        end
      end
    end

    describe '#tukey_hsd' do
      it 'calculates correct q-statistic for pairwise comparison' do
        analyzer = Numana.new([])
        q_stat = analyzer.send(:calculate_tukey_q_statistic, group1, group2)

        # Manual calculation: q = |mean1 - mean2| / sqrt(MSE/n)
        # For groups with means 3 and 8, difference is 5
        # This is a private method test, so we check reasonable range
        expect(q_stat).to be > 0
        expect(q_stat).to be_finite
      end

      it 'determines critical q-value based on groups and total observations' do
        analyzer = Numana.new([])
        critical_q = analyzer.send(:tukey_critical_value, 3, 15, 0.05) # 3 groups, 15 total obs, alpha=0.05

        # Should return a reasonable critical value
        expect(critical_q).to be > 3.0
        expect(critical_q).to be < 5.0
      end
    end

    describe '#bonferroni_correction' do
      it 'adjusts p-values for multiple comparisons' do
        analyzer = Numana.new([])
        original_p_values = [0.01, 0.03, 0.04]
        adjusted = analyzer.send(:bonferroni_adjust, original_p_values)

        # Each p-value should be multiplied by number of comparisons
        expect(adjusted[0]).to eq(0.03) # 0.01 * 3
        expect(adjusted[1]).to eq(0.09) # 0.03 * 3
        expect(adjusted[2]).to eq(0.12) # 0.04 * 3
      end

      it 'caps adjusted p-values at 1.0' do
        analyzer = Numana.new([])
        original_p_values = [0.5, 0.6]
        adjusted = analyzer.send(:bonferroni_adjust, original_p_values)

        # Should not exceed 1.0
        expect(adjusted[0]).to eq(1.0)
        expect(adjusted[1]).to eq(1.0)
      end
    end
  end
end
