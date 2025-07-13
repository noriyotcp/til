# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# SeasonalPresenter: Handles formatting of seasonal analysis results
# Supports all standard output formats (default, JSON, quiet) with precision control
#
# Example usage:
#   seasonal_data = {
#     period: 4,
#     seasonal_indices: [0.95, 1.05, 1.02, 0.98],
#     seasonal_strength: 0.15,
#     has_seasonality: true
#   }
#   presenter = NumberAnalyzer::Presenters::SeasonalPresenter.new(seasonal_data, options)
#   puts presenter.format
class NumberAnalyzer::Presenters::SeasonalPresenter < NumberAnalyzer::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'エラー: データが不十分です（季節性分析には最低4つの値が必要）' if seasonal_data_invalid?

    formatted_indices = @result[:seasonal_indices].map { |index| format_value(index) }
    strength_formatted = format_value(@result[:seasonal_strength])
    seasonality_status = @result[:has_seasonality] ? '季節性あり' : '季節性なし'

    result = "季節性分析結果:\n"
    result += "検出周期: #{@result[:period]}\n"
    result += "季節指数: #{formatted_indices.join(', ')}\n"
    result += "季節性強度: #{strength_formatted}\n"
    result += "季節性判定: #{seasonality_status}"
    result
  end

  def format_quiet
    return '' if seasonal_data_invalid?

    strength = format_value(@result[:seasonal_strength])
    has_seasonality = @result[:has_seasonality] ? 'true' : 'false'
    "#{@result[:period]} #{strength} #{has_seasonality}"
  end

  def json_fields
    return { seasonal_analysis: nil, error: 'データが不十分です' }.merge(dataset_metadata) if seasonal_data_invalid?

    formatted_indices = @result[:seasonal_indices].map do |index|
      apply_precision(index, @precision)
    end

    {
      seasonal_analysis: {
        period: @result[:period],
        seasonal_indices: formatted_indices,
        seasonal_strength: apply_precision(@result[:seasonal_strength], @precision),
        has_seasonality: @result[:has_seasonality]
      }
    }.merge(dataset_metadata)
  end

  private

  def seasonal_data_invalid?
    @result.nil?
  end
end
