# frozen_string_literal: true

# Plugin without proper interface - FOR TESTING ONLY
module NoInterfacePlugin
  # This plugin doesn't include any NumberAnalyzer plugin interface
  # Should trigger a warning about missing interface

  def some_method
    puts 'This plugin has no proper interface'
  end

  def self.plugin_name
    'no_interface'
  end

  def self.plugin_version
    '1.0.0'
  end
end
