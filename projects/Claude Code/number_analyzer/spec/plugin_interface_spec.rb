# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe NumberAnalyzer::StatisticsPlugin do
  let(:test_plugin_class) do
    Class.new do
      include NumberAnalyzer::StatisticsPlugin

      plugin_name 'test_statistics'
      plugin_version '2.0.0'
      plugin_description 'Test statistics plugin for RSpec'
      plugin_author 'Test Developer'
      plugin_dependencies ['basic_math']

      register_method :double_sum, 'Calculates sum multiplied by 2'
      register_method :triple_mean, 'Calculates mean multiplied by 3'

      def double_sum(numbers)
        numbers.sum * 2
      end

      def triple_mean(numbers)
        (numbers.sum.to_f / numbers.length) * 3
      end
    end
  end

  describe 'plugin metadata' do
    it 'stores and retrieves plugin name' do
      expect(test_plugin_class.plugin_name).to eq('test_statistics')
    end

    it 'stores and retrieves plugin version' do
      expect(test_plugin_class.plugin_version).to eq('2.0.0')
    end

    it 'stores and retrieves plugin description' do
      expect(test_plugin_class.plugin_description).to eq('Test statistics plugin for RSpec')
    end

    it 'stores and retrieves plugin author' do
      expect(test_plugin_class.plugin_author).to eq('Test Developer')
    end

    it 'stores and retrieves plugin dependencies' do
      expect(test_plugin_class.plugin_dependencies).to eq(['basic_math'])
    end
  end

  describe 'method registration' do
    it 'registers plugin methods with descriptions' do
      methods = test_plugin_class.plugin_methods

      expect(methods).to have_key(:double_sum)
      expect(methods[:double_sum]).to eq('Calculates sum multiplied by 2')
      expect(methods).to have_key(:triple_mean)
      expect(methods[:triple_mean]).to eq('Calculates mean multiplied by 3')
    end
  end

  describe 'default values' do
    let(:minimal_plugin) do
      Class.new do
        include NumberAnalyzer::StatisticsPlugin
      end
    end

    it 'provides default plugin name' do
      expect(minimal_plugin.plugin_name).to eq(minimal_plugin.name)
    end

    it 'provides default version' do
      expect(minimal_plugin.plugin_version).to eq('1.0.0')
    end

    it 'provides default description' do
      expect(minimal_plugin.plugin_description).to eq('')
    end

    it 'provides default author' do
      expect(minimal_plugin.plugin_author).to eq('Unknown')
    end

    it 'provides default dependencies' do
      expect(minimal_plugin.plugin_dependencies).to eq([])
    end
  end
end

RSpec.describe NumberAnalyzer::CLIPlugin do
  let(:test_cli_plugin) do
    Class.new(NumberAnalyzer::CLIPlugin) do
      plugin_name 'test_cli_commands'
      plugin_version '1.5.0'
      plugin_description 'Test CLI plugin'
      plugin_author 'CLI Developer'

      register_command 'test-add', :add_numbers, 'Adds two numbers'
      register_command 'test-multiply', :multiply_numbers, 'Multiplies two numbers'

      def self.add_numbers(args, options)
        numbers = args.map(&:to_f)
        result = numbers.sum
        options[:format] == 'json' ? { result: result }.to_json : "Result: #{result}"
      end

      def self.multiply_numbers(args, options)
        numbers = args.map(&:to_f)
        result = numbers.reduce(:*)
        options[:format] == 'json' ? { result: result }.to_json : "Result: #{result}"
      end
    end
  end

  describe 'CLI plugin metadata' do
    it 'stores plugin information' do
      expect(test_cli_plugin.plugin_name).to eq('test_cli_commands')
      expect(test_cli_plugin.plugin_version).to eq('1.5.0')
      expect(test_cli_plugin.plugin_description).to eq('Test CLI plugin')
      expect(test_cli_plugin.plugin_author).to eq('CLI Developer')
    end
  end

  describe 'command registration' do
    it 'registers CLI commands' do
      commands = test_cli_plugin.plugin_commands

      expect(commands).to have_key('test-add')
      expect(commands['test-add']).to eq(:add_numbers)
      expect(commands).to have_key('test-multiply')
      expect(commands['test-multiply']).to eq(:multiply_numbers)
    end

    it 'stores command descriptions' do
      descriptions = test_cli_plugin.command_descriptions

      expect(descriptions['test-add']).to eq('Adds two numbers')
      expect(descriptions['test-multiply']).to eq('Multiplies two numbers')
    end
  end

  describe 'command execution' do
    it 'executes add command' do
      result = test_cli_plugin.add_numbers(%w[5 3], {})
      expect(result).to eq('Result: 8.0')
    end

    it 'executes multiply command with JSON format' do
      result = test_cli_plugin.multiply_numbers(%w[4 2], { format: 'json' })
      expect(result).to eq('{"result":8.0}')
    end
  end
