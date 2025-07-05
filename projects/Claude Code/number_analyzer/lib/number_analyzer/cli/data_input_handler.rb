# frozen_string_literal: true

require_relative '../file_reader'

class NumberAnalyzer
  module Commands
    # Handles data input from command line arguments or files
    class DataInputHandler
      class << self
        def parse(args, options)
          if options[:file]
            parse_file(options[:file])
          elsif args.empty?
            raise ArgumentError, '数値またはファイルを指定してください'
          else
            parse_arguments(args)
          end
        end

        private

        def parse_arguments(args)
          args.map do |arg|
            Float(arg)
          rescue ArgumentError
            raise ArgumentError, "無効な数値: #{arg}"
          end
        end

        def parse_file(file_path)
          raise ArgumentError, "ファイルが見つかりません: #{file_path}" unless File.exist?(file_path)

          begin
            # Use existing FileReader for consistency
            FileReader.read_from_file(file_path)
          rescue StandardError => e
            raise ArgumentError, "無効なデータ: #{e.message}"
          end
        end
      end
    end
  end
end
