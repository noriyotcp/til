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
