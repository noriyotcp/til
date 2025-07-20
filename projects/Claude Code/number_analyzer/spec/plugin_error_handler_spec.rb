# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/plugin_error_handler'
require 'number_analyzer/dependency_resolver'

RSpec.describe Numana::PluginErrorHandler do
  let(:logger) { instance_double(Logger, error: nil, warn: nil, info: nil) }
  let(:error_handler) { described_class.new(logger: logger) }

  describe '#handle_error' do
    let(:error) { StandardError.new('Test error') }
    let(:context) { { plugin_name: 'test_plugin', operation: :load } }

    it 'logs the error' do
      expect(logger).to receive(:error).with('Plugin Error')
      error_handler.handle_error(error, context)
    end

    it 'adds error to error log' do
      error_handler.handle_error(error, context)
      stats = error_handler.error_statistics
      expect(stats[:total_errors]).to eq(1)
    end

    context 'with different error types' do
      it 'uses fallback strategy for LoadError' do
        load_error = LoadError.new('Cannot load plugin')
        result = error_handler.handle_error(load_error, context)
        expect(result[:action]).to eq(:disable)
      end

      it 'uses disable strategy for NoMethodError' do
        no_method_error = NoMethodError.new('undefined method')
        result = error_handler.handle_error(no_method_error, context)
        expect(result[:action]).to eq(:disable)
      end

      it 'uses fail_fast strategy for ArgumentError' do
        arg_error = ArgumentError.new('wrong number of arguments')
        expect { error_handler.handle_error(arg_error, context) }
          .to raise_error(ArgumentError)
      end

      it 'uses log_continue strategy for generic StandardError' do
        result = error_handler.handle_error(error, context)
        expect(result[:action]).to eq(:continue)
      end
    end

    context 'with custom recovery strategy' do
      it 'uses provided recovery strategy' do
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :retry))
        expect(result[:action]).to eq(:retry)
      end
    end

    context 'with error callbacks' do
      it 'calls registered error callbacks' do
        callback_called = false
        error_handler.on_error { |_err, _ctx| callback_called = true }

        error_handler.handle_error(error, context)
        expect(callback_called).to be true
      end

      it 'handles callback errors gracefully' do
        error_handler.on_error { |_err, _ctx| raise 'Callback error' }
        expect(logger).to receive(:error).with(/Error callback failed/)

        expect { error_handler.handle_error(error, context) }.not_to raise_error
      end
    end
  end

  describe 'recovery strategies' do
    let(:error) { StandardError.new('Test error') }
    let(:context) { { plugin_name: 'test_plugin' } }

    describe 'retry with backoff' do
      it 'retries with exponential backoff' do
        allow(error_handler).to receive(:sleep)

        # First attempt
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :retry))
        expect(result[:action]).to eq(:retry)
        expect(result[:delay]).to eq(1)

        # Second attempt
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :retry))
        expect(result[:action]).to eq(:retry)
        expect(result[:delay]).to eq(2)

        # Third attempt
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :retry))
        expect(result[:action]).to eq(:retry)
        expect(result[:delay]).to eq(4)

        # Fourth attempt - max retries reached
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :retry))
        expect(result[:action]).to eq(:disable)
      end
    end

    describe 'fallback plugin' do
      before do
        error_handler.register_fallback('test_plugin', 'fallback_plugin')
      end

      it 'suggests fallback plugin when available' do
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :fallback))
        expect(result[:action]).to eq(:fallback)
        expect(result[:fallback_plugin]).to eq('fallback_plugin')
      end

      it 'disables plugin when fallback is not available' do
        error_handler.register_fallback('test_plugin', nil)
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :fallback))
        expect(result[:action]).to eq(:disable)
      end

      it 'disables plugin when fallback is also disabled' do
        error_handler.register_fallback('test_plugin', 'fallback_plugin')
        error_handler.handle_error(error, { plugin_name: 'fallback_plugin', recovery_strategy: :disable })

        result = error_handler.handle_error(error, context.merge(recovery_strategy: :fallback))
        expect(result[:action]).to eq(:disable)
      end
    end

    describe 'disable plugin' do
      it 'disables the plugin' do
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :disable))
        expect(result[:action]).to eq(:disable)
        expect(error_handler.plugin_disabled?('test_plugin')).to be true
      end
    end

    describe 'fail fast' do
      it 'propagates the error' do
        expect { error_handler.handle_error(error, context.merge(recovery_strategy: :fail_fast)) }
          .to raise_error(StandardError, 'Test error')
      end
    end

    describe 'log and continue' do
      it 'logs warning and continues' do
        expect(logger).to receive(:warn).with(/Continuing despite error/)
        result = error_handler.handle_error(error, context.merge(recovery_strategy: :log_continue))
        expect(result[:action]).to eq(:continue)
      end
    end
  end

  describe '#plugin_disabled?' do
    it 'returns false for enabled plugins' do
      expect(error_handler.plugin_disabled?('test_plugin')).to be false
    end

    it 'returns true for disabled plugins' do
      error_handler.handle_error(StandardError.new, { plugin_name: 'test_plugin', recovery_strategy: :disable })
      expect(error_handler.plugin_disabled?('test_plugin')).to be true
    end
  end

  describe '#enable_plugin' do
    it 're-enables a disabled plugin' do
      error_handler.handle_error(StandardError.new, { plugin_name: 'test_plugin', recovery_strategy: :disable })
      expect(error_handler.plugin_disabled?('test_plugin')).to be true

      error_handler.enable_plugin('test_plugin')
      expect(error_handler.plugin_disabled?('test_plugin')).to be false
    end

    it 'resets retry attempts' do
      3.times do
        error_handler.handle_error(StandardError.new, { plugin_name: 'test_plugin', recovery_strategy: :retry })
      end

      error_handler.enable_plugin('test_plugin')
      stats = error_handler.error_statistics
      expect(stats[:recovery_attempts]['test_plugin']).to eq(0)
    end
  end

  describe '#error_statistics' do
    before do
      error_handler.handle_error(StandardError.new('Error 1'), { plugin_name: 'plugin_a' })
      error_handler.handle_error(StandardError.new('Error 2'), { plugin_name: 'plugin_a' })
      error_handler.handle_error(LoadError.new('Error 3'), { plugin_name: 'plugin_b' })
      error_handler.handle_error(StandardError.new('Error 4'), { plugin_name: 'plugin_b', recovery_strategy: :disable })
    end

    it 'returns total error count' do
      stats = error_handler.error_statistics
      expect(stats[:total_errors]).to eq(4)
    end

    it 'groups errors by plugin' do
      stats = error_handler.error_statistics
      expect(stats[:errors_by_plugin]).to eq({
                                               'plugin_a' => 2,
                                               'plugin_b' => 2
                                             })
    end

    it 'groups errors by type' do
      stats = error_handler.error_statistics
      expect(stats[:errors_by_type]).to eq({
                                             'StandardError' => 3,
                                             'LoadError' => 1
                                           })
    end

    it 'lists disabled plugins' do
      stats = error_handler.error_statistics
      expect(stats[:disabled_plugins]).to eq(['plugin_b'])
    end
  end

  describe '#clear_errors' do
    before do
      error_handler.handle_error(StandardError.new, { plugin_name: 'test_plugin' })
      error_handler.handle_error(StandardError.new, { plugin_name: 'test_plugin', recovery_strategy: :disable })
    end

    it 'clears error log' do
      error_handler.clear_errors
      stats = error_handler.error_statistics
      expect(stats[:total_errors]).to eq(0)
    end

    it 'clears disabled plugins' do
      expect(error_handler.plugin_disabled?('test_plugin')).to be true
      error_handler.clear_errors
      expect(error_handler.plugin_disabled?('test_plugin')).to be false
    end

    it 'clears recovery attempts' do
      error_handler.clear_errors
      stats = error_handler.error_statistics
      expect(stats[:recovery_attempts]).to be_empty
    end
  end
