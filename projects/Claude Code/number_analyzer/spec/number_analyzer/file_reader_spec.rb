# frozen_string_literal: true

require_relative '../../lib/number_analyzer/file_reader'
require 'tempfile'

RSpec.describe NumberAnalyzer::FileReader do
  describe '.read_from_file' do
    context 'with CSV files' do
      let(:csv_content_with_header) do
        "numbers\n1\n2\n3\n4\n5"
      end

      let(:csv_content_without_header) do
        "10\n20\n30\n40\n50"
      end

      it 'reads CSV file with header correctly' do
        Tempfile.create(['test', '.csv']) do |file|
          file.write(csv_content_with_header)
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0])
        end
      end

      it 'reads CSV file without header correctly' do
        Tempfile.create(['test', '.csv']) do |file|
          file.write(csv_content_without_header)
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([10.0, 20.0, 30.0, 40.0, 50.0])
        end
      end

      it 'skips empty lines in CSV' do
        Tempfile.create(['test', '.csv']) do |file|
          file.write("numbers\n1\n\n2\n \n3")
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0])
        end
      end

      it 'skips non-numeric lines in CSV' do
        Tempfile.create(['test', '.csv']) do |file|
          file.write("numbers\n1\nabc\n2\nxyz\n3")
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0])
        end
      end
    end

    context 'with JSON files' do
      it 'reads JSON array format correctly' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('[1, 2, 3, 4, 5]')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0])
        end
      end

      it 'reads JSON object with "numbers" key correctly' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('{"numbers": [10, 20, 30, 40, 50]}')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([10.0, 20.0, 30.0, 40.0, 50.0])
        end
      end

      it 'reads JSON object with "data" key correctly' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('{"data": [100, 200, 300]}')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([100.0, 200.0, 300.0])
        end
      end

      it 'reads JSON object with first value as array' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('{"values": [7, 8, 9]}')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([7.0, 8.0, 9.0])
        end
      end

      it 'raises error for invalid JSON' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('{invalid json}')
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, /Invalid JSON format/)
        end
      end

      it 'raises error for JSON without numeric array' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('{"text": "not an array"}')
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, /No numeric array found in JSON object/)
        end
      end

      it 'raises error for JSON with non-numeric data' do
        Tempfile.create(['test', '.json']) do |file|
          file.write('[1, "not a number", 3]')
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, /Invalid numeric data in JSON/)
        end
      end
    end

    context 'with TXT files' do
      it 'reads space-separated numbers correctly' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write('1 2 3 4 5')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0])
        end
      end

      it 'reads comma-separated numbers correctly' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write('10,20,30,40,50')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([10.0, 20.0, 30.0, 40.0, 50.0])
        end
      end

      it 'reads multi-line format correctly' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write("1 2 3\n4 5 6\n7,8,9")
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0])
        end
      end

      it 'skips empty lines' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write("1 2 3\n\n4 5 6\n \n")
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
        end
      end

      it 'skips non-numeric values' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write('1 abc 2 xyz 3')
          file.rewind

          result = NumberAnalyzer::FileReader.read_from_file(file.path)
          expect(result).to eq([1.0, 2.0, 3.0])
        end
      end

      it 'raises error for empty file' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write('')
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, 'Text file is empty')
        end
      end
    end

    context 'with file validation' do
      it 'raises error for empty file path' do
        expect do
          NumberAnalyzer::FileReader.read_from_file('')
        end.to raise_error(ArgumentError, 'File path cannot be empty')
      end

      it 'raises error for nil file path' do
        expect do
          NumberAnalyzer::FileReader.read_from_file(nil)
        end.to raise_error(ArgumentError, 'File path cannot be empty')
      end

      it 'raises error for non-existent file' do
        expect do
          NumberAnalyzer::FileReader.read_from_file('/path/to/nonexistent/file.csv')
        end.to raise_error(Errno::ENOENT, /File not found/)
      end

      it 'raises error for unsupported file format' do
        Tempfile.create(['test', '.xml']) do |file|
          file.write('<data>1,2,3</data>')
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, /Unsupported file format/)
        end
      end
    end

    context 'with no valid numeric data' do
      it 'raises error when CSV contains no valid numbers' do
        Tempfile.create(['test', '.csv']) do |file|
          file.write("text\nabc\ndef\nghi")
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, /No valid numeric data found/)
        end
      end

      it 'raises error when TXT contains no valid numbers' do
        Tempfile.create(['test', '.txt']) do |file|
          file.write('abc def ghi')
          file.rewind

          expect do
            NumberAnalyzer::FileReader.read_from_file(file.path)
          end.to raise_error(ArgumentError, /No valid numeric data found/)
        end
      end
    end
  end
end
