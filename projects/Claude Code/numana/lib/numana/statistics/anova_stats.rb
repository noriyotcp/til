# frozen_string_literal: true

require_relative 'one_way_anova'
require_relative 'two_way_anova'
require_relative 'anova_helpers'

# ANOVA (Analysis of Variance) statistical analysis module
# This module provides comprehensive variance analysis capabilities by combining:
# - One-way ANOVA with F-statistics and effect size measures
# - Two-way ANOVA with main effects and interaction analysis
# - Post-hoc analysis with Tukey HSD and Bonferroni correction
# - Variance homogeneity tests (Levene and Bartlett tests)
module ANOVAStats
  include OneWayAnova
  include TwoWayAnova
  include AnovaHelpers
end
