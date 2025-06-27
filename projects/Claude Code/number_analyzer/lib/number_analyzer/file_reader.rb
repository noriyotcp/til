# frozen_string_literal: true

require 'csv'
require 'json'

# Handles reading numeric data from various file formats
class NumberAnalyzer
  class FileReader
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
      numbers = []
      
      # まずはヘッダーなしで全ての行を数値として読み込みを試行
      CSV.foreach(file_path) do |row|
        value = row[0]
        next if value.nil? || value.strip.empty?
        
        begin
          numbers << Float(value.strip)
        rescue ArgumentError
          # 数値でない行はスキップ
          next
        end
      end

      # 数値が見つからなかった場合、ヘッダーありで試行
      if numbers.empty?
        begin
          CSV.foreach(file_path, headers: true) do |row|
            value = row[0]
            next if value.nil? || value.strip.empty?
            
            begin
              numbers << Float(value.strip)
            rescue ArgumentError
              next
            end
          end
        rescue
          # ヘッダー処理でもエラーの場合は空配列のまま
        end
      end

      validate_numbers(numbers, file_path)
      numbers
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
        # 配列形式: [1, 2, 3, 4, 5]
        data.map { |item| Float(item) }
      when Hash
        # オブジェクト形式: {"numbers": [1, 2, 3, 4, 5]} または {"data": [1, 2, 3]}
        numbers_array = data['numbers'] || data['data'] || data.values.first
        raise ArgumentError, 'No numeric array found in JSON object' unless numbers_array.is_a?(Array)
        
        numbers_array.map { |item| Float(item) }
      else
        raise ArgumentError, 'JSON must contain an array or object with numeric array'
      end
    rescue ArgumentError => e
      raise ArgumentError, "Invalid numeric data in JSON: #{e.message}"
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
      if numbers.empty?
        raise ArgumentError, "No valid numeric data found in file: #{file_path}"
      end
    end
  end
end