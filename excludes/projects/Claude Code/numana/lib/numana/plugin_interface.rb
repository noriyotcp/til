# frozen_string_literal: true

# Plugin Interface definitions and base classes for NumberAnalyzer
class Numana
  # Base module that all statistics plugins must include
  module StatisticsPlugin
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods available to all statistics plugins
    module ClassMethods
      def plugin_name(name = nil)
        @plugin_name = name if name
        @plugin_name || self.name
      end

      def plugin_version(version = nil)
        @plugin_version = version if version
        @plugin_version || '1.0.0'
      end

      def plugin_description(description = nil)
        @plugin_description = description if description
        @plugin_description || ''
      end

      def plugin_author(author = nil)
        @plugin_author = author if author
        @plugin_author || 'Unknown'
      end

      def plugin_dependencies(deps = nil)
        @plugin_dependencies = deps if deps
        @plugin_dependencies || []
      end

      def register_method(method_name, description = '')
        plugin_methods[method_name] = description
      end

      def plugin_methods
        @plugin_methods ||= {}
      end
    end
  end

  # Base class for CLI command plugins
  class CLIPlugin
    class << self
      def plugin_name(name = nil)
        @plugin_name = name if name
        @plugin_name || self.name
      end

      def plugin_version(version = nil)
        @plugin_version = version if version
        @plugin_version || '1.0.0'
      end

      def plugin_description(description = nil)
        @plugin_description = description if description
        @plugin_description || ''
      end

      def plugin_author(author = nil)
        @plugin_author = author if author
        @plugin_author || 'Unknown'
      end

      def plugin_dependencies(deps = nil)
        @plugin_dependencies = deps if deps
        @plugin_dependencies || []
      end

      def plugin_commands(commands = nil)
        @plugin_commands = commands if commands
        @plugin_commands || {}
      end

      def register_command(command_name, method_name, description = '')
        # Ensure the commands hash is initialized
        @plugin_commands ||= {}
        @plugin_commands[command_name] = method_name
        command_descriptions[command_name] = description
      end

      def command_descriptions
        @command_descriptions ||= {}
      end
    end
  end

  # Base class for file format plugins
  class FileFormatPlugin
    class << self
      def plugin_name(name = nil)
        @plugin_name = name if name
        @plugin_name || self.name
      end

      def supported_extensions(extensions = nil)
        @supported_extensions = extensions if extensions
        @supported_extensions || []
      end

      def can_read?(file_path)
        extension = File.extname(file_path).downcase
        supported_extensions.include?(extension)
      end

      def read_file(file_path)
        raise NotImplementedError, 'Subclasses must implement read_file method'
      end
    end
  end

  # Base class for output format plugins
  class OutputFormatPlugin
    class << self
      def plugin_name(name = nil)
        @plugin_name = name if name
        @plugin_name || self.name
      end

      def format_name(name = nil)
        @format_name = name if name
        @format_name || plugin_name
      end

      def format_data(data, options = {})
        raise NotImplementedError, 'Subclasses must implement format_data method'
      end
    end
  end

  # Base class for data validator plugins
  class ValidatorPlugin
    class << self
      def plugin_name(name = nil)
        @plugin_name = name if name
        @plugin_name || self.name
      end

      def validation_name(name = nil)
        @validation_name = name if name
        @validation_name || plugin_name
      end

      def validate(data, options = {})
        raise NotImplementedError, 'Subclasses must implement validate method'
      end
    end
  end
end
