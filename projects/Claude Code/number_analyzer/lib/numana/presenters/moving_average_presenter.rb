# frozen_string_literal: true

require_relative 'base_statistical_presenter'

# MovingAveragePresenter: Handles formatting of moving average analysis results
# Supports all standard output formats (default, JSON, quiet) with precision control
# Consolidates logic from both OutputFormatter and MovingAverageCommand
#
# Expected result format:
#   {
#     moving_average: [1.0, 1.5, 2.0, 2.5],
#     window_size: 3,
#     dataset_size: 7
#   }
#
# Example usage:
#   result = { moving_average: [1.0, 1.5, 2.0], window_size: 3, dataset_size: 5 }
#   presenter = Numana::Presenters::MovingAveragePresenter.new(result, options)
#   puts presenter.format
class Numana::Presenters::MovingAveragePresenter < Numana::Presenters::BaseStatisticalPresenter
  def format_verbose
    return 'エラー: データが不十分です（ウィンドウサイズがデータ長を超えています）' if moving_average_invalid?

    moving_average = @result[:moving_average]
    window_size = @result[:window_size]
    dataset_size = @result[:dataset_size]

    # Format the values with precision
    formatted_values = moving_average.map { |value| format_value(value) }

    result = "移動平均 (ウィンドウサイズ: #{window_size}):\n"
    result += formatted_values.join(', ')
    result += "\n元データサイズ: #{dataset_size}, 移動平均数: #{moving_average.length}"
    result
  end

  def format_quiet
    return '' if moving_average_invalid?

    moving_average = @result[:moving_average]
    formatted_values = moving_average.map { |value| format_value(value) }
    formatted_values.join(' ')
  end

  def json_fields
    return { moving_average: nil, error: 'データが不十分です' }.merge(dataset_metadata) if moving_average_invalid?

    {
      moving_average: @result[:moving_average].map { |value| apply_precision(value, @precision) },
      window_size: @result[:window_size],
      dataset_size: @result[:dataset_size]
    }.merge(dataset_metadata)
  end

  private

  def moving_average_invalid?
    @result.nil? || @result[:moving_average].nil? || @result[:moving_average].empty?
  end
end
