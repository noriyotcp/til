require_relative '../lib/number_analyzer'

RSpec.describe NumberAnalyzer do
  let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }
  let(:analyzer) { NumberAnalyzer.new(numbers) }

  describe '#calculate_statistics' do
    it 'outputs correct statistics for the given numbers' do
      expected_output = "合計: 55\n平均: 5.5\n最大値: 10\n最小値: 1\n中央値: 5.5\n分散: 8.25\n最頻値: なし\n標準偏差: 2.87\n"
      
      expect { analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with single number' do
    let(:single_analyzer) { NumberAnalyzer.new([42]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 42\n平均: 42.0\n最大値: 42\n最小値: 42\n中央値: 42\n分散: 0.0\n最頻値: なし\n標準偏差: 0.0\n"
      
      expect { single_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with negative numbers' do
    let(:negative_analyzer) { NumberAnalyzer.new([-5, -2, -10, -1]) }

    it 'handles negative numbers correctly' do
      expected_output = "合計: -18\n平均: -4.5\n最大値: -1\n最小値: -10\n中央値: -3.5\n分散: 12.25\n最頻値: なし\n標準偏差: 3.5\n"
      
      expect { negative_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with mixed positive and negative numbers' do
    let(:mixed_analyzer) { NumberAnalyzer.new([-3, 0, 5, -1, 2]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 3\n平均: 0.6\n最大値: 5\n最小値: -3\n中央値: 0\n分散: 7.44\n最頻値: なし\n標準偏差: 2.73\n"
      
      expect { mixed_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with duplicate numbers' do
    let(:duplicate_analyzer) { NumberAnalyzer.new([3, 3, 3, 3]) }

    it 'handles duplicate values correctly' do
      expected_output = "合計: 12\n平均: 3.0\n最大値: 3\n最小値: 3\n中央値: 3.0\n分散: 0.0\n最頻値: 3\n標準偏差: 0.0\n"
      
      expect { duplicate_analyzer.calculate_statistics }.to output(expected_output).to_stdout
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
end