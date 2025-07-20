# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/presenters/bartlett_test_presenter'

RSpec.describe Numana::Presenters::BartlettTestPresenter do
  let(:bartlett_result) do
    {
      test_type: 'Bartlett Test',
      chi_square_statistic: 3.456,
      p_value: 0.178,
      degrees_of_freedom: 2,
      significant: false,
      interpretation: 'Homogeneity of variance hypothesis is not rejected (group variances are assumed equal)',
      correction_factor: 1.0833,
      pooled_variance: 2.25
    }
  end

  let(:significant_result) do
    {
      test_type: 'Bartlett Test',
      chi_square_statistic: 8.234,
      p_value: 0.016,
      degrees_of_freedom: 2,
      significant: true,
      interpretation: 'Homogeneity of variance hypothesis is rejected (group variances are not equal)',
      correction_factor: 1.1245,
      pooled_variance: 4.75
    }
  end

  describe '#initialize' do
    it 'inherits from BaseStatisticalPresenter' do
      presenter = described_class.new(bartlett_result, {})
      expect(presenter).to be_a(Numana::Presenters::BaseStatisticalPresenter)
    end

    it 'accepts result and options' do
      options = { precision: 4 }
      presenter = described_class.new(bartlett_result, options)
      expect(presenter.result).to eq(bartlett_result)
      expect(presenter.options).to eq(options)
      expect(presenter.precision).to eq(4)
    end
  end

  describe 'JSON format output' do
    let(:options) { { format: 'json', precision: 3 } }
    let(:presenter) { described_class.new(bartlett_result, options) }

    it 'returns JSON with Bartlett test specific fields' do
      result = JSON.parse(presenter.format)
      expected_fields = {
        'test_type' => 'Bartlett Test',
        'chi_square_statistic' => 3.456,
        'p_value' => 0.178,
        'degrees_of_freedom' => 2,
        'significant' => false,
        'interpretation' => 'Homogeneity of variance hypothesis is not rejected (group variances are assumed equal)',
        'correction_factor' => 1.083,
        'pooled_variance' => 2.25
      }
      expect(result).to eq(expected_fields)
    end

    it 'respects precision option' do
      high_precision_result = bartlett_result.merge(
        chi_square_statistic: 3.456789,
        p_value: 0.178123,
        correction_factor: 1.083456
      )
      presenter = described_class.new(high_precision_result, { format: 'json', precision: 2 })

      result = JSON.parse(presenter.format)
      expect(result['chi_square_statistic']).to eq(3.46)
      expect(result['p_value']).to eq(0.18)
      expect(result['correction_factor']).to eq(1.08)
    end
  end

  describe 'Quiet format output' do
    let(:options) { { format: 'quiet', precision: 3 } }
    let(:presenter) { described_class.new(bartlett_result, options) }

    it 'returns chi-square statistic and p-value separated by space' do
      expect(presenter.format).to eq('3.456 0.178')
    end

    it 'respects precision option' do
      high_precision_result = bartlett_result.merge(
        chi_square_statistic: 3.456789,
        p_value: 0.178123
      )
      presenter = described_class.new(high_precision_result, { format: 'quiet', precision: 2 })

      expect(presenter.format).to eq('3.46 0.18')
    end
  end

  describe 'Verbose format output' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(bartlett_result, options) }

    it 'returns detailed multi-line output' do
      expected_output = [
        '=== Bartlett Test Results ===',
        '',
        'Test Statistics:',
        '  Chi-square statistic: 3.456',
        '  p-value: 0.178',
        '  Degrees of Freedom: 2',
        '  Correction Factor: 1.083',
        '  Pooled Variance: 2.25',
        '',
        'Statistical Decision:',
        '  Result: No significant difference (p ≥ 0.05)',
        '  Conclusion: Group variances are considered equal',
        '',
        'Interpretation:',
        '  Homogeneity of variance hypothesis is not rejected (group variances are assumed equal)',
        '',
        'Notes:',
        '  - Bartlett test assumes normal distribution',
        '  - More precise than Levene test when normality is satisfied',
        '  - This test is used to check ANOVA assumptions'
      ].join("\n")

      expect(presenter.format).to eq(expected_output)
    end

    it 'handles significant results correctly' do
      presenter = described_class.new(significant_result, { precision: 3 })
      output = presenter.format

      expect(output).to include('Result: **Significant difference** (p < 0.05)')
      expect(output).to include('Conclusion: Group variances are not equal')
    end

    it 'respects precision option' do
      high_precision_result = bartlett_result.merge(
        chi_square_statistic: 3.456789,
        p_value: 0.178123,
        correction_factor: 1.083456
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      output = presenter.format
      expect(output).to include('Chi-square statistic: 3.46')
      expect(output).to include('p-value: 0.18')
      expect(output).to include('Correction Factor: 1.08')
    end
  end

  describe '#format' do
    let(:presenter) { described_class.new(bartlett_result, { precision: 3 }) }

    context 'when format is json' do
      it 'returns JSON formatted output' do
        presenter = described_class.new(bartlett_result, { format: 'json', precision: 3 })
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['test_type']).to eq('Bartlett Test')
        expect(parsed['chi_square_statistic']).to eq(3.456)
        expect(parsed['p_value']).to eq(0.178)
        expect(parsed['correction_factor']).to eq(1.083)
      end
    end

    context 'when format is quiet' do
      it 'returns quiet formatted output' do
        presenter = described_class.new(bartlett_result, { format: 'quiet', precision: 3 })
        expect(presenter.format).to eq('3.456 0.178')
      end
    end

    context 'when format is verbose (default)' do
      it 'returns verbose formatted output' do
        result = presenter.format
        expect(result).to include('=== Bartlett Test Results ===')
        expect(result).to include('Chi-square statistic: 3.456')
        expect(result).to include('p-value: 0.178')
        expect(result).to include('Correction Factor: 1.083')
      end
    end
  end

  describe 'integration with existing StatisticsPresenter' do
    it 'produces same output as StatisticsPresenter.format_bartlett_test for verbose format' do
      presenter = described_class.new(bartlett_result, { precision: 3 })
      new_output = presenter.format
      old_output = Numana::StatisticsPresenter.format_bartlett_test(bartlett_result, { precision: 3 })

      expect(new_output).to eq(old_output)
    end

    it 'produces same output as StatisticsPresenter.format_bartlett_test for JSON format' do
      presenter = described_class.new(bartlett_result, { format: 'json', precision: 3 })
      new_output = presenter.format
      old_output = Numana::StatisticsPresenter.format_bartlett_test(bartlett_result, { format: 'json', precision: 3 })

      expect(JSON.parse(new_output)).to eq(JSON.parse(old_output))
    end

    it 'produces same output as StatisticsPresenter.format_bartlett_test for quiet format' do
      presenter = described_class.new(bartlett_result, { format: 'quiet', precision: 3 })
      new_output = presenter.format
      old_output = Numana::StatisticsPresenter.format_bartlett_test(bartlett_result, { quiet: true, precision: 3 })

      expect(new_output).to eq(old_output)
    end
  end
end
