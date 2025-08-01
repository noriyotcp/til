# frozen_string_literal: true

require 'spec_helper'
require 'numana/plugin_validator'

RSpec.describe Numana::PluginValidator::SecurityScanner do
  let(:fixtures_dir) { File.join(__dir__, '../../fixtures', 'plugins') }
  let(:scanner) { described_class.new(file_content, security_config) }
  let(:security_config) { {} }

  describe '#scan' do
    context 'with dangerous patterns' do
      context 'system command execution' do
        let(:file_content) { File.read(File.join(fixtures_dir, 'system_command_plugin.rb')) }

        it 'detects system calls' do
          result = scanner.scan
          expect(result).to include(
            hash_including(
              type: 'dangerous_pattern',
              risk_level: :high,
              description: match(/system/)
            )
          )
        end
      end

      context 'eval usage' do
        let(:file_content) { File.read(File.join(fixtures_dir, 'eval_plugin.rb')) }

        it 'detects eval calls' do
          result = scanner.scan
          expect(result).to include(
            hash_including(
              type: 'dangerous_pattern',
              risk_level: :high,
              description: match(/eval/)
            )
          )
        end
      end

      context 'network access' do
        let(:file_content) { File.read(File.join(fixtures_dir, 'network_access_plugin.rb')) }

        it 'detects network access' do
          result = scanner.scan
          expect(result).to include(
            hash_including(
              type: 'network_access',
              risk_level: :high
            )
          )
        end
      end

      context 'file deletion' do
        let(:file_content) { File.read(File.join(fixtures_dir, 'file_deletion_plugin.rb')) }

        it 'detects file deletion operations' do
          result = scanner.scan
          dangerous_patterns = result.select { |issue| issue[:type] == 'dangerous_pattern' }
          expect(dangerous_patterns).not_to be_empty
          expect(dangerous_patterns.any? { |p| p[:risk_level] == :high }).to be true
        end
      end
    end

    context 'with suspicious methods' do
      let(:file_content) { File.read(File.join(fixtures_dir, 'suspicious_methods_plugin.rb')) }

      it 'detects send usage' do
        result = scanner.scan
        expect(result).to include(
          hash_including(
            type: 'suspicious_method',
            method: 'send',
            risk_level: :medium
          )
        )
      end

      it 'detects method_missing' do
        result = scanner.scan
        expect(result).to include(
          hash_including(
            type: 'suspicious_method',
            method: 'method_missing',
            risk_level: :medium
          )
        )
      end
    end

    context 'with security configuration' do
      let(:file_content) { File.read(File.join(fixtures_dir, 'network_access_plugin.rb')) }

      it 'allows network access when configured' do
        scanner = described_class.new(file_content, { 'allow_network_access' => true })
        result = scanner.scan
        network_issues = result.select { |issue| issue[:type] == 'network_access' }
        expect(network_issues).to be_empty
      end
    end

    context 'with code obfuscation' do
      let(:file_content) { File.read(File.join(fixtures_dir, 'obfuscated_plugin.rb')) }

      it 'detects potential base64 obfuscation' do
        result = scanner.scan
        obfuscation_issues = result.select { |issue| issue[:type] == 'obfuscation' }
        expect(obfuscation_issues).not_to be_empty
      end
    end
  end
end
