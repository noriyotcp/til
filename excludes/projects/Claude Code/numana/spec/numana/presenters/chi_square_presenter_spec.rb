# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::ChiSquarePresenter do
  let(:options) { { precision: 3 } }

  describe 'Independence test' do
    let(:result) do
      {
        test_type: 'independence',
        chi_square_statistic: 5.991,
        degrees_of_freedom: 1,
        p_value: 0.014,
        significant: true,
        expected_frequencies_valid: true,
        warning: nil,
        cramers_v: 0.387,
        observed_frequencies: [[10, 20], [30, 40]],
        expected_frequencies: [[15, 15], [35, 35]]
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats independence test result correctly' do
        output = presenter.format_verbose

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('検定タイプ: 独立性検定')
        expect(output).to include('統計量: χ² = 5.991')
        expect(output).to include('自由度: df = 1')
        expect(output).to include('p値: 0.014')
        expect(output).to include('結論: 有意水準5%で有意差あり')
        expect(output).to include('効果サイズ (Cramér\'s V): 0.387')
        expect(output).to include('期待度数条件: 満たしている')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('5.991 1 0.014 true')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['test_type']).to eq('independence')
        expect(parsed['chi_square_statistic']).to eq(5.991)
        expect(parsed['degrees_of_freedom']).to eq(1)
        expect(parsed['p_value']).to eq(0.014)
        expect(parsed['significant']).to be true
        expect(parsed['expected_frequencies_valid']).to be true
        expect(parsed['cramers_v']).to eq(0.387)
        expect(parsed['observed_frequencies']).to eq([[10, 20], [30, 40]])
        expect(parsed['expected_frequencies']).to eq([[15, 15], [35, 35]])
      end
    end
  end

  describe 'Goodness-of-fit test' do
    let(:result) do
      {
        test_type: 'goodness_of_fit',
        chi_square_statistic: 12.345,
        degrees_of_freedom: 3,
        p_value: 0.006,
        significant: true,
        expected_frequencies_valid: true,
        warning: nil
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats goodness-of-fit test result correctly' do
        output = presenter.format_verbose

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('検定タイプ: 適合度検定')
        expect(output).to include('統計量: χ² = 12.345')
        expect(output).to include('自由度: df = 3')
        expect(output).to include('p値: 0.006')
        expect(output).to include('結論: 有意水準5%で有意差あり')
        expect(output).not_to include('効果サイズ')
        expect(output).to include('期待度数条件: 満たしている')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('12.345 3 0.006 true')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['test_type']).to eq('goodness_of_fit')
        expect(parsed['chi_square_statistic']).to eq(12.345)
        expect(parsed['degrees_of_freedom']).to eq(3)
        expect(parsed['p_value']).to eq(0.006)
        expect(parsed['significant']).to be true
        expect(parsed['cramers_v']).to be_nil
      end
    end
  end

  describe 'Non-significant test with warning' do
    let(:result) do
      {
        test_type: 'independence',
        chi_square_statistic: 2.345,
        degrees_of_freedom: 1,
        p_value: 0.126,
        significant: false,
        expected_frequencies_valid: false,
        warning: '警告: 一部の期待度数が5未満です',
        cramers_v: 0.234
      }
    end
    let(:presenter) { described_class.new(result, options) }

    describe '#format_verbose' do
      it 'formats non-significant test with warning correctly' do
        output = presenter.format_verbose

        expect(output).to include('p値: 0.126')
        expect(output).to include('結論: 有意水準5%で有意差なし')
        expect(output).to include('警告: 一部の期待度数が5未満です')
      end
    end

    describe '#format_quiet' do
      it 'formats quiet output correctly' do
        output = presenter.format_quiet

        expect(output).to eq('2.345 1 0.126 false')
      end
    end
  end

  describe 'Nil result handling' do
    let(:result) { nil }
    let(:presenter) { described_class.new(result, options) }

    it 'handles nil result in format_verbose' do
      output = presenter.format_verbose
      expect(output).to eq('')
    end

    it 'handles nil result in format_quiet' do
      output = presenter.format_quiet
      expect(output).to eq('')
    end

    it 'handles nil result in format_json' do
      json_output = presenter.format_json
      parsed = JSON.parse(json_output)
      expect(parsed).to eq({})
    end
  end

  describe 'Dataset metadata handling' do
    let(:result) do
      {
        test_type: 'independence',
        chi_square_statistic: 5.991,
        degrees_of_freedom: 1,
        p_value: 0.014,
        significant: true,
        expected_frequencies_valid: true,
        cramers_v: 0.387
      }
    end

    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 100)
      presenter = described_class.new(result, options_with_metadata)

      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(100)
    end
  end

  describe 'Backward compatibility' do
    let(:result) do
      {
        test_type: 'independence',
        chi_square_statistic: 5.991,
        degrees_of_freedom: 1,
        p_value: 0.014,
        significant: true,
        expected_frequencies_valid: true,
        cramers_v: 0.387
      }
    end

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      presenter = described_class.new(result, legacy_options)

      output = presenter.format

      expect(output).to eq('5.991 1 0.014 true')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      presenter = described_class.new(result, json_options)

      output = presenter.format
      parsed = JSON.parse(output)

      expect(parsed['test_type']).to eq('independence')
    end
  end
end