end

RSpec.describe Numana::PluginErrorReport do
  let(:error_handler) { Numana::PluginErrorHandler.new }

  describe '.generate' do
    before do
      error_handler.handle_error(StandardError.new('Error 1'), { plugin_name: 'plugin_a' })
      error_handler.handle_error(LoadError.new('Error 2'), { plugin_name: 'plugin_b' })
      error_handler.handle_error(StandardError.new('Error 3'), { plugin_name: 'plugin_a', recovery_strategy: :retry })
      error_handler.handle_error(StandardError.new('Error 4'), { plugin_name: 'plugin_b', recovery_strategy: :disable })
    end

    it 'generates comprehensive error report' do
      report = described_class.generate(error_handler)

      expect(report).to include('Plugin Error Report')
      expect(report).to include('Total Errors: 4')
      expect(report).to include('plugin_a: 2 errors')
      expect(report).to include('plugin_b: 2 errors')
      expect(report).to include('StandardError: 3 occurrences')
      expect(report).to include('LoadError: 1 occurrences')
      expect(report).to include('Disabled Plugins:')
      expect(report).to include('- plugin_b')
    end

    it 'handles empty error log gracefully' do
      empty_handler = Numana::PluginErrorHandler.new
      report = described_class.generate(empty_handler)

      expect(report).to include('Total Errors: 0')
      expect(report).not_to include('Errors by Plugin:')
      expect(report).not_to include('Errors by Type:')
      expect(report).not_to include('Disabled Plugins:')
    end
  end
end
