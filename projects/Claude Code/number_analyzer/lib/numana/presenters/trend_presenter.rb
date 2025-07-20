# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# TrendPresenter: Handles formatting of linear trend analysis results
# Supports all standard output formats (default, JSON, quiet) with precision control
#
# Example usage:
#   trend_data = { slope: 1.2, intercept: 0.5, r_squared: 0.85, direction: '上昇' }
#   presenter = Numana::Presenters::TrendPresenter.new(trend_data, options)
#   puts presenter.format
class Numana::Presenters::TrendPresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'エラー: データが不十分です（2つ以上の値が必要）' if trend_data_invalid?

    slope = format_value(@result[:slope])
    intercept = format_value(@result[:intercept])
    r_squared = format_value(@result[:r_squared])

    "トレンド分析結果:\n傾き: #{slope}\n切片: #{intercept}\n決定係数(R²): #{r_squared}\n方向性: #{@result[:direction]}"
  end

  def format_quiet
    return '' if trend_data_invalid?

    slope = format_value(@result[:slope])
    intercept = format_value(@result[:intercept])
    r_squared = format_value(@result[:r_squared])
    "#{slope} #{intercept} #{r_squared}"
  end

  def json_fields
    return { trend: nil }.merge(dataset_metadata) if trend_data_invalid?

    {
      trend: {
        slope: apply_precision(@result[:slope], @precision),
        intercept: apply_precision(@result[:intercept], @precision),
        r_squared: apply_precision(@result[:r_squared], @precision),
        direction: @result[:direction]
      }
    }.merge(dataset_metadata)
  end

  private

  def trend_data_invalid?
    @result.nil?
  end
end
