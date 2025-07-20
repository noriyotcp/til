# frozen_string_literal: true

require_relative '../../spec_helper'

describe NumberAnalyzer::Presenters::TTestPresenter do
  let(:options) { { precision: 3 } }

  describe 'Independent samples t-test' do
    let(:result) do
      {
        test_type: 'independent_samples',
        t_statistic: -2.7386127875258306,
        degrees_of_freedom: 7.0,
        p_value: 0.02924242424242424,
        significant: true,
        mean1: 85.5,
        mean2: 92.75,
        n1: 4,
        n2: 4
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats independent samples t-test result correctly' do
        output = presenter.format_verbose

        expect(output).to include('T検定結果:')
        expect(output).to include('検定タイプ: 独立2標本t検定')
        expect(output).to include('統計量: t = -2.739')
        expect(output).to include('自由度: df = 7.0')
        expect(output).to include('p値: 0.029')
        expect(output).to include('グループ1: 平均 = 85.5, n = 4')
        expect(output).to include('グループ2: 平均 = 92.75, n = 4')
        expect(output).to include('結論: 有意水準5%で有意差あり')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('-2.739 7.0 0.029 true')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['test_type']).to eq('independent_samples')
        expect(parsed['t_statistic']).to eq(-2.739)
        expect(parsed['degrees_of_freedom']).to eq(7.0)
        expect(parsed['p_value']).to eq(0.029)
        expect(parsed['significant']).to be true
        expect(parsed['mean1']).to eq(85.5)
        expect(parsed['mean2']).to eq(92.75)
        expect(parsed['n1']).to eq(4)
        expect(parsed['n2']).to eq(4)
      end
    end
  end

  describe 'Paired samples t-test' do
    let(:result) do
      {
        test_type: 'paired_samples',
        t_statistic: -3.5590169943749474,
        degrees_of_freedom: 3.0,
        p_value: 0.03751731198209014,
        significant: true,
        mean_difference: -7.25,
        n: 4
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats paired samples t-test result correctly' do
        output = presenter.format_verbose

        expect(output).to include('T検定結果:')
        expect(output).to include('検定タイプ: 対応ありt検定')
        expect(output).to include('統計量: t = -3.559')
        expect(output).to include('自由度: df = 3.0')
        expect(output).to include('p値: 0.038')
        expect(output).to include('平均差: -7.25')
        expect(output).to include('サンプルサイズ: n = 4')
        expect(output).to include('結論: 有意水準5%で有意差あり')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('-3.559 3.0 0.038 true')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['test_type']).to eq('paired_samples')
        expect(parsed['t_statistic']).to eq(-3.559)
        expect(parsed['degrees_of_freedom']).to eq(3.0)
        expect(parsed['p_value']).to eq(0.038)
        expect(parsed['significant']).to be true
        expect(parsed['mean_difference']).to eq(-7.25)
        expect(parsed['n']).to eq(4)
      end
    end
  end

  describe 'One-sample t-test' do
    let(:result) do
      {
        test_type: 'one_sample',
        t_statistic: -1.0606601717798212,
        degrees_of_freedom: 3.0,
        p_value: 0.36866776461628404,
        significant: false,
        sample_mean: 88.75,
        population_mean: 100.0,
        n: 4
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats one-sample t-test result correctly' do
        output = presenter.format_verbose

        expect(output).to include('T検定結果:')
        expect(output).to include('検定タイプ: 一標本t検定')
        expect(output).to include('統計量: t = -1.061')
        expect(output).to include('自由度: df = 3.0')
        expect(output).to include('p値: 0.369')
        expect(output).to include('標本平均: 88.75')
        expect(output).to include('母集団平均: 100.0')
        expect(output).to include('サンプルサイズ: n = 4')
        expect(output).to include('結論: 有意水準5%で有意差なし')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('-1.061 3.0 0.369 false')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['test_type']).to eq('one_sample')
        expect(parsed['t_statistic']).to eq(-1.061)
        expect(parsed['degrees_of_freedom']).to eq(3.0)
        expect(parsed['p_value']).to eq(0.369)
        expect(parsed['significant']).to be false
        expect(parsed['sample_mean']).to eq(88.75)
        expect(parsed['population_mean']).to eq(100.0)
        expect(parsed['n']).to eq(4)
      end
    end
  end

  describe 'Dataset metadata handling' do
    let(:result) do
      {
        test_type: 'independent_samples',
        t_statistic: -2.7386127875258306,
        degrees_of_freedom: 7.0,
        p_value: 0.02924242424242424,
        significant: true,
        mean1: 85.5,
        mean2: 92.75,
        n1: 4,
        n2: 4
      }
    end

    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(
        dataset1_size: 4,
        dataset2_size: 4
      )
      presenter = described_class.new(result, options_with_metadata)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset1_size']).to eq(4)
      expect(parsed['dataset2_size']).to eq(4)
    end

    it 'includes single dataset size when provided' do
      result_one_sample = result.merge(test_type: 'one_sample')
      options_with_metadata = options.merge(dataset_size: 10)
      presenter = described_class.new(result_one_sample, options_with_metadata)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(10)
    end
  end

  describe 'Precision handling' do
    let(:result) do
      {
        test_type: 'independent_samples',
        t_statistic: -2.7386127875258306,
        degrees_of_freedom: 7.123456789,
        p_value: 0.02924242424242424,
        significant: true,
        mean1: 85.555555,
        mean2: 92.777777,
        n1: 4,
        n2: 4
      }
    end

    it 'respects custom precision setting' do
      high_precision_options = { precision: 6 }
      presenter = described_class.new(result, high_precision_options)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['t_statistic']).to eq(-2.738613)
      expect(parsed['degrees_of_freedom']).to eq(7.123457)
      expect(parsed['p_value']).to eq(0.029242)
      expect(parsed['mean1']).to eq(85.555555)
      expect(parsed['mean2']).to eq(92.777777)
    end

    it 'uses default precision when not specified' do
      no_precision_options = {}
      presenter = described_class.new(result, no_precision_options)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      # Default precision is 6
      expect(parsed['t_statistic']).to eq(-2.738613)
    end
  end

  describe 'Backward compatibility' do
    let(:result) do
      {
        test_type: 'independent_samples',
        t_statistic: -2.7386127875258306,
        degrees_of_freedom: 7.0,
        p_value: 0.02924242424242424,
        significant: true,
        mean1: 85.5,
        mean2: 92.75,
        n1: 4,
        n2: 4
      }
    end

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      presenter = described_class.new(result, legacy_options)

      output = presenter.format

      expect(output).to eq('-2.739 7.0 0.029 true')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      presenter = described_class.new(result, json_options)

      output = presenter.format
      parsed = JSON.parse(output)

      expect(parsed['test_type']).to eq('independent_samples')
    end
  end
end
