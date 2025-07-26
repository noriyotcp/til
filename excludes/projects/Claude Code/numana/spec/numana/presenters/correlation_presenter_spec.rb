# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::CorrelationPresenter do
  let(:options) { { precision: 3 } }

  describe 'Valid correlation coefficient' do
    let(:correlation_value) { 0.8567 }
    let(:presenter) { described_class.new(correlation_value, options) }

    describe '#format_verbose' do
      it 'formats correlation with interpretation correctly' do
        output = presenter.format_verbose

        expect(output).to include('相関係数: 0.857')
        expect(output).to include('(Strong positive correlation)')
      end
    end

    describe '#format_quiet' do
      it 'returns only the correlation value' do
        output = presenter.format_quiet

        expect(output).to eq('0.857')
      end
    end

    describe '#format_json' do
      it 'formats JSON output correctly' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['correlation']).to eq(0.857)
      end
    end
  end

  describe 'Strong positive correlation' do
    let(:correlation_value) { 0.95 }
    let(:presenter) { described_class.new(correlation_value, options) }

    it 'interprets as strong positive correlation' do
      output = presenter.format_verbose
      expect(output).to include('Strong positive correlation')
    end
  end

  describe 'Moderate negative correlation' do
    let(:correlation_value) { -0.65 }
    let(:presenter) { described_class.new(correlation_value, options) }

    it 'interprets as moderate negative correlation' do
      output = presenter.format_verbose
      expect(output).to include('Moderate negative correlation')
    end
  end

  describe 'Weak correlation' do
    let(:correlation_value) { 0.25 }
    let(:presenter) { described_class.new(correlation_value, options) }

    it 'interprets as no correlation' do
      output = presenter.format_verbose
      expect(output).to include('No correlation')
    end
  end

  describe 'No correlation' do
    let(:correlation_value) { 0.05 }
    let(:presenter) { described_class.new(correlation_value, options) }

    it 'interprets as no correlation' do
      output = presenter.format_verbose
      expect(output).to include('No correlation')
    end
  end

  describe 'Perfect correlation' do
    let(:correlation_value) { 1.0 }
    let(:presenter) { described_class.new(correlation_value, options) }

    it 'interprets as strong positive correlation' do
      output = presenter.format_verbose
      expect(output).to include('Strong positive correlation')
    end
  end

  describe 'Perfect negative correlation' do
    let(:correlation_value) { -1.0 }
    let(:presenter) { described_class.new(correlation_value, options) }

    it 'interprets as strong negative correlation' do
      output = presenter.format_verbose
      expect(output).to include('Strong negative correlation')
    end
  end

  describe 'Invalid correlation (nil)' do
    let(:correlation_value) { nil }
    let(:presenter) { described_class.new(correlation_value, options) }

    describe '#format_verbose' do
      it 'returns error message' do
        output = presenter.format_verbose
        expect(output).to eq('エラー: データセットが無効です')
      end
    end

    describe '#format_quiet' do
      it 'returns empty string' do
        output = presenter.format_quiet
        expect(output).to eq('')
      end
    end

    describe '#format_json' do
      it 'returns null correlation in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['correlation']).to be_nil
      end
    end
  end

  describe 'Precision handling' do
    let(:correlation_value) { 0.123456789 }

    it 'respects custom precision setting' do
      high_precision_presenter = described_class.new(correlation_value, { precision: 6 })

      json_output = high_precision_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['correlation']).to eq(0.123457)
    end

    it 'uses default precision when not specified' do
      no_precision_presenter = described_class.new(correlation_value, {})

      json_output = no_precision_presenter.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['correlation']).to eq(0.123457) # Default precision is 6
    end

    it 'applies precision to verbose output' do
      high_precision_presenter = described_class.new(correlation_value, { precision: 2 })

      output = high_precision_presenter.format_verbose
      expect(output).to include('相関係数: 0.12')
    end
  end

  describe 'Dataset metadata handling' do
    let(:correlation_value) { 0.75 }

    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 50, dataset1_size: 25)
      presenter_with_metadata = described_class.new(correlation_value, options_with_metadata)

      json_output = presenter_with_metadata.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(50)
      expect(parsed['dataset1_size']).to eq(25)
      expect(parsed['correlation']).to eq(0.75)
    end

    it 'handles no metadata gracefully' do
      presenter_without_metadata = described_class.new(correlation_value, options)
      json_output = presenter_without_metadata.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['correlation']).to eq(0.75)
      expect(parsed.keys).not_to include('dataset_size')
    end
  end

  describe 'Backward compatibility' do
    let(:correlation_value) { 0.65 }

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      legacy_presenter = described_class.new(correlation_value, legacy_options)

      output = legacy_presenter.format
      expect(output).to eq('0.65')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      json_presenter = described_class.new(correlation_value, json_options)

      output = json_presenter.format
      parsed = JSON.parse(output)

      expect(parsed['correlation']).to eq(0.65)
    end
  end

  describe 'Edge cases' do
    describe 'Zero correlation' do
      let(:correlation_value) { 0.0 }
      let(:presenter) { described_class.new(correlation_value, options) }

      it 'handles zero correlation correctly' do
        output = presenter.format_verbose
        expect(output).to include('相関係数: 0.0')
        expect(output).to include('No correlation')
      end
    end

    describe 'Very small positive correlation' do
      let(:correlation_value) { 0.001 }
      let(:presenter) { described_class.new(correlation_value, options) }

      it 'formats small values correctly' do
        output = presenter.format_verbose
        expect(output).to include('相関係数: 0.001')
      end
    end

    describe 'Very small negative correlation' do
      let(:correlation_value) { -0.001 }
      let(:presenter) { described_class.new(correlation_value, options) }

      it 'formats small negative values correctly' do
        output = presenter.format_verbose
        expect(output).to include('相関係数: -0.001')
      end
    end
  end

  describe 'Integration with BaseStatisticalPresenter' do
    let(:correlation_value) { 0.5 }
    let(:presenter) { described_class.new(correlation_value, options) }

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
