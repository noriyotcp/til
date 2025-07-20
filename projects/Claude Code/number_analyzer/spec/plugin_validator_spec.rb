# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require 'fileutils'
require 'numana/plugin_validator'

RSpec.describe Numana::PluginValidator do
  let(:fixtures_dir) { File.join(__dir__, 'fixtures', 'plugins') }
  let(:safe_plugin_path) { File.join(fixtures_dir, 'safe_plugin.rb') }
  let(:dangerous_plugin_path) { File.join(fixtures_dir, 'dangerous_plugin.rb') }

  describe '.validate_plugin_file' do
    context 'with a valid safe plugin' do
      let(:result) { described_class.validate_plugin_file(safe_plugin_path) }

      it 'returns valid status' do
        expect(result[:valid]).to be true
      end

      it 'has low risk level' do
        expect(result[:risk_level]).to eq(:low)
      end

      it 'has no errors' do
        expect(result[:errors]).to be_empty
      end

      it 'includes integrity check with SHA256' do
        expect(result[:integrity_check]).to include(:sha256)
        expect(result[:integrity_check][:sha256]).to match(/^[a-f0-9]{64}$/)
      end

      it 'extracts metadata correctly' do
        expect(result[:metadata]).to include(
          'name' => 'safe_stats',
          'version' => '1.0.0',
          'description' => 'Safe statistics plugin',
          'author' => 'Test Author'
        )
      end
    end

    context 'with non-existent file' do
      it 'raises ValidationError' do
        expect do
          described_class.validate_plugin_file('/path/to/nonexistent.rb')
        end.to raise_error(Numana::PluginValidator::ValidationError, /does not exist/)
      end
    end

    context 'with dangerous patterns' do
      context 'system command execution' do
        let(:system_cmd_path) { File.join(fixtures_dir, 'system_command_plugin.rb') }
        let(:result) { described_class.validate_plugin_file(system_cmd_path) }

        it 'detects system calls' do
          security_issues = result[:security_issues]
          expect(security_issues).to include(
            hash_including(
              type: 'dangerous_pattern',
              risk_level: :high,
              description: match(/system/)
            )
          )
        end

        it 'sets high or critical risk level' do
          expect(%i[high critical]).to include(result[:risk_level])
        end
      end

      context 'eval usage' do
        let(:eval_path) { File.join(fixtures_dir, 'eval_plugin.rb') }
        let(:result) { described_class.validate_plugin_file(eval_path) }

        it 'detects eval calls' do
          security_issues = result[:security_issues]
          expect(security_issues).to include(
            hash_including(
              type: 'dangerous_pattern',
              risk_level: :high,
              description: match(/eval/)
            )
          )
        end
      end

      context 'network access' do
        let(:network_path) { File.join(fixtures_dir, 'network_access_plugin.rb') }
        let(:result) { described_class.validate_plugin_file(network_path) }

        it 'detects network access' do
          security_issues = result[:security_issues]
          expect(security_issues).to include(
            hash_including(
              type: 'network_access',
              risk_level: :high
            )
          )
        end
      end

      context 'file deletion' do
        let(:file_delete_path) { File.join(fixtures_dir, 'file_deletion_plugin.rb') }
        let(:result) { described_class.validate_plugin_file(file_delete_path) }

        it 'detects file deletion operations' do
          security_issues = result[:security_issues]
          # Ensure we have dangerous patterns detected
          expect(security_issues).not_to be_empty

          # Check that at least one dangerous pattern was found
          dangerous_patterns = security_issues.select { |issue| issue[:type] == 'dangerous_pattern' }
          expect(dangerous_patterns).not_to be_empty

          # Verify that it's marked as high risk
          expect(dangerous_patterns.any? { |p| p[:risk_level] == :high }).to be true
        end
      end
    end

    context 'with suspicious methods' do
      let(:suspicious_path) { File.join(fixtures_dir, 'suspicious_methods_plugin.rb') }
      let(:result) { described_class.validate_plugin_file(suspicious_path) }

      it 'detects send usage' do
        security_issues = result[:security_issues]
        expect(security_issues).to include(
          hash_including(
            type: 'suspicious_method',
            method: 'send',
            risk_level: :medium
          )
        )
      end

      it 'detects method_missing' do
        security_issues = result[:security_issues]
        expect(security_issues).to include(
          hash_including(
            type: 'suspicious_method',
            method: 'method_missing',
            risk_level: :medium
          )
        )
      end
    end

    context 'with large file' do
      let(:large_plugin_path) { File.join(fixtures_dir, 'large_plugin.rb') }

      before do
        # Create a large file temporarily (> 1MB)
        content = "# frozen_string_literal: true\n\nmodule LargePlugin\n  include Numana::StatisticsPlugin\n  plugin_name 'large'\n  plugin_version '1.0.0'\n\n"
        content += "  # Large comment to make file > 1MB\n" * 40_000
        content += "\nend"
        File.write(large_plugin_path, content)
      end

      after do
        FileUtils.rm_f(large_plugin_path)
      end

      it 'warns about large file size' do
        result = described_class.validate_plugin_file(large_plugin_path)
        expect(result[:warnings]).to include(match(/Large plugin file/))
      end
    end

    context 'with security configuration' do
      let(:network_path) { File.join(fixtures_dir, 'network_access_plugin.rb') }

      it 'allows network access when configured' do
        result = described_class.validate_plugin_file(
          network_path,
          security_config: { 'allow_network_access' => true }
        )
        network_issues = result[:security_issues].select { |issue| issue[:type] == 'network_access' }
        expect(network_issues).to be_empty
      end

      it 'blocks network access by default' do
        result = described_class.validate_plugin_file(network_path)
        network_issues = result[:security_issues].select { |issue| issue[:type] == 'network_access' }
        expect(network_issues).not_to be_empty
      end
    end
  end

  describe '.validate_metadata' do
    context 'with valid metadata' do
      let(:metadata) do
        {
          'name' => 'test_plugin',
          'version' => '1.2.3',
          'description' => 'Test plugin description',
          'author' => 'Test Author',
          'dependencies' => %w[plugin1 plugin2],
          'commands' => { 'test-cmd' => :test_method }
        }
      end

      it 'returns valid status' do
        result = described_class.validate_metadata(metadata)
        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
      end
    end

    context 'with missing required fields' do
      let(:metadata) { { 'name' => 'test_plugin' } }

      it 'returns invalid status' do
        result = described_class.validate_metadata(metadata)
        expect(result[:valid]).to be false
      end

      it 'reports missing fields' do
        result = described_class.validate_metadata(metadata)
        expect(result[:errors]).to include(match(/Missing required field: version/))
        expect(result[:errors]).to include(match(/Missing required field: description/))
        expect(result[:errors]).to include(match(/Missing required field: author/))
      end
    end

    context 'with invalid version format' do
      let(:metadata) do
        {
          'name' => 'test_plugin',
          'version' => '1.2.beta',
          'description' => 'Test',
          'author' => 'Test'
        }
      end

      it 'reports invalid version' do
        result = described_class.validate_metadata(metadata)
        expect(result[:errors]).to include(match(/Invalid version format/))
      end
    end

    context 'with empty author' do
      let(:metadata) do
        {
          'name' => 'test_plugin',
          'version' => '1.0.0',
          'description' => 'Test',
          'author' => '   '
        }
      end

      it 'warns about empty author' do
        result = described_class.validate_metadata(metadata)
        expect(result[:warnings]).to include('Author field is empty')
      end
    end

    context 'with invalid dependencies' do
      let(:metadata) do
        {
          'name' => 'test_plugin',
          'version' => '1.0.0',
          'description' => 'Test',
          'author' => 'Test',
          'dependencies' => 'not_an_array'
        }
      end

      it 'reports invalid dependencies' do
        result = described_class.validate_metadata(metadata)
        expect(result[:errors]).to include('Dependencies must be an array of strings')
      end
    end
  end

  describe '.trusted_author?' do
    let(:trusted_authors) { ['Alice Developer', 'Bob Coder'] }

    it 'returns true for trusted author' do
      expect(described_class.trusted_author?('Alice Developer', trusted_authors)).to be true
    end

    it 'returns false for untrusted author' do
      expect(described_class.trusted_author?('Unknown Person', trusted_authors)).to be false
    end

    it 'returns false for nil author' do
      expect(described_class.trusted_author?(nil, trusted_authors)).to be false
    end

    it 'returns false for empty author' do
      expect(described_class.trusted_author?('', trusted_authors)).to be false
    end

    it 'handles whitespace in author names' do
      expect(described_class.trusted_author?('  Alice Developer  ', trusted_authors)).to be true
    end
  end

  describe '.generate_security_report' do
    let(:validation_results) do
      [
        {
          valid: true,
          risk_level: :low,
          security_issues: []
        },
        {
          valid: true,
          risk_level: :medium,
          security_issues: [
            { type: 'suspicious_method', method: 'send' }
          ]
        },
        {
          valid: false,
          risk_level: :high,
          security_issues: [
            { type: 'system_command', pattern: 'system' },
            { type: 'network_access', pattern: 'Net::HTTP' }
          ]
        },
        {
          valid: false,
          risk_level: :critical,
          security_issues: [
            { type: 'system_command', pattern: 'eval' }
          ]
        }
      ]
    end

    let(:report) { described_class.generate_security_report(validation_results) }

    it 'generates summary statistics' do
      expect(report[:summary]).to include(
        total_files: 4,
        valid_files: 2,
        high_risk_files: 2,
        total_security_issues: 4
      )
    end

    it 'groups by risk level' do
      expect(report[:by_risk_level]).to include(
        low: 1,
        medium: 1,
        high: 1,
        critical: 1
      )
    end

    it 'groups security issues by type' do
      expect(report[:security_issues]).to include('system_command')
      expect(report[:security_issues]['system_command'].size).to eq(2)
    end

    it 'generates recommendations' do
      expect(report[:recommendations]).to include(match(/Review 2 high-risk plugins/))
      expect(report[:recommendations]).to include(match(/sandboxing plugins that execute system commands/))
      expect(report[:recommendations]).to include(match(/Review network access requirements/))
    end
  end

  describe 'code obfuscation detection' do
    context 'with base64 strings' do
      let(:obfuscated_path) { File.join(fixtures_dir, 'obfuscated_plugin.rb') }
      let(:result) { described_class.validate_plugin_file(obfuscated_path) }

      it 'detects potential base64 obfuscation' do
        security_issues = result[:security_issues]
        obfuscation_issues = security_issues.select { |issue| issue[:type] == 'obfuscation' }
        expect(obfuscation_issues).not_to be_empty
      end
    end
  end

  describe 'plugin structure validation' do
    context 'without proper interface' do
      let(:no_interface_path) { File.join(fixtures_dir, 'no_interface_plugin.rb') }
      let(:result) { described_class.validate_plugin_file(no_interface_path) }

      it 'warns about missing interface' do
        expect(result[:warnings]).to include(match(/does not include any recognized NumberAnalyzer plugin interface/))
      end
    end
  end
end
