# frozen_string_literal: true

# Plugin with suspicious methods - FOR TESTING ONLY
module SuspiciousMethodsPlugin
  include Numana::StatisticsPlugin

  plugin_name 'suspicious_methods'
  plugin_version '1.0.0'
  plugin_description 'Suspicious methods plugin'
  plugin_author 'Tricky Developer'

  def use_suspicious_methods
    # These should trigger suspicious method warnings
    object.send(:private_method)
    object.public_send(:method_name) # rubocop:disable Style/SendWithLiteralMethodName
    self.class.define_method(:dynamic) { puts 'dynamic' }
    alias_method :new_name, :old_name
    remove_method :some_method
    undef_method :another_method
    Object.const_set(:DYNAMIC, 'value')
  end

  def method_missing(method_name, *args) # rubocop:disable Style/MissingRespondToMissing
    # This should also trigger a warning
    super
  end
end
