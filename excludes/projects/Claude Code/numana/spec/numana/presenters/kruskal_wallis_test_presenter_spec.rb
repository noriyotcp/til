# frozen_string_literal: true

require 'spec_helper'
require 'numana/presenters/kruskal_wallis_test_presenter'

RSpec.describe Numana::Presenters::KruskalWallisTestPresenter do
  let(:kruskal_wallis_result) do
    {
      test_type: 'Kruskal-Wallis H Test',
      h_statistic: 8.456,
      p_value: 0.015,
      degrees_of_freedom: 2,
      significant: true,
      interpretation: 'グループ間に統計的有意差が認められる（分布に違いがある）',
      group_sizes: [5, 6, 4],
      total_n: 15
    }
  end

  let(:non_significant_result) do
    {
      test_type: 'Kruskal-Wallis H Test',
      h_statistic: 2.345,
      p_value: 0.310,
      degrees_of_freedom: 2,
      significant: false,
      interpretation: 'グループ間に統計的有意差は認められない（分布に違いはない）',
      group_sizes: [4, 4, 4],
      total_n: 12
    }
  end

  describe '#initialize' do
    it 'inherits from BaseStatisticalPresenter' do
      presenter = described_class.new(kruskal_wallis_result, {})
      expect(presenter).to be_a(Numana::Presenters::BaseStatisticalPresenter)
    end

    it 'accepts result and options' do
      options = { precision: 4 }
      presenter = described_class.new(kruskal_wallis_result, options)
      expect(presenter.result).to eq(kruskal_wallis_result)
      expect(presenter.options).to eq(options)
      expect(presenter.precision).to eq(4)
    end
  end

  describe '#json_fields' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(kruskal_wallis_result, options) }

    it 'returns hash with Kruskal-Wallis test specific fields' do
      expected_fields = {
        test_type: 'Kruskal-Wallis H Test',
        h_statistic: 8.456,
        p_value: 0.015,
        degrees_of_freedom: 2,
        significant: true,
        interpretation: 'グループ間に統計的有意差が認められる（分布に違いがある）',
        group_sizes: [5, 6, 4],
        total_n: 15
      }
      expect(presenter.json_fields).to eq(expected_fields)
    end

    it 'respects precision option' do
      high_precision_result = kruskal_wallis_result.merge(
        h_statistic: 8.456789,
        p_value: 0.015123
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      fields = presenter.json_fields
      expect(fields[:h_statistic]).to eq(8.46)
      expect(fields[:p_value]).to eq(0.02)
    end
  end

  describe '#format_quiet' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(kruskal_wallis_result, options) }

    it 'returns H-statistic and p-value separated by space' do
      expect(presenter.format_quiet).to eq('8.456 0.015')
    end

    it 'respects precision option' do
      high_precision_result = kruskal_wallis_result.merge(
        h_statistic: 8.456789,
        p_value: 0.015123
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      expect(presenter.format_quiet).to eq('8.46 0.02')
    end
  end

  describe '#format_verbose' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(kruskal_wallis_result, options) }

    it 'returns detailed multi-line output' do
      expected_output = [
        '=== Kruskal-Wallis H Test ===',
        'H-statistic: 8.456',
        'Degrees of Freedom: 2',
        'p-value: 0.015',
        'Total Sample Size: 15',
        'Group Sizes: 5, 6, 4',
        'Result: **Significant** (α = 0.05)',
        'Interpretation: グループ間に統計的有意差が認められる（分布に違いがある）',
        '',
        'Notes:',
        '• Kruskal-Wallis test is a non-parametric test',
        '• Does not require normal distribution assumption but assumes same distribution shape',
        '• If significant difference is found, consider post-hoc tests (e.g., Dunn test)'
      ].join("\n")

      expect(presenter.format_verbose).to eq(expected_output)
    end

    it 'handles non-significant results correctly' do
      presenter = described_class.new(non_significant_result, { precision: 3 })
      output = presenter.format_verbose

      expect(output).to include('Result: Not significant (α = 0.05)')
      expect(output).to include('グループ間に統計的有意差は認められない（分布に違いはない）')
    end

    it 'respects precision option' do
      high_precision_result = kruskal_wallis_result.merge(
        h_statistic: 8.456789,
        p_value: 0.015123
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      output = presenter.format_verbose
      expect(output).to include('H-statistic: 8.46')
      expect(output).to include('p-value: 0.02')
    end

    it 'displays group sizes correctly' do
      output = presenter.format_verbose
      expect(output).to include('Group Sizes: 5, 6, 4')
      expect(output).to include('Total Sample Size: 15')
    end
  end

  describe '#format' do
    let(:presenter) { described_class.new(kruskal_wallis_result, { precision: 3 }) }

    context 'when format is json' do
      it 'returns JSON formatted output' do
        presenter = described_class.new(kruskal_wallis_result, { format: 'json', precision: 3 })
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['test_type']).to eq('Kruskal-Wallis H Test')
        expect(parsed['h_statistic']).to eq(8.456)
        expect(parsed['p_value']).to eq(0.015)
        expect(parsed['group_sizes']).to eq([5, 6, 4])
        expect(parsed['total_n']).to eq(15)
      end
    end

    context 'when format is quiet' do
      it 'returns quiet formatted output' do
        presenter = described_class.new(kruskal_wallis_result, { format: 'quiet', precision: 3 })
        expect(presenter.format).to eq('8.456 0.015')
      end
    end

    context 'when format is verbose (default)' do
      it 'returns verbose formatted output' do
        result = presenter.format
        expect(result).to include('=== Kruskal-Wallis H Test ===')
        expect(result).to include('H-statistic: 8.456')
        expect(result).to include('p-value: 0.015')
        expect(result).to include('Group Sizes: 5, 6, 4')
      end
    end
  end

  describe 'integration with existing StatisticsPresenter' do
    let(:presenter) { described_class.new(kruskal_wallis_result, { precision: 3 }) }

    it 'produces same output as StatisticsPresenter.format_kruskal_wallis_test for verbose format' do
      new_output = presenter.format_verbose
      old_output = Numana::StatisticsPresenter.format_kruskal_wallis_test(kruskal_wallis_result, { precision: 3 })

      expect(new_output).to eq(old_output)
    end

    it 'produces same output as StatisticsPresenter.format_kruskal_wallis_test for JSON format' do
      new_output = presenter.format_json
      old_output = Numana::StatisticsPresenter.format_kruskal_wallis_test(kruskal_wallis_result, { format: 'json', precision: 3 })

      expect(JSON.parse(new_output)).to eq(JSON.parse(old_output))
    end

    it 'produces same output as StatisticsPresenter.format_kruskal_wallis_test for quiet format' do
      new_output = presenter.format_quiet
      old_output = Numana::StatisticsPresenter.format_kruskal_wallis_test(kruskal_wallis_result, { quiet: true, precision: 3 })

      expect(new_output).to eq(old_output)
    end
  end
end
