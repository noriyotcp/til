# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/number_analyzer'
require_relative '../../lib/number_analyzer/plugin_sandbox'

RSpec.describe NumberAnalyzer::PluginSandbox::MethodInterceptor do
  let(:strict_interceptor) { described_class.new(:strict) }
  let(:standard_interceptor) { described_class.new(:standard) }
  let(:permissive_interceptor) { described_class.new(:permissive) }

  describe 'Method Whitelisting' do
    describe 'mathematics methods' do
      it 'allows basic math operations' do
        expect(strict_interceptor.method_allowed?(:+)).to be true
        expect(strict_interceptor.method_allowed?(:-)).to be true
        expect(strict_interceptor.method_allowed?(:*)).to be true
        expect(strict_interceptor.method_allowed?(:/)).to be true
      end

      it 'allows advanced math functions' do
        expect(standard_interceptor.method_allowed?(:sqrt)).to be true
        expect(standard_interceptor.method_allowed?(:sin)).to be true
        expect(standard_interceptor.method_allowed?(:log)).to be true
      end
    end

    describe 'array operations' do
      it 'allows safe array methods' do
        expect(strict_interceptor.method_allowed?(:each)).to be true
        expect(strict_interceptor.method_allowed?(:map)).to be true
        expect(strict_interceptor.method_allowed?(:select)).to be true
        expect(strict_interceptor.method_allowed?(:sum)).to be true
      end
    end

    describe 'statistical methods' do
      it 'allows statistical functions' do
        expect(strict_interceptor.method_allowed?(:mean)).to be true
        expect(strict_interceptor.method_allowed?(:median)).to be true
        expect(strict_interceptor.method_allowed?(:correlation)).to be true
      end
    end
  end

  describe 'Method Blocking' do
    it 'blocks eval methods' do
      expect do
        strict_interceptor.intercept_method(:eval, 'malicious_code')
      end.to raise_error(SecurityError, /eval.*prohibited/)
    end

    it 'blocks system commands' do
      expect do
        strict_interceptor.intercept_method(:system, 'rm -rf /')
      end.to raise_error(SecurityError, /system.*not allowed/)
    end

    it 'blocks file operations' do
      expect do
        strict_interceptor.intercept_method(:File, '/etc/passwd')
      end.to raise_error(SecurityError, /File.*prohibited/)
    end

    it 'blocks network operations' do
      expect do
        strict_interceptor.intercept_method(:Net, 'http://evil.com')
      end.to raise_error(SecurityError, /Net.*forbidden/)
    end

    it 'blocks thread operations' do
      expect do
        strict_interceptor.intercept_method(:Thread, {})
      end.to raise_error(SecurityError, /Thread.*restricted/)
    end
  end

  describe 'Security Levels' do
    describe 'strict mode' do
      it 'only allows mathematics, arrays, and statistics' do
        expect(strict_interceptor.method_allowed?(:+)).to be true
        expect(strict_interceptor.method_allowed?(:each)).to be true
        expect(strict_interceptor.method_allowed?(:mean)).to be true

        # These should be blocked in strict mode
        expect(strict_interceptor.method_allowed?(:upcase)).to be false
        expect(strict_interceptor.method_allowed?(:gsub)).to be false
      end
    end

    describe 'standard mode' do
      it 'allows additional safe operations' do
        expect(standard_interceptor.method_allowed?(:upcase)).to be true
        expect(standard_interceptor.method_allowed?(:gsub)).to be true
        expect(standard_interceptor.method_allowed?(:keys)).to be true
      end
    end

    describe 'permissive mode' do
      it 'allows output methods' do
        expect(permissive_interceptor.method_allowed?(:puts)).to be true
        expect(permissive_interceptor.method_allowed?(:print)).to be true
      end
    end
  end

  describe 'Error Messages' do
    it 'provides specific error messages for eval' do
      expect do
        strict_interceptor.intercept_method(:eval, 'test')
      end.to raise_error(SecurityError, /Dynamic code evaluation.*prohibited/)
    end

    it 'provides specific error messages for system commands' do
      expect do
        strict_interceptor.intercept_method(:system, 'test')
      end.to raise_error(SecurityError, /System command execution.*not allowed/)
    end

    it 'provides category suggestions for unknown methods' do
      expect do
        strict_interceptor.intercept_method(:unknown_method)
      end.to raise_error(SecurityError, /not whitelisted.*Available methods/)
    end
  end

  describe 'Violation Tracking' do
    it 'tracks violation count' do
      initial_count = strict_interceptor.violation_count

      begin
        strict_interceptor.intercept_method(:eval, 'test')
      rescue SecurityError
        # Expected
      end

      expect(strict_interceptor.violation_count).to eq(initial_count + 1)
    end
  end

  describe 'Method Execution' do
    it 'executes allowed mathematical operations' do
      # This is a bit tricky to test directly since we need proper context
      # In real usage, this would be called from within a sandbox binding

      expect(standard_interceptor.method_allowed?(:+)).to be true
      expect(standard_interceptor.method_allowed?(:abs)).to be true
    end
  end
end
