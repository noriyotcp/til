# frozen_string_literal: true

require_relative 'two_way_anova_calculator'

# Two-way ANOVA statistical analysis module
module TwoWayAnova
  # Performs two-way Analysis of Variance on factorial design data
  def two_way_anova(_data, factor_a_levels, factor_b_levels, values)
    # The actual calculation is delegated to the TwoWayAnovaCalculator class
    # to keep this module clean and focused on providing the public API.
    Numana::Statistics::TwoWayAnovaCalculator.new(factor_a_levels, factor_b_levels, values).perform
  end
end
