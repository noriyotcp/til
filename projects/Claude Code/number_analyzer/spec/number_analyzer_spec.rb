require_relative '../number_analyzer'

RSpec.describe NumberAnalyzer do
  let(:numbers) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] }
  let(:analyzer) { NumberAnalyzer.new(numbers) }

  describe '#calculate_statistics' do
    it 'outputs correct statistics for the given numbers' do
      expected_output = "合計: 55\n平均: 5.5\n最大値: 10\n最小値: 1\n"
      
      expect { analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with single number' do
    let(:single_analyzer) { NumberAnalyzer.new([42]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 42\n平均: 42.0\n最大値: 42\n最小値: 42\n"
      
      expect { single_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with negative numbers' do
    let(:negative_analyzer) { NumberAnalyzer.new([-5, -2, -10, -1]) }

    it 'handles negative numbers correctly' do
      expected_output = "合計: -18\n平均: -4.5\n最大値: -1\n最小値: -10\n"
      
      expect { negative_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with mixed positive and negative numbers' do
    let(:mixed_analyzer) { NumberAnalyzer.new([-3, 0, 5, -1, 2]) }

    it 'calculates statistics correctly' do
      expected_output = "合計: 3\n平均: 0.6\n最大値: 5\n最小値: -3\n"
      
      expect { mixed_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end

  context 'with duplicate numbers' do
    let(:duplicate_analyzer) { NumberAnalyzer.new([3, 3, 3, 3]) }

    it 'handles duplicate values correctly' do
      expected_output = "合計: 12\n平均: 3.0\n最大値: 3\n最小値: 3\n"
      
      expect { duplicate_analyzer.calculate_statistics }.to output(expected_output).to_stdout
    end
  end
end