# frozen_string_literal: true

require 'csv'
require 'json'

# Handles reading numeric data from various file formats
# FileReader provides functionality to read numeric data from CSV, JSON, and TXT files.
# Supports automatic format detection and robust error handling for various data layouts.
class Numana::FileReader
  SUPPORTED_FORMATS = %w[.csv .json .txt].freeze

  def self.read_from_file(file_path)
    validate_file(file_path)

    case File.extname(file_path).downcase
    when '.csv'
      read_csv(file_path)
    when '.json'
      read_json(file_path)
    when '.txt'
      read_txt(file_path)
    else
      raise ArgumentError, "Unsupported file format. Supported formats: #{SUPPORTED_FORMATS.join(', ')}"
    end
  end

  private_class_method def self.validate_file(file_path)
    raise ArgumentError, 'File path cannot be empty' if file_path.nil? || file_path.empty?
    raise Errno::ENOENT, "File not found: #{file_path}" unless File.exist?(file_path)
    raise ArgumentError, "Cannot read file: #{file_path}" unless File.readable?(file_path)
  end

  private_class_method def self.read_csv(file_path)
    numbers = try_read_without_header(file_path)
    numbers = try_read_with_header(file_path) if numbers.empty?

    validate_numbers(numbers, file_path)
    numbers
  end

  private_class_method def self.try_read_without_header(file_path)
    numbers = []

    CSV.foreach(file_path) do |row|
      parsed_value = parse_csv_value(row[0])
      numbers << parsed_value if parsed_value
    end

    numbers
  end

  private_class_method def self.try_read_with_header(file_path)
    numbers = []

    begin
      CSV.foreach(file_path, headers: true) do |row|
        parsed_value = parse_csv_value(row[0])
        numbers << parsed_value if parsed_value
      end
    rescue StandardError
      # ヘッダー処理でもエラーの場合は空配列のまま
    end

    numbers
  end

  private_class_method def self.parse_csv_value(value)
    return nil if value.nil? || value.strip.empty?

    Float(value.strip, exception: false)
  end

  private_class_method def self.read_json(file_path)
    begin
      data = JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      raise ArgumentError, "Invalid JSON format: #{e.message}"
    end

    numbers = extract_numbers_from_json(data)
    validate_numbers(numbers, file_path)
    numbers
  end

  private_class_method def self.extract_numbers_from_json(data)
    case data
    when Array
      extract_from_json_array(data)
    when Hash
      extract_from_json_object(data)
    else
      raise ArgumentError, 'JSON must contain an array or object with numeric array'
    end
  rescue ArgumentError => e
    raise ArgumentError, "Invalid numeric data in JSON: #{e.message}"
  end

  private_class_method def self.extract_from_json_array(data)
    # 配列形式: [1, 2, 3, 4, 5]
    data.map { |item| Float(item) }
  end

  private_class_method def self.extract_from_json_object(data)
    # オブジェクト形式: {"numbers": [1, 2, 3, 4, 5]} または {"data": [1, 2, 3]}
    numbers_array = find_numeric_array_in_object(data)
    raise ArgumentError, 'No numeric array found in JSON object' unless numbers_array.is_a?(Array)

    numbers_array.map { |item| Float(item) }
  end

  private_class_method def self.find_numeric_array_in_object(data)
    data['numbers'] || data['data'] || data.values.first
  end

  private_class_method def self.read_txt(file_path)
    content = File.read(file_path).strip
    raise ArgumentError, 'Text file is empty' if content.empty?

    numbers = []

    # 各行を処理
    content.each_line do |line|
      line = line.strip
      next if line.empty?

      # スペースまたはカンマ区切りをサポート
      values = line.split(/[,\s]+/)
      values.each do |value|
        next if value.empty?

        begin
          numbers << Float(value)
        rescue ArgumentError
          # 数値でない値はスキップ
          next
        end
      end
    end

    validate_numbers(numbers, file_path)
    numbers
  end

  private_class_method def self.validate_numbers(numbers, file_path)
    return unless numbers.empty?

    raise ArgumentError, "No valid numeric data found in file: #{file_path}"
  end
end
