# frozen_string_literal: true

require_relative '../../spec_helper'

describe NumberAnalyzer::Presenters::AnovaPresenter do
  let(:options) { { precision: 3 } }

  describe 'One-way ANOVA' do
    let(:result) do
      {
        f_statistic: 5.662651821862349,
        p_value: 0.01921806730769231,
        degrees_of_freedom: [2, 9],
        sum_of_squares: {
          between: 566.1666666666666,
          within: 450.0,
          total: 1016.1666666666666
        },
        mean_squares: {
          between: 283.0833333333333,
          within: 50.0
        },
        effect_size: {
          eta_squared: 0.5574438202247191,
          omega_squared: 0.45579262348178374
        },
        group_means: [75.0, 85.0, 95.0],
        grand_mean: 85.0,
        significant: true,
        interpretation: 'グループ間に有意差があります (p < 0.05)'
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats one-way ANOVA result correctly' do
        output = presenter.format_verbose

        expect(output).to include('=== 一元配置分散分析結果 ===')
        expect(output).to include('グループ平均値: 75.0, 85.0, 95.0')
        expect(output).to include('全体平均値: 85.0')
        expect(output).to include('【分散分析表】')
        expect(output).to include('変動要因                  平方和      自由度         平均平方           F値')
        expect(output).to include('F統計量: 5.663')
        expect(output).to include('p値: 0.019')
        expect(output).to include('結果: 有意 (α = 0.05)')
        expect(output).to include('効果サイズ:')
        expect(output).to include('η² (eta squared): 0.557')
        expect(output).to include('ω² (omega squared): 0.456')
        expect(output).to include('解釈: グループ間に有意差があります (p < 0.05)')
      end

      it 'formats ANOVA table with proper alignment' do
        output = presenter.format_verbose

        expect(output).to match(/群間\s+566\.167\s+2\s+283\.083\s+5\.663/)
        expect(output).to match(/群内\s+450\.0\s+9\s+50\.0\s+-/)
        expect(output).to match(/全体\s+1016\.167\s+11\s+-\s+-/)
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('5.663 2 9 0.019 0.557 true')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['test_type']).to eq('one_way_anova')
        expect(parsed['f_statistic']).to eq(5.663)
        expect(parsed['p_value']).to eq(0.019)
        expect(parsed['degrees_of_freedom']['between']).to eq(2)
        expect(parsed['degrees_of_freedom']['within']).to eq(9)
        expect(parsed['sum_of_squares']['between']).to eq(566.167)
        expect(parsed['sum_of_squares']['within']).to eq(450.0)
        expect(parsed['sum_of_squares']['total']).to eq(1016.167)
        expect(parsed['mean_squares']['between']).to eq(283.083)
        expect(parsed['mean_squares']['within']).to eq(50.0)
        expect(parsed['effect_size']['eta_squared']).to eq(0.557)
        expect(parsed['effect_size']['omega_squared']).to eq(0.456)
        expect(parsed['group_means']).to eq([75.0, 85.0, 95.0])
        expect(parsed['grand_mean']).to eq(85.0)
        expect(parsed['significant']).to be true
        expect(parsed['interpretation']).to eq('グループ間に有意差があります (p < 0.05)')
      end
    end
  end

  describe 'Non-significant ANOVA' do
    let(:result) do
      {
        f_statistic: 1.2345,
        p_value: 0.3456,
        degrees_of_freedom: [2, 12],
        sum_of_squares: {
          between: 123.45,
          within: 567.89,
          total: 691.34
        },
        mean_squares: {
          between: 61.725,
          within: 47.324
        },
        effect_size: {
          eta_squared: 0.1785,
          omega_squared: 0.0417
        },
        group_means: [82.5, 85.2, 87.1],
        grand_mean: 84.9,
        significant: false,
        interpretation: 'グループ間に有意差は認められません (p ≥ 0.05)'
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats non-significant ANOVA result correctly' do
        output = presenter.format_verbose

        expect(output).to include('F統計量: 1.235')
        expect(output).to include('p値: 0.346')
        expect(output).to include('結果: 非有意 (α = 0.05)')
        expect(output).to include('解釈: グループ間に有意差は認められません (p ≥ 0.05)')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output with false significance' do
        output = presenter.format_quiet

        expect(output).to eq('1.235 2 12 0.346 0.179 false')
      end
    end

    describe '#format_json' do
      it 'formats JSON with false significance' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['significant']).to be false
        expect(parsed['f_statistic']).to eq(1.235)
        expect(parsed['p_value']).to eq(0.346)
      end
    end
  end

  describe 'Dataset metadata handling' do
    let(:result) do
      {
        f_statistic: 5.662651821862349,
        p_value: 0.01921806730769231,
        degrees_of_freedom: [2, 9],
        sum_of_squares: {
          between: 566.1666666666666,
          within: 450.0,
          total: 1016.1666666666666
        },
        mean_squares: {
          between: 283.0833333333333,
          within: 50.0
        },
        effect_size: {
          eta_squared: 0.5574438202247191,
          omega_squared: 0.45579262348178374
        },
        group_means: [75.0, 85.0, 95.0],
        grand_mean: 85.0,
        significant: true,
        interpretation: 'グループ間に有意差があります (p < 0.05)'
      }
    end

    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 12)
      presenter = described_class.new(result, options_with_metadata)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(12)
    end
  end

  describe 'Precision handling' do
    let(:result) do
      {
        f_statistic: 5.662651821862349,
        p_value: 0.019218067307692314,
        degrees_of_freedom: [2, 9],
        sum_of_squares: {
          between: 566.1666666666666,
          within: 450.0123456789,
          total: 1016.1790123456455
        },
        mean_squares: {
          between: 283.0833333333333,
          within: 50.001371742
        },
        effect_size: {
          eta_squared: 0.5574438202247191,
          omega_squared: 0.45579262348178374
        },
        group_means: [75.123456, 85.654321, 95.987654],
        grand_mean: 85.588477,
        significant: true,
        interpretation: 'グループ間に有意差があります (p < 0.05)'
      }
    end

    it 'respects custom precision setting' do
      high_precision_options = { precision: 6 }
      presenter = described_class.new(result, high_precision_options)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['f_statistic']).to eq(5.662652)
      expect(parsed['p_value']).to eq(0.019218)
      expect(parsed['sum_of_squares']['between']).to eq(566.166667)
      expect(parsed['sum_of_squares']['within']).to eq(450.012346)
      expect(parsed['group_means']).to eq([75.123456, 85.654321, 95.987654])
      expect(parsed['grand_mean']).to eq(85.588477)
    end

    it 'uses default precision when not specified' do
      no_precision_options = {}
      presenter = described_class.new(result, no_precision_options)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      # Default precision is 6
      expect(parsed['f_statistic']).to eq(5.662652)
    end
  end

  describe 'Backward compatibility' do
    let(:result) do
      {
        f_statistic: 5.662651821862349,
        p_value: 0.01921806730769231,
        degrees_of_freedom: [2, 9],
        sum_of_squares: {
          between: 566.1666666666666,
          within: 450.0,
          total: 1016.1666666666666
        },
        mean_squares: {
          between: 283.0833333333333,
          within: 50.0
        },
        effect_size: {
          eta_squared: 0.5574438202247191,
          omega_squared: 0.45579262348178374
        },
        group_means: [75.0, 85.0, 95.0],
        grand_mean: 85.0,
        significant: true,
        interpretation: 'グループ間に有意差があります (p < 0.05)'
      }
    end

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      presenter = described_class.new(result, legacy_options)

      output = presenter.format

      expect(output).to eq('5.663 2 9 0.019 0.557 true')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      presenter = described_class.new(result, json_options)

      output = presenter.format
      parsed = JSON.parse(output)

      expect(parsed['test_type']).to eq('one_way_anova')
    end
  end
end
