# frozen_string_literal: true

require_relative '../../spec_helper'

describe NumberAnalyzer::Presenters::ConfidenceIntervalPresenter do
  let(:options) { { precision: 3 } }
  let(:result) do
    {
      confidence_level: 95,
      lower_bound: 23.456,
      upper_bound: 28.754,
      point_estimate: 26.105,
      margin_of_error: 2.649,
      standard_error: 1.234,
      sample_size: 25
    }
  end
  let(:presenter) { described_class.new(result, options) }

  describe '#format_verbose' do
    it 'formats confidence interval result correctly' do
      output = presenter.format_verbose

      expect(output).to include('95%信頼区間: [23.456, 28.754]')
      expect(output).to include('下限: 23.456')
      expect(output).to include('上限: 28.754')
      expect(output).to include('標本平均: 26.105')
      expect(output).to include('誤差の幅: 2.649')
      expect(output).to include('標準誤差: 1.234')
      expect(output).to include('サンプルサイズ: 25')
    end

    it 'handles different confidence levels' do
      result_ninety_nine = result.merge(confidence_level: 99)
      presenter_ninety_nine = described_class.new(result_ninety_nine, options)

      output = presenter_ninety_nine.format_verbose
      expect(output).to include('99%信頼区間')
    end

    it 'handles precision correctly' do
      high_precision_options = { precision: 6 }
      precise_result = result.merge(
        lower_bound: 23.456789,
        upper_bound: 28.754321
      )
      precise_presenter = described_class.new(precise_result, high_precision_options)

      output = precise_presenter.format_verbose
      expect(output).to include('下限: 23.456789')
      expect(output).to include('上限: 28.754321')
    end
  end

  describe '#format_quiet' do
    it 'formats quiet output correctly' do
      output = presenter.format_quiet

      expect(output).to eq('23.456 28.754')
    end

    it 'respects precision in quiet mode' do
      low_precision_options = { precision: 1 }
      low_precision_presenter = described_class.new(result, low_precision_options)

      output = low_precision_presenter.format_quiet
      expect(output).to eq('23.5 28.8')
    end
  end

  describe '#format_json' do
    it 'formats JSON output correctly' do
      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['confidence_level']).to eq(95)
      expect(parsed['lower_bound']).to eq(23.456)
      expect(parsed['upper_bound']).to eq(28.754)
      expect(parsed['point_estimate']).to eq(26.105)
      expect(parsed['margin_of_error']).to eq(2.649)
      expect(parsed['standard_error']).to eq(1.234)
      expect(parsed['sample_size']).to eq(25)
    end

    it 'applies precision to JSON values' do
      high_precision_options = { precision: 2 }
      precise_result = result.merge(
        lower_bound: 23.456789,
        upper_bound: 28.754321,
        point_estimate: 26.105555
      )
      precise_presenter = described_class.new(precise_result, high_precision_options)

      json_output = precise_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['lower_bound']).to eq(23.46)
      expect(parsed['upper_bound']).to eq(28.75)
      expect(parsed['point_estimate']).to eq(26.11)
    end
  end

  describe 'Dataset metadata handling' do
    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 25, dataset1_size: 15)
      presenter_with_metadata = described_class.new(result, options_with_metadata)

      json_output = presenter_with_metadata.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(25)
      expect(parsed['dataset1_size']).to eq(15)
    end

    it 'handles no additional metadata gracefully' do
      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      # Should still have basic confidence interval data
      expect(parsed['confidence_level']).to eq(95)
      expect(parsed['sample_size']).to eq(25)
    end
  end

  describe 'Backward compatibility' do
    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      legacy_presenter = described_class.new(result, legacy_options)

      output = legacy_presenter.format

      expect(output).to eq('23.456 28.754')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      json_presenter = described_class.new(result, json_options)

      output = json_presenter.format
      parsed = JSON.parse(output)

      expect(parsed['confidence_level']).to eq(95)
      expect(parsed['lower_bound']).to eq(23.456)
    end

    it 'handles sample_mean alias for point_estimate' do
      result_with_sample_mean = result.dup
      result_with_sample_mean.delete(:point_estimate)
      result_with_sample_mean[:sample_mean] = 26.105

      sample_mean_presenter = described_class.new(result_with_sample_mean, options)

      output = sample_mean_presenter.format_verbose
      expect(output).to include('標本平均: 26.105')
    end
  end

  describe 'Default precision handling' do
    it 'uses default precision when not specified' do
      no_precision_options = {}
      no_precision_presenter = described_class.new(result, no_precision_options)

      json_output = no_precision_presenter.format_json
      parsed = JSON.parse(json_output)

      # Default precision should be 6
      expect(parsed['lower_bound']).to eq(23.456)
      expect(parsed['upper_bound']).to eq(28.754)
    end
  end

  describe 'Edge cases' do
    describe 'Nil result handling' do
      let(:nil_presenter) { described_class.new(nil, options) }

      it 'handles nil result in verbose format' do
        output = nil_presenter.format_verbose
        expect(output).to eq('')
      end

      it 'handles nil result in quiet format' do
        output = nil_presenter.format_quiet
        expect(output).to eq('')
      end

      it 'handles nil result in JSON format' do
        json_output = nil_presenter.format_json
        parsed = JSON.parse(json_output)
        expect(parsed).to eq({})
      end
    end

    describe 'Very wide confidence intervals' do
      let(:wide_result) do
        result.merge(
          lower_bound: -1000.123,
          upper_bound: 2000.456,
          margin_of_error: 1500.289
        )
      end
      let(:wide_presenter) { described_class.new(wide_result, options) }

      it 'handles very wide intervals correctly' do
        output = wide_presenter.format_verbose
        expect(output).to include('95%信頼区間: [-1000.123, 2000.456]')
        expect(output).to include('誤差の幅: 1500.289')
      end
    end

    describe 'Very narrow confidence intervals' do
      let(:narrow_result) do
        result.merge(
          lower_bound: 25.001,
          upper_bound: 25.002,
          margin_of_error: 0.0005
        )
      end
      let(:narrow_presenter) { described_class.new(narrow_result, options) }

      it 'handles very narrow intervals correctly' do
        output = narrow_presenter.format_verbose
        expect(output).to include('95%信頼区間: [25.001, 25.002]')
        expect(output).to include('誤差の幅: 0.001')
      end
    end

    describe 'High precision requirements' do
      let(:high_precision_options) { { precision: 10 } }
      let(:high_precision_result) do
        result.merge(
          lower_bound: 23.1234567890,
          upper_bound: 28.9876543210
        )
      end
      let(:high_precision_presenter) { described_class.new(high_precision_result, high_precision_options) }

      it 'handles high precision correctly' do
        output = high_precision_presenter.format_verbose
        expect(output).to include('下限: 23.123456789')
        expect(output).to include('上限: 28.987654321')
      end
    end
  end

  describe 'Integration with BaseStatisticalPresenter' do
    it 'inherits format method correctly' do
      expect(presenter).to respond_to(:format)
    end

    it 'inherits dataset_metadata method' do
      expect(presenter).to respond_to(:dataset_metadata)
    end

    it 'inherits apply_precision method' do
      expect(presenter).to respond_to(:apply_precision)
    end
  end
end
