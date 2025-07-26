# frozen_string_literal: true

require 'spec_helper'
require 'numana/plugin_validator'

RSpec.describe Numana::PluginValidator::ValidationReporter do
  let(:validation_results) do
    [
      { valid: true, risk_level: :low, security_issues: [] },
      { valid: true, risk_level: :medium, security_issues: [{ type: 'suspicious_method', method: 'send' }] },
      { valid: false, risk_level: :high, security_issues: [{ type: 'system_command', pattern: 'system' }, { type: 'network_access', pattern: 'Net::HTTP' }] },
      { valid: false, risk_level: :critical, security_issues: [{ type: 'system_command', pattern: 'eval' }] }
    ]
  end
  let(:reporter) { described_class.new(validation_results) }

  describe '#generate' do
    let(:report) { reporter.generate }

    it 'generates summary statistics' do
      expect(report[:summary]).to include(
        total_files: 4, valid_files: 2,
        high_risk_files: 2, total_security_issues: 4
      )
    end

    it 'groups by risk level' do
      expect(report[:by_risk_level]).to include(low: 1, medium: 1, high: 1, critical: 1)
    end

    it 'groups security issues by type' do
      expect(report[:security_issues]['system_command'].size).to eq(2)
    end

    it 'generates recommendations' do
      expect(report[:recommendations]).to include(match(/Review 2 high-risk plugins/))
    end
  end
end
