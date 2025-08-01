# frozen_string_literal: true

# Input processing module for NumberAnalyzer CLI
# Handles file and command-line input processing
module Numana::CLI::InputProcessor
  extend self

  # Process arguments, handling both file input and command-line arguments
  def process_arguments(argv = ARGV)
    options, remaining_args = Numana::CLI::Options.parse(argv)

    if options[:file]
      begin
        Numana::FileReader.read_from_file(options[:file])
      rescue StandardError => e
        puts "File read error: #{e.message}"
        exit 1
      end
    elsif remaining_args.empty?
      puts 'Error: Please specify numbers or --file option.'
      exit 1
    else
      # Get numbers from command line arguments
      parse_numeric_arguments(remaining_args)
    end
  end

  # Parse numbers from arguments and options, handling file input
  def parse_numbers_with_options(args, options)
    if options[:file]
      begin
        Numana::FileReader.read_from_file(options[:file])
      rescue StandardError => e
        puts "File read error: #{e.message}"
        exit 1
      end
    elsif args.empty?
      puts 'Error: Please specify numbers or --file option.'
      exit 1
    else
      parse_numeric_arguments(args)
    end
  end

  # Parse numeric arguments with comprehensive error handling
  def parse_numeric_arguments(argv)
    invalid_args = []
    numbers = argv.map do |arg|
      Float(arg)
    rescue ArgumentError
      invalid_args << arg
      nil
    end.compact

    unless invalid_args.empty?
      puts "Error: Invalid arguments found: #{invalid_args.join(', ')}"
      puts 'Please enter numeric values only.'
      exit 1
    end

    if numbers.empty?
      puts 'Error: No valid numbers found.'
      exit 1
    end

    numbers
  end

  # Validate that required arguments are present
  def validate_required_args(args, min_count = 1)
    return true if args.length >= min_count

    puts "Error: At least #{min_count} #{pluralize('argument', min_count)} required."
    exit 1
  end

  # Check if input appears to be a file path
  def looks_like_file_path?(input)
    return false if input.nil? || input.empty?

    # Check for common file extensions
    has_extension = input.match?(/\.[a-zA-Z]{1,4}$/)

    # Check if it's a path-like string
    has_path_separators = input.include?('/') || input.include?('\\')

    # Check if it exists as a file
    file_exists = File.exist?(input)

    has_extension || has_path_separators || file_exists
  end

  # Extract numeric data from mixed input
  def extract_numbers_from_mixed_input(inputs)
    all_numbers = []

    inputs.each do |input|
      if looks_like_file_path?(input)
        # Try to read as file
        begin
          file_numbers = Numana::FileReader.read_from_file(input)
          all_numbers.concat(file_numbers)
        rescue StandardError => e
          puts "Warning: Could not read file #{input}: #{e.message}"
        end
      else
        # Try to parse as number
        begin
          number = Float(input)
          all_numbers << number
        rescue ArgumentError
          puts "Warning: Could not parse '#{input}' as number"
        end
      end
    end

    if all_numbers.empty?
      puts 'Error: No valid numbers found in input.'
      exit 1
    end

    all_numbers
  end

  # Split arguments by separator (like '--' for grouped data)
  def split_arguments_by_separator(args, separator = '--')
    return [args] unless args.include?(separator)

    groups = []
    current_group = []

    args.each do |arg|
      if arg == separator
        groups << current_group unless current_group.empty?
        current_group = []
      else
        current_group << arg
      end
    end

    groups << current_group unless current_group.empty?
    groups
  end

  # Parse grouped numeric data (for ANOVA, etc.)
  def parse_grouped_numeric_data(args, separator = '--')
    groups = split_arguments_by_separator(args, separator)

    groups.map do |group|
      parse_numeric_arguments(group)
    end
  end

  private

  # Simple pluralization helper
  def pluralize(word, count)
    count == 1 ? word : "#{word}s"
  end
end
