# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::QuartilesPresenter do
  let(:options) { { precision: 3 } }
  let(:quartiles_result) do
    {
      q1: 25.5,
      q2: 50.0,
      q3: 75.5
    }
  end
  let(:presenter) { described_class.new(quartiles_result, options) }

  describe '#format_verbose' do
    it 'formats quartiles correctly' do
      output = presenter.format_verbose

      expect(output).to eq("Q1: 25.5\nQ2: 50.0\nQ3: 75.5")
    end

    it 'applies precision to quartile values' do
      high_precision_result = {
        q1: 25.123456789,
        q2: 50.987654321,
        q3: 75.555555555
      }
      high_precision_presenter = described_class.new(high_precision_result, { precision: 2 })

      output = high_precision_presenter.format_verbose
      expect(output).to eq("Q1: 25.12\nQ2: 50.99\nQ3: 75.56")
    end
  end

  describe '#format_quiet' do
    it 'formats quartiles in space-separated format' do
      output = presenter.format_quiet

      expect(output).to eq('25.5 50.0 75.5')
    end

    it 'respects precision in quiet mode' do
      high_precision_result = {
        q1: 25.123456789,
        q2: 50.987654321,
        q3: 75.555555555
      }
      precision_presenter = described_class.new(high_precision_result, { precision: 1 })

      output = precision_presenter.format_quiet
      expect(output).to eq('25.1 51.0 75.6')
    end
  end

  describe '#format_json' do
    it 'formats JSON output correctly' do
      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['q1']).to eq(25.5)
      expect(parsed['q2']).to eq(50.0)
      expect(parsed['q3']).to eq(75.5)
    end

    it 'applies precision to JSON values' do
      high_precision_result = {
        q1: 25.123456789,
        q2: 50.987654321,
        q3: 75.555555555
      }
      precision_presenter = described_class.new(high_precision_result, { precision: 4 })

      json_output = precision_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['q1']).to eq(25.1235)
      expect(parsed['q2']).to eq(50.9877)
      expect(parsed['q3']).to eq(75.5556)
    end
  end

  describe 'Integer quartiles' do
    let(:integer_result) do
      {
        q1: 10,
        q2: 20,
        q3: 30
      }
    end
    let(:integer_presenter) { described_class.new(integer_result, options) }

    it 'handles integer quartiles correctly' do
      output = integer_presenter.format_verbose
      expect(output).to eq("Q1: 10\nQ2: 20\nQ3: 30")
    end

    it 'formats integer quartiles in quiet mode' do
      output = integer_presenter.format_quiet
      expect(output).to eq('10 20 30')
    end

    it 'formats integer quartiles in JSON' do
      json_output = integer_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['q1']).to eq(10)
      expect(parsed['q2']).to eq(20)
      expect(parsed['q3']).to eq(30)
    end
  end

  describe 'Edge case quartiles' do
    let(:edge_case_result) do
      {
        q1: 0.0,
        q2: 0.1,
        q3: 100.0
      }
    end
    let(:edge_presenter) { described_class.new(edge_case_result, options) }

    it 'handles edge case values correctly' do
      output = edge_presenter.format_verbose
      expect(output).to eq("Q1: 0.0\nQ2: 0.1\nQ3: 100.0")
    end
  end

  describe 'Nil result handling' do
    let(:nil_presenter) { described_class.new(nil, options) }

    describe '#format_verbose' do
      it 'handles nil result gracefully' do
        output = nil_presenter.format_verbose
        expect(output).to eq('')
      end
    end

    describe '#format_quiet' do
      it 'handles nil result gracefully' do
        output = nil_presenter.format_quiet
        expect(output).to eq('')
      end
    end

    describe '#format_json' do
      it 'handles nil result gracefully' do
        json_output = nil_presenter.format_json
        parsed = JSON.parse(json_output)
        expect(parsed).to eq({})
      end
    end
  end

  describe 'Dataset metadata handling' do
    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 100, dataset1_size: 50)
      presenter_with_metadata = described_class.new(quartiles_result, options_with_metadata)

      json_output = presenter_with_metadata.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(100)
      expect(parsed['dataset1_size']).to eq(50)
      expect(parsed['q1']).to eq(25.5)
      expect(parsed['q2']).to eq(50.0)
      expect(parsed['q3']).to eq(75.5)
    end

    it 'handles no metadata gracefully' do
      json_output = presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['q1']).to eq(25.5)
      expect(parsed['q2']).to eq(50.0)
      expect(parsed['q3']).to eq(75.5)
      expect(parsed.keys).not_to include('dataset_size')
    end
  end

  describe 'Backward compatibility' do
    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      legacy_presenter = described_class.new(quartiles_result, legacy_options)

      output = legacy_presenter.format
      expect(output).to eq('25.5 50.0 75.5')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      json_presenter = described_class.new(quartiles_result, json_options)

      output = json_presenter.format
      parsed = JSON.parse(output)

      expect(parsed['q1']).to eq(25.5)
      expect(parsed['q2']).to eq(50.0)
      expect(parsed['q3']).to eq(75.5)
    end
  end

  describe 'Default precision handling' do
    it 'uses default precision when not specified' do
      no_precision_presenter = described_class.new(quartiles_result, {})

      json_output = no_precision_presenter.format_json
      parsed = JSON.parse(json_output)

      # Default precision should be 6
      expect(parsed['q1']).to eq(25.5)
      expect(parsed['q2']).to eq(50.0)
      expect(parsed['q3']).to eq(75.5)
    end
  end

  describe 'Very high precision' do
    let(:high_precision_result) do
      {
        q1: 1.123456789012345,
        q2: 2.987654321098765,
        q3: 3.555555555555555
      }
    end

    it 'handles very high precision correctly' do
      very_high_precision_presenter = described_class.new(high_precision_result, { precision: 10 })

      json_output = very_high_precision_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['q1']).to eq(1.123456789)
      expect(parsed['q2']).to eq(2.9876543211)
      expect(parsed['q3']).to eq(3.5555555556)
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
