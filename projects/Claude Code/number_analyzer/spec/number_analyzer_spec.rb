# frozen_string_literal: true

require_relative '../lib/numana'

RSpec.describe Numana do
  let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }
  let(:analyzer) { Numana.new(numbers) }

  describe '#calculate_statistics' do
    it 'outputs correct statistics for the given numbers' do
      expected_output = "合計: 55\n平均: 5.5\n最大値: 10\n最小値: 1\n中央値: 5.5\n分散: 8.25\n最頻値: なし\n標準偏差: 2.87\n四分位範囲(IQR): 4.5\n外れ値: なし\n偏差値: 34.33, 37.81, 41.3, 44.78, 48.26, 51.74, 55.22, 58.7, 62.19, 65.67\n\n度数分布ヒストグラム:\n1: ■ (1)\n2: ■ (1)\n3: ■ (1)\n4: ■ (1)\n5: ■ (1)\n6: ■ (1)\n7: ■ (1)\n8: ■ (1)\n9: ■ (1)\n10: ■ (1)\n"

      expect { analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with single number' do
    let(:single_analyzer) { Numana.new([42]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 42\n平均: 42.0\n最大値: 42\n最小値: 42\n中央値: 42\n分散: 0.0\n最頻値: なし\n標準偏差: 0.0\n四分位範囲(IQR): 0\n外れ値: なし\n偏差値: 50.0\n\n度数分布ヒストグラム:\n42: ■ (1)\n"

      expect { single_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with negative numbers' do
    let(:negative_analyzer) { Numana.new([-5, -2, -10, -1]) }

    it 'handles negative numbers correctly' do
      expected_output = "合計: -18\n平均: -4.5\n最大値: -1\n最小値: -10\n中央値: -3.5\n分散: 12.25\n最頻値: なし\n標準偏差: 3.5\n四分位範囲(IQR): 4.5\n外れ値: なし\n偏差値: 48.57, 57.14, 34.29, 60.0\n\n度数分布ヒストグラム:\n-10: ■ (1)\n-5: ■ (1)\n-2: ■ (1)\n-1: ■ (1)\n"

      expect { negative_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with mixed positive and negative numbers' do
    let(:mixed_analyzer) { Numana.new([-3, 0, 5, -1, 2]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 3\n平均: 0.6\n最大値: 5\n最小値: -3\n中央値: 0\n分散: 7.44\n最頻値: なし\n標準偏差: 2.73\n四分位範囲(IQR): 3\n外れ値: なし\n偏差値: 36.8, 47.8, 66.13, 44.13, 55.13\n\n度数分布ヒストグラム:\n-3: ■ (1)\n-1: ■ (1)\n0: ■ (1)\n2: ■ (1)\n5: ■ (1)\n"

      expect { mixed_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with duplicate numbers' do
    let(:duplicate_analyzer) { Numana.new([3, 3, 3, 3]) }

    it 'handles duplicate values correctly' do
      expected_output = "合計: 12\n平均: 3.0\n最大値: 3\n最小値: 3\n中央値: 3.0\n分散: 0.0\n最頻値: 3\n標準偏差: 0.0\n四分位範囲(IQR): 0.0\n外れ値: なし\n偏差値: 50.0, 50.0, 50.0, 50.0\n\n度数分布ヒストグラム:\n3: ■■■■ (4)\n"

      expect { duplicate_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  describe '#linear_trend' do
    context 'with perfect upward trend' do
      let(:trend_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'calculates correct trend slope and intercept' do
        result = trend_analyzer.linear_trend

        expect(result[:slope]).to be_within(0.001).of(1.0)
        expect(result[:intercept]).to be_within(0.001).of(1.0)
        expect(result[:r_squared]).to be_within(0.001).of(1.0)
        expect(result[:direction]).to eq('上昇')
      end
    end

    context 'with perfect downward trend' do
      let(:downward_analyzer) { Numana.new([5, 4, 3, 2, 1]) }

      it 'detects downward trend' do
        result = downward_analyzer.linear_trend

        expect(result[:slope]).to be_within(0.001).of(-1.0)
        expect(result[:direction]).to eq('下降')
      end
    end

    context 'with no trend (flat)' do
      let(:flat_analyzer) { Numana.new([5, 5, 5, 5, 5]) }

      it 'detects flat trend' do
        result = flat_analyzer.linear_trend

        expect(result[:slope]).to be_within(0.001).of(0.0)
        expect(result[:direction]).to eq('横ばい')
      end
    end

    context 'with empty array' do
      let(:empty_analyzer) { Numana.new([]) }

      it 'returns nil for empty dataset' do
        expect(empty_analyzer.linear_trend).to be_nil
      end
    end

    context 'with single value' do
      let(:single_analyzer) { Numana.new([42]) }

      it 'returns nil for single value' do
        expect(single_analyzer.linear_trend).to be_nil
      end
    end
  end

  describe '#median' do
    context 'with odd number of elements' do
      let(:odd_analyzer) { Numana.new([1, 3, 5, 7, 9]) }

      it 'returns the middle value' do
        expect(odd_analyzer.median).to eq(5)
      end
    end

    context 'with even number of elements' do
      let(:even_analyzer) { Numana.new([1, 2, 3, 4]) }

      it 'returns the average of two middle values' do
        expect(even_analyzer.median).to eq(2.5)
      end
    end

    context 'with single element' do
      let(:single_analyzer) { Numana.new([42]) }

      it 'returns the single element' do
        expect(single_analyzer.median).to eq(42)
      end
    end

    context 'with unsorted array' do
      let(:unsorted_analyzer) { Numana.new([5, 1, 9, 3, 7]) }

      it 'correctly finds median of unsorted data' do
        expect(unsorted_analyzer.median).to eq(5)
      end
    end
  end

  describe '#mode' do
    context 'with single mode' do
      let(:single_mode_analyzer) { Numana.new([1, 2, 2, 3, 4]) }

      it 'returns the most frequent value' do
        expect(single_mode_analyzer.mode).to eq([2])
      end
    end

    context 'with multiple modes' do
      let(:multi_mode_analyzer) { Numana.new([1, 1, 2, 2, 3]) }

      it 'returns array of most frequent values' do
        expect(multi_mode_analyzer.mode).to contain_exactly(1, 2)
      end
    end

    context 'with no mode (all unique)' do
      let(:no_mode_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'returns empty array' do
        expect(no_mode_analyzer.mode).to eq([])
      end
    end

    context 'with all same values' do
      let(:all_same_analyzer) { Numana.new([5, 5, 5, 5]) }

      it 'returns the repeated value' do
        expect(all_same_analyzer.mode).to eq([5])
      end
    end
  end

  describe '#variance' do
    context 'with known values' do
      let(:known_analyzer) { Numana.new([2, 4, 4, 4, 5, 5, 7, 9]) }

      it 'calculates variance correctly' do
        expect(known_analyzer.variance).to be_within(0.01).of(4.0)
      end
    end

    context 'with single value' do
      let(:single_analyzer) { Numana.new([5]) }

      it 'returns zero for single value' do
        expect(single_analyzer.variance).to eq(0)
      end
    end

    context 'with identical values' do
      let(:identical_analyzer) { Numana.new([3, 3, 3, 3]) }

      it 'returns zero for identical values' do
        expect(identical_analyzer.variance).to eq(0)
      end
    end

    context 'with simple case' do
      let(:simple_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'calculates variance for simple sequence' do
        expect(simple_analyzer.variance).to be_within(0.01).of(2.0)
      end
    end
  end

  describe '#percentile' do
    context 'with known dataset' do
      let(:percentile_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }

      it 'calculates 25th percentile correctly' do
        expect(percentile_analyzer.percentile(25)).to be_within(0.01).of(3.25)
      end

      it 'calculates 50th percentile correctly (median)' do
        expect(percentile_analyzer.percentile(50)).to be_within(0.01).of(5.5)
      end

      it 'calculates 75th percentile correctly' do
        expect(percentile_analyzer.percentile(75)).to be_within(0.01).of(7.75)
      end

      it 'calculates 95th percentile correctly' do
        expect(percentile_analyzer.percentile(95)).to be_within(0.01).of(9.55)
      end
    end

    context 'with boundary values' do
      let(:boundary_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'returns minimum for 0th percentile' do
        expect(boundary_analyzer.percentile(0)).to eq(1)
      end

      it 'returns maximum for 100th percentile' do
        expect(boundary_analyzer.percentile(100)).to eq(5)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { Numana.new([42]) }
      let(:two_analyzer) { Numana.new([1, 3]) }

      it 'handles single value correctly' do
        expect(single_analyzer.percentile(25)).to eq(42)
        expect(single_analyzer.percentile(50)).to eq(42)
        expect(single_analyzer.percentile(75)).to eq(42)
      end

      it 'handles two values correctly' do
        expect(two_analyzer.percentile(25)).to eq(1.5)
        expect(two_analyzer.percentile(50)).to eq(2.0)
        expect(two_analyzer.percentile(75)).to eq(2.5)
      end
    end

    context 'with unsorted data' do
      let(:unsorted_analyzer) { Numana.new([5, 1, 9, 3, 7]) }

      it 'correctly sorts data before calculation' do
        expect(unsorted_analyzer.percentile(50)).to eq(5)
      end
    end
  end

  describe '#quartiles' do
    context 'with known dataset' do
      let(:quartiles_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }

      it 'returns hash with correct quartile values' do
        result = quartiles_analyzer.quartiles

        expect(result).to be_a(Hash)
        expect(result[:q1]).to eq(3.25)
        expect(result[:q2]).to eq(5.5)
        expect(result[:q3]).to eq(7.75)
      end

      it 'has q2 equal to median' do
        result = quartiles_analyzer.quartiles
        expect(result[:q2]).to eq(quartiles_analyzer.median)
      end
    end

    context 'with different datasets' do
      let(:small_analyzer) { Numana.new([1, 2, 3, 4, 5]) }
      let(:even_analyzer) { Numana.new([2, 4, 6, 8]) }

      it 'calculates quartiles for small dataset' do
        result = small_analyzer.quartiles
        expect(result[:q1]).to eq(2.0)
        expect(result[:q2]).to eq(3.0)
        expect(result[:q3]).to eq(4.0)
      end

      it 'calculates quartiles for even-length dataset' do
        result = even_analyzer.quartiles
        expect(result[:q1]).to eq(3.5)
        expect(result[:q2]).to eq(5.0)
        expect(result[:q3]).to eq(6.5)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { Numana.new([42]) }
      let(:identical_analyzer) { Numana.new([5, 5, 5, 5]) }

      it 'handles single value correctly' do
        result = single_analyzer.quartiles
        expect(result[:q1]).to eq(42)
        expect(result[:q2]).to eq(42)
        expect(result[:q3]).to eq(42)
      end

      it 'handles identical values correctly' do
        result = identical_analyzer.quartiles
        expect(result[:q1]).to eq(5)
        expect(result[:q2]).to eq(5)
        expect(result[:q3]).to eq(5)
      end
    end
  end

  describe '#standard_deviation' do
    context 'with known values' do
      let(:known_analyzer) { Numana.new([2, 4, 4, 4, 5, 5, 7, 9]) }

      it 'calculates standard deviation correctly' do
        expect(known_analyzer.standard_deviation).to be_within(0.01).of(2.0)
      end
    end

    context 'with single value' do
      let(:single_analyzer) { Numana.new([5]) }

      it 'returns zero for single value' do
        expect(single_analyzer.standard_deviation).to eq(0)
      end
    end

    context 'with identical values' do
      let(:identical_analyzer) { Numana.new([3, 3, 3, 3]) }

      it 'returns zero for identical values' do
        expect(identical_analyzer.standard_deviation).to eq(0)
      end
    end

    context 'with simple case' do
      let(:simple_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'calculates standard deviation for simple sequence' do
        expect(simple_analyzer.standard_deviation).to be_within(0.01).of(1.41)
      end
    end
  end

  describe '#interquartile_range' do
    context 'with known dataset' do
      let(:iqr_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }

      it 'calculates IQR correctly' do
        # Q1 = 3.25, Q3 = 7.75, so IQR = 7.75 - 3.25 = 4.5
        expect(iqr_analyzer.interquartile_range).to be_within(0.01).of(4.5)
      end
    end

    context 'with simple sequence' do
      let(:simple_analyzer) { Numana.new([1, 3, 5, 7, 9]) }

      it 'calculates IQR for odd number of values' do
        # Q1 = 3, Q3 = 7, so IQR = 7 - 3 = 4
        expect(simple_analyzer.interquartile_range).to eq(4)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { Numana.new([42]) }
      let(:two_analyzer) { Numana.new([1, 5]) }

      it 'handles single value' do
        expect(single_analyzer.interquartile_range).to eq(0)
      end

      it 'handles two values' do
        # For [1, 5]: using linear interpolation, Q1 = 2, Q3 = 4, so IQR = 4 - 2 = 2
        expect(two_analyzer.interquartile_range).to eq(2.0)
      end
    end

    context 'with empty array' do
      let(:empty_analyzer) { Numana.new([]) }

      it 'returns nil for empty array' do
        expect(empty_analyzer.interquartile_range).to be_nil
      end
    end
  end

  describe '#outliers' do
    context 'with typical outlier data' do
      # Dataset: [1, 2, 3, 4, 5, 100]
      # Q1 = 2.25, Q3 = 4.75, IQR = 2.5
      # Lower bound = Q1 - 1.5*IQR = 2.25 - 3.75 = -1.5
      # Upper bound = Q3 + 1.5*IQR = 4.75 + 3.75 = 8.5
      # So 100 is an outlier (100 > 8.5)
      let(:outlier_analyzer) { Numana.new([1, 2, 3, 4, 5, 100]) }

      it 'identifies upper outliers correctly' do
        expect(outlier_analyzer.outliers).to contain_exactly(100)
      end
    end

    context 'with lower outlier' do
      # Dataset: [-50, 1, 2, 3, 4, 5]
      # Q1 = 1.25, Q3 = 3.75, IQR = 2.5
      # Lower bound = Q1 - 1.5*IQR = 1.25 - 3.75 = -2.5
      # Upper bound = Q3 + 1.5*IQR = 3.75 + 3.75 = 7.5
      # So -50 is an outlier (-50 < -2.5)
      let(:lower_outlier_analyzer) { Numana.new([-50, 1, 2, 3, 4, 5]) }

      it 'identifies lower outliers correctly' do
        expect(lower_outlier_analyzer.outliers).to contain_exactly(-50)
      end
    end

    context 'with multiple outliers' do
      # Dataset: [-100, 1, 2, 3, 4, 5, 200]
      # Q1 = 1.25, Q3 = 3.75, IQR = 2.5
      # Lower bound = Q1 - 1.5*IQR = 1.25 - 3.75 = -2.5
      # Upper bound = Q3 + 1.5*IQR = 3.75 + 3.75 = 7.5
      # So -100 and 200 are outliers
      let(:multi_outlier_analyzer) { Numana.new([-100, 1, 2, 3, 4, 5, 200]) }

      it 'identifies multiple outliers correctly' do
        expect(multi_outlier_analyzer.outliers).to contain_exactly(-100, 200)
      end
    end

    context 'with no outliers' do
      let(:no_outlier_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }

      it 'returns empty array when no outliers present' do
        expect(no_outlier_analyzer.outliers).to eq([])
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { Numana.new([42]) }
      let(:two_analyzer) { Numana.new([1, 5]) }
      let(:empty_analyzer) { Numana.new([]) }

      it 'handles single value' do
        expect(single_analyzer.outliers).to eq([])
      end

      it 'handles two values' do
        expect(two_analyzer.outliers).to eq([])
      end

      it 'handles empty array' do
        expect(empty_analyzer.outliers).to eq([])
      end
    end

    context 'with identical values' do
      let(:identical_analyzer) { Numana.new([5, 5, 5, 5, 5]) }

      it 'returns no outliers for identical values' do
        expect(identical_analyzer.outliers).to eq([])
      end
    end
  end

  describe '#deviation_scores' do
    context 'with known dataset' do
      # Dataset: [60, 70, 80, 90, 100]
      # Mean = 80, Standard Deviation = 14.14
      # Deviation scores:
      # 60: (60-80)/14.14*10+50 = 35.86
      # 70: (70-80)/14.14*10+50 = 42.93
      # 80: (80-80)/14.14*10+50 = 50.0
      # 90: (90-80)/14.14*10+50 = 57.07
      # 100: (100-80)/14.14*10+50 = 64.14
      let(:deviation_analyzer) { Numana.new([60, 70, 80, 90, 100]) }

      it 'calculates deviation scores correctly' do
        scores = deviation_analyzer.deviation_scores
        expect(scores).to be_a(Array)
        expect(scores.length).to eq(5)
        expect(scores[0]).to be_within(0.01).of(35.86)
        expect(scores[1]).to be_within(0.01).of(42.93)
        expect(scores[2]).to be_within(0.01).of(50.0)
        expect(scores[3]).to be_within(0.01).of(57.07)
        expect(scores[4]).to be_within(0.01).of(64.14)
      end

      it 'has mean value as deviation score 50' do
        scores = deviation_analyzer.deviation_scores
        mean_score = scores[2] # 80 is the mean
        expect(mean_score).to be_within(0.01).of(50.0)
      end
    end

    context 'with simple sequence' do
      # Dataset: [1, 2, 3, 4, 5]
      # Mean = 3, Standard Deviation = 1.41
      let(:simple_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'calculates deviation scores for simple sequence' do
        scores = simple_analyzer.deviation_scores
        expect(scores.length).to eq(5)
        expect(scores[2]).to be_within(0.01).of(50.0) # Middle value should be 50
        expect(scores.first).to be < 50 # First value should be below 50
        expect(scores.last).to be > 50 # Last value should be above 50
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { Numana.new([42]) }
      let(:identical_analyzer) { Numana.new([5, 5, 5, 5]) }

      it 'handles single value' do
        # Standard deviation is 0, so deviation score calculation is undefined
        # Should return array with NaN or handle gracefully
        expect { single_analyzer.deviation_scores }.not_to raise_error
      end

      it 'handles identical values' do
        # Standard deviation is 0, so deviation score calculation is undefined
        expect { identical_analyzer.deviation_scores }.not_to raise_error
      end
    end

    context 'with negative numbers' do
      let(:negative_analyzer) { Numana.new([-10, -5, 0, 5, 10]) }

      it 'handles negative numbers correctly' do
        scores = negative_analyzer.deviation_scores
        expect(scores.length).to eq(5)
        expect(scores[2]).to be_within(0.01).of(50.0) # Mean (0) should be 50
      end
    end

    context 'with precision' do
      let(:precision_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'returns values rounded to 2 decimal places' do
        scores = precision_analyzer.deviation_scores
        scores.each do |score|
          # Check that each score has at most 2 decimal places
          expect(score).to eq(score.round(2))
        end
      end
    end
  end

  describe '#frequency_distribution' do
    context 'with basic dataset' do
      # Dataset: [1, 2, 2, 3, 3, 3]
      # Expected: {1=>1, 2=>2, 3=>3}
      let(:basic_analyzer) { Numana.new([1, 2, 2, 3, 3, 3]) }

      it 'counts frequency of each value correctly' do
        freq_dist = basic_analyzer.frequency_distribution
        expect(freq_dist).to be_a(Hash)
        expect(freq_dist[1]).to eq(1)
        expect(freq_dist[2]).to eq(2)
        expect(freq_dist[3]).to eq(3)
      end

      it 'includes all unique values as keys' do
        freq_dist = basic_analyzer.frequency_distribution
        expect(freq_dist.keys).to contain_exactly(1, 2, 3)
      end
    end

    context 'with mixed data types' do
      # Dataset: [1.5, 2.5, 1.5, 3.0]
      # Expected: {1.5=>2, 2.5=>1, 3.0=>1}
      let(:float_analyzer) { Numana.new([1.5, 2.5, 1.5, 3.0]) }

      it 'handles float values correctly' do
        freq_dist = float_analyzer.frequency_distribution
        expect(freq_dist[1.5]).to eq(2)
        expect(freq_dist[2.5]).to eq(1)
        expect(freq_dist[3.0]).to eq(1)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { Numana.new([42]) }
      let(:empty_analyzer) { Numana.new([]) }
      let(:identical_analyzer) { Numana.new([5, 5, 5, 5]) }

      it 'handles single value' do
        freq_dist = single_analyzer.frequency_distribution
        expect(freq_dist).to eq({ 42 => 1 })
      end

      it 'handles empty array' do
        freq_dist = empty_analyzer.frequency_distribution
        expect(freq_dist).to eq({})
      end

      it 'handles identical values' do
        freq_dist = identical_analyzer.frequency_distribution
        expect(freq_dist).to eq({ 5 => 4 })
      end
    end

    context 'with unsorted data' do
      # Dataset: [5, 1, 3, 1, 5, 2]
      # Expected: {1=>2, 2=>1, 3=>1, 5=>2}
      let(:unsorted_analyzer) { Numana.new([5, 1, 3, 1, 5, 2]) }

      it 'works correctly with unsorted data' do
        freq_dist = unsorted_analyzer.frequency_distribution
        expect(freq_dist[1]).to eq(2)
        expect(freq_dist[2]).to eq(1)
        expect(freq_dist[3]).to eq(1)
        expect(freq_dist[5]).to eq(2)
      end
    end
  end

  describe '#display_histogram' do
    context 'with basic dataset' do
      # Dataset: [1, 2, 2, 3, 3, 3]
      # Expected histogram:
      # 1: ■ (1)
      # 2: ■■ (2)
      # 3: ■■■ (3)
      let(:basic_analyzer) { Numana.new([1, 2, 2, 3, 3, 3]) }

      it 'displays histogram with ASCII art bars' do
        expected_output = <<~OUTPUT
          度数分布ヒストグラム:
          1: ■ (1)
          2: ■■ (2)
          3: ■■■ (3)
        OUTPUT

        expect { basic_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end

    context 'with single value' do
      let(:single_analyzer) { Numana.new([42]) }

      it 'displays single bar histogram' do
        expected_output = <<~OUTPUT
          度数分布ヒストグラム:
          42: ■ (1)
        OUTPUT

        expect { single_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end

    context 'with empty array' do
      let(:empty_analyzer) { Numana.new([]) }

      it 'displays empty histogram message' do
        expected_output = "度数分布ヒストグラム:\n(データが空です)\n"

        expect { empty_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end

    context 'with varied frequencies' do
      # Dataset: [1, 2, 2, 2, 2, 2] (1 appears 1 time, 2 appears 5 times)
      let(:varied_analyzer) { Numana.new([1, 2, 2, 2, 2, 2]) }

      it 'scales bars correctly based on frequency' do
        expected_output = <<~OUTPUT
          度数分布ヒストグラム:
          1: ■ (1)
          2: ■■■■■ (5)
        OUTPUT

        expect { varied_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end

    context 'with decimal values' do
      let(:decimal_analyzer) { Numana.new([1.5, 1.5, 2.0, 2.5]) }

      it 'handles decimal values correctly' do
        expected_output = <<~OUTPUT
          度数分布ヒストグラム:
          1.5: ■■ (2)
          2.0: ■ (1)
          2.5: ■ (1)
        OUTPUT

        expect { decimal_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end
  end

  describe '#correlation' do
    context 'with perfect positive correlation' do
      let(:analyzer) { Numana.new([1, 2, 3, 4, 5]) }
      let(:other_dataset) { [2, 4, 6, 8, 10] }

      it 'calculates perfect positive correlation' do
        result = analyzer.correlation(other_dataset)
        expect(result).to eq(1.0)
      end
    end

    context 'with perfect negative correlation' do
      let(:analyzer) { Numana.new([1, 2, 3, 4, 5]) }
      let(:other_dataset) { [10, 8, 6, 4, 2] }

      it 'calculates perfect negative correlation' do
        result = analyzer.correlation(other_dataset)
        expect(result).to eq(-1.0)
      end
    end

    context 'with no correlation' do
      let(:analyzer) { Numana.new([1, 2, 3, 4, 5]) }
      let(:other_dataset) { [5, 1, 3, 2, 4] }

      it 'calculates near-zero correlation' do
        result = analyzer.correlation(other_dataset)
        expect(result).to be_within(0.3).of(0.0)
      end
    end

    context 'with edge cases' do
      let(:analyzer) { Numana.new([1, 2, 3]) }

      it 'returns nil for empty dataset' do
        result = analyzer.correlation([])
        expect(result).to be_nil
      end

      it 'returns nil for mismatched lengths' do
        result = analyzer.correlation([1, 2])
        expect(result).to be_nil
      end

      it 'handles identical values' do
        identical_analyzer = Numana.new([5, 5, 5])
        result = identical_analyzer.correlation([5, 5, 5])
        expect(result).to eq(0.0)
      end
    end

    context 'with empty analyzer' do
      let(:empty_analyzer) { Numana.new([]) }

      it 'returns nil for empty analyzer' do
        result = empty_analyzer.correlation([1, 2, 3])
        expect(result).to be_nil
      end
    end
  end

  describe '#moving_average' do
    context 'with basic dataset and window size 3' do
      let(:ma_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }

      it 'calculates 3-period moving average correctly' do
        result = ma_analyzer.moving_average(3)

        expect(result).to be_an(Array)
        expect(result.length).to eq(8) # 10 - 3 + 1 = 8
        expect(result[0]).to be_within(0.001).of(2.0) # (1+2+3)/3
        expect(result[1]).to be_within(0.001).of(3.0) # (2+3+4)/3
        expect(result[2]).to be_within(0.001).of(4.0) # (3+4+5)/3
        expect(result.last).to be_within(0.001).of(9.0) # (8+9+10)/3
      end
    end

    context 'with window size 5' do
      let(:ma_analyzer) { Numana.new([2, 4, 6, 8, 10, 12, 14, 16, 18, 20]) }

      it 'calculates 5-period moving average correctly' do
        result = ma_analyzer.moving_average(5)

        expect(result.length).to eq(6) # 10 - 5 + 1 = 6
        expect(result[0]).to be_within(0.001).of(6.0) # (2+4+6+8+10)/5
        expect(result.last).to be_within(0.001).of(16.0) # (12+14+16+18+20)/5
      end
    end

    context 'with edge cases' do
      it 'returns nil for empty array' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.moving_average(3)).to be_nil
      end

      it 'returns nil when window size is larger than dataset' do
        small_analyzer = Numana.new([1, 2])
        expect(small_analyzer.moving_average(5)).to be_nil
      end

      it 'returns single value when window size equals dataset size' do
        equal_analyzer = Numana.new([1, 2, 3])
        result = equal_analyzer.moving_average(3)
        expect(result).to eq([2.0])
      end

      it 'returns nil for invalid window size' do
        analyzer = Numana.new([1, 2, 3, 4, 5])
        expect(analyzer.moving_average(0)).to be_nil
        expect(analyzer.moving_average(-1)).to be_nil
      end
    end

    context 'with decimal values' do
      let(:decimal_analyzer) { Numana.new([1.5, 2.5, 3.5, 4.5, 5.5]) }

      it 'handles decimal values correctly' do
        result = decimal_analyzer.moving_average(3)

        expect(result.length).to eq(3)
        expect(result[0]).to be_within(0.001).of(2.5) # (1.5+2.5+3.5)/3
        expect(result[1]).to be_within(0.001).of(3.5) # (2.5+3.5+4.5)/3
        expect(result[2]).to be_within(0.001).of(4.5) # (3.5+4.5+5.5)/3
      end
    end
  end

  describe '#growth_rates' do
    context 'with valid numeric data' do
      let(:growth_analyzer) { Numana.new([100, 110, 121, 133]) }

      it 'calculates period-over-period growth rates correctly' do
        result = growth_analyzer.growth_rates

        expect(result.length).to eq(3)
        expect(result[0]).to be_within(0.0001).of(10.0)      # (110-100)/100 * 100
        expect(result[1]).to be_within(0.0001).of(10.0)      # (121-110)/110 * 100
        expect(result[2]).to be_within(0.0001).of(9.9173553719) # (133-121)/121 * 100
      end
    end

    context 'with edge cases' do
      it 'returns empty array for empty dataset' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.growth_rates).to eq([])
      end

      it 'returns empty array for single value' do
        single_analyzer = Numana.new([100])
        expect(single_analyzer.growth_rates).to eq([])
      end

      it 'handles zero values correctly' do
        zero_analyzer = Numana.new([0, 10, 0])
        result = zero_analyzer.growth_rates

        expect(result.length).to eq(2)
        expect(result[0]).to eq(Float::INFINITY) # 10/0 = infinity
        expect(result[1]).to be_within(0.0001).of(-100.0) # (0-10)/10 * 100
      end

      it 'handles negative values correctly' do
        negative_analyzer = Numana.new([100, 90, 110])
        result = negative_analyzer.growth_rates

        expect(result.length).to eq(2)
        expect(result[0]).to be_within(0.0001).of(-10.0) # (90-100)/100 * 100
        expect(result[1]).to be_within(0.0001).of(22.2222222222) # (110-90)/90 * 100
      end

      it 'handles zero to zero transition' do
        zero_to_zero_analyzer = Numana.new([0, 0, 5])
        result = zero_to_zero_analyzer.growth_rates

        expect(result.length).to eq(2)
        expect(result[0]).to eq(0.0)              # (0-0)/0 = 0 (special case)
        expect(result[1]).to eq(Float::INFINITY)  # (5-0)/0 = infinity
      end
    end
  end

  describe '#compound_annual_growth_rate' do
    context 'with valid positive data' do
      let(:cagr_analyzer) { Numana.new([100, 110, 121, 133]) }

      it 'calculates CAGR correctly' do
        result = cagr_analyzer.compound_annual_growth_rate
        # CAGR = ((133/100)^(1/3) - 1) * 100 ≈ 9.97%
        expect(result).to be_within(0.0001).of(9.9724448886)
      end
    end

    context 'with edge cases' do
      it 'returns nil for empty dataset' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.compound_annual_growth_rate).to be_nil
      end

      it 'returns nil for single value' do
        single_analyzer = Numana.new([100])
        expect(single_analyzer.compound_annual_growth_rate).to be_nil
      end

      it 'returns nil for zero or negative initial value' do
        zero_analyzer = Numana.new([0, 100])
        negative_analyzer = Numana.new([-50, 100])

        expect(zero_analyzer.compound_annual_growth_rate).to be_nil
        expect(negative_analyzer.compound_annual_growth_rate).to be_nil
      end

      it 'returns -100% for zero final value' do
        decline_analyzer = Numana.new([100, 50, 0])
        expect(decline_analyzer.compound_annual_growth_rate).to eq(-100.0)
      end

      it 'handles two-value dataset correctly' do
        two_value_analyzer = Numana.new([100, 110])
        result = two_value_analyzer.compound_annual_growth_rate
        # CAGR = ((110/100)^(1/1) - 1) * 100 = 10%
        expect(result).to be_within(0.0001).of(10.0)
      end
    end
  end

  describe '#average_growth_rate' do
    context 'with valid data' do
      let(:avg_analyzer) { Numana.new([100, 110, 121, 133]) }

      it 'calculates average growth rate correctly' do
        result = avg_analyzer.average_growth_rate
        # Average of [10.0, 10.0, 9.9173553719] ≈ 9.9724517906
        expect(result).to be_within(0.0001).of(9.9724517906)
      end
    end

    context 'with edge cases' do
      it 'returns nil for empty dataset' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.average_growth_rate).to be_nil
      end

      it 'returns nil for single value' do
        single_analyzer = Numana.new([100])
        expect(single_analyzer.average_growth_rate).to be_nil
      end

      it 'filters out infinite values in calculation' do
        infinity_analyzer = Numana.new([0, 10, 20])
        result = infinity_analyzer.average_growth_rate
        # Should average only the finite value: (20-10)/10 * 100 = 100%
        expect(result).to be_within(0.0001).of(100.0)
      end

      it 'handles zero values correctly' do
        all_zero_analyzer = Numana.new([0, 0, 0])
        expect(all_zero_analyzer.average_growth_rate).to eq(0.0)
      end
    end
  end

  describe '#seasonal_decomposition' do
    context 'with seasonal data' do
      # Quarterly seasonal pattern: [10, 20, 15, 25, 12, 22, 17, 27]
      # Period 4: indices [11.0, 21.0, 16.0, 26.0]
      let(:seasonal_analyzer) { Numana.new([10, 20, 15, 25, 12, 22, 17, 27]) }

      it 'detects seasonal decomposition correctly' do
        result = seasonal_analyzer.seasonal_decomposition
        expect(result).not_to be_nil
        expect(result[:period]).to eq(4)
        expect(result[:seasonal_indices]).to eq([11.0, 21.0, 16.0, 26.0])
        expect(result[:has_seasonality]).to be true
        expect(result[:seasonal_strength]).to be > 0.1
      end

      it 'accepts manual period specification' do
        result = seasonal_analyzer.seasonal_decomposition(2)
        expect(result).not_to be_nil
        expect(result[:period]).to eq(2)
        expect(result[:seasonal_indices].length).to eq(2)
      end
    end

    context 'with non-seasonal data' do
      # Linear trend with no seasonality: [1, 2, 3, 4, 5, 6, 7, 8]
      let(:linear_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8]) }

      it 'returns nil for linear data (no seasonality detected)' do
        result = linear_analyzer.seasonal_decomposition
        expect(result).to be_nil
      end
    end

    context 'with edge cases' do
      it 'returns nil for insufficient data' do
        short_analyzer = Numana.new([1, 2, 3])
        expect(short_analyzer.seasonal_decomposition).to be_nil
      end

      it 'returns nil for empty dataset' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.seasonal_decomposition).to be_nil
      end

      it 'handles invalid period specification' do
        analyzer = Numana.new([1, 2, 3, 4, 5, 6])
        expect(analyzer.seasonal_decomposition(1)).to be_nil
        expect(analyzer.seasonal_decomposition(10)).to be_nil
      end
    end
  end

  describe '#detect_seasonal_period' do
    context 'with clear seasonal pattern' do
      # 4-period seasonal: [10, 20, 15, 25, 12, 22, 17, 27, 14, 24, 19, 29]
      let(:quarterly_analyzer) { Numana.new([10, 20, 15, 25, 12, 22, 17, 27, 14, 24, 19, 29]) }

      it 'detects quarterly pattern correctly' do
        expect(quarterly_analyzer.detect_seasonal_period).to eq(4)
      end
    end

    context 'with weak or no pattern' do
      let(:linear_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8]) }

      it 'returns nil for data without strong seasonality' do
        expect(linear_analyzer.detect_seasonal_period).to be_nil
      end
    end

    context 'with edge cases' do
      it 'returns nil for insufficient data' do
        short_analyzer = Numana.new([1, 2, 3])
        expect(short_analyzer.detect_seasonal_period).to be_nil
      end

      it 'returns nil for empty dataset' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.detect_seasonal_period).to be_nil
      end
    end
  end

  describe '#seasonal_strength' do
    context 'with seasonal data' do
      let(:seasonal_analyzer) { Numana.new([10, 20, 15, 25, 12, 22, 17, 27]) }

      it 'returns positive strength for seasonal data' do
        strength = seasonal_analyzer.seasonal_strength
        expect(strength).to be > 0.1
        expect(strength).to be <= 1.0
      end
    end

    context 'with non-seasonal data' do
      let(:linear_analyzer) { Numana.new([1, 2, 3, 4, 5, 6, 7, 8]) }

      it 'returns 0.0 strength for non-seasonal data' do
        strength = linear_analyzer.seasonal_strength
        expect(strength).to eq(0.0)
      end
    end

    context 'with edge cases' do
      it 'returns 0.0 for insufficient data' do
        short_analyzer = Numana.new([1, 2, 3])
        expect(short_analyzer.seasonal_strength).to eq(0.0)
      end

      it 'returns 0.0 for empty dataset' do
        empty_analyzer = Numana.new([])
        expect(empty_analyzer.seasonal_strength).to eq(0.0)
      end
    end
  end

  describe '#t_test' do
    context 'independent samples t-test' do
      let(:group1) { Numana.new([20, 22, 24, 26, 28]) }
      let(:group2) { [18, 20, 22, 24, 26] }

      it 'performs independent samples t-test correctly' do
        result = group1.t_test(group2, type: :independent)

        expect(result).not_to be_nil
        expect(result[:test_type]).to eq('independent_samples')
        expect(result[:t_statistic]).to be_a(Float)
        expect(result[:degrees_of_freedom]).to be_a(Float)
        expect(result[:p_value]).to be_a(Float)
        expect(result[:mean1]).to eq(24.0)
        expect(result[:mean2]).to eq(22.0)
        expect(result[:n1]).to eq(5)
        expect(result[:n2]).to eq(5)
        expect(result).to have_key(:significant)
      end

      it 'handles equal groups with known result' do
        equal_group1 = Numana.new([1, 2, 3, 4, 5])
        equal_group2 = [1, 2, 3, 4, 5]

        result = equal_group1.t_test(equal_group2, type: :independent)

        expect(result[:t_statistic]).to be_within(0.001).of(0.0)
        expect(result[:p_value]).to be > 0.05
        expect(result[:significant]).to be false
      end

      it 'returns nil for empty other_data' do
        result = group1.t_test([], type: :independent)
        expect(result).to be_nil
      end

      it 'returns nil for nil other_data' do
        result = group1.t_test(nil, type: :independent)
        expect(result).to be_nil
      end
    end

    context 'paired samples t-test' do
      let(:before) { Numana.new([20, 22, 24, 26, 28]) }
      let(:after) { [21, 24, 25, 28, 32] }

      it 'performs paired samples t-test correctly' do
        result = before.t_test(after, type: :paired)

        expect(result).not_to be_nil
        expect(result[:test_type]).to eq('paired_samples')
        expect(result[:t_statistic]).to be_a(Float)
        expect(result[:degrees_of_freedom]).to eq(4)
        expect(result[:p_value]).to be_a(Float)
        expect(result[:mean_difference]).to be_a(Float)
        expect(result[:n]).to eq(5)
        expect(result).to have_key(:significant)
      end

      it 'handles identical pairs with known result' do
        identical = Numana.new([1, 2, 3, 4, 5])

        result = identical.t_test([1, 2, 3, 4, 5], type: :paired)

        # When all differences are zero, standard error is zero, so result is nil
        expect(result).to be_nil
      end

      it 'returns nil for mismatched array lengths' do
        result = before.t_test([1, 2, 3], type: :paired)
        expect(result).to be_nil
      end

      it 'returns nil for empty other_data' do
        result = before.t_test([], type: :paired)
        expect(result).to be_nil
      end

      it 'returns nil for nil other_data' do
        result = before.t_test(nil, type: :paired)
        expect(result).to be_nil
      end
    end

    context 'one sample t-test' do
      let(:sample) { Numana.new([18, 20, 22, 24, 26]) }

      it 'performs one sample t-test correctly' do
        result = sample.t_test(nil, type: :one_sample, population_mean: 20)

        expect(result).not_to be_nil
        expect(result[:test_type]).to eq('one_sample')
        expect(result[:t_statistic]).to be_a(Float)
        expect(result[:degrees_of_freedom]).to eq(4)
        expect(result[:p_value]).to be_a(Float)
        expect(result[:sample_mean]).to eq(22.0)
        expect(result[:population_mean]).to eq(20.0)
        expect(result[:n]).to eq(5)
        expect(result).to have_key(:significant)
      end

      it 'handles sample mean equal to population mean' do
        equal_sample = Numana.new([20, 20, 20, 20, 20])

        result = equal_sample.t_test(nil, type: :one_sample, population_mean: 20)

        expect(result).to be_nil # Standard error is zero
      end

      it 'returns nil for nil population_mean' do
        result = sample.t_test(nil, type: :one_sample, population_mean: nil)
        expect(result).to be_nil
      end

      it 'returns nil for insufficient sample size' do
        single_sample = Numana.new([20])

        result = single_sample.t_test(nil, type: :one_sample, population_mean: 20)
        expect(result).to be_nil
      end
    end

    context 'invalid test types' do
      let(:data) { Numana.new([1, 2, 3, 4, 5]) }

      it 'raises error for invalid test type' do
        expect { data.t_test([1, 2, 3], type: :invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'empty dataset' do
      let(:empty_data) { Numana.new([]) }

      it 'returns nil for empty dataset' do
        result = empty_data.t_test([1, 2, 3], type: :independent)
        expect(result).to be_nil
      end
    end

    context 'mathematical accuracy verification' do
      it 'produces expected t-statistic for known data' do
        # Known test case: group1 mean = 3, group2 mean = 2, with specific variances
        group1_data = Numana.new([1, 3, 5])
        group2_data = [0, 2, 4]

        result = group1_data.t_test(group2_data, type: :independent)

        # With these specific values, we expect a t-statistic around 0.612
        expect(result[:t_statistic]).to be_within(0.1).of(0.612)
        expect(result[:mean1]).to eq(3.0)
        expect(result[:mean2]).to eq(2.0)
      end

      it 'produces expected results for paired test with known differences' do
        before_data = Numana.new([10, 12, 14, 16, 18])
        after_data = [11, 14, 15, 18, 22]

        result = before_data.t_test(after_data, type: :paired)

        # Should have negative mean difference and t-statistic
        expect(result).not_to be_nil
        expect(result[:mean_difference]).to be < 0
        expect(result[:t_statistic]).to be < 0
      end
    end
  end

  describe '#confidence_interval' do
    context 'with basic sample data' do
      # Sample: [1, 2, 3, 4, 5], n=5, mean=3.0, standard_error=0.707
      # Calculated 95% CI: [1.037, 4.963] using t-distribution (df=4, t=2.776)
      let(:basic_data) { [1, 2, 3, 4, 5] }
      let(:basic_analyzer) { Numana.new(basic_data) }

      it 'calculates 95% confidence interval for mean' do
        result = basic_analyzer.confidence_interval(95)

        expect(result).to be_a(Hash)
        expect(result[:confidence_level]).to eq(95)
        expect(result[:point_estimate]).to be_within(0.01).of(3.0)
        expect(result[:lower_bound]).to be_within(0.01).of(1.037)
        expect(result[:upper_bound]).to be_within(0.01).of(4.963)
        expect(result[:margin_of_error]).to be > 0
        expect(result[:sample_size]).to eq(5)
      end

      it 'calculates 90% confidence interval for mean' do
        result = basic_analyzer.confidence_interval(90)

        expect(result[:confidence_level]).to eq(90)
        expect(result[:lower_bound]).to be_within(0.01).of(1.43) # 90% CI should be narrower
        expect(result[:upper_bound]).to be_within(0.01).of(4.57) # than 95% CI
      end

      it 'calculates 99% confidence interval for mean' do
        result = basic_analyzer.confidence_interval(99)

        expect(result[:confidence_level]).to eq(99)
        expect(result[:lower_bound]).to be_within(0.01).of(0.448) # 99% CI should be wider
        expect(result[:upper_bound]).to be_within(0.01).of(5.552) # than 95% CI
      end
    end

    context 'with edge cases' do
      it 'handles single value dataset' do
        single_analyzer = Numana.new([42])
        result = single_analyzer.confidence_interval(95)

        expect(result).to be_nil # Cannot calculate CI with n=1
      end

      it 'handles empty dataset' do
        empty_analyzer = Numana.new([])
        result = empty_analyzer.confidence_interval(95)

        expect(result).to be_nil
      end

      it 'handles two-value dataset' do
        two_analyzer = Numana.new([10, 20])
        result = two_analyzer.confidence_interval(95)

        expect(result).not_to be_nil
        expect(result[:point_estimate]).to eq(15.0)
        expect(result[:sample_size]).to eq(2)
      end
    end

    context 'with larger sample' do
      # Large sample to test normal approximation
      let(:large_data) { (1..50).to_a }
      let(:large_analyzer) { Numana.new(large_data) }

      it 'calculates confidence interval for large sample' do
        result = large_analyzer.confidence_interval(95)

        expect(result[:point_estimate]).to eq(25.5)
        expect(result[:sample_size]).to eq(50)
        expect(result[:lower_bound]).to be < 25.5
        expect(result[:upper_bound]).to be > 25.5
      end
    end

    context 'with invalid inputs' do
      let(:test_analyzer) { Numana.new([1, 2, 3, 4, 5]) }

      it 'raises error for invalid confidence level' do
        expect { test_analyzer.confidence_interval(150) }.to raise_error(ArgumentError)
        expect { test_analyzer.confidence_interval(-10) }.to raise_error(ArgumentError)
        expect { test_analyzer.confidence_interval(0) }.to raise_error(ArgumentError)
      end

      it 'raises error for invalid type' do
        expect { test_analyzer.confidence_interval(95, type: :invalid) }.to raise_error(ArgumentError)
      end
    end

    context 'with different data types' do
      let(:float_data) { [1.1, 2.2, 3.3, 4.4, 5.5] }
      let(:float_analyzer) { Numana.new(float_data) }

      it 'handles floating point data correctly' do
        result = float_analyzer.confidence_interval(95)

        expect(result[:point_estimate]).to be_within(0.01).of(3.3)
        expect(result[:lower_bound]).to be < result[:point_estimate]
        expect(result[:upper_bound]).to be > result[:point_estimate]
      end
    end
  end

  describe '#chi_square_test' do
    context 'with independence test data' do
      # Classic 2x2 contingency table example: Gender vs Product Preference
      # Male: Product A=30, Product B=20 (total=50)
      # Female: Product A=15, Product B=35 (total=50)
      # Expected: χ² = 9.091, df = 1, p ≈ 0.0026
      let(:contingency_data) { [[30, 20], [15, 35]] }
      let(:independence_analyzer) { Numana.new(contingency_data.flatten) }

      it 'calculates independence test correctly for 2x2 table' do
        result = independence_analyzer.chi_square_test(contingency_data, type: :independence)

        expect(result).to be_a(Hash)
        expect(result[:test_type]).to eq('independence')
        expect(result[:chi_square_statistic]).to be_within(0.01).of(9.091)
        expect(result[:degrees_of_freedom]).to eq(1)
        expect(result[:p_value]).to be < 0.01 # p < 0.01 for significance
        expect(result[:significant]).to be true
        expect(result[:cramers_v]).to be_within(0.01).of(0.302)
        expect(result[:expected_frequencies_valid]).to be true
      end

      it 'includes expected frequencies in result' do
        result = independence_analyzer.chi_square_test(contingency_data, type: :independence)

        expect(result[:expected_frequencies]).to eq([[22.5, 27.5], [22.5, 27.5]])
        expect(result[:observed_frequencies]).to eq([[30, 20], [15, 35]])
      end
    end

    context 'with 3x3 contingency table' do
      # Larger table: Education Level vs Voting Preference
      let(:larger_table) { [[20, 30, 25], [15, 20, 30], [10, 25, 40]] }
      let(:larger_analyzer) { Numana.new(larger_table.flatten) }

      it 'calculates independence test for larger tables' do
        result = larger_analyzer.chi_square_test(larger_table, type: :independence)

        expect(result[:test_type]).to eq('independence')
        expect(result[:degrees_of_freedom]).to eq(4) # (3-1) × (3-1)
        expect(result[:chi_square_statistic]).to be > 0
        expect(result[:p_value]).to be_between(0, 1)
        expect(result[:cramers_v]).to be_between(0, 1)
      end
    end

    context 'with goodness-of-fit test data' do
      # Dice fairness test: observed frequencies for faces 1-6
      # Expected: uniform distribution (10 each)
      # Observed: [8, 12, 10, 15, 9, 6]
      # Expected: χ² = 4.0, df = 5
      let(:dice_observed) { [8, 12, 10, 15, 9, 6] }
      let(:dice_expected) { [10, 10, 10, 10, 10, 10] }
      let(:dice_analyzer) { Numana.new(dice_observed) }

      it 'calculates goodness-of-fit test correctly' do
        result = dice_analyzer.chi_square_test(dice_expected, type: :goodness_of_fit)

        expect(result[:test_type]).to eq('goodness_of_fit')
        expect(result[:chi_square_statistic]).to be_within(0.01).of(5.0)
        expect(result[:degrees_of_freedom]).to eq(5) # categories - 1
        expect(result[:p_value]).to eq(0.4) # Based on our critical value table
        expect(result[:significant]).to be false
        expect(result[:observed_frequencies]).to eq(dice_observed)
        expect(result[:expected_frequencies]).to eq(dice_expected)
      end

      it 'handles uniform distribution assumption' do
        result = dice_analyzer.chi_square_test(nil, type: :goodness_of_fit)

        expected_uniform = [10, 10, 10, 10, 10, 10] # 60/6 = 10 each
        expect(result[:expected_frequencies]).to eq(expected_uniform)
        expect(result[:test_type]).to eq('goodness_of_fit')
      end
    end

    context 'with edge cases and validation' do
      let(:empty_analyzer) { Numana.new([]) }
      let(:single_analyzer) { Numana.new([42]) }
      let(:test_analyzer) { Numana.new([8, 12, 10, 15, 9, 6]) }

      it 'returns nil for empty data' do
        result = empty_analyzer.chi_square_test([[1, 2], [3, 4]], type: :independence)
        expect(result).to be_nil
      end

      it 'returns nil for insufficient data' do
        result = single_analyzer.chi_square_test([5], type: :goodness_of_fit)
        expect(result).to be_nil
      end

      it 'validates expected frequency conditions' do
        # Low expected frequencies (< 5 in some cells)
        low_freq_data = [[2, 1], [1, 2]]
        low_freq_analyzer = Numana.new(low_freq_data.flatten)

        result = low_freq_analyzer.chi_square_test(low_freq_data, type: :independence)
        expect(result[:expected_frequencies_valid]).to be false
        expect(result[:warning]).to include('期待度数')
      end

      it 'raises error for invalid test type' do
        expect do
          test_analyzer.chi_square_test([1, 2, 3], type: :invalid)
        end.to raise_error(ArgumentError, /Invalid chi-square test type/)
      end

      it 'raises error for mismatched dimensions' do
        expect do
          test_analyzer.chi_square_test([1, 2], type: :goodness_of_fit)
        end.to raise_error(ArgumentError, /Observed and expected frequencies must have same length/)
      end
    end

    context 'with different significance levels' do
      let(:marginal_data) { [[15, 10], [10, 15]] } # Weaker association
      let(:marginal_analyzer) { Numana.new(marginal_data.flatten) }

      it 'correctly identifies non-significant results' do
        result = marginal_analyzer.chi_square_test(marginal_data, type: :independence)

        expect(result[:significant]).to be false
        expect(result[:p_value]).to be > 0.05
        expect(result[:cramers_v]).to be < 0.3 # Weak effect size
      end
    end

    context 'with perfect independence' do
      # Perfectly independent data (no association)
      let(:perfect_data) { [[25, 25], [25, 25]] }
      let(:perfect_analyzer) { Numana.new(perfect_data.flatten) }

      it 'identifies perfect independence' do
        result = perfect_analyzer.chi_square_test(perfect_data, type: :independence)

        expect(result[:chi_square_statistic]).to be_within(0.001).of(0.0)
        expect(result[:p_value]).to be_within(0.001).of(1.0)
        expect(result[:significant]).to be false
        expect(result[:cramers_v]).to be_within(0.001).of(0.0)
      end
    end
  end
end
