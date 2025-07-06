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
      エラー: カイ二乗検定のタイプを指定してください。
      使用例: number_analyzer chi-square --independence contingency.csv
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
      エラー: 有効な分割表を作成できませんでした。
      使用例: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def validate_minimum_table_size(rows)
    return unless rows.length < 2

    raise ArgumentError, <<~ERROR
      エラー: 独立性検定には少なくとも2x2の分割表が必要です。
      使用例: number_analyzer chi-square --independence 30 20 -- 15 35
    ERROR
  end

  def validate_consistent_column_count(rows)
    col_count = rows.first.length
    return unless rows.any? { |row| row.length != col_count }

    raise ArgumentError, 'エラー: 分割表の各行は同じ列数である必要があります。'
  end
end
