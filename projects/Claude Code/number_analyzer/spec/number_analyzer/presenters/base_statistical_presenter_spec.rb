# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/presenters/base_statistical_presenter'

RSpec.describe NumberAnalyzer::Presenters::BaseStatisticalPresenter do
  let(:test_result) do
    {
      test_type: 'Test',
      statistic: 2.5,
      p_value: 0.03,
      significant: true,
      interpretation: 'Significant difference detected'
    }
  end

  let(:options) { { precision: 3 } }
  let(:presenter) { described_class.new(test_result, options) }

  describe '#initialize' do
    it 'sets result and options' do
      expect(presenter.instance_variable_get(:@result)).to eq(test_result)
      expect(presenter.instance_variable_get(:@options)).to eq(options)
    end

    it 'sets default precision when not specified' do
      presenter_no_precision = described_class.new(test_result, {})
      expect(presenter_no_precision.instance_variable_get(:@precision)).to eq(6)
    end

    it 'uses custom precision when specified' do
      expect(presenter.instance_variable_get(:@precision)).to eq(3)
    end
  end

  describe '#format' do
    context 'when format is json' do
      let(:options) { { format: 'json' } }

      it 'calls format_json' do
        allow(presenter).to receive(:format_json).and_return('{"test": "json"}')
        result = presenter.format
        expect(presenter).to have_received(:format_json)
        expect(result).to eq('{"test": "json"}')
      end
    end

    context 'when format is quiet' do
      let(:options) { { format: 'quiet' } }

      it 'calls format_quiet' do
        allow(presenter).to receive(:format_quiet).and_return('2.5 0.03')
        result = presenter.format
        expect(presenter).to have_received(:format_quiet)
        expect(result).to eq('2.5 0.03')
      end
    end

    context 'when format is verbose (default)' do
      it 'calls format_verbose' do
        allow(presenter).to receive(:format_verbose).and_return('Detailed output')
        result = presenter.format
        expect(presenter).to have_received(:format_verbose)
        expect(result).to eq('Detailed output')
      end
    end
  end

  describe '#format_json' do
    it 'calls json_fields and returns JSON' do
      allow(presenter).to receive(:json_fields).and_return({ test: 'data' })
      result = presenter.format_json
      expect(JSON.parse(result)).to eq({ 'test' => 'data' })
    end
  end

  describe '#round_value' do
    it 'rounds value to specified precision' do
      expect(presenter.round_value(2.56789)).to eq(2.568)
    end
  end

  describe '#format_significance' do
    it 'returns "**Significant**" for significant results' do
      expect(presenter.format_significance(true)).to eq('**Significant**')
    end

    it 'returns "Not significant" for non-significant results' do
      expect(presenter.format_significance(false)).to eq('Not significant')
    end
  end

  describe 'abstract methods' do
    describe '#json_fields' do
      it 'raises NotImplementedError' do
        expect { presenter.json_fields }.to raise_error(NotImplementedError, 'Subclass must implement json_fields')
      end
    end

    describe '#format_quiet' do
      it 'raises NotImplementedError' do
        expect { presenter.format_quiet }.to raise_error(NotImplementedError, 'Subclass must implement format_quiet')
      end
    end

    describe '#format_verbose' do
      it 'raises NotImplementedError' do
        expect { presenter.format_verbose }.to raise_error(NotImplementedError, 'Subclass must implement format_verbose')
      end
    end
  end
end
