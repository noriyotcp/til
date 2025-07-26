# frozen_string_literal: true

require_relative '../../spec_helper'

describe Numana::Presenters::ModePresenter do
  let(:options) { { precision: 3 } }

  describe 'Single mode value' do
    let(:mode_result) { [5] }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'formats single mode correctly' do
        output = presenter.format_verbose
        expect(output).to eq('5')
      end
    end

    describe '#format_quiet' do
      it 'formats single mode correctly' do
        output = presenter.format_quiet
        expect(output).to eq('5')
      end
    end

    describe '#format_json' do
      it 'formats single mode in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to eq([5])
      end
    end
  end

  describe 'Multiple mode values' do
    let(:mode_result) { [3, 7, 9] }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'formats multiple modes with comma separation' do
        output = presenter.format_verbose
        expect(output).to eq('3, 7, 9')
      end
    end

    describe '#format_quiet' do
      it 'formats multiple modes with space separation' do
        output = presenter.format_quiet
        expect(output).to eq('3 7 9')
      end
    end

    describe '#format_json' do
      it 'formats multiple modes in JSON array' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to eq([3, 7, 9])
      end
    end
  end

  describe 'Floating point mode values' do
    let(:mode_result) { [1.5, 2.75] }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'formats floating point modes correctly' do
        output = presenter.format_verbose
        expect(output).to eq('1.5, 2.75')
      end
    end

    describe '#format_quiet' do
      it 'formats floating point modes correctly' do
        output = presenter.format_quiet
        expect(output).to eq('1.5 2.75')
      end
    end

    describe '#format_json' do
      it 'formats floating point modes in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to eq([1.5, 2.75])
      end
    end
  end

  describe 'Empty mode array (no mode)' do
    let(:mode_result) { [] }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'returns English "no mode" message' do
        output = presenter.format_verbose
        expect(output).to eq('No mode')
      end
    end

    describe '#format_quiet' do
      it 'returns empty string' do
        output = presenter.format_quiet
        expect(output).to eq('')
      end
    end

    describe '#format_json' do
      it 'returns null mode in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to be_nil
      end
    end
  end

  describe 'Nil mode result' do
    let(:mode_result) { nil }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'returns English "no mode" message' do
        output = presenter.format_verbose
        expect(output).to eq('No mode')
      end
    end

    describe '#format_quiet' do
      it 'returns empty string' do
        output = presenter.format_quiet
        expect(output).to eq('')
      end
    end

    describe '#format_json' do
      it 'returns null mode in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to be_nil
      end
    end
  end

  describe 'String mode values' do
    let(:mode_result) { %w[apple banana] }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'formats string modes correctly' do
        output = presenter.format_verbose
        expect(output).to eq('apple, banana')
      end
    end

    describe '#format_quiet' do
      it 'formats string modes correctly' do
        output = presenter.format_quiet
        expect(output).to eq('apple banana')
      end
    end

    describe '#format_json' do
      it 'formats string modes in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to eq(%w[apple banana])
      end
    end
  end

  describe 'Large numbers mode' do
    let(:mode_result) { [1_000_000, 2_000_000] }
    let(:presenter) { described_class.new(mode_result, options) }

    describe '#format_verbose' do
      it 'formats large numbers correctly' do
        output = presenter.format_verbose
        expect(output).to eq('1000000, 2000000')
      end
    end

    describe '#format_json' do
      it 'formats large numbers in JSON' do
        json_output = presenter.format_json
        parsed = JSON.parse(json_output)

        expect(parsed['mode']).to eq([1_000_000, 2_000_000])
      end
    end
  end

  describe 'Dataset metadata handling' do
    let(:mode_result) { [42] }

    it 'includes dataset metadata in JSON output when provided' do
      options_with_metadata = options.merge(dataset_size: 100, dataset1_size: 50)
      presenter_with_metadata = described_class.new(mode_result, options_with_metadata)

      json_output = presenter_with_metadata.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['dataset_size']).to eq(100)
      expect(parsed['dataset1_size']).to eq(50)
      expect(parsed['mode']).to eq([42])
    end

    it 'handles no metadata gracefully' do
      presenter_without_metadata = described_class.new(mode_result, options)
      json_output = presenter_without_metadata.format_json
      parsed = JSON.parse(json_output)

      expect(parsed['mode']).to eq([42])
      expect(parsed.keys).not_to include('dataset_size')
    end
  end

  describe 'Backward compatibility' do
    let(:mode_result) { [10, 20] }

    it 'handles legacy quiet option' do
      legacy_options = options.merge(quiet: true)
      legacy_presenter = described_class.new(mode_result, legacy_options)

      output = legacy_presenter.format
      expect(output).to eq('10 20')
    end

    it 'handles format option correctly' do
      json_options = options.merge(format: 'json')
      json_presenter = described_class.new(mode_result, json_options)

      output = json_presenter.format
      parsed = JSON.parse(output)

      expect(parsed['mode']).to eq([10, 20])
    end
  end

  describe 'Edge cases' do
    describe 'Single zero mode' do
      let(:mode_result) { [0] }
      let(:presenter) { described_class.new(mode_result, options) }

      it 'handles zero mode correctly' do
        output = presenter.format_verbose
        expect(output).to eq('0')
      end
    end

    describe 'Negative mode values' do
      let(:mode_result) { [-5, -10] }
      let(:presenter) { described_class.new(mode_result, options) }

      it 'handles negative modes correctly' do
        output = presenter.format_verbose
        expect(output).to eq('-5, -10')
      end
    end

    describe 'Mixed positive and negative modes' do
      let(:mode_result) { [-2, 0, 5] }
      let(:presenter) { described_class.new(mode_result, options) }

      it 'handles mixed sign modes correctly' do
        output = presenter.format_verbose
        expect(output).to eq('-2, 0, 5')
      end
    end
  end

  describe 'Integration with BaseStatisticalPresenter' do
    let(:mode_result) { [15] }
    let(:presenter) { described_class.new(mode_result, options) }

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
