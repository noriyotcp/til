# frozen_string_literal: true

require 'spec_helper'
require 'numana/plugin_validator'

RSpec.describe Numana::PluginValidator::MetadataValidator do
  let(:validator) { described_class.new(metadata) }

  describe '#validate' do
    context 'with valid metadata' do
      let(:metadata) do
        {
          'name' => 'test_plugin', 'version' => '1.2.3',
          'description' => 'Test plugin description', 'author' => 'Test Author',
          'dependencies' => %w[plugin1 plugin2],
          'commands' => { 'test-cmd' => :test_method }
        }
      end

      it 'returns valid status' do
        result = validator.validate
        expect(result[:valid]).to be true
        expect(result[:errors]).to be_empty
      end
    end

    context 'with missing required fields' do
      let(:metadata) { { 'name' => 'test_plugin' } }

      it 'reports missing fields' do
        result = validator.validate
        expect(result[:valid]).to be false
        expect(result[:errors]).to include(match(/Missing required field: version/))
      end
    end

    context 'with invalid version format' do
      let(:metadata) { { 'name' => 'test_plugin', 'version' => '1.2.beta', 'description' => 'Test', 'author' => 'Test' } }

      it 'reports invalid version' do
        result = validator.validate
        expect(result[:errors]).to include(match(/Invalid version format/))
      end
    end
  end
end
