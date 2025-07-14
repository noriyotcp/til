# frozen_string_literal: true

require 'erb'
require 'fileutils'

# Plugin Template Generator for NumberAnalyzer
# Provides utilities for creating standardized plugins
# Generator for creating new plugins from templates
class NumberAnalyzer::PluginTemplate
  # Plugin generation errors
  class TemplateError < StandardError; end
  class InvalidTemplateError < TemplateError; end

  # Available plugin templates
  PLUGIN_TYPES = {
    statistics: {
      name: 'Statistics Plugin',
      description: 'Plugin for statistical analysis functions',
      extension_point: :statistics_module,
      template_file: 'statistics_plugin_template.rb.erb'
    },
    cli_command: {
      name: 'CLI Command Plugin',
      description: 'Plugin for adding new CLI commands',
      extension_point: :cli_command,
      template_file: 'cli_command_plugin_template.rb.erb'
    },
    file_format: {
      name: 'File Format Plugin',
      description: 'Plugin for supporting new file formats',
      extension_point: :file_format,
      template_file: 'file_format_plugin_template.rb.erb'
    },
    output_format: {
      name: 'Output Format Plugin',
      description: 'Plugin for new output formats',
      extension_point: :output_format,
      template_file: 'output_format_plugin_template.rb.erb'
    },
    validator: {
      name: 'Validator Plugin',
      description: 'Plugin for data validation',
      extension_point: :validator,
      template_file: 'validator_plugin_template.rb.erb'
    },
    integration: {
      name: 'Integration Plugin',
      description: 'Plugin for external system integration',
      extension_point: :statistics_module,
      template_file: 'integration_plugin_template.rb.erb'
    }
  }.freeze

  class << self
    # Generate a new plugin from template
    def generate(plugin_name, plugin_type, options = {})
      validate_plugin_name!(plugin_name)
      validate_plugin_type!(plugin_type)

      template_info = PLUGIN_TYPES[plugin_type.to_sym]
      plugin_config = build_plugin_config(plugin_name, template_info, options)

      # Generate plugin file
      plugin_content = render_template(template_info[:template_file], plugin_config)
      plugin_file_path = determine_output_path(plugin_name, options[:output_dir])

      write_plugin_file(plugin_file_path, plugin_content)

      # Generate test file
      if options[:generate_tests] != false
        test_content = render_test_template(plugin_config)
        test_file_path = determine_test_path(plugin_name, options[:output_dir])
        write_plugin_file(test_file_path, test_content)
      end

      # Generate documentation
      if options[:generate_docs]
        doc_content = render_documentation_template(plugin_config)
        doc_file_path = determine_doc_path(plugin_name, options[:output_dir])
        write_plugin_file(doc_file_path, doc_content)
      end

      {
        plugin_file: plugin_file_path,
        test_file: options[:generate_tests] == false ? nil : test_file_path,
        doc_file: options[:generate_docs] ? doc_file_path : nil,
        plugin_name: plugin_name,
        plugin_type: plugin_type
      }
    end

    # List available plugin types
    def available_types
      PLUGIN_TYPES.keys
    end

    # Get plugin type information
    def type_info(plugin_type)
      PLUGIN_TYPES[plugin_type.to_sym]
    end

    # Validate plugin configuration
    def validate_plugin_config(config)
      required_fields = %i[plugin_name class_name module_name author version]
      missing_fields = required_fields - config.keys

      raise InvalidTemplateError, "Missing required fields: #{missing_fields.join(', ')}" unless missing_fields.empty?

      # Validate plugin name format
      unless config[:plugin_name].match?(/^[a-z][a-z0-9_]*$/)
        raise InvalidTemplateError,
              'Plugin name must start with a letter and contain only lowercase letters, numbers, and underscores'
      end

      # Validate version format
      raise InvalidTemplateError, 'Version must follow semantic versioning (x.y.z)' unless config[:version].match?(/^\d+\.\d+\.\d+$/)

      true
    end

    private

    def validate_plugin_name!(name)
      raise TemplateError, 'Plugin name cannot be nil or empty' if name.nil? || name.to_s.strip.empty?

      return if name.to_s.match?(/^[a-z][a-z0-9_]*$/)

      raise TemplateError,
            'Plugin name must start with a letter and contain only lowercase letters, numbers, and underscores'
    end

    def validate_plugin_type!(type)
      return if PLUGIN_TYPES.key?(type.to_sym)

      raise TemplateError, "Invalid plugin type: #{type}. Available types: #{PLUGIN_TYPES.keys.join(', ')}"
    end

    def build_plugin_config(plugin_name, template_info, options)
      {
        plugin_name: plugin_name,
        class_name: camelize(plugin_name),
        module_name: "#{camelize(plugin_name)}Plugin",
        plugin_type: template_info[:name],
        description: options[:description] || template_info[:description],
        author: options[:author] || 'Plugin Author',
        version: options[:version] || '1.0.0',
        dependencies: options[:dependencies] || [],
        extension_point: template_info[:extension_point],
        commands: options[:commands] || [],
        timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        year: Time.now.year
      }
    end

    def camelize(string)
      string.to_s.split('_').map(&:capitalize).join
    end

    def determine_output_path(plugin_name, output_dir)
      base_dir = output_dir || 'plugins'
      FileUtils.mkdir_p(base_dir)
      File.join(base_dir, "#{plugin_name}_plugin.rb")
    end

    def determine_test_path(plugin_name, output_dir)
      base_dir = output_dir ? File.join(output_dir, '..', 'spec') : 'spec'
      FileUtils.mkdir_p(base_dir)
      File.join(base_dir, "#{plugin_name}_plugin_spec.rb")
    end

    def determine_doc_path(plugin_name, output_dir)
      base_dir = output_dir ? File.join(output_dir, '..', 'docs') : 'docs'
      FileUtils.mkdir_p(base_dir)
      File.join(base_dir, "#{plugin_name}_plugin.md")
    end

    def render_template(template_file, config)
      validate_plugin_config(config)
      template_content = get_template_content(template_file)

      erb = ERB.new(template_content, trim_mode: '-')
      erb.result(binding)
    end

    def render_test_template(config)
      template_content = get_test_template_content
      erb = ERB.new(template_content, trim_mode: '-')
      erb.result(binding)
    end

    def render_documentation_template(config)
      template_content = documentation_template_content
      erb = ERB.new(template_content, trim_mode: '-')
      erb.result(binding)
    end

    def write_plugin_file(file_path, content)
      File.write(file_path, content)
      puts "Generated: #{file_path}"
    end

    def get_template_content(template_file)
      case template_file
      when 'statistics_plugin_template.rb.erb'
        statistics_plugin_template
      when 'cli_command_plugin_template.rb.erb'
        cli_command_plugin_template
      when 'file_format_plugin_template.rb.erb'
        file_format_plugin_template
      when 'output_format_plugin_template.rb.erb'
        output_format_plugin_template
      when 'validator_plugin_template.rb.erb'
        validator_plugin_template
      when 'integration_plugin_template.rb.erb'
        integration_plugin_template
      else
        raise InvalidTemplateError, "Unknown template file: #{template_file}"
      end
    end

    def test_template_content
      plugin_test_template
    end

    def documentation_template_content
      plugin_documentation_template
    end

    # Template definitions
    def statistics_plugin_template
      <<~ERB
        # frozen_string_literal: true

        require_relative '../lib/number_analyzer/plugin_interface'

        # <%= config[:module_name] %> - <%= config[:description] %>
        # Generated on <%= config[:timestamp] %>
        # Author: <%= config[:author] %>
        module <%= config[:module_name] %>
          include NumberAnalyzer::StatisticsPlugin
        #{'  '}
          # Plugin metadata
          plugin_name '<%= config[:plugin_name] %>'
          plugin_version '<%= config[:version] %>'
          plugin_description '<%= config[:description] %>'
          plugin_author '<%= config[:author] %>'
          plugin_dependencies <%= config[:dependencies].inspect %>
        #{'  '}
        <% config[:commands].each do |command| -%>
          # Register plugin method: <%= command %>
          register_method :<%= command %>, 'Description for <%= command %>'
        <% end -%>
        #{'  '}
          # Define CLI commands mapping
          def self.plugin_commands
            {
        <% config[:commands].each do |command| -%>
              '<%= command.tr('_', '-') %>' => :<%= command %>,
        <% end -%>
            }
          end
        #{'  '}
        <% config[:commands].each do |command| -%>
          # <%= command.capitalize.tr('_', ' ') %> implementation
          def <%= command %>
            # Example implementation for <%= command %>
            # Replace this with your statistical calculation
            validate_numbers!
        #{'    '}
            # Example: Calculate <%= command %> statistic
            result_value = @numbers.sum.to_f / @numbers.length # Replace with actual <%= command %> logic
        #{'    '}
            {
              result: result_value,
              data: @numbers,
              interpretation: "<%= command.capitalize.tr('_', ' ') %> analysis completed. Implement your statistical calculation here."
            }
          end
        <% end -%>
        #{'  '}
          private
        #{'  '}
          # Helper methods
          def validate_numbers!
            raise ArgumentError, 'Numbers array cannot be empty' if @numbers.empty?
          end
        end
      ERB
    end

    def cli_command_plugin_template
      <<~ERB
        # frozen_string_literal: true

        require_relative '../lib/number_analyzer/plugin_interface'

        # <%= config[:module_name] %> - <%= config[:description] %>
        # Generated on <%= config[:timestamp] %>
        # Author: <%= config[:author] %>
        class <%= config[:module_name] %> < NumberAnalyzer::CLIPlugin
        #{'  '}
          # Plugin metadata
          plugin_name '<%= config[:plugin_name] %>'
          plugin_version '<%= config[:version] %>'
          plugin_description '<%= config[:description] %>'
          plugin_author '<%= config[:author] %>'
          plugin_dependencies <%= config[:dependencies].inspect %>
        #{'  '}
        <% config[:commands].each do |command| -%>
          # Register CLI command: <%= command %>
          register_command '<%= command.tr('_', '-') %>', :<%= command %>, 'Description for <%= command %> command'
        <% end -%>
        #{'  '}
        <% config[:commands].each do |command| -%>
          # <%= command.capitalize.tr('_', ' ') %> command implementation
          def self.<%= command %>(args)
            # Example CLI command implementation for <%= command %>
            # Replace this with your command logic
            puts "Executing <%= command %> command..."
        #{'    '}
            # Validate arguments
            return { error: 'No arguments provided' } if args.empty?
        #{'    '}
            # Parse command line arguments
            options = parse_<%= command %>_options(args)
        #{'    '}
            # Execute command logic
            execute_<%= command %>(options)
          end
        #{'  '}
          def self.parse_<%= command %>_options(args)
            # Example argument parsing for <%= command %>
            # Add your specific option parsing here
            options = {#{' '}
              data: [],
              format: 'text',
              precision: 2
            }
        #{'    '}
            # Parse arguments (example implementation)
            args.each_with_index do |arg, index|
              case arg
              when '--format'
                options[:format] = args[index + 1] if args[index + 1]
              when '--precision'
                options[:precision] = args[index + 1].to_i if args[index + 1]
              else
                options[:data] << arg.to_f if arg.match?(/^-?\d+(.\d+)?$/)
              end
            end
        #{'    '}
            options
          end
        #{'  '}
          def self.execute_<%= command %>(options)
            # Example execution logic for <%= command %>
            # Implement your command's core functionality here
        #{'    '}
            if options[:data].empty?
              puts "Error: No numerical data provided for <%= command %>"
              return { error: 'No data provided' }
            end
        #{'    '}
            # Example calculation (replace with actual <%= command %> logic)
            result = options[:data].sum.to_f / options[:data].length
        #{'    '}
            # Format and display result
            formatted_result = "%.#{options[:precision]}f" % result
            puts "<%= command.capitalize.tr('_', ' ') %> result: #{formatted_result}"
        #{'    '}
            { success: true, result: result, formatted: formatted_result }
          end
        <% end -%>
        end
      ERB
    end

    def file_format_plugin_template
      <<~ERB
        # frozen_string_literal: true

        require_relative '../lib/number_analyzer/plugin_interface'

        # <%= config[:module_name] %> - <%= config[:description] %>
        # Generated on <%= config[:timestamp] %>
        # Author: <%= config[:author] %>
        class <%= config[:module_name] %> < NumberAnalyzer::FileFormatPlugin
        #{'  '}
          # Plugin metadata
          plugin_name '<%= config[:plugin_name] %>'
          plugin_version '<%= config[:version] %>'
          plugin_description '<%= config[:description] %>'
          plugin_author '<%= config[:author] %>'
        #{'  '}
          # Supported file extensions
          supported_extensions ['.csv', '.tsv', '.txt']  # Define supported file extensions
        #{'  '}
          # Read file and return data
          def self.read_file(file_path)
            # Example file reading implementation
            # Customize this based on your file format
        #{'    '}
            unless File.exist?(file_path)
              raise ArgumentError, "File not found: #{file_path}"
            end
        #{'    '}
            content = File.read(file_path)
            parse_content(content)
          rescue => e
            raise "Failed to read file #{file_path}: #{e.message}"
          end
        #{'  '}
          private
        #{'  '}
          def self.parse_content(content)
            # Example content parsing (customize for your format)
            # This example handles CSV-like data with numbers
        #{'    '}
            lines = content.strip.split("\n")
            data = []
        #{'    '}
            lines.each_with_index do |line, index|
              # Skip empty lines and comments
              next if line.strip.empty? || line.strip.start_with?('#')
        #{'      '}
              # Parse numerical data (example: comma or tab separated)
              numbers = line.split(/[,\t]/).map(&:strip)
                           .select { |val| val.match?(/^-?\d+(.\d+)?$/) }
                           .map(&:to_f)
        #{'      '}
              data.concat(numbers) unless numbers.empty?
            end
        #{'    '}
            data
          end
        end
      ERB
    end

    def output_format_plugin_template
      <<~ERB
        # frozen_string_literal: true

        require_relative '../lib/number_analyzer/plugin_interface'

        # <%= config[:module_name] %> - <%= config[:description] %>
        # Generated on <%= config[:timestamp] %>
        # Author: <%= config[:author] %>
        class <%= config[:module_name] %> < NumberAnalyzer::OutputFormatPlugin
        #{'  '}
          # Plugin metadata
          plugin_name '<%= config[:plugin_name] %>'
          plugin_version '<%= config[:version] %>'
          plugin_description '<%= config[:description] %>'
          plugin_author '<%= config[:author] %>'
        #{'  '}
          # Format name
          format_name '<%= config[:plugin_name] %>'
        #{'  '}
          # Format data for output
          def self.format_data(data, options = {})
            # Example data formatting implementation
            # Customize this for your specific output format
        #{'    '}
            case data
            when Hash
              format_hash(data, options)
            when Array
              format_array(data, options)
            when Numeric
              precision = options[:precision] || 2
              "%.#{precision}f" % data
            else
              data.to_s
            end
          end
        #{'  '}
          private
        #{'  '}
          def self.format_hash(hash, options)
            # Example hash formatting (customize for your format)
            indent = options[:indent] || 0
            spacing = ' ' * indent
        #{'    '}
            formatted = hash.map do |key, value|
              formatted_value = value.is_a?(Numeric) ? ("%.#{options[:precision] || 2}f" % value) : value
              "#{spacing}#{key}: #{formatted_value}"
            end
        #{'    '}
            formatted.join("\n")
          end
        #{'  '}
          def self.format_array(array, options)
            # Example array formatting (customize for your format)
            separator = options[:separator] || ', '
            precision = options[:precision] || 2
        #{'    '}
            formatted_items = array.map do |item|
              item.is_a?(Numeric) ? ("%.#{precision}f" % item) : item.to_s
            end
        #{'    '}
            formatted_items.join(separator)
          end
        end
      ERB
    end

    def validator_plugin_template
      <<~ERB
        # frozen_string_literal: true

        require_relative '../lib/number_analyzer/plugin_interface'

        # <%= config[:module_name] %> - <%= config[:description] %>
        # Generated on <%= config[:timestamp] %>
        # Author: <%= config[:author] %>
        class <%= config[:module_name] %> < NumberAnalyzer::ValidatorPlugin
        #{'  '}
          # Plugin metadata
          plugin_name '<%= config[:plugin_name] %>'
          plugin_version '<%= config[:version] %>'
          plugin_description '<%= config[:description] %>'
          plugin_author '<%= config[:author] %>'
        #{'  '}
          # Validation name
          validation_name '<%= config[:plugin_name] %>'
        #{'  '}
          # Validate data
          def self.validate(data, options = {})
            # Example data validation implementation
            # Add your specific validation rules here
            errors = []
        #{'    '}
            # Basic validations
            errors << 'Data cannot be nil' if data.nil?
            errors << 'Data cannot be empty' if data.respond_to?(:empty?) && data.empty?
        #{'    '}
            # Type-specific validations
            if data.is_a?(Array)
              errors << 'Array contains non-numeric values' unless data.all? { |x| x.is_a?(Numeric) }
              errors << 'Array contains infinite values' if data.any? { |x| x.is_a?(Float) && x.infinite? }
              errors << 'Array contains NaN values' if data.any? { |x| x.is_a?(Float) && x.nan? }
            end
        #{'    '}
            # Custom validation based on options
            if options[:min_size] && data.respond_to?(:size)
              errors << "Data size #{data.size} is below minimum #{options[:min_size]}" if data.size < options[:min_size]
            end
        #{'    '}
            {
              valid: errors.empty?,
              errors: errors,
              data: data
            }
          end
        #{'  '}
          private
        #{'  '}
          def self.validate_numeric(data)
            # Example numeric validation with comprehensive checks
            return false unless data.respond_to?(:all?)
        #{'    '}
            data.all? do |value|
              value.is_a?(Numeric) &&#{' '}
              !value.is_a?(Float) || (!value.infinite? && !value.nan?)
            end
          end
        end
      ERB
    end

    def integration_plugin_template
      <<~ERB
        # frozen_string_literal: true

        require_relative '../lib/number_analyzer/plugin_interface'

        # <%= config[:module_name] %> - <%= config[:description] %>
        # Generated on <%= config[:timestamp] %>
        # Author: <%= config[:author] %>
        module <%= config[:module_name] %>
          include NumberAnalyzer::StatisticsPlugin
        #{'  '}
          # Plugin metadata
          plugin_name '<%= config[:plugin_name] %>'
          plugin_version '<%= config[:version] %>'
          plugin_description '<%= config[:description] %>'
          plugin_author '<%= config[:author] %>'
          plugin_dependencies <%= config[:dependencies].inspect %>
        #{'  '}
          # Define CLI commands mapping
          def self.plugin_commands
            {
              '<%= config[:plugin_name].tr('_', '-') %>' => :run_<%= config[:plugin_name] %>
            }
          end
        #{'  '}
          # Main integration method
          def run_<%= config[:plugin_name] %>
            # Example integration implementation
            # Replace with your specific integration logic
        #{'    '}
            begin
              # Step 1: Connect to external system
              connection = connect_to_external_system
        #{'      '}
              # Step 2: Process data
              processed_data = process_external_data(@numbers)
        #{'      '}
              # Step 3: Return results
              {
                result: "Integration completed successfully",
                data: processed_data,
                interpretation: "Successfully integrated #{@numbers.length} data points with external system",
                connection_status: connection ? 'connected' : 'disconnected'
              }
            rescue => e
              {
                result: "Integration failed",
                data: @numbers,
                interpretation: "Integration failed: #{e.message}",
                error: e.message
              }
            end
          end
        #{'  '}
          private
        #{'  '}
          # Helper methods for integration
          def connect_to_external_system
            # Example connection logic for external system
            # Replace with your specific connection implementation
        #{'    '}
            begin
              # Example: Connect to database, API, or external service
              # connection = SomeExternalAPI.connect(
              #   host: 'api.example.com',
              #   token: ENV['API_TOKEN']
              # )
        #{'      '}
              # For demonstration, return a mock connection
              puts "Connecting to external system..."
              sleep(0.1) # Simulate connection time
        #{'      '}
              # Return connection object or true/false
              true
            rescue => e
              puts "Connection failed: #{e.message}"
              false
            end
          end
        #{'  '}
          def process_external_data(data)
            # Example data processing logic
            # Customize this based on your integration requirements
        #{'    '}
            return [] if data.nil? || data.empty?
        #{'    '}
            # Example: Transform data for external system
            processed = data.map do |value|
              {
                original_value: value,
                processed_value: value * 1.0, # Example transformation
                timestamp: Time.now.iso8601,
                status: 'processed'
              }
            end
        #{'    '}
            # Example: Log processing
            puts "Processed #{processed.length} data points"
        #{'    '}
            processed
          end
        end
      ERB
    end

    def plugin_test_template
      <<~ERB
        # frozen_string_literal: true

        require 'spec_helper'
        require_relative '../plugins/<%= config[:plugin_name] %>_plugin'

        RSpec.describe <%= config[:module_name] %> do
          describe 'plugin metadata' do
            it 'has correct plugin name' do
              expect(<%= config[:module_name] %>.plugin_name).to eq('<%= config[:plugin_name] %>')
            end
        #{'    '}
            it 'has correct version' do
              expect(<%= config[:module_name] %>.plugin_version).to eq('<%= config[:version] %>')
            end
        #{'    '}
            it 'has description' do
              expect(<%= config[:module_name] %>.plugin_description).not_to be_empty
            end
        #{'    '}
            it 'has author' do
              expect(<%= config[:module_name] %>.plugin_author).to eq('<%= config[:author] %>')
            end
          end
        #{'  '}
        <% if config[:extension_point] == :statistics_module -%>
          describe 'statistical functions' do
            let(:analyzer) { NumberAnalyzer.new([1, 2, 3, 4, 5]) }
        #{'    '}
            before do
              analyzer.extend(<%= config[:module_name] %>)
            end
        #{'    '}
          <% config[:commands].each do |command| -%>
            describe '#<%= command %>' do
              it 'returns a result' do
                result = analyzer.<%= command %>
                expect(result).not_to be_nil
              end
        #{'      '}
              it 'includes interpretation' do
                result = analyzer.<%= command %>
                expect(result).to have_key(:interpretation)
              end
            end
          <% end -%>
          end
        <% elsif config[:extension_point] == :cli_command -%>
          describe 'CLI commands' do
          <% config[:commands].each do |command| -%>
            describe '.<%= command %>' do
              it 'executes without error' do
                expect { <%= config[:module_name] %>.<%= command %>([]) }.not_to raise_error
              end
            end
          <% end -%>
          end
        <% end -%>
        end
      ERB
    end

    def plugin_documentation_template
      <<~ERB
        # <%= config[:module_name] %>

        <%= config[:description] %>

        ## Overview

        This plugin was generated on <%= config[:timestamp] %> by <%= config[:author] %>.

        **Plugin Type**: <%= config[:plugin_type] %>#{'  '}
        **Version**: <%= config[:version] %>#{'  '}
        **Extension Point**: <%= config[:extension_point] %>

        ## Installation

        1. Copy the plugin file to your `plugins/` directory
        2. Enable the plugin in your `plugins.yml` configuration file
        3. Restart NumberAnalyzer or reload plugins

        ## Configuration

        Add the following to your `plugins.yml` file:

        ```yaml
        plugins:
          enabled:
            - '<%= config[:plugin_name] %>'
        ```

        ## Usage

        <% if config[:extension_point] == :statistics_module -%>
        ### Statistical Functions

        <% config[:commands].each do |command| -%>
        #### <%= command.capitalize.tr('_', ' ') %>

        ```ruby
        analyzer = NumberAnalyzer.new([1, 2, 3, 4, 5])
        result = analyzer.<%= command %>
        puts result[:interpretation]
        ```

        **CLI Usage:**
        ```bash
        bundle exec number_analyzer <%= command.tr('_', '-') %> 1 2 3 4 5
        ```

        <% end -%>
        <% elsif config[:extension_point] == :cli_command -%>
        ### CLI Commands

        <% config[:commands].each do |command| -%>
        #### <%= command.tr('_', '-') %>

        ```bash
        bundle exec number_analyzer <%= command.tr('_', '-') %> [options]
        ```

        <% end -%>
        <% end -%>

        ## Dependencies

        <% if config[:dependencies].any? -%>
        This plugin depends on the following plugins:
        <% config[:dependencies].each do |dep| -%>
        - <%= dep %>
        <% end -%>
        <% else -%>
        This plugin has no dependencies.
        <% end -%>

        ## Development

        To modify this plugin:

        1. Edit the plugin file: `plugins/<%= config[:plugin_name] %>_plugin.rb`
        2. Run tests: `rspec spec/<%= config[:plugin_name] %>_plugin_spec.rb`
        3. Update this documentation as needed

        ## License

        Copyright © <%= config[:year] %> <%= config[:author] %>. All rights reserved.
      ERB
    end
  end
end
