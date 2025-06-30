# frozen_string_literal: true

# 相関分析に関する統計機能を提供するモジュール
module CorrelationStats
  # ピアソン相関係数を計算する
  # @param other_dataset [Array<Numeric>] 比較対象のデータセット
  # @return [Float, nil] 相関係数（-1から1の範囲）、計算不可能な場合はnil
  def correlation(other_dataset)
    return nil if @numbers.empty? || other_dataset.empty?
    return nil if @numbers.length != other_dataset.length

    # Calculate means
    mean_x = @numbers.sum.to_f / @numbers.length
    mean_y = other_dataset.sum.to_f / other_dataset.length

    # Calculate numerator and denominators for Pearson correlation
    numerator = 0.0
    sum_sq_x = 0.0
    sum_sq_y = 0.0

    @numbers.length.times do |i|
      diff_x = @numbers[i] - mean_x
      diff_y = other_dataset[i] - mean_y

      numerator += diff_x * diff_y
      sum_sq_x += diff_x * diff_x
      sum_sq_y += diff_y * diff_y
    end

    # Avoid division by zero
    denominator = Math.sqrt(sum_sq_x * sum_sq_y)
    return 0.0 if denominator.zero?

    # Return Pearson correlation coefficient
    (numerator / denominator).round(10)
  end

  # 相関係数の強度を解釈する
  # @param correlation_value [Float] 相関係数
  # @return [String] 相関の強度を示す日本語の説明
  def interpret_correlation(correlation_value)
    abs_value = correlation_value.abs
    case abs_value
    when 0.8..1.0
      correlation_value.positive? ? '強い正の相関' : '強い負の相関'
    when 0.5..0.8
      correlation_value.positive? ? '中程度の正の相関' : '中程度の負の相関'
    when 0.3..0.5
      correlation_value.positive? ? '弱い正の相関' : '弱い負の相関'
    else
      'ほぼ無相関'
    end
  end
end
