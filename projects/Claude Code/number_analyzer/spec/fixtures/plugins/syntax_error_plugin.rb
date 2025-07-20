# frozen_string_literal: true
# rubocop:disable all

# Plugin with syntax error - FOR TESTING ONLY
module SyntaxErrorPlugin
  include NumberAnalyzer::StatisticsPlugin

  plugin_name 'syntax_error'
  plugin_version '1.0.0'

  def broken_method
    # This has a syntax error
    puts "unclosed string
  end
end