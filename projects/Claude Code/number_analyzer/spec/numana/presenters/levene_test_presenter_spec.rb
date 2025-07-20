# frozen_string_literal: true

require 'spec_helper'
require 'numana/presenters/levene_test_presenter'

RSpec.describe Numana::Presenters::LeveneTestPresenter do
  let(:levene_result) do
    {
      test_type: 'Levene Test',
      f_statistic: 2.456,
      p_value: 0.089,
      degrees_of_freedom: [2, 27],
      significant: false,
      interpretation: 'No significant difference in group variances'
    }
  end

  let(:significant_result) do
    {
      test_type: 'Levene Test',
      f_statistic: 5.234,
      p_value: 0.012,
      degrees_of_freedom: [3, 36],
      significant: true,
      interpretation: 'Significant difference in group variances detected'
    }
  end

  describe '#initialize' do
    it 'inherits from BaseStatisticalPresenter' do
      presenter = described_class.new(levene_result, {})
      expect(presenter).to be_a(Numana::Presenters::BaseStatisticalPresenter)
    end

    it 'accepts result and options' do
      options = { precision: 3 }
      presenter = described_class.new(levene_result, options)
      expect(presenter.result).to eq(levene_result)
      expect(presenter.options).to eq(options)
      expect(presenter.precision).to eq(3)
    end
  end

  describe '#json_fields' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(levene_result, options) }

    it 'returns hash with Levene test specific fields' do
      expected_fields = {
        test_type: 'Levene Test',
        f_statistic: 2.456,
        p_value: 0.089,
        degrees_of_freedom: [2, 27],
        significant: false,
        interpretation: 'No significant difference in group variances'
      }
      expect(presenter.json_fields).to eq(expected_fields)
    end

    it 'respects precision option' do
      high_precision_result = levene_result.merge(f_statistic: 2.456789, p_value: 0.089123)
      presenter = described_class.new(high_precision_result, { precision: 2 })

      fields = presenter.json_fields
      expect(fields[:f_statistic]).to eq(2.46)
      expect(fields[:p_value]).to eq(0.09)
    end
  end

  describe '#format_quiet' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(levene_result, options) }

    it 'returns F-statistic and p-value separated by space' do
      expect(presenter.format_quiet).to eq('2.456 0.089')
    end

    it 'respects precision option' do
      high_precision_result = levene_result.merge(f_statistic: 2.456789, p_value: 0.089123)
      presenter = described_class.new(high_precision_result, { precision: 2 })

      expect(presenter.format_quiet).to eq('2.46 0.09')
    end
  end

  describe '#format_verbose' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(levene_result, options) }

    it 'returns detailed multi-line output' do
      expected_output = [
        '=== Levene Test Results (Brown-Forsythe Modified) ===',
        '',
        'Test Statistics:',
        '  F-statistic: 2.456',
        '  p-value: 0.089',
        '  Degrees of Freedom: 2, 27',
        '',
        'Statistical Decision:',
        '  Result: No significant difference (p ≥ 0.05)',
        '  Conclusion: Group variances are considered equal',
        '',
        'Interpretation:',
        '  No significant difference in group variances',
        '',
        'Notes:',
        '  - Brown-Forsythe modification is robust against outliers',
        '  - This test is used to check ANOVA assumptions'
      ].join("\n")

      expect(presenter.format_verbose).to eq(expected_output)
    end

    it 'handles significant results correctly' do
      presenter = described_class.new(significant_result, { precision: 3 })
      output = presenter.format_verbose

      expect(output).to include('Result: **Significant difference** (p < 0.05)')
      expect(output).to include('Conclusion: Group variances are not equal')
    end

    it 'respects precision option' do
      high_precision_result = levene_result.merge(f_statistic: 2.456789, p_value: 0.089123)
      presenter = described_class.new(high_precision_result, { precision: 2 })

      output = presenter.format_verbose
      expect(output).to include('F-statistic: 2.46')
      expect(output).to include('p-value: 0.09')
    end
  end

  describe '#format' do
    let(:presenter) { described_class.new(levene_result, { precision: 3 }) }

    context 'when format is json' do
      it 'returns JSON formatted output' do
        presenter = described_class.new(levene_result, { format: 'json', precision: 3 })
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['test_type']).to eq('Levene Test')
        expect(parsed['f_statistic']).to eq(2.456)
        expect(parsed['p_value']).to eq(0.089)
      end
    end

    context 'when format is quiet' do
      it 'returns quiet formatted output' do
        presenter = described_class.new(levene_result, { format: 'quiet', precision: 3 })
        expect(presenter.format).to eq('2.456 0.089')
      end
    end

    context 'when format is verbose (default)' do
      it 'returns verbose formatted output' do
        result = presenter.format
        expect(result).to include('=== Levene Test Results (Brown-Forsythe Modified) ===')
        expect(result).to include('F-statistic: 2.456')
        expect(result).to include('p-value: 0.089')
      end
    end
  end

  describe 'integration with existing StatisticsPresenter' do
    let(:presenter) { described_class.new(levene_result, { precision: 3 }) }

    it 'produces same output as StatisticsPresenter.format_levene_test for verbose format' do
      new_output = presenter.format_verbose
      old_output = Numana::StatisticsPresenter.format_levene_test(levene_result, { precision: 3 })

      expect(new_output).to eq(old_output)
    end

    it 'produces same output as StatisticsPresenter.format_levene_test for JSON format' do
      new_output = presenter.format_json
      old_output = Numana::StatisticsPresenter.format_levene_test(levene_result, { format: 'json', precision: 3 })

      expect(JSON.parse(new_output)).to eq(JSON.parse(old_output))
    end

    it 'produces same output as StatisticsPresenter.format_levene_test for quiet format' do
      new_output = presenter.format_quiet
      old_output = Numana::StatisticsPresenter.format_levene_test(levene_result, { quiet: true, precision: 3 })

      expect(new_output).to eq(old_output)
    end
  end
end
