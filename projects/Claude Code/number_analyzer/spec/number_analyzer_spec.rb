require_relative '../lib/number_analyzer'

RSpec.describe NumberAnalyzer do
  let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }
  let(:analyzer) { NumberAnalyzer.new(numbers) }

  describe '#calculate_statistics' do
    it 'outputs correct statistics for the given numbers' do
      expected_output = "合計: 55\n平均: 5.5\n最大値: 10\n最小値: 1\n中央値: 5.5\n分散: 8.25\n最頻値: なし\n標準偏差: 2.87\n四分位範囲(IQR): 4.5\n外れ値: なし\n偏差値: 34.33, 37.81, 41.3, 44.78, 48.26, 51.74, 55.22, 58.7, 62.19, 65.67\n\n度数分布ヒストグラム:\n1: ■ (1)\n2: ■ (1)\n3: ■ (1)\n4: ■ (1)\n5: ■ (1)\n6: ■ (1)\n7: ■ (1)\n8: ■ (1)\n9: ■ (1)\n10: ■ (1)\n"
      
      expect { analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with single number' do
    let(:single_analyzer) { NumberAnalyzer.new([42]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 42\n平均: 42.0\n最大値: 42\n最小値: 42\n中央値: 42\n分散: 0.0\n最頻値: なし\n標準偏差: 0.0\n四分位範囲(IQR): 0\n外れ値: なし\n偏差値: 50.0\n\n度数分布ヒストグラム:\n42: ■ (1)\n"
      
      expect { single_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with negative numbers' do
    let(:negative_analyzer) { NumberAnalyzer.new([-5, -2, -10, -1]) }

    it 'handles negative numbers correctly' do
      expected_output = "合計: -18\n平均: -4.5\n最大値: -1\n最小値: -10\n中央値: -3.5\n分散: 12.25\n最頻値: なし\n標準偏差: 3.5\n四分位範囲(IQR): 4.5\n外れ値: なし\n偏差値: 48.57, 57.14, 34.29, 60.0\n\n度数分布ヒストグラム:\n-10: ■ (1)\n-5: ■ (1)\n-2: ■ (1)\n-1: ■ (1)\n"
      
      expect { negative_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with mixed positive and negative numbers' do
    let(:mixed_analyzer) { NumberAnalyzer.new([-3, 0, 5, -1, 2]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 3\n平均: 0.6\n最大値: 5\n最小値: -3\n中央値: 0\n分散: 7.44\n最頻値: なし\n標準偏差: 2.73\n四分位範囲(IQR): 3\n外れ値: なし\n偏差値: 36.8, 47.8, 66.13, 44.13, 55.13\n\n度数分布ヒストグラム:\n-3: ■ (1)\n-1: ■ (1)\n0: ■ (1)\n2: ■ (1)\n5: ■ (1)\n"
      
      expect { mixed_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with duplicate numbers' do
    let(:duplicate_analyzer) { NumberAnalyzer.new([3, 3, 3, 3]) }

    it 'handles duplicate values correctly' do
      expected_output = "合計: 12\n平均: 3.0\n最大値: 3\n最小値: 3\n中央値: 3.0\n分散: 0.0\n最頻値: 3\n標準偏差: 0.0\n四分位範囲(IQR): 0.0\n外れ値: なし\n偏差値: 50.0, 50.0, 50.0, 50.0\n\n度数分布ヒストグラム:\n3: ■■■■ (4)\n"
      
      expect { duplicate_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  describe '#linear_trend' do
    context 'with perfect upward trend' do
      let(:trend_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }

      it 'calculates correct trend slope and intercept' do
        result = trend_analyzer.linear_trend
        
        expect(result[:slope]).to be_within(0.001).of(1.0)
        expect(result[:intercept]).to be_within(0.001).of(1.0)
        expect(result[:r_squared]).to be_within(0.001).of(1.0)
        expect(result[:direction]).to eq('上昇')
      end
    end

    context 'with perfect downward trend' do
      let(:downward_analyzer) { NumberAnalyzer.new([5, 4, 3, 2, 1]) }

      it 'detects downward trend' do
        result = downward_analyzer.linear_trend
        
        expect(result[:slope]).to be_within(0.001).of(-1.0)
        expect(result[:direction]).to eq('下降')
      end
    end

    context 'with no trend (flat)' do
      let(:flat_analyzer) { NumberAnalyzer.new([5, 5, 5, 5, 5]) }

      it 'detects flat trend' do
        result = flat_analyzer.linear_trend
        
        expect(result[:slope]).to be_within(0.001).of(0.0)
        expect(result[:direction]).to eq('横ばい')
      end
    end

    context 'with empty array' do
      let(:empty_analyzer) { NumberAnalyzer.new([]) }

      it 'returns nil for empty dataset' do
        expect(empty_analyzer.linear_trend).to be_nil
      end
    end

    context 'with single value' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }

      it 'returns nil for single value' do
        expect(single_analyzer.linear_trend).to be_nil
      end
    end
  end

  describe '#median' do
    context 'with odd number of elements' do
      let(:odd_analyzer) { NumberAnalyzer.new([1, 3, 5, 7, 9]) }
      
      it 'returns the middle value' do
        expect(odd_analyzer.median).to eq(5)
      end
    end

    context 'with even number of elements' do
      let(:even_analyzer) { NumberAnalyzer.new([1, 2, 3, 4]) }
      
      it 'returns the average of two middle values' do
        expect(even_analyzer.median).to eq(2.5)
      end
    end

    context 'with single element' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      
      it 'returns the single element' do
        expect(single_analyzer.median).to eq(42)
      end
    end

    context 'with unsorted array' do
      let(:unsorted_analyzer) { NumberAnalyzer.new([5, 1, 9, 3, 7]) }
      
      it 'correctly finds median of unsorted data' do
        expect(unsorted_analyzer.median).to eq(5)
      end
    end
  end

  describe '#mode' do
    context 'with single mode' do
      let(:single_mode_analyzer) { NumberAnalyzer.new([1, 2, 2, 3, 4]) }
      
      it 'returns the most frequent value' do
        expect(single_mode_analyzer.mode).to eq([2])
      end
    end

    context 'with multiple modes' do
      let(:multi_mode_analyzer) { NumberAnalyzer.new([1, 1, 2, 2, 3]) }
      
      it 'returns array of most frequent values' do
        expect(multi_mode_analyzer.mode).to contain_exactly(1, 2)
      end
    end

    context 'with no mode (all unique)' do
      let(:no_mode_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      
      it 'returns empty array' do
        expect(no_mode_analyzer.mode).to eq([])
      end
    end

    context 'with all same values' do
      let(:all_same_analyzer) { NumberAnalyzer.new([5, 5, 5, 5]) }
      
      it 'returns the repeated value' do
        expect(all_same_analyzer.mode).to eq([5])
      end
    end
  end

  describe '#variance' do
    context 'with known values' do
      let(:known_analyzer) { NumberAnalyzer.new([2, 4, 4, 4, 5, 5, 7, 9]) }
      
      it 'calculates variance correctly' do
        expect(known_analyzer.variance).to be_within(0.01).of(4.0)
      end
    end

    context 'with single value' do
      let(:single_analyzer) { NumberAnalyzer.new([5]) }
      
      it 'returns zero for single value' do
        expect(single_analyzer.variance).to eq(0)
      end
    end

    context 'with identical values' do
      let(:identical_analyzer) { NumberAnalyzer.new([3, 3, 3, 3]) }
      
      it 'returns zero for identical values' do
        expect(identical_analyzer.variance).to eq(0)
      end
    end

    context 'with simple case' do
      let(:simple_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      
      it 'calculates variance for simple sequence' do
        expect(simple_analyzer.variance).to be_within(0.01).of(2.0)
      end
    end
  end

  describe '#percentile' do
    context 'with known dataset' do
      let(:percentile_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }
      
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
      let(:boundary_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      
      it 'returns minimum for 0th percentile' do
        expect(boundary_analyzer.percentile(0)).to eq(1)
      end
      
      it 'returns maximum for 100th percentile' do
        expect(boundary_analyzer.percentile(100)).to eq(5)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      let(:two_analyzer) { NumberAnalyzer.new([1, 3]) }
      
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
      let(:unsorted_analyzer) { NumberAnalyzer.new([5, 1, 9, 3, 7]) }
      
      it 'correctly sorts data before calculation' do
        expect(unsorted_analyzer.percentile(50)).to eq(5)
      end
    end
  end

  describe '#quartiles' do
    context 'with known dataset' do
      let(:quartiles_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }
      
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
      let(:small_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      let(:even_analyzer) { NumberAnalyzer.new([2, 4, 6, 8]) }
      
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
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      let(:identical_analyzer) { NumberAnalyzer.new([5, 5, 5, 5]) }
      
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
      let(:known_analyzer) { NumberAnalyzer.new([2, 4, 4, 4, 5, 5, 7, 9]) }
      
      it 'calculates standard deviation correctly' do
        expect(known_analyzer.standard_deviation).to be_within(0.01).of(2.0)
      end
    end

    context 'with single value' do
      let(:single_analyzer) { NumberAnalyzer.new([5]) }
      
      it 'returns zero for single value' do
        expect(single_analyzer.standard_deviation).to eq(0)
      end
    end

    context 'with identical values' do
      let(:identical_analyzer) { NumberAnalyzer.new([3, 3, 3, 3]) }
      
      it 'returns zero for identical values' do
        expect(identical_analyzer.standard_deviation).to eq(0)
      end
    end

    context 'with simple case' do
      let(:simple_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      
      it 'calculates standard deviation for simple sequence' do
        expect(simple_analyzer.standard_deviation).to be_within(0.01).of(1.41)
      end
    end
  end

  describe '#interquartile_range' do
    context 'with known dataset' do
      let(:iqr_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }
      
      it 'calculates IQR correctly' do
        # Q1 = 3.25, Q3 = 7.75, so IQR = 7.75 - 3.25 = 4.5
        expect(iqr_analyzer.interquartile_range).to be_within(0.01).of(4.5)
      end
    end

    context 'with simple sequence' do
      let(:simple_analyzer) { NumberAnalyzer.new([1, 3, 5, 7, 9]) }
      
      it 'calculates IQR for odd number of values' do
        # Q1 = 3, Q3 = 7, so IQR = 7 - 3 = 4
        expect(simple_analyzer.interquartile_range).to eq(4)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      let(:two_analyzer) { NumberAnalyzer.new([1, 5]) }
      
      it 'handles single value' do
        expect(single_analyzer.interquartile_range).to eq(0)
      end
      
      it 'handles two values' do
        # For [1, 5]: using linear interpolation, Q1 = 2, Q3 = 4, so IQR = 4 - 2 = 2
        expect(two_analyzer.interquartile_range).to eq(2.0)
      end
    end

    context 'with empty array' do
      let(:empty_analyzer) { NumberAnalyzer.new([]) }
      
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
      let(:outlier_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5, 100]) }
      
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
      let(:lower_outlier_analyzer) { NumberAnalyzer.new([-50, 1, 2, 3, 4, 5]) }
      
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
      let(:multi_outlier_analyzer) { NumberAnalyzer.new([-100, 1, 2, 3, 4, 5, 200]) }
      
      it 'identifies multiple outliers correctly' do
        expect(multi_outlier_analyzer.outliers).to contain_exactly(-100, 200)
      end
    end

    context 'with no outliers' do
      let(:no_outlier_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) }
      
      it 'returns empty array when no outliers present' do
        expect(no_outlier_analyzer.outliers).to eq([])
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      let(:two_analyzer) { NumberAnalyzer.new([1, 5]) }
      let(:empty_analyzer) { NumberAnalyzer.new([]) }
      
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
      let(:identical_analyzer) { NumberAnalyzer.new([5, 5, 5, 5, 5]) }
      
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
      let(:deviation_analyzer) { NumberAnalyzer.new([60, 70, 80, 90, 100]) }
      
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
      let(:simple_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      
      it 'calculates deviation scores for simple sequence' do
        scores = simple_analyzer.deviation_scores
        expect(scores.length).to eq(5)
        expect(scores[2]).to be_within(0.01).of(50.0) # Middle value should be 50
        expect(scores.first).to be < 50 # First value should be below 50
        expect(scores.last).to be > 50 # Last value should be above 50
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      let(:identical_analyzer) { NumberAnalyzer.new([5, 5, 5, 5]) }
      
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
      let(:negative_analyzer) { NumberAnalyzer.new([-10, -5, 0, 5, 10]) }
      
      it 'handles negative numbers correctly' do
        scores = negative_analyzer.deviation_scores
        expect(scores.length).to eq(5)
        expect(scores[2]).to be_within(0.01).of(50.0) # Mean (0) should be 50
      end
    end

    context 'with precision' do
      let(:precision_analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      
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
      let(:basic_analyzer) { NumberAnalyzer.new([1, 2, 2, 3, 3, 3]) }
      
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
      let(:float_analyzer) { NumberAnalyzer.new([1.5, 2.5, 1.5, 3.0]) }
      
      it 'handles float values correctly' do
        freq_dist = float_analyzer.frequency_distribution
        expect(freq_dist[1.5]).to eq(2)
        expect(freq_dist[2.5]).to eq(1)
        expect(freq_dist[3.0]).to eq(1)
      end
    end

    context 'with edge cases' do
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      let(:empty_analyzer) { NumberAnalyzer.new([]) }
      let(:identical_analyzer) { NumberAnalyzer.new([5, 5, 5, 5]) }
      
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
      let(:unsorted_analyzer) { NumberAnalyzer.new([5, 1, 3, 1, 5, 2]) }
      
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
      let(:basic_analyzer) { NumberAnalyzer.new([1, 2, 2, 3, 3, 3]) }
      
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
      let(:single_analyzer) { NumberAnalyzer.new([42]) }
      
      it 'displays single bar histogram' do
        expected_output = <<~OUTPUT
          度数分布ヒストグラム:
          42: ■ (1)
        OUTPUT

        expect { single_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end

    context 'with empty array' do
      let(:empty_analyzer) { NumberAnalyzer.new([]) }
      
      it 'displays empty histogram message' do
        expected_output = "度数分布ヒストグラム:\n(データが空です)\n"

        expect { empty_analyzer.display_histogram }.to output(expected_output).to_stdout
      end
    end

    context 'with varied frequencies' do
      # Dataset: [1, 2, 2, 2, 2, 2] (1 appears 1 time, 2 appears 5 times)
      let(:varied_analyzer) { NumberAnalyzer.new([1, 2, 2, 2, 2, 2]) }
      
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
      let(:decimal_analyzer) { NumberAnalyzer.new([1.5, 1.5, 2.0, 2.5]) }
      
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
      let(:analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      let(:other_dataset) { [2, 4, 6, 8, 10] }
      
      it 'calculates perfect positive correlation' do
        result = analyzer.correlation(other_dataset)
        expect(result).to eq(1.0)
      end
    end

    context 'with perfect negative correlation' do
      let(:analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      let(:other_dataset) { [10, 8, 6, 4, 2] }
      
      it 'calculates perfect negative correlation' do
        result = analyzer.correlation(other_dataset)
        expect(result).to eq(-1.0)
      end
    end

    context 'with no correlation' do
      let(:analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
      let(:other_dataset) { [5, 1, 3, 2, 4] }
      
      it 'calculates near-zero correlation' do
        result = analyzer.correlation(other_dataset)
        expect(result).to be_within(0.3).of(0.0)
      end
    end

    context 'with edge cases' do
      let(:analyzer) { NumberAnalyzer.new([1, 2, 3]) }
      
      it 'returns nil for empty dataset' do
        result = analyzer.correlation([])
        expect(result).to be_nil
      end
      
      it 'returns nil for mismatched lengths' do
        result = analyzer.correlation([1, 2])
        expect(result).to be_nil
      end
      
      it 'handles identical values' do
        identical_analyzer = NumberAnalyzer.new([5, 5, 5])
        result = identical_analyzer.correlation([5, 5, 5])
        expect(result).to eq(0.0)
      end
    end

    context 'with empty analyzer' do
      let(:empty_analyzer) { NumberAnalyzer.new([]) }
      
      it 'returns nil for empty analyzer' do
        result = empty_analyzer.correlation([1, 2, 3])
        expect(result).to be_nil
      end
    end
  end
end