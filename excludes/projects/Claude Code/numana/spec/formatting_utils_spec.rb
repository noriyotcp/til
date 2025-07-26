# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/numana/formatting_utils'

# Test class to include the module for testing
class TestFormattingUtils
  include Numana::FormattingUtils
end

RSpec.describe Numana::FormattingUtils do
  let(:formatter) { TestFormattingUtils.new }

  describe '#format_value' do
    context 'with default format' do
      it 'formats numeric values as strings' do
        expect(formatter.format_value(42)).to eq('42')
        expect(formatter.format_value(3.14159)).to eq('3.14159')
      end

      it 'applies precision when specified' do
        expect(formatter.format_value(3.14159, precision: 2)).to eq('3.14')
        expect(formatter.format_value(42.0, precision: 0)).to eq('42')
      end

      it 'handles non-numeric values' do
        expect(formatter.format_value('text')).to eq('text')
        expect(formatter.format_value(nil)).to eq('')
      end

      it 'ignores precision for non-numeric values' do
        expect(formatter.format_value('text', precision: 2)).to eq('text')
      end
    end

    context 'with JSON format' do
      it 'returns JSON with value and metadata' do
        result = formatter.format_value(42, format: 'json')
        parsed = JSON.parse(result)

        expect(parsed['value']).to eq(42)
      end

      it 'includes dataset metadata when provided' do
        result = formatter.format_value(42, format: 'json', dataset_size: 100)
        parsed = JSON.parse(result)

        expect(parsed['value']).to eq(42)
        expect(parsed['dataset_size']).to eq(100)
      end

      it 'applies precision before JSON formatting' do
        result = formatter.format_value(3.14159, format: 'json', precision: 2)
        parsed = JSON.parse(result)

        expect(parsed['value']).to eq(3.14)
      end
    end
  end

  describe '#format_array' do
    let(:values) { [1.234, 2.567, 3.891] }

    context 'with default format' do
      it 'joins values with commas and spaces' do
        expect(formatter.format_array(values)).to eq('1.234, 2.567, 3.891')
      end

      it 'applies precision to all values' do
        expect(formatter.format_array(values, precision: 1)).to eq('1.2, 2.6, 3.9')
      end

      it 'handles empty arrays' do
        expect(formatter.format_array([])).to eq('')
      end

      it 'handles single values' do
        expect(formatter.format_array([42])).to eq('42')
      end
    end

    context 'with quiet format' do
      it 'joins values with spaces only' do
        expect(formatter.format_array(values, format: 'quiet')).to eq('1.234 2.567 3.891')
      end

      it 'applies precision in quiet mode' do
        expect(formatter.format_array(values, format: 'quiet', precision: 2)).to eq('1.23 2.57 3.89')
      end

      it 'handles empty arrays in quiet mode' do
        expect(formatter.format_array([], format: 'quiet')).to eq('')
      end
    end

    context 'with JSON format' do
      it 'returns JSON with values array' do
        result = formatter.format_array(values, format: 'json')
        parsed = JSON.parse(result)

        expect(parsed['values']).to eq([1.234, 2.567, 3.891])
      end

      it 'includes dataset metadata' do
        result = formatter.format_array(values, format: 'json', dataset_size: 100)
        parsed = JSON.parse(result)

        expect(parsed['values']).to eq(values)
        expect(parsed['dataset_size']).to eq(100)
      end

      it 'applies precision before JSON formatting' do
        result = formatter.format_array(values, format: 'json', precision: 1)
        parsed = JSON.parse(result)

        expect(parsed['values']).to eq([1.2, 2.6, 3.9])
      end
    end
  end

  describe '#apply_precision' do
    it 'rounds numeric values to specified precision' do
      expect(formatter.apply_precision(3.14159, 2)).to eq(3.14)
      expect(formatter.apply_precision(42.0, 0)).to eq(42)
      expect(formatter.apply_precision(1.999, 1)).to eq(2.0)
    end

    it 'returns original value when precision is nil' do
      expect(formatter.apply_precision(3.14159, nil)).to eq(3.14159)
      expect(formatter.apply_precision('text', nil)).to eq('text')
    end

    it 'returns original value for non-numeric input' do
      expect(formatter.apply_precision('text', 2)).to eq('text')
      expect(formatter.apply_precision(nil, 2)).to eq(nil)
      expect(formatter.apply_precision([], 2)).to eq([])
    end

    it 'handles zero precision' do
      expect(formatter.apply_precision(3.7, 0)).to eq(4)
      expect(formatter.apply_precision(3.2, 0)).to eq(3)
    end

    it 'handles negative precision gracefully' do
      # Ruby's round method supports negative precision
      expect(formatter.apply_precision(1234.56, -1)).to eq(1230.0)
      expect(formatter.apply_precision(1234.56, -2)).to eq(1200.0)
    end
  end

  describe '#format_json_value' do
    it 'creates JSON with value field' do
      result = formatter.format_json_value(42, {})
      parsed = JSON.parse(result)

      expect(parsed['value']).to eq(42)
    end

    it 'includes metadata from options' do
      result = formatter.format_json_value(42, { dataset_size: 100 })
      parsed = JSON.parse(result)

      expect(parsed['value']).to eq(42)
      expect(parsed['dataset_size']).to eq(100)
    end

    it 'handles complex values' do
      complex_value = { nested: 'data', numbers: [1, 2, 3] }
      result = formatter.format_json_value(complex_value, {})
      parsed = JSON.parse(result)

      expect(parsed['value']).to eq(complex_value.transform_keys(&:to_s))
    end
  end

  describe '#format_json_array' do
    it 'creates JSON with values field' do
      values = [1, 2, 3]
      result = formatter.format_json_array(values, {})
      parsed = JSON.parse(result)

      expect(parsed['values']).to eq(values)
    end

    it 'includes metadata from options' do
      values = [1, 2, 3]
      result = formatter.format_json_array(values, { dataset_size: 100 })
      parsed = JSON.parse(result)

      expect(parsed['values']).to eq(values)
      expect(parsed['dataset_size']).to eq(100)
    end

    it 'handles empty arrays' do
      result = formatter.format_json_array([], {})
      parsed = JSON.parse(result)

      expect(parsed['values']).to eq([])
    end
  end

  describe '#dataset_metadata' do
    it 'extracts dataset_size when present' do
      options = { dataset_size: 100, other_option: 'ignored' }
      metadata = formatter.dataset_metadata(options)

      expect(metadata).to eq({ dataset_size: 100 })
    end

    it 'returns empty hash when no metadata present' do
      options = { other_option: 'ignored' }
      metadata = formatter.dataset_metadata(options)

      expect(metadata).to eq({})
    end

    it 'handles empty options' do
      metadata = formatter.dataset_metadata({})

      expect(metadata).to eq({})
    end

    it 'ignores nil dataset_size' do
      options = { dataset_size: nil }
      metadata = formatter.dataset_metadata(options)

      expect(metadata).to eq({})
    end

    it 'includes dataset_size even when zero' do
      options = { dataset_size: 0 }
      metadata = formatter.dataset_metadata(options)

      expect(metadata).to eq({ dataset_size: 0 })
    end
  end
end
