# frozen_string_literal: true

# Handles validation for chi-square test inputs
class NumberAnalyzer::CLI::ChiSquareValidator
  def initialize(options)
    @options = options
  end

  def validate_arguments(_args, test_type)
    return if @options[:help]

    return unless test_type.nil?

    raise ArgumentError, <<~ERROR
      Error: Please specify the type of chi-square test.
      Example: number_analyzer chi-square --independence contingency.csv
             number_analyzer chi-square --goodness-of-fit observed.csv expected.csv
    ERROR
  end

  def validate_contingency_table(rows)
    validate_non_empty_table(rows)
    validate_minimum_table_size(rows)
    validate_consistent_column_count(rows)
  end

  private

  def validate_non_empty_table(rows)
    return unless rows.empty? || rows.any?(&:empty?)

    raise ArgumentError, <<~ERROR
      Error: Could not create valid contingency table.
      Example: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def validate_minimum_table_size(rows)
    return unless rows.length < 2

    raise ArgumentError, <<~ERROR
      Error: Independence test requires at least a 2x2 contingency table.
      Example: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def validate_consistent_column_count(rows)
    col_count = rows.first.length
    return unless rows.any? { |row| row.length != col_count }

    raise ArgumentError, 'Error: Each row in contingency table must have the same number of columns'
  end
end
