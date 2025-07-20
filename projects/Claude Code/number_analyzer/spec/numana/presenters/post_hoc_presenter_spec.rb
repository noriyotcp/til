# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::PostHocPresenter do
  let(:options) { { precision: 3 } }

  describe 'Tukey HSD test' do
    let(:result) do
      {
        method: 'Tukey HSD',
        pairwise_comparisons: [
          {
            groups: %w[Group1 Group2],
            mean_difference: 5.25,
            q_statistic: 3.456,
            q_critical: 3.314,
            p_value: 0.043,
            significant: true
          },
          {
            groups: %w[Group1 Group3],
            mean_difference: 2.75,
            q_statistic: 1.812,
            q_critical: 3.314,
            p_value: 0.234,
            significant: false
          },
          {
            groups: %w[Group2 Group3],
            mean_difference: -2.50,
            q_statistic: 1.644,
            q_critical: 3.314,
            p_value: 0.287,
            significant: false
          }
        ]
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats Tukey HSD result correctly' do
        output = presenter.format_verbose

        expect(output).to include('=== Post-hoc Analysis (Tukey HSD) ===')
        expect(output).to include('ペアワイズ比較:')
        expect(output).to include('グループ Group1 vs グループ Group2:')
        expect(output).to include('  平均値の差: 5.25')
        expect(output).to include('  q統計量: 3.456')
        expect(output).to include('  q臨界値: 3.314')
        expect(output).to include('  p値: 0.043')
        expect(output).to include('  有意差: あり')
        expect(output).to include('グループ Group1 vs グループ Group3:')
        expect(output).to include('  有意差: なし')
        expect(output).to include('グループ Group2 vs グループ Group3:')
        expect(output).to include('  平均値の差: -2.5')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('Tukey HSD 3 1')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['method']).to eq('Tukey HSD')
        expect(parsed['pairwise_comparisons'].length).to eq(3)

        first_comparison = parsed['pairwise_comparisons'][0]
        expect(first_comparison['groups']).to eq(%w[Group1 Group2])
        expect(first_comparison['mean_difference']).to eq(5.25)
        expect(first_comparison['q_statistic']).to eq(3.456)
        expect(first_comparison['q_critical']).to eq(3.314)
        expect(first_comparison['p_value']).to eq(0.043)
        expect(first_comparison['significant']).to be true
      end
    end
  end

  describe 'Bonferroni correction test' do
    let(:result) do
      {
        method: 'Bonferroni',
        adjusted_alpha: 0.0167,
        pairwise_comparisons: [
          {
            groups: %w[Control Treatment1],
            mean_difference: 8.45,
            t_statistic: 2.789,
            p_value: 0.012,
            adjusted_p_value: 0.036,
            significant: false
          },
          {
            groups: %w[Control Treatment2],
            mean_difference: 12.67,
            t_statistic: 4.123,
            p_value: 0.003,
            adjusted_p_value: 0.009,
            significant: true
          },
          {
            groups: %w[Treatment1 Treatment2],
            mean_difference: 4.22,
            t_statistic: 1.456,
            p_value: 0.167,
            adjusted_p_value: 0.501,
            significant: false
          }
        ]
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats Bonferroni result correctly' do
        output = presenter.format_verbose

        expect(output).to include('=== Post-hoc Analysis (Bonferroni) ===')
        expect(output).to include('調整済みα値: 0.017')
        expect(output).to include('ペアワイズ比較:')
        expect(output).to include('グループ Control vs グループ Treatment1:')
        expect(output).to include('  平均値の差: 8.45')
        expect(output).to include('  t統計量: 2.789')
        expect(output).to include('  p値: 0.012')
        expect(output).to include('  調整済みp値: 0.036')
        expect(output).to include('  有意差: なし')
        expect(output).to include('グループ Control vs グループ Treatment2:')
        expect(output).to include('  有意差: あり')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('Bonferroni 3 1')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['method']).to eq('Bonferroni')
        expect(parsed['adjusted_alpha']).to eq(0.017)
        expect(parsed['pairwise_comparisons'].length).to eq(3)

        second_comparison = parsed['pairwise_comparisons'][1]
        expect(second_comparison['groups']).to eq(%w[Control Treatment2])
        expect(second_comparison['mean_difference']).to eq(12.67)
        expect(second_comparison['t_statistic']).to eq(4.123)
        expect(second_comparison['p_value']).to eq(0.003)
        expect(second_comparison['adjusted_p_value']).to eq(0.009)
        expect(second_comparison['significant']).to be true
      end
    end
  end

  describe 'With warning message' do
    let(:result) do
      {
        method: 'Tukey HSD',
        warning: '警告: 等分散性の仮定が満たされていない可能性があります',
        pairwise_comparisons: [
          {
            groups: %w[A B],
            mean_difference: 3.45,
            q_statistic: 2.123,
            q_critical: 3.314,
            p_value: 0.156,
            significant: false
          }
        ]
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'includes warning message' do
        output = presenter.format_verbose

        expect(output).to include('=== Post-hoc Analysis (Tukey HSD) ===')
        expect(output).to include('警告: 等分散性の仮定が満たされていない可能性があります')
        expect(output).to include('ペアワイズ比較:')
      end
    end

    describe '#format_json' do
      it 'includes warning in JSON output' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['warning']).to eq('警告: 等分散性の仮定が満たされていない可能性があります')
      end
    end
  end

  describe 'Dataset metadata handling' do
    let(:result) do
      {
        method: 'Tukey HSD',
        pairwise_comparisons: [
          {
            groups: %w[A B],
            mean_difference: 3.45,
            q_statistic: 2.123,
            q_critical: 3.314,
            p_value: 0.156,
            significant: false
          }
        ]
      }
    end

    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 30)
      presenter = described_class.new(result, options_with_metadata)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(30)
    end
  end

  describe 'Precision handling' do
    let(:result) do
      {
        method: 'Bonferroni',
        adjusted_alpha: 0.016666666667,
        pairwise_comparisons: [
          {
            groups: %w[X Y],
            mean_difference: 5.123456789,
            t_statistic: 2.987654321,
            p_value: 0.012345678,
            adjusted_p_value: 0.037037037,
            significant: true
          }
        ]
      }
    end

    it 'respects custom precision setting' do
      high_precision_options = { precision: 6 }
      presenter = described_class.new(result, high_precision_options)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['adjusted_alpha']).to eq(0.016667)
      comparison = parsed['pairwise_comparisons'][0]
      expect(comparison['mean_difference']).to eq(5.123457)
      expect(comparison['t_statistic']).to eq(2.987654)
      expect(comparison['p_value']).to eq(0.012346)
      expect(comparison['adjusted_p_value']).to eq(0.037037)
    end

    it 'uses default precision when not specified' do
      no_precision_options = {}
      presenter = described_class.new(result, no_precision_options)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      # Default precision is 6
      expect(parsed['adjusted_alpha']).to eq(0.016667)
    end
  end

  describe 'Backward compatibility' do
    let(:result) do
      {
        method: 'Tukey HSD',
        pairwise_comparisons: [
          {
            groups: %w[A B],
            mean_difference: 3.45,
            q_statistic: 2.123,
            q_critical: 3.314,
            p_value: 0.156,
            significant: false
          }
        ]
      }
    end

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      presenter = described_class.new(result, legacy_options)

      output = presenter.format

      expect(output).to eq('Tukey HSD 1 0')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      presenter = described_class.new(result, json_options)

      output = presenter.format
      parsed = JSON.parse(output)

      expect(parsed['method']).to eq('Tukey HSD')
    end
  end

  describe 'Edge cases' do
    describe 'No significant comparisons' do
      let(:result) do
        {
          method: 'Tukey HSD',
          pairwise_comparisons: [
            {
              groups: %w[A B],
              mean_difference: 1.23,
              q_statistic: 0.987,
              q_critical: 3.314,
              p_value: 0.756,
              significant: false
            },
            {
              groups: %w[A C],
              mean_difference: 0.89,
              q_statistic: 0.654,
              q_critical: 3.314,
              p_value: 0.892,
              significant: false
            }
          ]
        }
      end
      let(:presenter) { described_class.new(result, options) }

      it 'handles no significant comparisons correctly' do
        output = presenter.format_quiet
        expect(output).to eq('Tukey HSD 2 0')
      end
    end

    describe 'All significant comparisons' do
      let(:result) do
        {
          method: 'Bonferroni',
          pairwise_comparisons: [
            {
              groups: %w[X Y],
              mean_difference: 8.45,
              t_statistic: 4.567,
              p_value: 0.001,
              adjusted_p_value: 0.003,
              significant: true
            },
            {
              groups: %w[X Z],
              mean_difference: 9.78,
              t_statistic: 5.123,
              p_value: 0.0005,
              adjusted_p_value: 0.0015,
              significant: true
            }
          ]
        }
      end
      let(:presenter) { described_class.new(result, options) }

      it 'handles all significant comparisons correctly' do
        output = presenter.format_quiet
        expect(output).to eq('Bonferroni 2 2')
      end
    end
  end
end
