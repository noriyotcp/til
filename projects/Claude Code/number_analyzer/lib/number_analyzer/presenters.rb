# frozen_string_literal: true

# Presenters module for statistical test output formatting
module NumberAnalyzer::Presenters
end

# Load all presenter classes
require_relative 'presenters/base_statistical_presenter'
require_relative 'presenters/levene_test_presenter'
require_relative 'presenters/bartlett_test_presenter'
require_relative 'presenters/kruskal_wallis_test_presenter'
require_relative 'presenters/mann_whitney_test_presenter'
require_relative 'presenters/wilcoxon_test_presenter'
require_relative 'presenters/friedman_test_presenter'