end

RSpec.describe NumberAnalyzer::FileFormatPlugin do
  let(:test_file_format_plugin) do
    Class.new(NumberAnalyzer::FileFormatPlugin) do
      plugin_name 'test_format'
      supported_extensions ['.test', '.demo']

      def self.read_file(file_path)
        content = File.read(file_path)
        content.split(',').map(&:strip).map(&:to_f)
      end
    end
  end

  describe 'file format support' do
    it 'declares supported extensions' do
      expect(test_file_format_plugin.supported_extensions).to eq(['.test', '.demo'])
    end

    it 'checks if file can be read' do
      expect(test_file_format_plugin.can_read?('data.test')).to be true
      expect(test_file_format_plugin.can_read?('data.demo')).to be true
      expect(test_file_format_plugin.can_read?('data.csv')).to be false
    end
  end

  describe 'file reading' do
    let(:temp_file) { Tempfile.new(['test_data', '.test']) }

    before do
      temp_file.write('1.5, 2.3, 3.7, 4.1')
      temp_file.rewind
    end

    after do
      temp_file.close
      temp_file.unlink
    end

    it 'reads and parses file content' do
      result = test_file_format_plugin.read_file(temp_file.path)
      expect(result).to eq([1.5, 2.3, 3.7, 4.1])
    end
  end
end

RSpec.describe NumberAnalyzer::OutputFormatPlugin do
  let(:test_output_plugin) do
    Class.new(NumberAnalyzer::OutputFormatPlugin) do
      plugin_name 'test_output'
      format_name 'test_format'

      def self.format_data(data, options = {})
        prefix = options[:prefix] || 'Data:'
        "#{prefix} #{data.inspect}"
      end
    end
  end

  describe 'output formatting' do
    it 'formats data with default options' do
      result = test_output_plugin.format_data([1, 2, 3])
      expect(result).to eq('Data: [1, 2, 3]')
    end

    it 'formats data with custom options' do
      result = test_output_plugin.format_data([1, 2, 3], { prefix: 'Numbers:' })
      expect(result).to eq('Numbers: [1, 2, 3]')
    end
  end
end

RSpec.describe NumberAnalyzer::ValidatorPlugin do
  let(:test_validator_plugin) do
    Class.new(NumberAnalyzer::ValidatorPlugin) do
      plugin_name 'test_validator'
      validation_name 'positive_numbers'

      def self.validate(data, options = {})
        min_value = options[:min] || 0

        if data.is_a?(Array) && data.all? { |n| n.is_a?(Numeric) && n > min_value }
          { valid: true, message: 'All numbers are positive' }
        else
          { valid: false, message: 'Data contains non-positive numbers' }
        end
      end
    end
  end

  describe 'data validation' do
    it 'validates positive numbers' do
      result = test_validator_plugin.validate([1, 2, 3, 4])
      expect(result[:valid]).to be true
      expect(result[:message]).to eq('All numbers are positive')
    end

    it 'rejects data with negative numbers' do
      result = test_validator_plugin.validate([1, -2, 3])
      expect(result[:valid]).to be false
      expect(result[:message]).to eq('Data contains non-positive numbers')
    end

    it 'validates with custom minimum' do
      result = test_validator_plugin.validate([5, 10, 15], { min: 3 })
      expect(result[:valid]).to be true
    end
  end
end
