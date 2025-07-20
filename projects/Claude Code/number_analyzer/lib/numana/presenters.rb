# frozen_string_literal: true

# Presenters module for statistical test output formatting
module NumberAnalyzer::Presenters
end

# Load all presenter classes
require_relative 'presenters/base_statistical_presenter'
require_relative 'presenters/t_test_presenter'
require_relative 'presenters/anova_presenter'
require_relative 'presenters/two_way_anova_presenter'
require_relative 'presenters/chi_square_presenter'
require_relative 'presenters/post_hoc_presenter'
require_relative 'presenters/levene_test_presenter'
require_relative 'presenters/bartlett_test_presenter'
require_relative 'presenters/kruskal_wallis_test_presenter'
require_relative 'presenters/mann_whitney_test_presenter'
require_relative 'presenters/wilcoxon_test_presenter'
require_relative 'presenters/friedman_test_presenter'
require_relative 'presenters/confidence_interval_presenter'
require_relative 'presenters/correlation_presenter'
require_relative 'presenters/quartiles_presenter'
require_relative 'presenters/mode_presenter'
require_relative 'presenters/outliers_presenter'
require_relative 'presenters/trend_presenter'
require_relative 'presenters/moving_average_presenter'
require_relative 'presenters/growth_rate_presenter'
