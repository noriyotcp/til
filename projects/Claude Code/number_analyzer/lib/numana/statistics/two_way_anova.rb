# frozen_string_literal: true

# Two-way ANOVA statistical analysis module
# This module provides two-way Analysis of Variance capabilities including:
# - Main effects calculation for two factors
# - Interaction effect analysis
# - Factorial design matrix handling
# - Effect size measures (partial eta squared)
module TwoWayAnova
  # Performs two-way Analysis of Variance on factorial design data
  # Returns main effects, interaction effect, F-statistics, p-values, and effect sizes
  def two_way_anova(data, factor_a_levels, factor_b_levels, values)
    # Validate input data structure
    return nil unless valid_two_way_anova_input?(data, factor_a_levels, factor_b_levels, values)

    # Extract unique levels for each factor
    a_levels = factor_a_levels.uniq.sort
    b_levels = factor_b_levels.uniq.sort

    # Create factorial design matrix
    cell_data = create_factorial_matrix({
                                          factor_a_levels: factor_a_levels,
                                          factor_b_levels: factor_b_levels,
                                          values: values,
                                          a_levels: a_levels,
                                          b_levels: b_levels
                                        })

    # Calculate basic statistics
    grand_mean = values.sum.to_f / values.length
    n_total = values.length
    a = a_levels.length  # number of levels in factor A
    b = b_levels.length  # number of levels in factor B

    # Calculate cell means and marginal means
    cell_means, marginal_means_a, marginal_means_b = calculate_factorial_means(cell_data, a_levels, b_levels)

    # Calculate sum of squares
    ss_total = calculate_total_sum_of_squares(values, grand_mean)
    ss_a = calculate_factor_a_sum_of_squares(cell_data, marginal_means_a, grand_mean, a_levels, b)
    ss_b = calculate_factor_b_sum_of_squares(cell_data, marginal_means_b, grand_mean, b_levels, a)
    ss_ab = calculate_interaction_sum_of_squares({
                                                   cell_data: cell_data,
                                                   cell_means: cell_means,
                                                   marginal_means_a: marginal_means_a,
                                                   marginal_means_b: marginal_means_b,
                                                   grand_mean: grand_mean,
                                                   a_levels: a_levels,
                                                   b_levels: b_levels
                                                 })
    ss_error = ss_total - ss_a - ss_b - ss_ab

    # Calculate degrees of freedom
    df_a = a - 1
    df_b = b - 1
    df_ab = (a - 1) * (b - 1)

    # Calculate error degrees of freedom (total cells minus parameters)
    cell_sample_sizes = calculate_cell_sample_sizes(cell_data, a_levels, b_levels)
    df_error = cell_sample_sizes.values.sum - (a * b)
    df_total = n_total - 1

    # Calculate mean squares
    ms_a = df_a.zero? ? 0.0 : ss_a / df_a
    ms_b = df_b.zero? ? 0.0 : ss_b / df_b
    ms_ab = df_ab.zero? ? 0.0 : ss_ab / df_ab
    ms_error = df_error.zero? ? 0.0 : ss_error / df_error

    # Calculate F-statistics
    f_a = if ms_error.zero?
            ms_a.zero? ? 0.0 : Float::INFINITY
          else
            ms_a / ms_error
          end
    f_b = if ms_error.zero?
            ms_b.zero? ? 0.0 : Float::INFINITY
          else
            ms_b / ms_error
          end
    f_ab = if ms_error.zero?
             ms_ab.zero? ? 0.0 : Float::INFINITY
           else
             ms_ab / ms_error
           end

    # Calculate p-values
    p_a = MathUtils.calculate_f_distribution_p_value(f_a, df_a, df_error)
    p_b = MathUtils.calculate_f_distribution_p_value(f_b, df_b, df_error)
    p_ab = MathUtils.calculate_f_distribution_p_value(f_ab, df_ab, df_error)

    # Calculate effect sizes (partial eta squared)
    eta_squared_a = ss_total.zero? ? 0.0 : ss_a / (ss_a + ss_error)
    eta_squared_b = ss_total.zero? ? 0.0 : ss_b / (ss_b + ss_error)
    eta_squared_ab = ss_total.zero? ? 0.0 : ss_ab / (ss_ab + ss_error)

    {
      main_effects: {
        factor_a: {
          f_statistic: f_a.round(6),
          p_value: p_a.round(6),
          degrees_of_freedom: [df_a, df_error],
          sum_of_squares: ss_a.round(6),
          mean_squares: ms_a.round(6),
          eta_squared: eta_squared_a.round(6),
          significant: p_a < 0.05
        },
        factor_b: {
          f_statistic: f_b.round(6),
          p_value: p_b.round(6),
          degrees_of_freedom: [df_b, df_error],
          sum_of_squares: ss_b.round(6),
          mean_squares: ms_b.round(6),
          eta_squared: eta_squared_b.round(6),
          significant: p_b < 0.05
        }
      },
      interaction: {
        f_statistic: f_ab.round(6),
        p_value: p_ab.round(6),
        degrees_of_freedom: [df_ab, df_error],
        sum_of_squares: ss_ab.round(6),
        mean_squares: ms_ab.round(6),
        eta_squared: eta_squared_ab.round(6),
        significant: p_ab < 0.05
      },
      error: {
        sum_of_squares: ss_error.round(6),
        mean_squares: ms_error.round(6),
        degrees_of_freedom: df_error
      },
      total: {
        sum_of_squares: ss_total.round(6),
        degrees_of_freedom: df_total
      },
      grand_mean: grand_mean.round(6),
      cell_means: format_cell_means(cell_means, a_levels, b_levels),
      marginal_means: {
        factor_a: marginal_means_a.transform_values { |v| v.round(6) },
        factor_b: marginal_means_b.transform_values { |v| v.round(6) }
      },
      interpretation: interpret_two_way_anova_results({
                                                        p_a: p_a, p_b: p_b, p_ab: p_ab,
                                                        eta_a: eta_squared_a,
                                                        eta_b: eta_squared_b,
                                                        eta_ab: eta_squared_ab
                                                      })
    }
  end

  private

  # Validates two-way ANOVA input data structure
  def valid_two_way_anova_input?(data, factor_a_levels, factor_b_levels, values)
    return false if data.nil? && (factor_a_levels.nil? || factor_b_levels.nil? || values.nil?)
    return false if !data.nil? && (factor_a_levels || factor_b_levels || values)

    # If using separate arrays
    if data.nil?
      return false unless factor_a_levels.is_a?(Array) && factor_b_levels.is_a?(Array) && values.is_a?(Array)
      return false unless factor_a_levels.length == factor_b_levels.length && factor_a_levels.length == values.length
      return false if factor_a_levels.empty?

      # Check for minimum factor levels
      return false if factor_a_levels.uniq.length < 2 || factor_b_levels.uniq.length < 2

      # Check all values are numeric
      return false unless values.all? { |v| v.is_a?(Numeric) }
    end

    true
  end

  # Creates factorial design matrix from input data
  def create_factorial_matrix(data_params)
    factor_a_levels = data_params[:factor_a_levels]
    factor_b_levels = data_params[:factor_b_levels]
    values = data_params[:values]
    a_levels = data_params[:a_levels]
    b_levels = data_params[:b_levels]

    # Initialize cell data structure
    cell_data = {}
    a_levels.each do |a|
      cell_data[a] = {}
      b_levels.each do |b|
        cell_data[a][b] = []
      end
    end

    # Populate cells with values
    factor_a_levels.each_with_index do |a, idx|
      b = factor_b_levels[idx]
      val = values[idx]
      cell_data[a][b] << val if val.is_a?(Numeric)
    end

    cell_data
  end

  # Calculates cell means and marginal means for factorial design
  def calculate_factorial_means(cell_data, a_levels, b_levels)
    cell_means = {}
    marginal_means_a = {}
    marginal_means_b = {}

    # Calculate cell means
    a_levels.each do |a|
      cell_means[a] = {}
      b_levels.each do |b|
        cell_values = cell_data[a][b]
        cell_means[a][b] = cell_values.empty? ? 0.0 : cell_values.sum.to_f / cell_values.length
      end

      # Calculate marginal means for factor A
      all_values_a = b_levels.flat_map { |b| cell_data[a][b] }
      marginal_means_a[a] = all_values_a.empty? ? 0.0 : all_values_a.sum.to_f / all_values_a.length
    end

    # Calculate marginal means for factor B
    b_levels.each do |b|
      all_values_b = a_levels.flat_map { |a| cell_data[a][b] }
      marginal_means_b[b] = all_values_b.empty? ? 0.0 : all_values_b.sum.to_f / all_values_b.length
    end

    [cell_means, marginal_means_a, marginal_means_b]
  end

  # Calculates total sum of squares
  def calculate_total_sum_of_squares(values, grand_mean)
    values.sum { |v| (v - grand_mean)**2 }
  end

  # Calculates sum of squares for factor A
  def calculate_factor_a_sum_of_squares(cell_data, marginal_means_a, grand_mean, a_levels, _b_levels)
    ss_a = 0.0
    a_levels.each do |a|
      n_a = cell_data[a].values.sum(&:length)
      ss_a += n_a * ((marginal_means_a[a] - grand_mean)**2)
    end
    ss_a
  end

  # Calculates sum of squares for factor B
  def calculate_factor_b_sum_of_squares(cell_data, marginal_means_b, grand_mean, b_levels, _a_levels)
    ss_b = 0.0
    b_levels.each do |b|
      n_b = cell_data.values.sum { |row| row[b].length }
      ss_b += n_b * ((marginal_means_b[b] - grand_mean)**2)
    end
    ss_b
  end

  # Calculates interaction sum of squares
  def calculate_interaction_sum_of_squares(interaction_params)
    cell_data = interaction_params[:cell_data]
    cell_means = interaction_params[:cell_means]
    marginal_means_a = interaction_params[:marginal_means_a]
    marginal_means_b = interaction_params[:marginal_means_b]
    grand_mean = interaction_params[:grand_mean]
    a_levels = interaction_params[:a_levels]
    b_levels = interaction_params[:b_levels]

    ss_ab = 0.0

    a_levels.each do |a|
      b_levels.each do |b|
        n_ab = cell_data[a][b].length
        next if n_ab.zero?

        # Interaction effect = cell mean - row mean - column mean + grand mean
        interaction_effect = cell_means[a][b] - marginal_means_a[a] - marginal_means_b[b] + grand_mean
        ss_ab += n_ab * (interaction_effect**2)
      end
    end

    ss_ab
  end

  # Calculates sample sizes for each cell
  def calculate_cell_sample_sizes(cell_data, a_levels, b_levels)
    sizes = {}
    a_levels.each do |a|
      b_levels.each do |b|
        key = "#{a}_#{b}"
        sizes[key] = cell_data[a][b].length
      end
    end
    sizes
  end

  # Formats cell means for output
  def format_cell_means(cell_means, a_levels, b_levels)
    formatted = {}
    a_levels.each do |a|
      formatted[a] = {}
      b_levels.each do |b|
        formatted[a][b] = cell_means[a][b].round(6)
      end
    end
    formatted
  end

  # Interprets two-way ANOVA results
  def interpret_two_way_anova_results(interpretation_params)
    p_a = interpretation_params[:p_a]
    p_b = interpretation_params[:p_b]
    p_ab = interpretation_params[:p_ab]
    eta_a = interpretation_params[:eta_a]
    eta_b = interpretation_params[:eta_b]
    eta_ab = interpretation_params[:eta_ab]

    interpretation = []

    # Main effect A
    if p_a < 0.05
      effect_size = interpret_effect_size(eta_a)
      interpretation << "Factor A has a significant main effect (p = #{p_a.round(4)}) with #{effect_size} effect size."
    else
      interpretation << "Factor A does not have a significant main effect (p = #{p_a.round(4)})."
    end

    # Main effect B
    if p_b < 0.05
      effect_size = interpret_effect_size(eta_b)
      interpretation << "Factor B has a significant main effect (p = #{p_b.round(4)}) with #{effect_size} effect size."
    else
      interpretation << "Factor B does not have a significant main effect (p = #{p_b.round(4)})."
    end

    # Interaction effect
    if p_ab < 0.05
      effect_size = interpret_effect_size(eta_ab)
      interpretation << "There is a significant interaction between factors (p = #{p_ab.round(4)}) with #{effect_size} effect size."
      interpretation << 'The interaction suggests that the effect of one factor depends on the level of the other factor.'
    else
      interpretation << "There is no significant interaction between factors (p = #{p_ab.round(4)})."
    end

    interpretation.join(' ')
  end

  # Calculate sum of squares components for two-way ANOVA
  def calculate_sum_of_squares_components(params)
    ss_total = calculate_total_sum_of_squares(params[:values], params[:grand_mean])
    ss_a = calculate_factor_a_sum_of_squares(
      params[:cell_data], params[:marginal_means_a],
      params[:grand_mean], params[:a_levels], params[:b_levels].length
    )
    ss_b = calculate_factor_b_sum_of_squares(
      params[:cell_data], params[:marginal_means_b],
      params[:grand_mean], params[:b_levels], params[:a_levels].length
    )
    ss_ab = calculate_interaction_sum_of_squares({
                                                   cell_data: params[:cell_data],
                                                   cell_means: params[:cell_means],
                                                   marginal_means_a: params[:marginal_means_a],
                                                   marginal_means_b: params[:marginal_means_b],
                                                   grand_mean: params[:grand_mean],
                                                   a_levels: params[:a_levels],
                                                   b_levels: params[:b_levels]
                                                 })
    ss_error = ss_total - ss_a - ss_b - ss_ab

    {
      total: ss_total,
      factor_a: ss_a,
      factor_b: ss_b,
      interaction: ss_ab,
      error: ss_error
    }
  end

  # Calculate degrees of freedom for all components
  def calculate_degrees_of_freedom(a_levels, b_levels, cell_data, n_total)
    df_a = a_levels.length - 1
    df_b = b_levels.length - 1
    df_ab = df_a * df_b

    cell_sample_sizes = calculate_cell_sample_sizes(cell_data, a_levels, b_levels)
    df_error = cell_sample_sizes.values.sum - (a_levels.length * b_levels.length)
    df_total = n_total - 1

    {
      factor_a: df_a,
      factor_b: df_b,
      interaction: df_ab,
      error: df_error,
      total: df_total
    }
  end

  # Calculate mean squares from sum of squares and degrees of freedom
  def calculate_mean_squares(sum_of_squares, degrees_of_freedom)
    {
      factor_a: degrees_of_freedom[:factor_a].zero? ? 0.0 : sum_of_squares[:factor_a] / degrees_of_freedom[:factor_a],
      factor_b: degrees_of_freedom[:factor_b].zero? ? 0.0 : sum_of_squares[:factor_b] / degrees_of_freedom[:factor_b],
      interaction: degrees_of_freedom[:interaction].zero? ? 0.0 : sum_of_squares[:interaction] / degrees_of_freedom[:interaction],
      error: degrees_of_freedom[:error].zero? ? 0.0 : sum_of_squares[:error] / degrees_of_freedom[:error]
    }
  end

  # Calculate F-statistics from mean squares
  def calculate_f_statistics(mean_squares)
    ms_error = mean_squares[:error]

    {
      factor_a: calculate_f_value(mean_squares[:factor_a], ms_error),
      factor_b: calculate_f_value(mean_squares[:factor_b], ms_error),
      interaction: calculate_f_value(mean_squares[:interaction], ms_error)
    }
  end

  # Calculate single F value with proper handling for zero error
  def calculate_f_value(ms_treatment, ms_error)
    if ms_error.zero?
      ms_treatment.zero? ? 0.0 : Float::INFINITY
    else
      ms_treatment / ms_error
    end
  end

  # Calculate p-values and effect sizes
  def calculate_statistics(f_stats, degrees_of_freedom, sum_of_squares)
    {
      p_values: {
        factor_a: MathUtils.calculate_f_distribution_p_value(f_stats[:factor_a], degrees_of_freedom[:factor_a], degrees_of_freedom[:error]),
        factor_b: MathUtils.calculate_f_distribution_p_value(f_stats[:factor_b], degrees_of_freedom[:factor_b], degrees_of_freedom[:error]),
        interaction: MathUtils.calculate_f_distribution_p_value(f_stats[:interaction], degrees_of_freedom[:interaction], degrees_of_freedom[:error])
      },
      effect_sizes: {
        factor_a: calculate_partial_eta_squared(sum_of_squares[:factor_a], sum_of_squares[:error]),
        factor_b: calculate_partial_eta_squared(sum_of_squares[:factor_b], sum_of_squares[:error]),
        interaction: calculate_partial_eta_squared(sum_of_squares[:interaction], sum_of_squares[:error])
      }
    }
  end

  # Calculate partial eta squared effect size
  def calculate_partial_eta_squared(ss_effect, ss_error)
    total = ss_effect + ss_error
    total.zero? ? 0.0 : ss_effect / total
  end

  # Build the final result hash for a factor
  def build_factor_result(f_stat, p_value, df_factor, df_error, sum_squares, mean_squares, eta_squared)
    {
      f_statistic: f_stat.round(6),
      p_value: p_value.round(6),
      degrees_of_freedom: [df_factor, df_error],
      sum_of_squares: sum_squares.round(6),
      mean_squares: mean_squares.round(6),
      eta_squared: eta_squared.round(6),
      significant: p_value < 0.05
    }
  end
end
