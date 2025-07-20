# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/presenters/mann_whitney_test_presenter'

RSpec.describe NumberAnalyzer::Presenters::MannWhitneyTestPresenter do
  let(:mann_whitney_result) do
    {
      test_type: 'Mann-Whitney U Test',
      u_statistic: 3.0,
      u1: 3.0,
      u2: 6.0,
      z_statistic: -1.535,
      p_value: 0.125,
      significant: false,
      interpretation: 'グループ間に統計的有意差は認められない（分布に違いはない）',
      effect_size: 0.628,
      group_sizes: [3, 3],
      rank_sums: [9.0, 12.0],
      total_n: 6
    }
  end

  let(:significant_result) do
    {
      test_type: 'Mann-Whitney U Test',
      u_statistic: 0.0,
      u1: 0.0,
      u2: 9.0,
      z_statistic: -2.121,
      p_value: 0.034,
      significant: true,
      interpretation: 'グループ間に統計的有意差が認められる（分布に違いがある）',
      effect_size: 0.866,
      group_sizes: [3, 3],
      rank_sums: [6.0, 15.0],
      total_n: 6
    }
  end

  let(:large_effect_result) do
    mann_whitney_result.merge(effect_size: 0.75)
  end

  let(:small_effect_result) do
    mann_whitney_result.merge(effect_size: 0.15)
  end

  let(:negligible_effect_result) do
    mann_whitney_result.merge(effect_size: 0.05)
  end

  describe '#initialize' do
    it 'inherits from BaseStatisticalPresenter' do
      presenter = described_class.new(mann_whitney_result, {})
      expect(presenter).to be_a(NumberAnalyzer::Presenters::BaseStatisticalPresenter)
    end

    it 'accepts result and options' do
      options = { precision: 4 }
      presenter = described_class.new(mann_whitney_result, options)
      expect(presenter.result).to eq(mann_whitney_result)
      expect(presenter.options).to eq(options)
      expect(presenter.precision).to eq(4)
    end
  end

  describe '#json_fields' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(mann_whitney_result, options) }

    it 'returns hash with Mann-Whitney test specific fields' do
      expected_fields = {
        test_type: 'Mann-Whitney U Test',
        u_statistic: 3.0,
        u1: 3.0,
        u2: 6.0,
        z_statistic: -1.535,
        p_value: 0.125,
        significant: false,
        interpretation: 'グループ間に統計的有意差は認められない（分布に違いはない）',
        effect_size: 0.628,
        group_sizes: [3, 3],
        rank_sums: [9.0, 12.0],
        total_n: 6
      }
      expect(presenter.json_fields).to eq(expected_fields)
    end

    it 'respects precision option' do
      high_precision_result = mann_whitney_result.merge(
        u_statistic: 3.456789,
        z_statistic: -1.535123,
        p_value: 0.125456,
        effect_size: 0.628789
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      fields = presenter.json_fields
      expect(fields[:u_statistic]).to eq(3.46)
      expect(fields[:z_statistic]).to eq(-1.54)
      expect(fields[:p_value]).to eq(0.13)
      expect(fields[:effect_size]).to eq(0.63)
    end
  end

  describe '#format_quiet' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(mann_whitney_result, options) }

    it 'returns U-statistic and p-value separated by space' do
      expect(presenter.format_quiet).to eq('3.0 0.125')
    end

    it 'respects precision option' do
      high_precision_result = mann_whitney_result.merge(
        u_statistic: 3.456789,
        p_value: 0.125456
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      expect(presenter.format_quiet).to eq('3.46 0.13')
    end
  end

  describe '#format_verbose' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(mann_whitney_result, options) }

    it 'returns detailed multi-line output' do
      expected_output = [
        '=== Mann-Whitney U Test ===',
        'U-statistic: 3.0',
        'U1: 3.0, U2: 6.0',
        'z-statistic: -1.535',
        'p-value: 0.125',
        'Effect Size (r): 0.628',
        'Group Sizes: 3, 3',
        'Rank Sums: 9.0, 12.0',
        'Result: Not significant (α = 0.05)',
        'Interpretation: グループ間に統計的有意差は認められない（分布に違いはない）',
        'Effect Size: Large',
        '',
        'Notes:',
        '• Mann-Whitney U test is a non-parametric test for two-group comparison',
        '• Used as alternative to t-test when normal distribution is not assumed',
        '• Robust against outliers due to rank-based testing',
        '• Assumes same distribution shape but tests for location (median) differences'
      ].join("\n")

      expect(presenter.format_verbose).to eq(expected_output)
    end

    it 'handles significant results correctly' do
      presenter = described_class.new(significant_result, { precision: 3 })
      output = presenter.format_verbose

      expect(output).to include('Result: **Significant** (α = 0.05)')
      expect(output).to include('グループ間に統計的有意差が認められる（分布に違いがある）')
    end

    it 'respects precision option' do
      high_precision_result = mann_whitney_result.merge(
        u_statistic: 3.456789,
        z_statistic: -1.535123,
        p_value: 0.125456,
        effect_size: 0.628789
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      output = presenter.format_verbose
      expect(output).to include('U-statistic: 3.46')
      expect(output).to include('z-statistic: -1.54')
      expect(output).to include('p-value: 0.13')
      expect(output).to include('Effect Size (r): 0.63')
    end
  end

  describe '#interpret_effect_size' do
    let(:presenter) { described_class.new(mann_whitney_result, {}) }

    it 'categorizes effect sizes correctly' do
      expect(described_class.new(negligible_effect_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Negligible')
      expect(described_class.new(small_effect_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Small')
      expect(described_class.new(mann_whitney_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Large')
      expect(described_class.new(large_effect_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Large')
    end

    it 'handles medium effect size' do
      medium_effect_result = mann_whitney_result.merge(effect_size: 0.35)
      presenter = described_class.new(medium_effect_result, {})
      expect(presenter.send(:interpret_effect_size)).to eq('Effect Size: Medium')
    end
  end

  describe '#format' do
    let(:presenter) { described_class.new(mann_whitney_result, { precision: 3 }) }

    context 'when format is json' do
      it 'returns JSON formatted output' do
        presenter = described_class.new(mann_whitney_result, { format: 'json', precision: 3 })
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['test_type']).to eq('Mann-Whitney U Test')
        expect(parsed['u_statistic']).to eq(3.0)
        expect(parsed['p_value']).to eq(0.125)
        expect(parsed['effect_size']).to eq(0.628)
        expect(parsed['group_sizes']).to eq([3, 3])
      end
    end

    context 'when format is quiet' do
      it 'returns quiet formatted output' do
        presenter = described_class.new(mann_whitney_result, { format: 'quiet', precision: 3 })
        expect(presenter.format).to eq('3.0 0.125')
      end
    end

    context 'when format is verbose (default)' do
      it 'returns verbose formatted output' do
        result = presenter.format
        expect(result).to include('=== Mann-Whitney U Test ===')
        expect(result).to include('U-statistic: 3.0')
        expect(result).to include('Effect Size (r): 0.628')
        expect(result).to include('Effect Size: Large')
      end
    end
  end

  describe 'integration with existing StatisticsPresenter' do
    let(:presenter) { described_class.new(mann_whitney_result, { precision: 3 }) }

    it 'produces same output as StatisticsPresenter.format_mann_whitney_test for verbose format' do
      new_output = presenter.format_verbose
      old_output = NumberAnalyzer::StatisticsPresenter.format_mann_whitney_test(mann_whitney_result, { precision: 3 })

      expect(new_output).to eq(old_output)
    end

    it 'produces same output as StatisticsPresenter.format_mann_whitney_test for JSON format' do
      new_output = presenter.format_json
      old_output = NumberAnalyzer::StatisticsPresenter.format_mann_whitney_test(mann_whitney_result, { format: 'json', precision: 3 })

      expect(JSON.parse(new_output)).to eq(JSON.parse(old_output))
    end

    it 'produces same output as StatisticsPresenter.format_mann_whitney_test for quiet format' do
      new_output = presenter.format_quiet
      old_output = NumberAnalyzer::StatisticsPresenter.format_mann_whitney_test(mann_whitney_result, { quiet: true, precision: 3 })

      expect(new_output).to eq(old_output)
    end
  end
end
