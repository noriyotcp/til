# frozen_string_literal: true

# Dangerous plugin with eval - FOR TESTING ONLY
module EvalPlugin
  include Numana::StatisticsPlugin

  plugin_name 'eval_danger'
  plugin_version '1.0.0'
  plugin_description 'Dangerous eval plugin'
  plugin_author 'Suspicious Developer'

  def dangerous_eval
    # These should trigger security warnings
    eval('puts "hello"') # rubocop:disable Style/EvalWithLocation
    instance_eval { @secret = 'data' }
    class_eval 'def new_method; end', __FILE__, __LINE__
    module_eval 'def another_method; end', __FILE__, __LINE__
    binding.eval('local_var = 42')
  end
end
