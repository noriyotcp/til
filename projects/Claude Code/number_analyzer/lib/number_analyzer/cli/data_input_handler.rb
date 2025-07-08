# frozen_string_literal: true

require_relative '../file_reader'

# Handles data input from command line arguments or files
class NumberAnalyzer::Commands::DataInputHandler
  class << self
    def parse(args, options)
      if options[:file]
        parse_file(options[:file])
      elsif args.empty?
        raise ArgumentError, 'Please specify numbers or a file'
      else
        parse_arguments(args)
      end
    end

    private

    def parse_arguments(args)
      args.map do |arg|
        Float(arg)
      rescue ArgumentError
        raise ArgumentError, "Invalid number: #{arg}"
      end
    end

    def parse_file(file_path)
      raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)

      begin
        # Use existing FileReader for consistency
        NumberAnalyzer::FileReader.read_from_file(file_path)
      rescue StandardError => e
        raise ArgumentError, "Invalid data: #{e.message}"
      end
    end
  end
end
