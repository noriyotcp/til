# frozen_string_literal: true

require 'spec_helper'
require 'numana/presenters/friedman_test_presenter'

RSpec.describe Numana::Presenters::FriedmanTestPresenter do
  let(:friedman_result) do
    {
      test_type: 'Friedman Test',
      chi_square_statistic: 8.667,
      p_value: 0.013,
      degrees_of_freedom: 2,
      significant: true,
      interpretation: '条件間に統計的有意差が認められる（被験者内要因の効果がある）',
      rank_sums: [6.0, 15.0, 9.0],
      n_subjects: 5,
      k_conditions: 3,
      total_observations: 15
    }
  end

  let(:non_significant_result) do
    {
      test_type: 'Friedman Test',
      chi_square_statistic: 2.333,
      p_value: 0.311,
      degrees_of_freedom: 2,
      significant: false,
      interpretation: '条件間に統計的有意差は認められない（被験者内要因の効果はない）',
      rank_sums: [7.5, 11.0, 11.5],
      n_subjects: 5,
      k_conditions: 3,
      total_observations: 15
    }
  end

  describe '#initialize' do
    it 'inherits from BaseStatisticalPresenter' do
      presenter = described_class.new(friedman_result, {})
      expect(presenter).to be_a(Numana::Presenters::BaseStatisticalPresenter)
    end

    it 'accepts result and options' do
      options = { precision: 4 }
      presenter = described_class.new(friedman_result, options)
      expect(presenter.result).to eq(friedman_result)
      expect(presenter.options).to eq(options)
      expect(presenter.precision).to eq(4)
    end
  end

  describe '#json_fields' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(friedman_result, options) }

    it 'returns hash with Friedman test specific fields' do
      expected_fields = {
        test_type: 'Friedman Test',
        chi_square_statistic: 8.667,
        p_value: 0.013,
        degrees_of_freedom: 2,
        significant: true,
        interpretation: '条件間に統計的有意差が認められる（被験者内要因の効果がある）',
        rank_sums: [6.0, 15.0, 9.0],
        n_subjects: 5,
        k_conditions: 3,
        total_observations: 15
      }
      expect(presenter.json_fields).to eq(expected_fields)
    end

    it 'respects precision option' do
      high_precision_result = friedman_result.merge(
        chi_square_statistic: 8.667123,
        p_value: 0.013456
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      fields = presenter.json_fields
      expect(fields[:chi_square_statistic]).to eq(8.67)
      expect(fields[:p_value]).to eq(0.01)
    end
  end

  describe '#format_quiet' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(friedman_result, options) }

    it 'returns chi-square statistic and p-value separated by space' do
      expect(presenter.format_quiet).to eq('8.667 0.013')
    end

    it 'respects precision option' do
      high_precision_result = friedman_result.merge(
        chi_square_statistic: 8.667123,
        p_value: 0.013456
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      expect(presenter.format_quiet).to eq('8.67 0.01')
    end
  end

  describe '#format_verbose' do
    let(:options) { { precision: 3 } }
    let(:presenter) { described_class.new(friedman_result, options) }

    it 'returns detailed multi-line output' do
      expected_output = [
        '=== Friedman Test ===',
        'χ²-statistic: 8.667',
        'Degrees of Freedom: 2',
        'p-value: 0.013',
        'Number of Subjects: 5',
        'Number of Conditions: 3',
        'Total Observations: 15',
        'Rank Sums: 6.0, 15.0, 9.0',
        'Result: **Significant** (α = 0.05)',
        'Interpretation: 条件間に統計的有意差が認められる（被験者内要因の効果がある）',
        '',
        'Notes:',
        '• Friedman test is a non-parametric test for repeated measures data',
        '• Used as alternative to repeated measures ANOVA when normal distribution is not assumed',
        '• Assumes same subjects are measured under multiple conditions',
        '• If significant difference is found, consider post-hoc tests (e.g., Nemenyi test)'
      ].join("\n")

      expect(presenter.format_verbose).to eq(expected_output)
    end

    it 'handles non-significant results correctly' do
      presenter = described_class.new(non_significant_result, { precision: 3 })
      output = presenter.format_verbose

      expect(output).to include('Result: Not significant (α = 0.05)')
      expect(output).to include('条件間に統計的有意差は認められない（被験者内要因の効果はない）')
    end

    it 'respects precision option' do
      high_precision_result = friedman_result.merge(
        chi_square_statistic: 8.667123,
        p_value: 0.013456
      )
      presenter = described_class.new(high_precision_result, { precision: 2 })

      output = presenter.format_verbose
      expect(output).to include('χ²-statistic: 8.67')
      expect(output).to include('p-value: 0.01')
    end

    it 'displays repeated measures information correctly' do
      output = presenter.format_verbose
      expect(output).to include('Number of Subjects: 5')
      expect(output).to include('Number of Conditions: 3')
      expect(output).to include('Total Observations: 15')
      expect(output).to include('Rank Sums: 6.0, 15.0, 9.0')
    end
  end

  describe '#format' do
    let(:presenter) { described_class.new(friedman_result, { precision: 3 }) }

    context 'when format is json' do
      it 'returns JSON formatted output' do
        presenter = described_class.new(friedman_result, { format: 'json', precision: 3 })
        result = presenter.format
        parsed = JSON.parse(result)

        expect(parsed['test_type']).to eq('Friedman Test')
        expect(parsed['chi_square_statistic']).to eq(8.667)
        expect(parsed['p_value']).to eq(0.013)
        expect(parsed['rank_sums']).to eq([6.0, 15.0, 9.0])
        expect(parsed['n_subjects']).to eq(5)
        expect(parsed['k_conditions']).to eq(3)
      end
    end

    context 'when format is quiet' do
      it 'returns quiet formatted output' do
        presenter = described_class.new(friedman_result, { format: 'quiet', precision: 3 })
        expect(presenter.format).to eq('8.667 0.013')
      end
    end

    context 'when format is verbose (default)' do
      it 'returns verbose formatted output' do
        result = presenter.format
        expect(result).to include('=== Friedman Test ===')
        expect(result).to include('χ²-statistic: 8.667')
        expect(result).to include('Number of Subjects: 5')
        expect(result).to include('Rank Sums: 6.0, 15.0, 9.0')
      end
    end
  end

  describe 'repeated measures specific functionality' do
    let(:presenter) { described_class.new(friedman_result, { precision: 3 }) }

    it 'correctly shows rank sums for all conditions' do
      output = presenter.format_verbose
      expect(output).to include('Rank Sums: 6.0, 15.0, 9.0')
    end

    it 'displays subjects and conditions count' do
      output = presenter.format_verbose
      expect(output).to include('Number of Subjects: 5')
      expect(output).to include('Number of Conditions: 3')
    end

    it 'shows total observations (subjects × conditions)' do
      output = presenter.format_verbose
      expect(output).to include('Total Observations: 15')
    end
  end

  describe 'integration with existing StatisticsPresenter' do
    let(:presenter) { described_class.new(friedman_result, { precision: 3 }) }

    it 'produces same output as StatisticsPresenter.format_friedman_test for verbose format' do
      new_output = presenter.format_verbose
      old_output = Numana::StatisticsPresenter.format_friedman_test(friedman_result, { precision: 3 })

      expect(new_output).to eq(old_output)
    end

    it 'produces same output as StatisticsPresenter.format_friedman_test for JSON format' do
      new_output = presenter.format_json
      old_output = Numana::StatisticsPresenter.format_friedman_test(friedman_result, { format: 'json', precision: 3 })

      expect(JSON.parse(new_output)).to eq(JSON.parse(old_output))
    end

    it 'produces same output as StatisticsPresenter.format_friedman_test for quiet format' do
      new_output = presenter.format_quiet
      old_output = Numana::StatisticsPresenter.format_friedman_test(friedman_result, { quiet: true, precision: 3 })

      expect(new_output).to eq(old_output)
    end
  end
end
