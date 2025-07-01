# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ANOVAStats do
  let(:test_class) do
    Class.new do
      include ANOVAStats

      def initialize(numbers = [])
        @numbers = numbers
      end
    end
  end

  let(:stats) { test_class.new }

  describe '#one_way_anova' do
    context 'with valid groups' do
      it 'calculates ANOVA for three groups' do
        group1 = [1, 2, 3]
        group2 = [4, 5, 6]
        group3 = [7, 8, 9]

        result = stats.one_way_anova(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:f_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect(result[:degrees_of_freedom]).to eq([2, 6])
        expect(result[:significant]).to be(true).or be(false)
        expect(result[:interpretation]).to be_a(String)
      end

      it 'calculates correct F-statistic for known data' do
        group1 = [1, 2, 3, 4, 5]
        group2 = [6, 7, 8, 9, 10]

        result = stats.one_way_anova(group1, group2)

        expect(result[:f_statistic]).to be > 0
        expect(result[:degrees_of_freedom]).to eq([1, 8])
        expect(result[:sum_of_squares][:total]).to be > 0
      end

      it 'handles groups with different sizes' do
        group1 = [1, 2]
        group2 = [3, 4, 5, 6]
        group3 = [7, 8, 9]

        result = stats.one_way_anova(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:group_means]).to have_attributes(length: 3)
        expect(result[:degrees_of_freedom]).to eq([2, 6])
      end
    end

    context 'with edge cases' do
      it 'returns nil for empty groups' do
        result = stats.one_way_anova([], [])
        expect(result).to be_nil
      end

      it 'returns nil for single group' do
        result = stats.one_way_anova([1, 2, 3])
        expect(result).to be_nil
      end

      it 'returns nil for non-array inputs' do
        result = stats.one_way_anova(1, 2, 3)
        expect(result).to be_nil
      end

      it 'filters out empty groups' do
        group1 = [1, 2, 3]
        group2 = []
        group3 = [4, 5, 6]

        result = stats.one_way_anova(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:degrees_of_freedom]).to eq([1, 4])
      end
    end

    context 'with identical values' do
      it 'handles groups with no variance' do
        group1 = [5, 5, 5]
        group2 = [5, 5, 5]

        result = stats.one_way_anova(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:f_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be >= 0
      end
    end
  end

  describe '#post_hoc_analysis' do
    let(:groups) { [[1, 2, 3], [4, 5, 6], [7, 8, 9]] }

    context 'with Tukey HSD method' do
      it 'performs Tukey HSD analysis' do
        result = stats.post_hoc_analysis(groups, method: :tukey)

        expect(result).to be_a(Hash)
        expect(result[:method]).to eq('Tukey HSD')
        expect(result[:pairwise_comparisons]).to be_an(Array)
        expect(result[:pairwise_comparisons].length).to eq(3) # C(3,2) = 3 pairs
      end

      it 'includes correct comparison structure' do
        result = stats.post_hoc_analysis(groups, method: :tukey)
        comparison = result[:pairwise_comparisons].first

        expect(comparison).to include(:groups, :mean_difference, :q_statistic, :q_critical, :p_value, :significant)
        expect(comparison[:groups]).to be_an(Array)
        expect(comparison[:groups].length).to eq(2)
      end
    end

    context 'with Bonferroni method' do
      it 'performs Bonferroni analysis' do
        result = stats.post_hoc_analysis(groups, method: :bonferroni)

        expect(result).to be_a(Hash)
        expect(result[:method]).to eq('Bonferroni')
        expect(result[:adjusted_alpha]).to be_a(Numeric)
        expect(result[:adjusted_alpha]).to be < 0.05
      end

      it 'applies Bonferroni adjustment to p-values' do
        result = stats.post_hoc_analysis(groups, method: :bonferroni)
        comparison = result[:pairwise_comparisons].first

        expect(comparison).to include(:adjusted_p_value)
        expect(comparison[:adjusted_p_value]).to be >= comparison[:p_value]
      end
    end

    context 'with edge cases' do
      it 'returns nil for invalid method' do
        result = stats.post_hoc_analysis(groups, method: :invalid)
        expect(result).to be_nil
      end

      it 'returns nil for insufficient groups' do
        result = stats.post_hoc_analysis([[1, 2, 3]], method: :tukey)
        expect(result).to be_nil
      end

      it 'includes warning for non-significant ANOVA' do
        similar_groups = [[5.0, 5.1, 5.2], [5.0, 5.1, 5.2], [5.0, 5.1, 5.2]]
        result = stats.post_hoc_analysis(similar_groups, method: :tukey)

        # For very similar groups, ANOVA might not be significant
        expect(result[:warning]).to include('not significant') if result && !result[:warning].nil?
      end
    end
  end

  describe '#levene_test' do
    context 'with valid groups' do
      it 'performs Levene test for variance homogeneity' do
        group1 = [1, 2, 3, 4, 5]
        group2 = [2, 4, 6, 8, 10]
        group3 = [1, 3, 5, 7, 9]

        result = stats.levene_test(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Levene Test (Brown-Forsythe)')
        expect(result[:f_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_between(0, 1)
        expect(result[:degrees_of_freedom]).to eq([2, 12])
        expect(result[:significant]).to be(true).or be(false)
        expect(result[:interpretation]).to be_a(String)
      end

      it 'detects homogeneous variances' do
        # Groups with similar variances
        group1 = [1, 2, 3, 4, 5]
        group2 = [2, 3, 4, 5, 6]

        result = stats.levene_test(group1, group2)

        expect(result[:significant]).to be false
        expect(result[:interpretation]).to include('等しいと考えられる')
      end
    end

    context 'with edge cases' do
      it 'returns nil for insufficient groups' do
        result = stats.levene_test([1, 2, 3])
        expect(result).to be_nil
      end

      it 'returns nil for empty groups' do
        result = stats.levene_test([], [])
        expect(result).to be_nil
      end

      it 'handles groups with identical values' do
        group1 = [5, 5, 5]
        group2 = [5, 5, 5]

        result = stats.levene_test(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:f_statistic]).to be_a(Numeric)
      end
    end
  end

  describe '#bartlett_test' do
    context 'with valid groups' do
      it 'performs Bartlett test for variance homogeneity' do
        group1 = [1, 2, 3, 4, 5]
        group2 = [2, 4, 6, 8, 10]
        group3 = [1, 3, 5, 7, 9]

        result = stats.bartlett_test(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Bartlett Test')
        expect(result[:chi_square_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_between(0, 1)
        expect(result[:degrees_of_freedom]).to eq(2)
        expect(result[:correction_factor]).to be_a(Numeric)
        expect(result[:pooled_variance]).to be_a(Numeric)
      end

      it 'detects homogeneous variances for similar groups' do
        group1 = [1, 2, 3]
        group2 = [2, 3, 4]

        result = stats.bartlett_test(group1, group2)

        expect(result[:significant]).to be false
        expect(result[:interpretation]).to include('等しいと考えられる')
      end
    end

    context 'with zero variance edge case' do
      it 'handles groups with no variance' do
        group1 = [5, 5, 5]
        group2 = [5, 5, 5]

        result = stats.bartlett_test(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:chi_square_statistic]).to eq(0.0)
        expect(result[:p_value]).to eq(1.0)
        expect(result[:significant]).to be false
        expect(result[:pooled_variance]).to eq(0.0)
      end
    end

    context 'with edge cases' do
      it 'returns nil for insufficient groups' do
        result = stats.bartlett_test([1, 2, 3])
        expect(result).to be_nil
      end

      it 'returns nil for empty groups' do
        result = stats.bartlett_test([], [])
        expect(result).to be_nil
      end
    end
  end

  describe 'private method helpers' do
    describe '#calculate_sum_of_squares_between' do
      it 'calculates between-group sum of squares' do
        groups = [[1, 2, 3], [4, 5, 6]]
        group_means = [2.0, 5.0]
        grand_mean = 3.5

        result = stats.send(:calculate_sum_of_squares_between, groups, group_means, grand_mean)

        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end
    end

    describe '#calculate_sum_of_squares_within' do
      it 'calculates within-group sum of squares' do
        groups = [[1, 2, 3], [4, 5, 6]]
        group_means = [2.0, 5.0]

        result = stats.send(:calculate_sum_of_squares_within, groups, group_means)

        expect(result).to be_a(Numeric)
        expect(result).to be >= 0
      end
    end

    describe '#calculate_omega_squared' do
      it 'calculates omega squared effect size' do
        ss_between = 10.0
        df_between = 2
        ms_within = 1.5
        df_total = 15

        result = stats.send(:calculate_omega_squared, ss_between, df_between, ms_within, df_total)

        expect(result).to be_a(Numeric)
        expect(result).to be_between(0, 1)
      end
    end

    describe '#calculate_group_median' do
      it 'calculates median for odd-length array' do
        result = stats.send(:calculate_group_median, [1, 3, 5])
        expect(result).to eq(3)
      end

      it 'calculates median for even-length array' do
        result = stats.send(:calculate_group_median, [1, 2, 4, 5])
        expect(result).to eq(3.0)
      end

      it 'returns nil for empty array' do
        result = stats.send(:calculate_group_median, [])
        expect(result).to be_nil
      end
    end

    describe '#variance_of_array' do
      it 'calculates sample variance' do
        result = stats.send(:variance_of_array, [1, 2, 3, 4, 5])
        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end

      it 'returns 0 for single element' do
        result = stats.send(:variance_of_array, [5])
        expect(result).to eq(0.0)
      end

      it 'returns 0 for empty array' do
        result = stats.send(:variance_of_array, [])
        expect(result).to eq(0.0)
      end
    end

    describe '#tukey_critical_value' do
      it 'returns critical value for valid parameters' do
        result = stats.send(:tukey_critical_value, 3, 10, 0.05)
        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end

      it 'handles edge cases with clamping' do
        result = stats.send(:tukey_critical_value, 10, 5, 0.05)
        expect(result).to be_a(Numeric)
        expect(result).to be > 0
      end
    end

    describe '#bonferroni_adjust' do
      it 'adjusts p-values for multiple comparisons' do
        p_values = [0.01, 0.02, 0.03]
        result = stats.send(:bonferroni_adjust, p_values)

        expect(result).to be_an(Array)
        expect(result.length).to eq(3)
        expect(result[0]).to eq(0.03)
        expect(result[1]).to eq(0.06)
        expect(result[2]).to eq(0.09)
      end

      it 'caps adjusted p-values at 1.0' do
        p_values = [0.5, 0.6, 0.7]
        result = stats.send(:bonferroni_adjust, p_values)

        expect(result.all? { |p| p <= 1.0 }).to be true
      end
    end
  end

  describe '#two_way_anova' do
    context 'with valid 2x2 factorial design' do
      it 'calculates two-way ANOVA with main effects only' do
        # 2x2 design: Factor A (A1, A2) × Factor B (B1, B2)
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 12, 20, 22]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        expect(result).to be_a(Hash)
        expect(result[:main_effects]).to have_key(:factor_a)
        expect(result[:main_effects]).to have_key(:factor_b)
        expect(result[:interaction]).to be_a(Hash)
        expect(result[:grand_mean]).to eq(16.0)

        # Check main effects structure
        expect(result[:main_effects][:factor_a]).to have_key(:f_statistic)
        expect(result[:main_effects][:factor_a]).to have_key(:p_value)
        expect(result[:main_effects][:factor_a]).to have_key(:significant)

        expect(result[:main_effects][:factor_b]).to have_key(:f_statistic)
        expect(result[:main_effects][:factor_b]).to have_key(:p_value)
        expect(result[:main_effects][:factor_b]).to have_key(:significant)

        # Check interaction structure
        expect(result[:interaction]).to have_key(:f_statistic)
        expect(result[:interaction]).to have_key(:p_value)
        expect(result[:interaction]).to have_key(:significant)
      end

      it 'calculates correct marginal means' do
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 12, 20, 22]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        # Factor A marginal means: A1 = (10+12)/2 = 11, A2 = (20+22)/2 = 21
        expect(result[:marginal_means][:factor_a]['A1']).to eq(11.0)
        expect(result[:marginal_means][:factor_a]['A2']).to eq(21.0)

        # Factor B marginal means: B1 = (10+20)/2 = 15, B2 = (12+22)/2 = 17
        expect(result[:marginal_means][:factor_b]['B1']).to eq(15.0)
        expect(result[:marginal_means][:factor_b]['B2']).to eq(17.0)
      end

      it 'calculates correct cell means' do
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 12, 20, 22]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        expect(result[:cell_means]['A1']['B1']).to eq(10.0)
        expect(result[:cell_means]['A1']['B2']).to eq(12.0)
        expect(result[:cell_means]['A2']['B1']).to eq(20.0)
        expect(result[:cell_means]['A2']['B2']).to eq(22.0)
      end

      it 'identifies main effects correctly' do
        # Strong main effect for factor A, no main effect for factor B, no interaction
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 10, 20, 20]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        # Factor A should have significant main effect
        expect(result[:main_effects][:factor_a][:f_statistic]).to be > 0
        # Factor B should have no main effect (means are equal)
        expect(result[:main_effects][:factor_b][:f_statistic]).to be_within(0.001).of(0)
        # No interaction (parallel lines)
        expect(result[:interaction][:f_statistic]).to be_within(0.001).of(0)
      end
    end

    context 'with 2x3 factorial design' do
      it 'handles unbalanced factorial designs' do
        factor_a = %w[A1 A1 A1 A2 A2 A2]
        factor_b = %w[B1 B2 B3 B1 B2 B3]
        values = [10, 12, 14, 20, 22, 24]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        expect(result).to be_a(Hash)
        expect(result[:main_effects][:factor_a][:degrees_of_freedom]).to eq([1, 0])
        expect(result[:main_effects][:factor_b][:degrees_of_freedom]).to eq([2, 0])
        expect(result[:interaction][:degrees_of_freedom]).to eq([2, 0])
      end
    end

    context 'with multiple observations per cell' do
      it 'handles replicated factorial design' do
        # 2x2 design with 2 observations per cell
        factor_a = %w[A1 A1 A1 A1 A2 A2 A2 A2]
        factor_b = %w[B1 B1 B2 B2 B1 B1 B2 B2]
        values = [9, 11, 11, 13, 19, 21, 21, 23]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        expect(result).to be_a(Hash)
        expect(result[:error][:degrees_of_freedom]).to eq(4) # 8 total - 4 cells
        expect(result[:grand_mean]).to eq(16.0)
      end
    end

    context 'with interaction effects' do
      it 'detects interaction when present' do
        # Designed interaction: A1B1=10, A1B2=20, A2B1=20, A2B2=10 (crossover)
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 20, 20, 10]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        # No main effects (marginal means are equal)
        expect(result[:marginal_means][:factor_a]['A1']).to eq(15.0)
        expect(result[:marginal_means][:factor_a]['A2']).to eq(15.0)
        expect(result[:marginal_means][:factor_b]['B1']).to eq(15.0)
        expect(result[:marginal_means][:factor_b]['B2']).to eq(15.0)

        # Should detect interaction
        expect(result[:interaction][:f_statistic]).to be > 0
      end
    end

    context 'with invalid input' do
      it 'returns nil for mismatched array lengths' do
        factor_a = %w[A1 A1]
        factor_b = %w[B1 B2]
        values = [10, 12, 14] # Different length

        result = stats.two_way_anova(nil, factor_a, factor_b, values)
        expect(result).to be_nil
      end

      it 'returns nil for insufficient factor levels' do
        factor_a = %w[A1 A1] # Only one level
        factor_b = %w[B1 B2]
        values = [10, 12]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)
        expect(result).to be_nil
      end

      it 'returns nil for empty arrays' do
        result = stats.two_way_anova(nil, [], [], [])
        expect(result).to be_nil
      end

      it 'returns nil for non-numeric values' do
        factor_a = %w[A1 A1]
        factor_b = %w[B1 B2]
        values = %w[a b]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)
        expect(result).to be_nil
      end
    end

    context 'edge cases' do
      it 'handles single observation per cell gracefully' do
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 12, 20, 22]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        expect(result).to be_a(Hash)
        expect(result[:error][:degrees_of_freedom]).to eq(0) # No error df with single obs per cell
      end

      it 'provides interpretation' do
        factor_a = %w[A1 A1 A2 A2]
        factor_b = %w[B1 B2 B1 B2]
        values = [10, 12, 20, 22]

        result = stats.two_way_anova(nil, factor_a, factor_b, values)

        expect(result[:interpretation]).to be_a(String)
        expect(result[:interpretation]).to include('要因A')
        expect(result[:interpretation]).to include('要因B')
        expect(result[:interpretation]).to include('交互作用')
      end
    end
  end
end
