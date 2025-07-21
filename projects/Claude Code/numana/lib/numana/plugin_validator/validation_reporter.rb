# frozen_string_literal: true

# Generates reports from validation results
class Numana::PluginValidator::ValidationReporter
  def initialize(validation_results)
    @results = validation_results
  end

  def generate
    {
      summary: generate_summary,
      by_risk_level: group_by_risk_level,
      security_issues: group_security_issues,
      recommendations: generate_recommendations
    }
  end

  private

  def generate_summary
    {
      total_files: @results.size,
      valid_files: @results.count { |r| r[:valid] },
      high_risk_files: @results.count { |r| %i[high critical].include?(r[:risk_level]) },
      total_security_issues: @results.sum { |r| r[:security_issues].size }
    }
  end

  def group_by_risk_level
    @results.group_by { |r| r[:risk_level] }.transform_values(&:count)
  end

  def group_security_issues
    @results.flat_map { |r| r[:security_issues] }.group_by { |issue| issue[:type] }
  end

  def generate_recommendations
    recommendations = []
    add_high_risk_recommendation(recommendations)
    add_issue_specific_recommendations(recommendations)
    recommendations
  end
end
