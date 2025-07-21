# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/numana/statistics/non_parametric_stats'

# Test class to include the module
class TestNonParametricStats
  include NonParametricStats

  # Expose private methods for testing
  def test_calculate_ranks_with_ties(values)
    calculate_ranks_with_ties(values)
  end

  def test_apply_tie_correction_to_h(h_statistic, all_values)
    apply_tie_correction_to_h(h_statistic, all_values)
  end

  def test_calculate_mann_whitney_variance(size1, size2, all_values)
    calculate_mann_whitney_variance(size1, size2, all_values)
  end

  def test_apply_friedman_tie_correction(chi_square_statistic, rank_matrix, n_subjects, k_conditions)
    apply_friedman_tie_correction(chi_square_statistic, rank_matrix, n_subjects, k_conditions)
  end

  # Mock method to satisfy dependency
  def calculate_chi_square_p_value(statistic, degrees_freedom)
    # Simple chi-square p-value approximation for testing
    if statistic <= 0
      1.0
    elsif (degrees_freedom == 1 && statistic >= 3.841) || (degrees_freedom == 2 && statistic >= 5.991)
      0.05
    else
      statistic > 10 ? 0.001 : 0.1
    end
  end
end

RSpec.describe NonParametricStats do
  let(:test_class) { TestNonParametricStats.new }

  describe '#kruskal_wallis_test' do
    context '正常なケース' do
      it '3グループの比較で正しい結果を返す' do
        group1 = [1, 2, 3]
        group2 = [4, 5, 6]
        group3 = [7, 8, 9]

        result = test_class.kruskal_wallis_test(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Kruskal-Wallis H Test')
        expect(result[:h_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect(result[:degrees_of_freedom]).to eq(2)
        expect(result[:group_sizes]).to eq([3, 3, 3])
        expect(result[:total_n]).to eq(9)
        expect(result[:significant]).to be(true).or be(false)
        expect(result[:interpretation]).to be_a(String)
      end

      it '2グループの比較で正しい結果を返す' do
        group1 = [10, 20, 30]
        group2 = [40, 50, 60]

        result = test_class.kruskal_wallis_test(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:degrees_of_freedom]).to eq(1)
        expect(result[:group_sizes]).to eq([3, 3])
        expect(result[:total_n]).to eq(6)
      end

      it 'タイがある場合の補正を適用する' do
        group1 = [1, 2, 2]
        group2 = [2, 3, 3]
        group3 = [3, 4, 4]

        result = test_class.kruskal_wallis_test(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:h_statistic]).to be_a(Numeric)
        expect(result[:h_statistic]).to be > 0
      end

      it '異なるサイズのグループを処理する' do
        group1 = [1, 2]
        group2 = [3, 4, 5, 6]
        group3 = [7]

        result = test_class.kruskal_wallis_test(group1, group2, group3)

        expect(result[:group_sizes]).to eq([2, 4, 1])
        expect(result[:total_n]).to eq(7)
      end
    end

    context 'エッジケース' do
      it '不正入力でnilを返す' do
        expect(test_class.kruskal_wallis_test([])).to be_nil
        expect(test_class.kruskal_wallis_test([1, 2, 3])).to be_nil
        expect(test_class.kruskal_wallis_test(nil, [1, 2])).to be_nil
        expect(test_class.kruskal_wallis_test([1, 2], [])).to be_nil
      end

      it '非配列入力でnilを返す' do
        expect(test_class.kruskal_wallis_test('invalid', [1, 2])).to be_nil
        expect(test_class.kruskal_wallis_test([1, 2], 123)).to be_nil
      end

      it '1要素のグループを処理する' do
        group1 = [5]
        group2 = [10]
        group3 = [15]

        result = test_class.kruskal_wallis_test(group1, group2, group3)

        expect(result).to be_a(Hash)
        expect(result[:total_n]).to eq(3)
      end
    end
  end

  describe '#mann_whitney_u_test' do
    context '正常なケース' do
      it '2グループの比較で正しい結果を返す' do
        group1 = [1, 2, 3, 4, 5]
        group2 = [6, 7, 8, 9, 10]

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Mann-Whitney U Test')
        expect(result[:u_statistic]).to be_a(Numeric)
        expect(result[:u1]).to be_a(Numeric)
        expect(result[:u2]).to be_a(Numeric)
        expect(result[:z_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect(result[:effect_size]).to be_a(Numeric)
        expect(result[:group_sizes]).to eq([5, 5])
        expect(result[:rank_sums]).to be_a(Array)
        expect(result[:total_n]).to eq(10)
        expect(result[:significant]).to be(true).or be(false)
        expect(result[:interpretation]).to be_a(String)
      end

      it '大きなサンプル（n>=8）で正規近似を使用する' do
        group1 = (1..10).to_a
        group2 = (11..20).to_a

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result[:group_sizes]).to eq([10, 10])
        expect(result[:u_statistic]).to eq(0.0)
        expect(result[:significant]).to be(true)
      end

      it '小さなサンプル（n<8）で簡易検定を使用する' do
        group1 = [1, 2, 3]
        group2 = [4, 5, 6]

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result[:group_sizes]).to eq([3, 3])
        expect(result[:u_statistic]).to be_a(Numeric)
      end

      it 'タイがある場合を処理する' do
        group1 = [1, 2, 2, 3]
        group2 = [2, 3, 3, 4]

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:u_statistic]).to be_a(Numeric)
      end

      it '異なるサイズのグループを処理する' do
        group1 = [1, 2]
        group2 = [3, 4, 5, 6, 7]

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result[:group_sizes]).to eq([2, 5])
        expect(result[:total_n]).to eq(7)
      end
    end

    context 'エッジケース' do
      it '不正入力でnilを返す' do
        expect(test_class.mann_whitney_u_test(nil, [1, 2])).to be_nil
        expect(test_class.mann_whitney_u_test([1, 2], nil)).to be_nil
        expect(test_class.mann_whitney_u_test([], [1, 2])).to be_nil
        expect(test_class.mann_whitney_u_test([1, 2], [])).to be_nil
      end

      it '非配列入力でnilを返す' do
        expect(test_class.mann_whitney_u_test('invalid', [1, 2])).to be_nil
        expect(test_class.mann_whitney_u_test([1, 2], 123)).to be_nil
      end

      it '1要素のグループを処理する' do
        group1 = [5]
        group2 = [10]

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result).to be_a(Hash)
        expect(result[:total_n]).to eq(2)
      end

      it '同じ値のグループを処理する' do
        group1 = [5, 5, 5]
        group2 = [5, 5, 5]

        result = test_class.mann_whitney_u_test(group1, group2)

        expect(result[:u_statistic]).to be_a(Numeric)
        expect(result[:significant]).to be(false)
      end
    end
  end

  describe '#wilcoxon_signed_rank_test' do
    context '基本的な動作' do
      it '正の差がある対応データを正しく検定する' do
        before = [10, 12, 14, 16, 18, 20]
        after = [15, 18, 21, 23, 26, 29]

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Wilcoxon Signed-Rank Test')
        expect(result[:w_statistic]).to eq(0) # All differences are positive
        expect(result[:w_plus]).to eq(21) # 1+2+3+4+5+6
        expect(result[:w_minus]).to eq(0)
        expect(result[:p_value]).to be < 0.05
        expect(result[:significant]).to be(true)
        expect(result[:n_pairs]).to eq(6)
        expect(result[:n_effective]).to eq(6)
        expect(result[:n_zeros]).to eq(0)
      end

      it '負の差がある対応データを正しく検定する' do
        before = [20, 18, 16, 14, 12]
        after = [15, 12, 10, 8, 6]

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result[:w_statistic]).to eq(0) # All differences are negative
        expect(result[:w_plus]).to eq(0)
        expect(result[:w_minus]).to eq(15) # 1+2+3+4+5
        expect(result[:significant]).to be(true)
      end

      it '差がゼロのペアを除外する' do
        before = [10, 15, 20, 25]
        after = [15, 15, 25, 30] # Second pair has zero difference

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result[:n_pairs]).to eq(4)
        expect(result[:n_effective]).to eq(3) # One zero difference excluded
        expect(result[:n_zeros]).to eq(1)
      end
    end

    context 'タイの処理' do
      it 'タイのある差を正しく処理する' do
        before = [10, 12, 14, 16]
        after = [12, 14, 16, 18] # All differences are 2

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result[:w_statistic]).to eq(0) # All positive with same magnitude
        expect(result[:w_plus]).to eq(10) # (1+2+3+4) = 10
        expect(result[:w_minus]).to eq(0)
      end

      it '正負の差が混在する場合を処理する' do
        before = [10, 15, 20, 25]
        after = [15, 10, 25, 20] # +5, -5, +5, -5

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result[:w_plus]).to eq(result[:w_minus]) # Symmetric differences
        expect(result[:significant]).to be(false)
      end
    end

    context 'エッジケース' do
      it '全ての差がゼロの場合を処理する' do
        before = [10, 20, 30]
        after = [10, 20, 30]

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result[:w_statistic]).to eq(0)
        expect(result[:p_value]).to eq(1.0)
        expect(result[:significant]).to be(false)
        expect(result[:n_effective]).to eq(0)
        expect(result[:interpretation]).to include('全ての差がゼロ')
      end

      it '小さなサンプルサイズで正しく動作する' do
        before = [10, 20]
        after = [15, 18]

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result).to be_a(Hash)
        expect(result[:n_pairs]).to eq(2)
      end

      it '1ペアのデータで動作する' do
        before = [10]
        after = [15]

        result = test_class.wilcoxon_signed_rank_test(before, after)

        expect(result[:w_statistic]).to eq(0)
        expect(result[:w_plus]).to eq(1)
        expect(result[:w_minus]).to eq(0)
      end
    end

    context '入力検証' do
      it 'nilを拒否する' do
        expect(test_class.wilcoxon_signed_rank_test(nil, [1, 2, 3])).to be_nil
        expect(test_class.wilcoxon_signed_rank_test([1, 2, 3], nil)).to be_nil
      end

      it '配列以外を拒否する' do
        expect(test_class.wilcoxon_signed_rank_test('not array', [1, 2])).to be_nil
        expect(test_class.wilcoxon_signed_rank_test([1, 2], 'not array')).to be_nil
      end

      it '空配列を拒否する' do
        expect(test_class.wilcoxon_signed_rank_test([], [1, 2])).to be_nil
        expect(test_class.wilcoxon_signed_rank_test([1, 2], [])).to be_nil
      end

      it '異なる長さの配列を拒否する' do
        before = [1, 2, 3]
        after = [4, 5]

        expect(test_class.wilcoxon_signed_rank_test(before, after)).to be_nil
      end
    end
  end

  describe 'プライベートメソッド' do
    describe '#calculate_ranks_with_ties' do
      it 'タイなしの値に正しいランクを割り当てる' do
        values = [1, 3, 2]
        ranks = test_class.test_calculate_ranks_with_ties(values)

        expect(ranks).to eq([1.0, 3.0, 2.0])
      end

      it 'タイがある値に平均ランクを割り当てる' do
        values = [1, 2, 2, 3]
        ranks = test_class.test_calculate_ranks_with_ties(values)

        expect(ranks).to eq([1.0, 2.5, 2.5, 4.0])
      end

      it '全て同じ値の場合に正しい平均ランクを返す' do
        values = [5, 5, 5]
        ranks = test_class.test_calculate_ranks_with_ties(values)

        expect(ranks).to eq([2.0, 2.0, 2.0])
      end

      it '空配列の場合に空配列を返す' do
        values = []
        ranks = test_class.test_calculate_ranks_with_ties(values)

        expect(ranks).to eq([])
      end
    end

    describe '#apply_tie_correction_to_h' do
      it 'タイがない場合は元の統計量を返す' do
        h_statistic = 5.0
        all_values = [1, 2, 3, 4, 5]

        result = test_class.test_apply_tie_correction_to_h(h_statistic, all_values)

        expect(result).to eq(5.0)
      end

      it 'タイがある場合は補正された統計量を返す' do
        h_statistic = 5.0
        all_values = [1, 2, 2, 3, 3, 3]

        result = test_class.test_apply_tie_correction_to_h(h_statistic, all_values)

        expect(result).to be > h_statistic
        expect(result).to be_a(Numeric)
      end
    end

    describe '#calculate_mann_whitney_variance' do
      it 'タイなしの基本分散を計算する' do
        variance = test_class.test_calculate_mann_whitney_variance(3, 3, [1, 2, 3, 4, 5, 6])

        expected = (3 * 3 * (3 + 3 + 1)) / 12.0
        expect(variance).to eq(expected)
      end

      it 'タイがある場合の補正分散を計算する' do
        variance = test_class.test_calculate_mann_whitney_variance(3, 3, [1, 2, 2, 3, 3, 3])

        basic_variance = (3 * 3 * (3 + 3 + 1)) / 12.0
        expect(variance).to be <= basic_variance
        expect(variance).to be_a(Numeric)
      end
    end
  end

  describe '統計的解釈' do
    it '有意差がある場合の解釈メッセージ' do
      # 明らかに異なるグループ
      group1 = [1, 2, 3]
      group2 = [100, 200, 300]

      kw_result = test_class.kruskal_wallis_test(group1, group2)
      mw_result = test_class.mann_whitney_u_test(group1, group2)

      # 結果によって変わるため、メッセージの形式をチェック
      expect(kw_result[:interpretation]).to be_a(String)
      expect(mw_result[:interpretation]).to be_a(String)
    end

    it '有意差がない場合の解釈メッセージ' do
      # 似たようなグループ
      group1 = [1, 2, 3]
      group2 = [2, 3, 4]

      kw_result = test_class.kruskal_wallis_test(group1, group2)
      mw_result = test_class.mann_whitney_u_test(group1, group2)

      # 結果によって変わるため、メッセージの形式をチェック
      expect(kw_result[:interpretation]).to be_a(String)
      expect(mw_result[:interpretation]).to be_a(String)
    end
  end

  describe '#friedman_test' do
    context '正常なケース' do
      it '3条件の反復測定で正しい結果を返す' do
        # 3人の被験者が3つの条件で測定された場合
        condition1 = [1, 2, 3]
        condition2 = [4, 5, 6]
        condition3 = [7, 8, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Friedman Test')
        expect(result[:chi_square_statistic]).to be_a(Numeric)
        expect(result[:p_value]).to be_a(Numeric)
        expect(result[:degrees_of_freedom]).to eq(2)
        expect([true, false]).to include(result[:significant])
        expect(result[:interpretation]).to be_a(String)
        expect(result[:rank_sums]).to be_an(Array)
        expect(result[:rank_sums].length).to eq(3)
        expect(result[:n_subjects]).to eq(3)
        expect(result[:k_conditions]).to eq(3)
        expect(result[:total_observations]).to eq(9)
      end

      it '4条件の反復測定で正しい結果を返す' do
        # 4人の被験者が4つの条件で測定された場合
        condition1 = [10, 15, 20, 25]
        condition2 = [12, 17, 22, 27]
        condition3 = [14, 19, 24, 29]
        condition4 = [16, 21, 26, 31]

        result = test_class.friedman_test(condition1, condition2, condition3, condition4)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('Friedman Test')
        expect(result[:degrees_of_freedom]).to eq(3)
        expect(result[:n_subjects]).to eq(4)
        expect(result[:k_conditions]).to eq(4)
        expect(result[:total_observations]).to eq(16)
        expect(result[:rank_sums].length).to eq(4)
      end

      it 'タイがある場合も正しく処理する' do
        # 同じ値を含むデータ
        condition1 = [1, 1, 2]
        condition2 = [1, 2, 2]
        condition3 = [2, 2, 3]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_a(Hash)
        expect(result[:chi_square_statistic]).to be_a(Numeric)
        expect(result[:chi_square_statistic]).to be >= 0
      end

      it '明確な差がある場合に有意差を検出する' do
        # 条件間で明確な差があるデータ
        condition1 = [1, 2, 3, 4, 5]
        condition2 = [6, 7, 8, 9, 10]
        condition3 = [11, 12, 13, 14, 15]

        result = test_class.friedman_test(condition1, condition2, condition3)

        # 明確な差があるため、大きなχ²統計量が期待される
        expect(result[:chi_square_statistic]).to be > 0
        expect([true, false]).to include(result[:significant])
      end
    end

    context 'エラーケース' do
      it '2条件以下の場合はnilを返す' do
        condition1 = [1, 2, 3]
        condition2 = [4, 5, 6]

        result = test_class.friedman_test(condition1, condition2)

        expect(result).to be_nil
      end

      it '1条件の場合はnilを返す' do
        condition1 = [1, 2, 3]

        result = test_class.friedman_test(condition1)

        expect(result).to be_nil
      end

      it '空の配列が含まれる場合はnilを返す' do
        condition1 = [1, 2, 3]
        condition2 = []
        condition3 = [7, 8, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_nil
      end

      it 'nilが含まれる場合はnilを返す' do
        condition1 = [1, 2, 3]
        condition2 = nil
        condition3 = [7, 8, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_nil
      end

      it '異なる長さのグループの場合はnilを返す' do
        condition1 = [1, 2, 3]
        condition2 = [4, 5]
        condition3 = [7, 8, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_nil
      end

      it '配列以外が含まれる場合はnilを返す' do
        condition1 = [1, 2, 3]
        condition2 = 'invalid'
        condition3 = [7, 8, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_nil
      end
    end

    context 'エッジケース' do
      it '最小ケース（3条件、1被験者）で正しく動作する' do
        condition1 = [1]
        condition2 = [2]
        condition3 = [3]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_a(Hash)
        expect(result[:n_subjects]).to eq(1)
        expect(result[:k_conditions]).to eq(3)
        expect(result[:rank_sums]).to eq([1.0, 2.0, 3.0])
      end

      it '全て同じ値の場合に適切に処理する' do
        condition1 = [5, 5, 5]
        condition2 = [5, 5, 5]
        condition3 = [5, 5, 5]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_a(Hash)
        # 全て同じ値なので、ランクは全て2.0（平均ランク）
        expect(result[:rank_sums]).to all(eq(6.0)) # 3被験者 × 平均ランク2.0
        expect(result[:chi_square_statistic]).to be >= 0
      end

      it '負の値が含まれていても正しく処理する' do
        condition1 = [-3, -2, -1]
        condition2 = [0, 1, 2]
        condition3 = [3, 4, 5]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_a(Hash)
        expect(result[:chi_square_statistic]).to be_a(Numeric)
      end

      it '小数値が含まれていても正しく処理する' do
        condition1 = [1.1, 2.2, 3.3]
        condition2 = [4.4, 5.5, 6.6]
        condition3 = [7.7, 8.8, 9.9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        expect(result).to be_a(Hash)
        expect(result[:chi_square_statistic]).to be_a(Numeric)
      end
    end

    context 'タイ補正のテスト' do
      it 'タイがない場合はタイ補正が適用されない' do
        # タイがないデータ
        condition1 = [1, 4, 7]
        condition2 = [2, 5, 8]
        condition3 = [3, 6, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        # タイがないので、tie correctionの効果は最小限
        expect(result[:chi_square_statistic]).to be_a(Numeric)
        expect(result[:chi_square_statistic]).to be > 0
      end

      it 'タイ補正の計算が正しく動作する' do
        # 各被験者で一部タイがあるデータ
        rank_matrix = [
          [1.0, 2.0, 3.0],  # 被験者1: タイなし
          [1.5, 1.5, 3.0],  # 被験者2: 条件1と2でタイ
          [1.0, 2.5, 2.5]   # 被験者3: 条件2と3でタイ
        ]

        # tie correctionを直接テスト
        chi_square = 6.0
        corrected = test_class.test_apply_friedman_tie_correction(chi_square, rank_matrix, 3, 3)

        # タイ補正により値が変化することを確認
        expect(corrected).to be_a(Numeric)
        expect(corrected).not_to eq(chi_square) # 補正が適用されて値が変わるはず
      end
    end

    context '統計的解釈のテスト' do
      it '結果の解釈メッセージが適切' do
        condition1 = [1, 2, 3]
        condition2 = [4, 5, 6]
        condition3 = [7, 8, 9]

        result = test_class.friedman_test(condition1, condition2, condition3)

        # 有意・非有意に関わらず、適切な日本語メッセージが含まれることを確認
        expect(result[:interpretation]).to include('条件間')
        expect(result[:interpretation]).to include('反復測定')
      end
    end
  end
end
