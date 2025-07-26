# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::TwoWayAnovaPresenter do
  let(:options) { { precision: 3 } }

  describe 'Two-way ANOVA' do
    let(:result) do
      {
        grand_mean: 75.5,
        main_effects: {
          factor_a: {
            f_statistic: 12.345,
            p_value: 0.001,
            degrees_of_freedom: [1, 8],
            sum_of_squares: 123.45,
            mean_squares: 123.45,
            eta_squared: 0.6,
            significant: true
          },
          factor_b: {
            f_statistic: 8.765,
            p_value: 0.018,
            degrees_of_freedom: [1, 8],
            sum_of_squares: 87.65,
            mean_squares: 87.65,
            eta_squared: 0.52,
            significant: true
          }
        },
        interaction: {
          f_statistic: 2.345,
          p_value: 0.165,
          degrees_of_freedom: [1, 8],
          sum_of_squares: 23.45,
          mean_squares: 23.45,
          eta_squared: 0.23,
          significant: false
        },
        error: {
          sum_of_squares: 80.0,
          mean_squares: 10.0,
          degrees_of_freedom: 8
        },
        total: {
          sum_of_squares: 314.55,
          degrees_of_freedom: 11
        },
        cell_means: {
          'A1' => { 'B1' => 70.0, 'B2' => 75.0 },
          'A2' => { 'B1' => 78.0, 'B2' => 79.0 }
        },
        marginal_means: {
          factor_a: { 'A1' => 72.5, 'A2' => 78.5 },
          factor_b: { 'B1' => 74.0, 'B2' => 77.0 }
        },
        interpretation: '要因Aと要因Bに有意な主効果があります。交互作用は有意ではありません。'
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats two-way ANOVA result correctly' do
        output = presenter.format_verbose

        expect(output).to include('=== 二元配置分散分析結果 ===')
        expect(output).to include('全体平均値: 75.5')
        expect(output).to include('【要因A 水準別平均値】')
        expect(output).to include('A1: 72.5')
        expect(output).to include('A2: 78.5')
        expect(output).to include('【要因B 水準別平均値】')
        expect(output).to include('B1: 74.0')
        expect(output).to include('B2: 77.0')
        expect(output).to include('【セル平均値 (要因A × 要因B)】')
        expect(output).to include('A1 × B1: 70.0')
        expect(output).to include('【二元配置分散分析表】')
        expect(output).to include('主効果A (要因A)')
        expect(output).to include('主効果B (要因B)')
        expect(output).to include('交互作用A×B')
        expect(output).to include('【効果サイズ (Partial η²)】')
        expect(output).to include('要因A: 0.6')
        expect(output).to include('要因B: 0.52')
        expect(output).to include('交互作用A×B: 0.23')
        expect(output).to include('【解釈】')
        expect(output).to include('要因Aと要因Bに有意な主効果があります。交互作用は有意ではありません。')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('A:12.345,0.001,true B:8.765,0.018,true AB:2.345,0.165,false')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['type']).to eq('two_way_anova')
        expect(parsed['grand_mean']).to eq(75.5)
        expect(parsed['main_effects']['factor_a']['f_statistic']).to eq(12.345)
        expect(parsed['main_effects']['factor_a']['p_value']).to eq(0.001)
        expect(parsed['main_effects']['factor_a']['significant']).to be true
        expect(parsed['main_effects']['factor_b']['f_statistic']).to eq(8.765)
        expect(parsed['main_effects']['factor_b']['significant']).to be true
        expect(parsed['interaction']['f_statistic']).to eq(2.345)
        expect(parsed['interaction']['significant']).to be false
        expect(parsed['cell_means']['A1']['B1']).to eq(70.0)
        expect(parsed['marginal_means']['factor_a']['A1']).to eq(72.5)
        expect(parsed['interpretation']).to eq('要因Aと要因Bに有意な主効果があります。交互作用は有意ではありません。')
      end
    end
  end

  describe 'Backward compatibility' do
    let(:result) do
      {
        grand_mean: 75.5,
        main_effects: {
          factor_a: {
            f_statistic: 12.345,
            p_value: 0.001,
            degrees_of_freedom: [1, 8],
            sum_of_squares: 123.45,
            mean_squares: 123.45,
            eta_squared: 0.6,
            significant: true
          },
          factor_b: {
            f_statistic: 8.765,
            p_value: 0.018,
            degrees_of_freedom: [1, 8],
            sum_of_squares: 87.65,
            mean_squares: 87.65,
            eta_squared: 0.52,
            significant: true
          }
        },
        interaction: {
          f_statistic: 2.345,
          p_value: 0.165,
          degrees_of_freedom: [1, 8],
          sum_of_squares: 23.45,
          mean_squares: 23.45,
          eta_squared: 0.23,
          significant: false
        },
        error: {
          sum_of_squares: 80.0,
          mean_squares: 10.0,
          degrees_of_freedom: 8
        },
        total: {
          sum_of_squares: 314.55,
          degrees_of_freedom: 11
        },
        cell_means: {
          'A1' => { 'B1' => 70.0, 'B2' => 75.0 },
          'A2' => { 'B1' => 78.0, 'B2' => 79.0 }
        },
        marginal_means: {
          factor_a: { 'A1' => 72.5, 'A2' => 78.5 },
          factor_b: { 'B1' => 74.0, 'B2' => 77.0 }
        },
        interpretation: '要因Aと要因Bに有意な主効果があります。交互作用は有意ではありません。'
      }
    end

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      presenter = described_class.new(result, legacy_options)

      output = presenter.format

      expect(output).to eq('A:12.345,0.001,true B:8.765,0.018,true AB:2.345,0.165,false')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      presenter = described_class.new(result, json_options)

      output = presenter.format
      parsed = JSON.parse(output)

      expect(parsed['type']).to eq('two_way_anova')
    end
  end
end
