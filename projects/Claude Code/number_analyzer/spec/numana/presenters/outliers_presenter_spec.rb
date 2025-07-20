# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::OutliersPresenter do
  let(:options) { { precision: 3 } }

  describe 'With outliers' do
    let(:outliers_result) { [1.5, 95.8, -2.3] }
    let(:presenter) { described_class.new(outliers_result, options) }

    describe '#format_verbose' do
      it 'formats outliers with comma separation' do
        output = presenter.format_verbose
        expect(output).to eq('1.5, 95.8, -2.3')
      end
    end

    describe '#format_quiet' do
      it 'formats outliers with space separation' do
        output = presenter.format_quiet
        expect(output).to eq('1.5 95.8 -2.3')
      end
    end

    describe '#format_json' do
      it 'formats outliers in JSON array' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['outliers']).to eq([1.5, 95.8, -2.3])
      end
    end
  end

  describe 'No outliers (empty array)' do
    let(:outliers_result) { [] }
    let(:presenter) { described_class.new(outliers_result, options) }

    describe '#format_verbose' do
      it 'returns Japanese "none" message' do
        output = presenter.format_verbose
        expect(output).to eq('なし')
      end
    end

    describe '#format_quiet' do
      it 'returns empty string' do
        output = presenter.format_quiet
        expect(output).to eq('')
      end
    end

    describe '#format_json' do
      it 'returns empty array in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['outliers']).to eq([])
      end
    end
  end

  describe 'Nil outliers result' do
    let(:outliers_result) { nil }
    let(:presenter) { described_class.new(outliers_result, options) }

    describe '#format_verbose' do
      it 'returns Japanese "none" message' do
        output = presenter.format_verbose
        expect(output).to eq('なし')
      end
    end

    describe '#format_quiet' do
      it 'returns empty string' do
        output = presenter.format_quiet
        expect(output).to eq('')
      end
    end

    describe '#format_json' do
      it 'returns empty array in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['outliers']).to eq([])
      end
    end
  end

  describe 'Precision handling' do
    let(:outliers_result) { [1.123456789, -5.987654321] }

    it 'applies precision to outlier values' do
      precision_presenter = described_class.new(outliers_result, { precision: 2 })

      json_output = precision_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['outliers']).to eq([1.12, -5.99])
    end
  end

  describe 'Backward compatibility' do
    let(:outliers_result) { [10.5, 20.7] }

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      legacy_presenter = described_class.new(outliers_result, legacy_options)

      output = legacy_presenter.format
      expect(output).to eq('10.5 20.7')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      json_presenter = described_class.new(outliers_result, json_options)

      output = json_presenter.format
      parsed = JSON.parse(output)

      expect(parsed['outliers']).to eq([10.5, 20.7])
    end
  end
end
