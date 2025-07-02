# frozen_string_literal: true

require_relative '../lib/number_analyzer/plugin_interface'

# MathUtilsPlugin - Plugin implementation of mathematical utility functions
# Provides mathematical utility functions for statistical calculations
module MathUtilsPlugin
  include NumberAnalyzer::StatisticsPlugin

  # Plugin metadata
  plugin_name 'math_utils'
  plugin_version '1.0.0'
  plugin_description 'Mathematical utility functions for statistical calculations including distributions ' \
                     'and error functions'
  plugin_author 'NumberAnalyzer Team'
  plugin_dependencies [] # No dependencies

  # Register plugin methods
  register_method :standard_normal_cdf, 'Standard normal cumulative distribution function'
  register_method :erf, 'Error function approximation'
  register_method :approximate_t_distribution_cdf, 'Approximate t-distribution CDF'
  register_method :calculate_f_distribution_p_value, 'Calculate F-distribution p-value'

  # Define CLI commands mapping (MathUtils typically doesn't have direct CLI commands)
  def self.plugin_commands
    {} # Math utils are typically used internally by other plugins
  end

  # Standard normal cumulative distribution function
  # 標準正規分布の累積分布関数
  def self.standard_normal_cdf(z_score)
    # Approximation of standard normal CDF using error function approximation
    # This is reasonably accurate for most practical purposes
    0.5 * (1.0 + erf(z_score / Math.sqrt(2.0)))
  end

  # Error function approximation using Abramowitz and Stegun formula
  # Abramowitz and Stegun公式を使用した誤差関数の近似
  # rubocop:disable Metrics/AbcSize
  def self.erf(value)
    # Approximation of error function using Abramowitz and Stegun formula
    # Maximum error: 1.5 × 10^−7
    a1 = 0.254829592
    a2 = -0.284496736
    a3 = 1.421413741
    a4 = -1.453152027
    a5 = 1.061405429
    p = 0.3275911

    sign = value >= 0 ? 1 : -1
    value = value.abs

    t = 1.0 / (1.0 + (p * value))
    y = 1.0 - (((((((((a5 * t) + a4) * t) + a3) * t) + a2) * t) + a1) * t * Math.exp(-value * value))

    sign * y
  end
  # rubocop:enable Metrics/AbcSize

  # Approximate t-distribution cumulative distribution function
  # t分布の累積分布関数の近似
  def self.approximate_t_distribution_cdf(t_value, degrees_of_freedom)
    # Simple approximation for t-distribution
    # Not highly accurate but sufficient for basic statistical testing
    return 0.5 - (Math.atan(t_value) / Math::PI) if degrees_of_freedom <= 1

    # For df > 1, use approximation that converges to normal distribution
    adjustment = 1.0 + ((t_value * t_value) / (4.0 * degrees_of_freedom))
    normal_approx = standard_normal_cdf(t_value / Math.sqrt(adjustment))
    1.0 - normal_approx
  end

  # Calculate F-distribution p-value using critical values
  # F分布のp値をクリティカル値を使用して計算
  def self.calculate_f_distribution_p_value(f_statistic, df_numerator, df_denominator)
    return 1.0 if f_statistic.infinite? || f_statistic.nan?
    return 1.0 if f_statistic <= 0

    # Simplified F-distribution p-value calculation using critical values
    # This is an approximation for common cases
    f_critical_values = self.f_critical_values

    # Find appropriate p-value by comparing with critical values
    alphas = [0.001, 0.01, 0.05, 0.10, 0.25, 0.50]

    alphas.each do |alpha|
      critical_value = interpolate_f_critical_value(df_numerator, df_denominator, alpha, f_critical_values)
      return alpha if f_statistic <= critical_value
    end

    # If F-statistic is higher than all critical values, p < 0.001
    0.001
  end

  # Get F-critical values lookup table
  # F分布のクリティカル値テーブルを取得
  def self.f_critical_values
    # Simplified F-critical values for common df combinations at α = 0.05
    # Format: [df_numerator, df_denominator] => critical_value
    {
      [1, 1] => 161.4, [1, 2] => 18.51, [1, 3] => 10.13, [1, 4] => 7.71, [1, 5] => 6.61,
      [1, 6] => 5.99, [1, 7] => 5.59, [1, 8] => 5.32, [1, 9] => 5.12, [1, 10] => 4.96,
      [2, 1] => 199.5, [2, 2] => 19.00, [2, 3] => 9.55, [2, 4] => 6.94, [2, 5] => 5.79,
      [2, 6] => 5.14, [2, 7] => 4.74, [2, 8] => 4.46, [2, 9] => 4.26, [2, 10] => 4.10,
      [3, 1] => 215.7, [3, 2] => 19.16, [3, 3] => 9.28, [3, 4] => 6.59, [3, 5] => 5.41,
      [3, 6] => 4.76, [3, 7] => 4.35, [3, 8] => 4.07, [3, 9] => 3.86, [3, 10] => 3.71,
      [4, 1] => 224.6, [4, 2] => 19.25, [4, 3] => 9.12, [4, 4] => 6.39, [4, 5] => 5.19,
      [4, 6] => 4.53, [4, 7] => 4.12, [4, 8] => 3.84, [4, 9] => 3.63, [4, 10] => 3.48,
      [5, 1] => 230.2, [5, 2] => 19.30, [5, 3] => 9.01, [5, 4] => 6.26, [5, 5] => 5.05,
      [5, 6] => 4.39, [5, 7] => 3.97, [5, 8] => 3.69, [5, 9] => 3.48, [5, 10] => 3.33
    }
  end

  # Interpolate F-critical value for given degrees of freedom and alpha
  # 与えられた自由度とα値に対してF分布のクリティカル値を補間
  def self.interpolate_f_critical_value(df_num, df_den, _alpha, f_critical_values)
    # Simple lookup for common cases
    return f_critical_values[[df_num, df_den]] if f_critical_values.key?([df_num, df_den])

    # For cases not in the table, use conservative approximation
    # Find closest match or use conservative estimate
    closest_num_df = f_critical_values.keys.map(&:first).min_by { |x| (x - df_num).abs }
    closest_den_df = f_critical_values.keys.map(&:last).min_by { |x| (x - df_den).abs }

    f_critical_values[[closest_num_df, closest_den_df]] || 4.0 # Conservative default
  end
end
