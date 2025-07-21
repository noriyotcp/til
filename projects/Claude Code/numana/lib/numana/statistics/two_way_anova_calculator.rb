# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Main Numana class for statistical analysis
# Namespace for statistical calculation classes
# Performs two-way Analysis of Variance calculations
class Numana::Statistics::TwoWayAnovaCalculator
  def initialize(factor_a_levels, factor_b_levels, values)
    @factor_a_levels = factor_a_levels
    @factor_b_levels = factor_b_levels
    @values = values
  end

  def perform
    return nil unless valid_input?

    a_levels = @factor_a_levels.uniq.sort
    b_levels = @factor_b_levels.uniq.sort

    analysis_params = prepare_anova_parameters(a_levels, b_levels)
    results = calculate_anova_statistics(analysis_params)

    format_two_way_anova_result(results)
  end

  private

  def valid_input?
    return false unless @factor_a_levels.is_a?(Array) && @factor_b_levels.is_a?(Array) && @values.is_a?(Array)
    return false if @factor_a_levels.length != @factor_b_levels.length || @factor_a_levels.length != @values.length
    return false if @factor_a_levels.empty?
    return false if @factor_a_levels.uniq.length < 2 || @factor_b_levels.uniq.length < 2

    @values.all? { |v| v.is_a?(Numeric) }
  end

  def prepare_anova_parameters(a_levels, b_levels)
    cell_data = create_factorial_matrix
    grand_mean = @values.sum.to_f / @values.length
    cell_means, marginal_means_a, marginal_means_b = calculate_factorial_means(cell_data, a_levels, b_levels)
    {
      values: @values, a_levels: a_levels, b_levels: b_levels, cell_data: cell_data,
      grand_mean: grand_mean, cell_means: cell_means,
      marginal_means_a: marginal_means_a, marginal_means_b: marginal_means_b
    }
  end

  def calculate_anova_statistics(params)
    sum_squares = calculate_all_sum_of_squares(params)
    degrees_freedom = calculate_all_degrees_of_freedom(params)
    mean_squares = calculate_all_mean_squares(sum_squares, degrees_freedom)
    f_stats = calculate_all_f_statistics(mean_squares)
    p_values = calculate_all_p_values(f_stats, degrees_freedom)
    etas = calculate_all_partial_eta_squared(sum_squares)
    params.merge(ss: sum_squares, df: degrees_freedom, ms: mean_squares, f_stats: f_stats, p_values: p_values, etas: etas)
  end

  def create_factorial_matrix
    cell_data = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
    @factor_a_levels.each_with_index do |a, idx|
      cell_data[a][@factor_b_levels[idx]] << @values[idx]
    end
    cell_data
  end

  # rubocop:disable Metrics/AbcSize
  def calculate_factorial_means(cell_data, a_levels, b_levels)
    cell_means = a_levels.to_h do |a|
      [a, b_levels.to_h do |b|
        [b, cell_data[a][b].empty? ? 0.0 : cell_data[a][b].sum.to_f / cell_data[a][b].length]
      end]
    end
    marginal_a = a_levels.to_h do |a|
      all_a = b_levels.flat_map { |b| cell_data[a][b] }
      [a, all_a.empty? ? 0.0 : all_a.sum / all_a.size.to_f]
    end
    marginal_b = b_levels.to_h do |b|
      all_b = a_levels.flat_map { |a| cell_data[a][b] }
      [b, all_b.empty? ? 0.0 : all_b.sum / all_b.size.to_f]
    end
    [cell_means, marginal_a, marginal_b]
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def calculate_all_sum_of_squares(params)
    ss_total = params[:values].sum { |v| (v - params[:grand_mean])**2 }
    ss_a = params[:a_levels].sum { |a| params[:cell_data][a].values.sum(&:length) * ((params[:marginal_means_a][a] - params[:grand_mean])**2) }
    ss_b = params[:b_levels].sum do |b|
      params[:cell_data].values.sum do |row|
        row[b].length
      end * ((params[:marginal_means_b][b] - params[:grand_mean])**2)
    end
    ss_ab = params[:a_levels].sum do |a|
      params[:b_levels].sum do |b|
        n_ab = params[:cell_data][a][b].length
        next 0 if n_ab.zero?

        interaction_effect = params[:cell_means][a][b] - params[:marginal_means_a][a] - params[:marginal_means_b][b] + params[:grand_mean]
        n_ab * (interaction_effect**2)
      end
    end
    ss_error = ss_total - ss_a - ss_b - ss_ab
    { a: ss_a, b: ss_b, ab: ss_ab, error: ss_error, total: ss_total }
  end
  # rubocop:enable Metrics/AbcSize

  def calculate_all_degrees_of_freedom(params)
    a = params[:a_levels].length
    b = params[:b_levels].length
    df_error = params[:cell_data].values.sum { |row| row.values.sum(&:length) } - (a * b)
    { a: a - 1, b: b - 1, ab: (a - 1) * (b - 1), error: df_error, total: @values.length - 1 }
  end

  def calculate_all_mean_squares(sum_squares, degrees_freedom)
    {
      a: degrees_freedom[:a].zero? ? 0.0 : sum_squares[:a] / degrees_freedom[:a],
      b: degrees_freedom[:b].zero? ? 0.0 : sum_squares[:b] / degrees_freedom[:b],
      ab: degrees_freedom[:ab].zero? ? 0.0 : sum_squares[:ab] / degrees_freedom[:ab],
      error: degrees_freedom[:error].zero? ? 0.0 : sum_squares[:error] / degrees_freedom[:error]
    }
  end

  def calculate_all_f_statistics(mean_squares)
    ms_error = mean_squares[:error]
    {
      a: if ms_error.zero?
           mean_squares[:a].zero? ? 0.0 : Float::INFINITY
         else
           mean_squares[:a] / ms_error
         end,
      b: if ms_error.zero?
           mean_squares[:b].zero? ? 0.0 : Float::INFINITY
         else
           mean_squares[:b] / ms_error
         end,
      ab: if ms_error.zero?
            mean_squares[:ab].zero? ? 0.0 : Float::INFINITY
          else
            mean_squares[:ab] / ms_error
          end
    }
  end

  def calculate_all_p_values(f_stats, degrees_freedom)
    {
      a: MathUtils.calculate_f_distribution_p_value(f_stats[:a], degrees_freedom[:a], degrees_freedom[:error]),
      b: MathUtils.calculate_f_distribution_p_value(f_stats[:b], degrees_freedom[:b], degrees_freedom[:error]),
      ab: MathUtils.calculate_f_distribution_p_value(f_stats[:ab], degrees_freedom[:ab], degrees_freedom[:error])
    }
  end

  def calculate_all_partial_eta_squared(sum_squares)
    {
      a: sum_squares[:total].zero? ? 0.0 : sum_squares[:a] / (sum_squares[:a] + sum_squares[:error]),
      b: sum_squares[:total].zero? ? 0.0 : sum_squares[:b] / (sum_squares[:b] + sum_squares[:error]),
      ab: sum_squares[:total].zero? ? 0.0 : sum_squares[:ab] / (sum_squares[:ab] + sum_squares[:error])
    }
  end

  # rubocop:disable Metrics/AbcSize
  def format_two_way_anova_result(results)
    {
      main_effects: {
        factor_a: format_effect_result(results[:f_stats][:a], results[:p_values][:a], results[:df][:a], results[:df][:error], results[:ss][:a],
                                       results[:ms][:a], results[:etas][:a]),
        factor_b: format_effect_result(results[:f_stats][:b], results[:p_values][:b], results[:df][:b], results[:df][:error], results[:ss][:b],
                                       results[:ms][:b], results[:etas][:b])
      },
      interaction: format_effect_result(results[:f_stats][:ab], results[:p_values][:ab], results[:df][:ab], results[:df][:error],
                                        results[:ss][:ab], results[:ms][:ab], results[:etas][:ab]),
      error: { sum_of_squares: results[:ss][:error].round(6), mean_squares: results[:ms][:error].round(6),
               degrees_of_freedom: results[:df][:error] },
      total: { sum_of_squares: results[:ss][:total].round(6), degrees_of_freedom: results[:df][:total] },
      grand_mean: results[:grand_mean].round(6),
      cell_means: format_cell_means(results[:cell_means], results[:a_levels], results[:b_levels]),
      marginal_means: {
        factor_a: results[:marginal_means_a].transform_values { |v| v.round(6) },
        factor_b: results[:marginal_means_b].transform_values { |v| v.round(6) }
      },
      interpretation: interpret_two_way_anova_results(results[:p_values][:a], results[:p_values][:b], results[:p_values][:ab],
                                                      results[:etas][:a], results[:etas][:b], results[:etas][:ab])
    }
  end
  # rubocop:enable Metrics/AbcSize

  def format_effect_result(f_stat, p_value, df1, df2, sum_squares, mean_squares, eta)
    {
      f_statistic: f_stat.round(6), p_value: p_value.round(6), degrees_of_freedom: [df1, df2],
      sum_of_squares: sum_squares.round(6), mean_squares: mean_squares.round(6), eta_squared: eta.round(6),
      significant: p_value < 0.05
    }
  end

  def format_cell_means(cell_means, a_levels, b_levels)
    a_levels.to_h { |a| [a, b_levels.to_h { |b| [b, cell_means[a][b].round(6)] }] }
  end

  def interpret_two_way_anova_results(p_a, p_b, p_ab, eta_a, eta_b, eta_ab)
    [
      interpret_main_effect('A', p_a, eta_a),
      interpret_main_effect('B', p_b, eta_b),
      interpret_interaction_effect(p_ab, eta_ab)
    ].join(' ')
  end

  def interpret_main_effect(factor_name, p_value, eta_squared)
    sig = p_value < 0.05 ? 'a significant' : 'no significant'
    eff = interpret_effect_size(eta_squared)
    "Factor #{factor_name} has #{sig} main effect (p = #{p_value.round(4)}) with #{eff} effect size."
  end

  def interpret_interaction_effect(p_value, eta_squared)
    if p_value < 0.05
      eff = interpret_effect_size(eta_squared)
      "There is a significant interaction between factors (p = #{p_value.round(4)}) with #{eff} effect size. " \
        'The interaction suggests that the effect of one factor depends on the level of the other factor.'
    else
      "There is no significant interaction between factors (p = #{p_value.round(4)})."
    end
  end

  def interpret_effect_size(eta_squared)
    if eta_squared >= 0.14
      'large'
    elsif eta_squared >= 0.06
      'medium'
    elsif eta_squared >= 0.01
      'small'
    else
      'negligible'
    end
  end
end
# rubocop:enable Metrics/ClassLength
