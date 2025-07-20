# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/presenters/wilcoxon_test_presenter'

RSpec.describe Numana::Presenters::WilcoxonTestPresenter do
  let(:wilcoxon_result) do
    {
      test_type: 'Wilcoxon Signed-Rank Test',
      w_statistic: 6.0,
      w_plus: 6.0,
      w_minus: 0.0,
      z_statistic: -1.826,
      p_value: 0.068,
      significant: false,
      interpretation: '対応のあるデータ間に統計的有意差は認められない',
      effect_size: 0.748,
      n_pairs: 6,
      n_effective: 3,
      n_zeros: 3
    }
  end

  let(:significant_result) do
    {
      test_type: 'Wilcoxon Signed-Rank Test',
      w_statistic: 0.0,
      w_plus: 0.0,
      w_minus: 15.0,
      z_statistic: -2.201,
      p_value: 0.028,
      significant: true,
      interpretation: '対応のあるデータ間に統計的有意差が認められる',
      effect_size: 0.894,
      n_pairs: 6,
      n_effective: 5,
      n_zeros: 1
    }
  end

  let(:small_effect_result) do
    wilcoxon_result.merge(effect_size: 0.25)
  end

  let(:medium_effect_result) do
    wilcoxon_result.merge(effect_size: 0.35)
  end

  let(:negligible_effect_result) do
    wilcoxon_result.merge(effect_size: 0.08)
  end

  describe '#initialize' do
    it 'inherits from BaseStatisticalPresenter' do
      presenter = described_class.new(wilcoxon_result, {})
      expect(presenter).to be_a(Numana::Presenters::BaseStatisticalPresenter)
    end

    it 'accepts result and options' do
      options = { precision: 4 }
      presenter = described_class.new(wilcoxon_result, options)
      expect(presenter.result).to eq(wilcoxon_result)
      expect(presenter.options).to eq(options)
      expect(presenter.precision).to eq(4)
    end
  end

  describe '#json_fields' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(wilcoxon_result, options) }

    it 'returns hash with Wilcoxon test specific fields' do
      expected_fields = {
        test_type: 'Wilcoxon Signed-Rank Test',
        w_statistic: 6.0,
        w_plus: 6.0,
        w_minus: 0.0,
        z_statistic: -1.826,
        p_value: 0.068,
        significant: false,
        interpretation: '対応のあるデータ間に統計的有意差は認められない',
        effect_size: 0.748,
        n_pairs: 6,
        n_effective: 3,
        n_zeros: 3
      }
      expect(presenter.json_fields).to eq(expected_fields)
    end

    it 'respects precision option' do
      high_precision_result = wilcoxon_result.merge(
        w_statistic: 6.456789,
        w_plus: 6.456789,
        w_minus: 0.123456,
        z_statistic: -1.826123,
        p_value: 0.068456,
        effect_size: 0.748789
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      fields = presenter.json_fields
      expect(fields[:w_statistic]).to eq(6.46)
      expect(fields[:w_plus]).to eq(6.46)
      expect(fields[:w_minus]).to eq(0.12)
      expect(fields[:z_statistic]).to eq(-1.83)
      expect(fields[:p_value]).to eq(0.07)
      expect(fields[:effect_size]).to eq(0.75)
    end
  end

  describe '#format_quiet' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(wilcoxon_result, options) }

    it 'returns W-statistic and p-value separated by space' do
      expect(presenter.format_quiet).to eq('6.0 0.068')
    end

    it 'respects precision option' do
      high_precision_result = wilcoxon_result.merge(
        w_statistic: 6.456789,
        p_value: 0.068456
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      expect(presenter.format_quiet).to eq('6.46 0.07')
    end
  end

  describe '#format_verbose' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(wilcoxon_result, options) }

    it 'returns detailed multi-line output' do
      expected_output = [
        '=== Wilcoxon Signed-Rank Test ===',
        'W-statistic: 6.0',
        'W+ (positive rank sum): 6.0',
        'W- (negative rank sum): 0.0',
        'z-statistic: -1.826',
        'p-value: 0.068',
        'Effect Size (r): 0.748',
        'Number of Pairs: 6',
        'Effective Pairs: 3 (Zero differences excluded: 3)',
        'Result: Not significant (α = 0.05)',
        'Interpretation: 対応のあるデータ間に統計的有意差は認められない',
        'Effect Size: Large',
        '',
        'Notes:',
        '• Wilcoxon signed-rank test is a non-parametric test for paired data',
        '• Used as alternative to paired t-test when normal distribution is not assumed',
        '• Assumes symmetric distribution of differences but normality is not required',
        '• Zero differences are excluded from the test'
      ].join("\n")

      expect(presenter.format_verbose).to eq(expected_output)
    end

    it 'handles significant results correctly' do
      presenter = described_class.new(significant_result, { precision: 3 })
      output = presenter.format_verbose

      expect(output).to include('Result: **Significant** (α = 0.05)')
      expect(output).to include('対応のあるデータ間に統計的有意差が認められる')
    end

    it 'respects precision option' do
      high_precision_result = wilcoxon_result.merge(
        w_statistic: 6.456789,
        w_plus: 6.456789,
        z_statistic: -1.826123,
        p_value: 0.068456,
        effect_size: 0.748789
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      output = presenter.format_verbose
      expect(output).to include('W-statistic: 6.46')
      expect(output).to include('W+ (positive rank sum): 6.46')
      expect(output).to include('z-statistic: -1.83')
      expect(output).to include('p-value: 0.07')
      expect(output).to include('Effect Size (r): 0.75')
    end

    it 'displays zero differences information correctly' do
      output = presenter.format_verbose
      expect(output).to include('Number of Pairs: 6')
      expect(output).to include('Effective Pairs: 3 (Zero differences excluded: 3)')
    end
  end

  describe '#interpret_effect_size' do
    it 'categorizes effect sizes correctly' do
      expect(described_class.new(negligible_effect_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Negligible')
      expect(described_class.new(small_effect_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Small')
      expect(described_class.new(medium_effect_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Medium')
      expect(described_class.new(wilcoxon_result, {}).send(:interpret_effect_size)).to eq('Effect Size: Large')
    end
  end

  describe '#format' do
    let(:presenter) { described_class.new(wilcoxon_result, { precision: 3 }) }

    context 'when format is json' do
      it 'returns JSON formatted output' do
        presenter = described_class.new(wilcoxon_result, { format: 'json', precision: 3 })
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['test_type']).to eq('Wilcoxon Signed-Rank Test')
        expect(parsed['w_statistic']).to eq(6.0)
        expect(parsed['w_plus']).to eq(6.0)
        expect(parsed['w_minus']).to eq(0.0)
        expect(parsed['p_value']).to eq(0.068)
        expect(parsed['n_pairs']).to eq(6)
        expect(parsed['n_zeros']).to eq(3)
      end
    end

    context 'when format is quiet' do
      it 'returns quiet formatted output' do
        presenter = described_class.new(wilcoxon_result, { format: 'quiet', precision: 3 })
        expect(presenter.format).to eq('6.0 0.068')
      end
    end

    context 'when format is verbose (default)' do
      it 'returns verbose formatted output' do
        result = presenter.format
        expect(result).to include('=== Wilcoxon Signed-Rank Test ===')
        expect(result).to include('W-statistic: 6.0')
        expect(result).to include('Effect Size (r): 0.748')
        expect(result).to include('Zero differences excluded: 3')
      end
    end
  end

  describe 'integration with existing StatisticsPresenter' do
    let(:presenter) { described_class.new(wilcoxon_result, { precision: 3 }) }

    it 'produces same output as StatisticsPresenter.format_wilcoxon_test for verbose format' do
      new_output = presenter.format_verbose
      old_output = Numana::StatisticsPresenter.format_wilcoxon_test(wilcoxon_result, { precision: 3 })

      expect(new_output).to eq(old_output)
    end

    it 'produces same output as StatisticsPresenter.format_wilcoxon_test for JSON format' do
      new_output = presenter.format_json
      old_output = Numana::StatisticsPresenter.format_wilcoxon_test(wilcoxon_result, { format: 'json', precision: 3 })

      expect(JSON.parse(new_output)).to eq(JSON.parse(old_output))
    end

    it 'produces same output as StatisticsPresenter.format_wilcoxon_test for quiet format' do
      new_output = presenter.format_quiet
      old_output = Numana::StatisticsPresenter.format_wilcoxon_test(wilcoxon_result, { quiet: true, precision: 3 })

      expect(new_output).to eq(old_output)
    end
  end
end
