# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NumberAnalyzer is a comprehensive statistical analysis tool built in Ruby. Originally started as a refactoring exercise from beginner-level code to professional Ruby Gem, it has evolved into an enterprise-ready statistical analysis library with data visualization capabilities.

**Current Status**: ✅ **Production Ready** - 33 statistical functions, 140+ test examples, CLI Modularization Phase 1 **COMPLETE** + CLI Refactoring Phase 1-2 **COMPLETE** + **Phase 9 CLI Ultimate Optimization COMPLETE** with Command Pattern architecture (29/29 commands migrated) and fully modular architecture (8 modules extracted + 6 CLI modules), 96.1%+ code reduction achieved + CLI 95.1% reduction (2094→102 lines), **100% RuboCop compliance**, enterprise-level code quality with TDD methodology, intelligent error handling and performance optimization, English error messages for international accessibility

## Development Commands

**Ruby Execution**:
- `bundle exec number_analyzer` (help display - modern CLI behavior)
- `bundle exec number_analyzer --help` (general help)
- `bundle exec number_analyzer help` (help command)
- `bundle exec number_analyzer help <command>` (specific command help)
- `bundle exec number_analyzer mean 1 2 3 4 5` (specific analysis with data)
- `bundle exec number_analyzer median --file data.csv` (file input analysis)

**Basic Subcommands** (Phase 6.1):
- `bundle exec number_analyzer median 1 2 3 4 5` (central tendency)
- `bundle exec number_analyzer histogram --file data.csv` (visualization)
- `bundle exec number_analyzer mean 10 20 30` (basic statistics)
- Basic commands: `median`, `mean`, `mode`, `sum`, `min`, `max`, `histogram`

**Advanced Subcommands** (Phase 6.2):
- `bundle exec number_analyzer outliers 1 2 3 100` (outlier detection)
- `bundle exec number_analyzer percentile 75 1 2 3 4 5` (parameterized statistics)
- `bundle exec number_analyzer quartiles 1 2 3 4 5` (detailed analysis)
- Advanced commands: `outliers`, `percentile`, `quartiles`, `variance`, `std`, `deviation-scores`

**Output Format & Options** (Phase 6.3):
- `bundle exec number_analyzer median --format=json 1 2 3` (JSON output)
- `bundle exec number_analyzer mean --precision=2 1.234 2.567` (precision control)
- `bundle exec number_analyzer outliers --quiet 1 2 3 100` (script-friendly output)
- `bundle exec number_analyzer variance --help` (command help)
- All 29 subcommands support: `--format`, `--precision`, `--quiet`, `--help`, `--file`

**Correlation Analysis** (Phase 7.1):
- `bundle exec number_analyzer correlation 1 2 3 2 4 6` (Pearson correlation)
- `bundle exec number_analyzer correlation --format=json 1 2 3 2 4 6` (JSON output)
- `bundle exec number_analyzer correlation file1.csv file2.csv` (file input)

**Time Series Analysis** (Phase 7.2):
- `bundle exec number_analyzer trend 1 2 3 4 5` (linear trend analysis)
- `bundle exec number_analyzer trend --format=json --file sales.csv` (JSON output)
- `bundle exec number_analyzer trend --precision=2 1.1 2.3 3.2 4.8` (precision control)
- `bundle exec number_analyzer moving-average 1 2 3 4 5 6 7` (3-period moving average)
- `bundle exec number_analyzer moving-average --window=5 --file sales.csv` (5-period moving average)
- `bundle exec number_analyzer moving-average --format=json --window=7 1 2 3 4 5 6 7 8 9` (JSON output)
- `bundle exec number_analyzer growth-rate 100 110 121 133` (growth rate analysis)
- `bundle exec number_analyzer growth-rate --format=json --file sales.csv` (JSON output)
- `bundle exec number_analyzer growth-rate --precision=1 50 55 60 62` (precision control)
- `bundle exec number_analyzer seasonal 10 20 15 25 12 22 17 27` (seasonal pattern analysis)
- `bundle exec number_analyzer seasonal --format=json --file quarterly.csv` (JSON output)
- `bundle exec number_analyzer seasonal --period=4 --precision=2 sales_data.csv` (manual period specification)

**Statistical Tests** (Phase 7.3):
- `bundle exec number_analyzer t-test group1.csv group2.csv` (independent samples t-test)
- `bundle exec number_analyzer t-test --paired before.csv after.csv` (paired samples t-test)
- `bundle exec number_analyzer t-test --one-sample --population-mean=100 --file data.csv` (one-sample t-test)
- `bundle exec number_analyzer t-test --format=json --precision=3 group1.csv group2.csv` (JSON output)
- `bundle exec number_analyzer confidence-interval 95 1 2 3 4 5` (95% confidence interval for mean)
- `bundle exec number_analyzer confidence-interval --level=90 --file data.csv` (90% confidence interval from file)
- `bundle exec number_analyzer confidence-interval --format=json --precision=2 data.csv` (JSON output with precision)
- `bundle exec number_analyzer chi-square --independence 30 20 -- 15 35` (independence test with 2x2 contingency table)
- `bundle exec number_analyzer chi-square --goodness-of-fit 8 12 10 15 9 6 10 10 10 10 10 10` (goodness-of-fit test with observed/expected)
- `bundle exec number_analyzer chi-square --uniform 8 12 10 15 9 6` (goodness-of-fit test with uniform distribution)
- `bundle exec number_analyzer chi-square --format=json --precision=3 data.csv` (JSON output with precision)

**Analysis of Variance** (Phase 7.4):
- `bundle exec number_analyzer anova 1 2 3 -- 4 5 6 -- 7 8 9` (one-way ANOVA with command-line data)
- `bundle exec number_analyzer anova --file group1.csv group2.csv group3.csv` (one-way ANOVA with file input)
- `bundle exec number_analyzer anova --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9` (JSON output with precision)
- `bundle exec number_analyzer anova --post-hoc=tukey 1 2 3 -- 4 5 6 -- 7 8 9` (ANOVA with Tukey HSD post-hoc test)
- `bundle exec number_analyzer anova --post-hoc=bonferroni 1 2 3 -- 4 5 6 -- 7 8 9` (ANOVA with Bonferroni correction)
- `bundle exec number_analyzer anova --alpha=0.01 --quiet 1 2 3 -- 4 5 6 -- 7 8 9` (custom significance level, quiet output)

**Variance Homogeneity Tests** (Phase 7.5):
- `bundle exec number_analyzer levene 1 2 3 -- 4 5 6 -- 7 8 9` (Levene test for variance homogeneity, Brown-Forsythe modification)
- `bundle exec number_analyzer levene --file group1.csv group2.csv group3.csv` (Levene test with file input)
- `bundle exec number_analyzer levene --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9` (JSON output with precision)
- `bundle exec number_analyzer levene --quiet 1 2 3 -- 4 5 6 -- 7 8 9` (quiet output for scripting)
- `bundle exec number_analyzer bartlett 1 2 3 -- 4 5 6 -- 7 8 9` (Bartlett test for variance homogeneity, assumes normality)
- `bundle exec number_analyzer bartlett --file group1.csv group2.csv group3.csv` (Bartlett test with file input)
- `bundle exec number_analyzer bartlett --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9` (JSON output with precision)
- `bundle exec number_analyzer bartlett --quiet 1 2 3 -- 4 5 6 -- 7 8 9` (quiet output for scripting)

**Non-parametric Tests** (Phase 7.5-7.6):
- `bundle exec number_analyzer kruskal-wallis 1 2 3 -- 4 5 6 -- 7 8 9` (Kruskal-Wallis test for comparing medians, non-parametric ANOVA)
- `bundle exec number_analyzer kruskal-wallis --file group1.csv group2.csv group3.csv` (Kruskal-Wallis test with file input)
- `bundle exec number_analyzer kruskal-wallis --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9` (JSON output with precision)
- `bundle exec number_analyzer kruskal-wallis --quiet 1 2 3 -- 4 5 6 -- 7 8 9` (quiet output for scripting)
- `bundle exec number_analyzer mann-whitney 1 2 3 -- 4 5 6` (Mann-Whitney U test for comparing two groups, non-parametric t-test)
- `bundle exec number_analyzer mann-whitney --file group1.csv group2.csv` (Mann-Whitney test with file input)
- `bundle exec number_analyzer mann-whitney --format=json --precision=3 1 2 3 -- 6 7 8` (JSON output with precision)
- `bundle exec number_analyzer mann-whitney --quiet 10 20 30 -- 40 50 60` (quiet output for scripting)
- `bundle exec number_analyzer wilcoxon 10 12 14 -- 15 18 20` (Wilcoxon signed-rank test for paired samples)
- `bundle exec number_analyzer wilcoxon before.csv after.csv` (Wilcoxon test with file input)
- `bundle exec number_analyzer wilcoxon --format=json --precision=3 1 2 3 -- 4 5 6` (JSON output with precision)
- `bundle exec number_analyzer friedman 1 2 3 -- 4 5 6 -- 7 8 9` (Friedman test for repeated measures across multiple conditions)
- `bundle exec number_analyzer friedman condition1.csv condition2.csv condition3.csv` (Friedman test with file input)
- `bundle exec number_analyzer friedman --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9` (JSON output with precision)
- `bundle exec number_analyzer two-way-anova --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 10,12,20,22` (two-way ANOVA with factorial design)
- `bundle exec number_analyzer two-way-anova --file factorial_data.csv` (two-way ANOVA with CSV file input)
- `bundle exec number_analyzer two-way-anova --format=json --precision=3 --factor-a Drug,Drug,Placebo,Placebo --factor-b Male,Female,Male,Female 5.2,7.1,3.8,4.5` (JSON output with precision)

## CLI Entry Points

**Production Entry Point** (`bin/number_analyzer`):
- **Purpose**: Main CLI command for production and distribution use
- **Usage**: `bundle exec number_analyzer [command] [args]`
- **Characteristics**: 
  - Contains shebang (`#!/usr/bin/env ruby`) for direct execution
  - Always executes CLI when invoked
  - Official entry point for gem users
  - Used by bundler when running `bundle exec number_analyzer`

**Development Entry Point** (`lib/number_analyzer/cli.rb`):
- **Purpose**: Development and testing convenience
- **Usage**: `ruby lib/number_analyzer/cli.rb [command] [args]`
- **Characteristics**:
  - Conditional execution with `if __FILE__ == $PROGRAM_NAME`
  - Only executes when run directly, not when required as library
  - Useful for development debugging and testing
  - Maintains library functionality when required by other code

**Key Distinction**: The production entry point is designed for end-users and gem distribution, while the development entry point provides convenience for developers working on the codebase directly.

**Development Tools**:
- `bundle install` - Install dependencies
- `rspec` - Run test suite (140+ comprehensive tests including TDD-based command tests)
- `bundle exec rubocop` - Code style checking (**✅ ZERO VIOLATIONS ACHIEVED**)
- `bundle exec rubocop -a` - Auto-fix style violations (run first)
- `bundle exec rubocop [file]` - Check specific file
- `/project:commit-message` - Generate commit messages **ONLY** (no auto-commit)
- `/project:gemini-search` - Web search integration

**Plugin System Development (Phase 8.0)**:
- `rspec spec/plugin_system_spec.rb` - Test plugin system core (14 tests)
- `rspec spec/cli_plugin_integration_spec.rb` - Test CLI plugin integration (7 tests)  
- `rspec spec/plugin_interface_spec.rb` - Test plugin interfaces (24 tests)
- `rspec spec/plugin_namespace_spec.rb` - Test namespace management system (26 tests)
- `rspec spec/plugin_priority_spec.rb` - Test priority system with sorting (18 tests)
- `rspec spec/plugin_conflict_resolver_spec.rb` - Test conflict resolution (43 tests)
- Plugin configuration: `plugins.yml` - YAML-based plugin management

**Plugin Conflict Management (Phase 8.0 Step 5)** ✅ 完了:
- `bundle exec number_analyzer plugins list` - プラグイン一覧表示
- `bundle exec number_analyzer plugins list --show-conflicts` - プラグイン一覧と重複表示
- `bundle exec number_analyzer plugins conflicts` または `bundle exec number_analyzer plugins --conflicts` - 重複検出と表示
- `bundle exec number_analyzer plugins resolve <plugin> --strategy=interactive` - インタラクティブ重複解決
- `bundle exec number_analyzer plugins resolve <plugin> --strategy=namespace` - 名前空間による解決
- `bundle exec number_analyzer plugins resolve <plugin> --strategy=priority` - 優先度による解決
- `bundle exec number_analyzer plugins resolve <plugin> --strategy=disable` - プラグイン無効化
- `bundle exec number_analyzer --dev-mode <command>` - 開発モード（全上書き許可）
- Plugin configuration: `plugins.yml` - プラグイン設定管理
- Plugin priority system: Development(100) > Core(90) > Official(70) > ThirdParty(50) > Local(30)

**Git Command Usage**:
- `/commit-message` = Message generation only (no commit execution)
- Explicit user request like "commit", "コミット", "コミットして" = Actual commit
- Settings prohibit auto-commits for stability

## Current Architecture

**Enhanced Ruby Gem Structure** with modular architecture + Command Pattern + TDD Refactoring:

```
lib/
├── number_analyzer.rb              # Core integration (68 lines) - 96.1% reduction achieved
└── number_analyzer/
    ├── cli.rb                      # Ultra-lightweight CLI orchestrator (2094→102 lines, 95.1% reduction achieved)
    ├── cli/                        # CLI Modular Architecture ✅ Phase 1 Complete + Phase 9 Ultimate Optimization + Command Pattern + TDD
    │   ├── options.rb              # Option parsing system (243 lines)
    │   ├── help_generator.rb       # Dynamic help generation (155 lines)
    │   ├── input_processor.rb      # Unified input processing (160 lines)
    │   ├── error_handler.rb        # Intelligent error handling with Levenshtein distance suggestions (124 lines)
    │   ├── command_cache.rb        # Performance optimization with 60-second TTL caching (73 lines)
    │   ├── plugin_router.rb        # Smart command routing with conflict resolution (112 lines)
    │   ├── base_command.rb         # Template Method Pattern base class
    │   ├── command_registry.rb     # Command registration and management
    │   ├── commands.rb             # Auto-loader for all command classes  
    │   ├── data_input_handler.rb   # Unified file/CLI input processing
    │   ├── t_test_input_handler.rb   # TDD-refactored t-test input processing
    │   ├── t_test_output_formatter.rb # TDD-refactored output formatting
    │   ├── t_test_help_constants.rb   # Externalized help text
    │   ├── chi_square_input_handler.rb # Strategy Pattern input processing
    │   ├── chi_square_validator.rb     # Extracted validation logic
    │   ├── statistical_output_formatter.rb # Enhanced statistical formatting
    │   └── commands/               # Individual command implementations (29/29 migrated)
    │       ├── median_command.rb   # 50-80 lines each vs 2185-line monolith
    │       ├── mean_command.rb     # Independent testability & maintainability
    │       ├── mode_command.rb     # TDD implementation, zero RuboCop violations
    │       ├── sum_command.rb      # Consistent error handling & validation
    │       ├── min_command.rb      # Full backward compatibility maintained
    │       ├── max_command.rb      # JSON/precision/quiet/help options support
    │       ├── histogram_command.rb
    │       ├── outliers_command.rb
    │       ├── percentile_command.rb
    │       ├── quartiles_command.rb
    │       ├── variance_command.rb
    │       ├── std_command.rb
    │       ├── deviation_scores_command.rb
    │       ├── t_test_command.rb   # 222→138 lines (38% reduction via TDD refactoring)
    │       └── chi_square_command.rb # 275→204 lines (26% reduction via Strategy Pattern)
    ├── file_reader.rb              # File input handling
    ├── statistics_presenter.rb     # Output formatting
    ├── output_formatter.rb         # Advanced output formatting
    ├── plugin_system.rb            # Plugin System Core (Phase 8.0 Step 1)
    ├── plugin_interface.rb         # Plugin base classes & interfaces
    ├── plugin_loader.rb            # Plugin discovery & auto-loading
    ├── plugin_priority.rb          # Priority management with sorting (Phase 8.0 Step 5)
    ├── plugin_namespace.rb         # Namespace generation & conflict resolution (Phase 8.0 Step 5)
    ├── plugin_conflict_resolver.rb # 6-strategy conflict resolution system
    └── statistics/                 # Complete Modular Architecture (8 modules)
        ├── basic_stats.rb          # BasicStats module (sum, mean, mode, variance, std_dev)
        ├── math_utils.rb           # MathUtils module (mathematical functions)
        ├── advanced_stats.rb       # AdvancedStats module (percentiles, quartiles, outliers)
        ├── correlation_stats.rb    # CorrelationStats module (correlation analysis)
        ├── time_series_stats.rb    # TimeSeriesStats module (time series analysis)
        ├── hypothesis_testing.rb   # HypothesisTesting module (t-test, confidence intervals, chi-square)
        ├── anova_stats.rb          # ANOVAStats module (one-way/two-way ANOVA, post-hoc tests)
        └── non_parametric_stats.rb # NonParametricStats module (non-parametric tests)
```

**Key Classes**:
- **NumberAnalyzer**: Core integration class (68 lines) + 8 modular components
- **BasicStats**: Basic statistics (sum, mean, mode, variance, standard_deviation)
- **MathUtils**: Mathematical utility functions (standard_normal_cdf, erf, t_distribution_cdf, f_distribution_p_value)
- **AdvancedStats**: Advanced analysis (percentile, quartiles, interquartile_range, outliers, deviation_scores)
- **CorrelationStats**: Correlation analysis (correlation, interpret_correlation)
- **TimeSeriesStats**: Time series analysis (linear_trend, moving_average, growth_rates, seasonal_decomposition)
- **HypothesisTesting**: Statistical tests (t_test, confidence_interval, chi_square_test)
- **ANOVAStats**: Variance analysis (one_way_anova, two_way_anova, post_hoc_analysis, levene_test, bartlett_test)
- **NonParametricStats**: Non-parametric tests (kruskal_wallis_test, mann_whitney_u_test, wilcoxon_signed_rank_test, friedman_test)
- **NumberAnalyzer::CLI**: Ultra-lightweight command orchestrator (reduced from 2094 to 102 lines, 95.1% reduction)
- **NumberAnalyzer::CLI::Options**: Option parsing system (243 lines) - comprehensive CLI argument handling
- **NumberAnalyzer::CLI::HelpGenerator**: Dynamic help generation (155 lines) - command descriptions and usage
- **NumberAnalyzer::CLI::InputProcessor**: Input processing (160 lines) - unified file/CLI input handling
- **NumberAnalyzer::CLI::ErrorHandler**: Intelligent error handling (124 lines) - Levenshtein distance-based command suggestions
- **NumberAnalyzer::CLI::CommandCache**: Performance optimization (73 lines) - 60-second TTL caching system
- **NumberAnalyzer::CLI::PluginRouter**: Smart command routing (112 lines) - unified routing with conflict resolution
- **NumberAnalyzer::Commands::BaseCommand**: Template Method Pattern base class for all commands
- **NumberAnalyzer::Commands::CommandRegistry**: Command registration and discovery system
- **NumberAnalyzer::Commands::DataInputHandler**: Unified file/CLI input processing
- **NumberAnalyzer::Commands::[Command]**: Individual command classes (29 fully migrated: all statistical commands, time series, ANOVA, non-parametric tests, plugin management)
- **NumberAnalyzer::FileReader**: CSV/JSON/TXT file input
- **NumberAnalyzer::StatisticsPresenter**: Output formatting and histogram display
- **NumberAnalyzer::PluginSystem**: Plugin registration, loading, and management (Phase 8.0 Step 1)
- **NumberAnalyzer::PluginLoader**: Plugin discovery and auto-loading utilities
- **NumberAnalyzer::PluginPriority**: 5-tier priority management with sorting capabilities
- **NumberAnalyzer::PluginNamespace**: Automatic namespace generation and conflict detection
- **NumberAnalyzer::PluginConflictResolver**: 6-strategy conflict resolution system
- **NumberAnalyzer::StatisticsPlugin**: Base module for statistics plugins
- **NumberAnalyzer::CLIPlugin**: Base class for CLI command plugins
- **NumberAnalyzer::OutputFormatter**: Advanced output formatting (JSON, precision, quiet mode)

## Implemented Features

**Statistical Functions (33+)**:
- **Basic Statistics**: sum, mean, min, max, median, mode, variance, standard deviation, IQR
- **Advanced Analysis**: percentiles, quartiles, outliers, deviation scores  
- **Correlation Analysis**: Pearson correlation coefficient with interpretation
- **Time Series Analysis**: linear trend analysis (slope, intercept, R², direction), moving averages with customizable windows, growth rate analysis (period-over-period, CAGR, average growth rate), seasonal pattern analysis (decomposition, period detection, seasonal strength)
- **Hypothesis Testing**: independent samples t-test (Welch's t-test), paired samples t-test, one-sample t-test with p-value and significance testing, confidence intervals for population mean (t-distribution and normal approximation), chi-square test for independence and goodness-of-fit with Cramér's V effect size
- **Analysis of Variance**: one-way ANOVA and **two-way ANOVA** with F-statistic, p-value calculation, effect size measures (η², ω², partial η²), statistical interpretation, comprehensive ANOVA table output, **main effects and interaction analysis**, post-hoc tests (Tukey HSD, Bonferroni correction) for multiple pairwise comparisons
- **Variance Homogeneity Tests**: Levene test with Brown-Forsythe modification for robust variance equality testing, Bartlett test for high-precision variance equality testing under normality assumptions, ANOVA prerequisite checking, outlier-resistant analysis
- **Non-parametric Tests**: Kruskal-Wallis test (non-parametric ANOVA), Mann-Whitney U test (non-parametric t-test), Wilcoxon signed-rank test (paired non-parametric), Friedman test (repeated measures non-parametric ANOVA)
- **Data Visualization**: frequency distribution, ASCII histogram

**Input Support**: CLI arguments, CSV/JSON/TXT files (both full analysis and all subcommands)
**Output**: Comprehensive analysis OR individual statistics + visualization
**CLI Modes**: Full analysis (default) OR 29 individual subcommands (comprehensive statistical analysis suite)
**Subcommand Categories**: Basic statistics, advanced analysis, parameterized commands, correlation analysis, time series analysis, statistical inference, analysis of variance (one-way & two-way), variance homogeneity tests, non-parametric tests
**Output Options (Phase 6.3)**: JSON format, precision control, quiet mode, help system
**Correlation Analysis (Phase 7.1)**: Dual dataset input, mathematical interpretation, file/numeric support
**Time Series Analysis (Phase 7.2)**: Linear trend analysis, moving averages with customizable window sizes, growth rate analysis with CAGR calculation, seasonal pattern analysis with automatic period detection
**Statistical Tests (Phase 7.3)**: T-test analysis with all three types (independent, paired, one-sample), confidence intervals for population mean using t-distribution, chi-square test for independence and goodness-of-fit with categorical data analysis, mathematical accuracy with Welch's formula and chi-square distribution, two-tailed p-values and significance interpretation
**Analysis of Variance (Phase 7.4)**: One-way ANOVA with F-distribution p-value calculation, comprehensive effect size analysis (eta squared and omega squared), statistical interpretation with significance testing, detailed ANOVA table output with sum of squares decomposition, and post-hoc multiple comparison tests (Tukey HSD and Bonferroni correction) for pairwise group analysis
**Variance Homogeneity Tests (Phase 7.5)**: Levene test with Brown-Forsythe modification using median-based calculations for robust variance equality testing, Bartlett test with chi-square distribution for high-precision variance equality testing under normality assumptions, ANOVA prerequisite checking with F-distribution and chi-square p-values, outlier-resistant statistical analysis, and comprehensive CLI integration with all standard output options

## Code Quality Standards

**Architecture Principles**:
- **Single Responsibility Principle**: Each class has one clear purpose
- **Clean Dependencies**: `bin → CLI → NumberAnalyzer ← StatisticsPresenter`
- **Ruby Idioms**: Effective use of `sum`, `tally`, `sort`, endless methods
- **TDD Practice**: Red-Green-Refactor cycle for all new features

**Code Quality Enforcement (ZERO TOLERANCE)**:
- **✅ RuboCop Compliance Achieved**: 100% zero violations across entire codebase (116 files)
- **TDD Methodology**: Test-Driven Development with Red-Green-Refactor cycle mandatory
- **Style Consistency**: All code must conform to project's .rubocop.yml configuration
- **Auto-correction First**: Always apply `bundle exec rubocop -a` before manual fixes
- **Configuration Changes**: RuboCop config modifications require documentation update
- **Compact Style Mandatory**: All classes/modules must use compact style (`NumberAnalyzer::ClassName`)

**Compact Style Standards** (MANDATORY - Project Standard):
- **Namespace Declaration**: Use compact style for all new classes/modules
- **Reference Resolution**: Always use fully qualified names (`NumberAnalyzer::CLI`, not `CLI`)
- **Consistency Enforcement**: RuboCop Style/ClassAndModuleChildren set to `EnforcedStyle: compact`
- **Migration Completed**: 100+ files successfully converted to compact style (January 2025)

```ruby
# ✅ Correct - Compact style (MANDATORY)
class NumberAnalyzer::CLI
  def self.run
    NumberAnalyzer::PluginSystem.new
  end
end

# ❌ Incorrect - Nested style (FORBIDDEN)
module NumberAnalyzer
  class CLI
    def self.run
      PluginSystem.new  # Also wrong - unqualified reference
    end
  end
end
```

**Ruby Naming Conventions** (MANDATORY - Consistency Policy):
- **Getter Methods**: Must match instance variable names exactly
- **Collections**: Use plural names for arrays/hashes containing multiple items
- **Consistency**: Maintain alignment between `@instance_variable` and `def method_name`
- **attr_reader Pattern**: Follow standard Ruby accessor patterns

```ruby
# ✅ Correct - Consistent naming
@namespace_mappings = {}
def namespace_mappings
  @namespace_mappings.dup
end

# ❌ Incorrect - Inconsistent naming  
@namespace_mappings = {}
def namespace_mapping  # Don't mix singular/plural
  @namespace_mappings.dup
end
```

**External References**:
- [Ruby Style Guide (GitHub)](https://github.com/rubocop/ruby-style-guide)
- [Ruby & Rails Naming Conventions](https://gist.github.com/alexpchin/f5d2be2ef3735889d315)
- [Stack Overflow - Hash Naming](https://stackoverflow.com/questions/27667460/good-explicit-naming-style-for-hash-in-ruby-and-other-languages)
- [RubyGuides - attr_accessor](https://www.rubyguides.com/2018/11/attr_accessor/)
- [Shopify Ruby Style Guide](https://ruby-style-guide.shopify.dev/)

**Quality Checklist** (MANDATORY - Zero Tolerance Policy):
1. **RuboCop compliance** - REQUIRED: `bundle exec rubocop` must show zero violations
2. **Auto-correction applied** - REQUIRED: `bundle exec rubocop -a` before manual review
3. **Naming conventions** - REQUIRED: Follow Ruby naming conventions (getter methods match instance variables)
4. **Test coverage** - All new features require comprehensive tests
5. **Documentation updates** - REQUIRED: Update ALL relevant docs (see Documentation Update Checklist below)
6. **Mathematical accuracy** - Verify statistical correctness

### Documentation Update Checklist (MANDATORY - 責務分離対応)
**新機能実装時の必須ドキュメント更新**:

**Primary Documentation Updates** (責務別):
- ✅ **[ai-docs/ROADMAP.md](ai-docs/ROADMAP.md)** - **必須**: Phase状況更新 + 達成メトリクス + テスト数・行数記録
- ✅ **[README.md](README.md)** - **必須**: ユーザー向け機能説明 + 基本的なCLI例
- ✅ **CLAUDE.md** - **条件付き**: 新CLI機能時のみコマンド例追加

**責務分離による更新ルール**:
- **プロジェクト管理情報** → ROADMAP.mdに集約（Phase状況、メトリクス、詳細履歴）
- **開発ガイダンス** → CLAUDE.mdに集約（品質基準、ワークフロー、コマンド例）
- **ユーザー情報** → README.mdに集約（機能使用法、API参考）

**Documentation Verification Process**:
```bash
# 実装完了前の必須確認:
1. ai-docs/ROADMAP.md - Phase status + metrics updated
2. README.md - user-facing features documented  
3. CLAUDE.md - development commands (新CLI機能のみ)
4. All examples tested and working
```

**Completion Redefinition** (責務分離版):
- ✅ **COMPLETE** = Code + Tests + **ROADMAP.md更新** + README.md更新 + RuboCop compliance
- ❌ **INCOMPLETE** = Working code without ROADMAP.md status update

## Development Guidelines

### Mandatory RuboCop Workflow (REQUIRED FOR ALL CHANGES)

#### Automated RuboCop Execution via Hooks
**RuboCop は Claude Code の Hooks 機能により自動実行されます**:
- Ruby ファイル (*.rb) 編集時に自動的に実行
- `bundle exec rubocop -a` で自動修正を適用
- その後 `bundle exec rubocop` で検証を実行
- 設定ファイル: `.claude/settings.local.json` の hooks セクション

**Pre-Development Check**:
```bash
bundle exec rubocop  # Must show zero violations before starting
```

**During Development** (after each change):
```bash
# Ruby ファイル編集時は Hooks により自動実行されます
# 手動実行が必要な場合:
bundle exec rubocop          # Check violations
bundle exec rubocop -a       # Auto-fix correctable issues
bundle exec rubocop          # Verify zero violations
rspec                        # Ensure tests pass
```

**Pre-Commit Gate** (MANDATORY):
```bash
bundle exec rubocop          # MUST be zero violations
rspec                        # MUST be all tests passing
# Documentation Verification (REQUIRED):
git status                   # Verify documentation files staged for commit
git diff --name-only --cached | grep -E "(README|ROADMAP|CLAUDE)\.md" || echo "⚠️  MISSING: Documentation updates not staged"
```

### New Feature Implementation (MANDATORY PROCESS)

**重要**: 実装とドキュメント更新は一体のプロセスです。コード動作確認だけでは「未完了」です。

### CLI Refactoring Phase 2 実装時の注意

**重要**: 新しいコマンドを Command Pattern で実装する際は、以下を確認してください：

1. **CommandRegistry への登録** - `commands.rb` でコマンドクラスを登録
2. **CORE_COMMANDS からの削除** - 重複を避けるため古い定義を削除
3. **CLI統合テスト** - 実際のCLI経由での動作確認が必須
4. **特殊な引数処理** - `--` 区切りや複数ファイル入力の場合は CLI.rb の修正も必要

詳細なトラブルシューティングガイドは `ai-docs/CLI_REFACTORING_GUIDE.md` を参照してください。

#### 実装開始時の必須TODO作成
```bash
# 新機能実装時は必ずこの5つのTodoを作成:
1. Core implementation (コアメソッド実装)
2. CLI integration (CLIサブコマンド追加)  
3. Test suite creation (包括的テストスイート)
4. Documentation updates (README + ROADMAP + examples)
5. RuboCop compliance + commit (コンプライアンス確認とコミット)
```

#### 実装順序 (MANDATORY)
1. **Plan** - `TodoWrite`で5つの必須項目作成
2. **TDD** - Write failing tests first
3. **Core Implement** - Follow existing patterns and Ruby conventions
4. **📝 即座にドキュメント更新** - README.md features section, ROADMAP.md phase status
5. **CLI Integration** - Add subcommand and CLI examples 
6. **Test Completion** - Ensure all tests pass with comprehensive coverage
7. **RuboCop Gate** - `bundle exec rubocop -a` then verify zero violations
8. **Final Documentation** - Verify all docs updated and staged for commit

#### ドキュメント更新必須ファイル (ALL REQUIRED)
**新機能実装完了の3つの必須ドキュメント更新**:
- ✅ **README.md**: Features section + CLI examples + subcommand count update
- ✅ **ROADMAP.md**: Phase status complete + checkbox [x] updates + achievement numbers  
- ✅ **CLAUDE.md**: Command examples (通常は実装中に既に更新済み)

**ドキュメント更新検証方法**:
```bash
# 実装完了前の必須確認コマンド:
# 実装で変更したファイルのみをステージング:
git add [変更したファイル]       # 例: git add lib/number_analyzer.rb lib/number_analyzer/statistics/new_module.rb
git add README.md ai-docs/ROADMAP.md CLAUDE.md  # ドキュメント更新
git status                   # README.md, ROADMAP.md, CLAUDE.md が含まれているか確認
# 以下のファイルが全て "to be committed" に含まれていることを確認:
# - README.md (new functionality documented)
# - ROADMAP.md (phase status updated)  
# - CLAUDE.md (command examples updated, if applicable)
```

#### 完了基準の再定義 (Zero Documentation Debt Policy)
- ✅ **完了** = Code + Tests + **All 3 Documentation Files Updated** + RuboCop compliance
- ❌ **未完了** = 動くけどドキュメント未更新の状態
- 🚨 **禁止**: 「後でドキュメント更新します」は認めない - 実装と同時に更新必須

### File Organization
- **Core logic**: `lib/number_analyzer.rb`
- **CLI changes**: `lib/number_analyzer/cli.rb`
- **New input formats**: `lib/number_analyzer/file_reader.rb`
- **Output changes**: `lib/number_analyzer/statistics_presenter.rb`
- **Tests**: Mirror structure in `spec/`

### Testing Strategy
- **Unit tests**: Test each method in isolation
- **Integration tests**: Test CLI workflows end-to-end
- **Edge cases**: Empty arrays, single values, extreme inputs
- **TDD cycle**: Red (failing test) → Green (minimal implementation) → Refactor

### CLI.rb Optimization Guidelines

**目標**: CLI.rb を138行から100行以下に削減しつつ、機能性と保守性を向上させる（Phase 1として385行→138行を達成済み）

#### モジュール分離の原則
1. **単一責任の原則**: 各モジュールは1つの明確な責任を持つ
2. **依存関係の明確化**: モジュール間の依存は最小限に
3. **テスタビリティ**: 各モジュールは独立してテスト可能

#### 推奨モジュール構造
```ruby
lib/number_analyzer/
├── cli.rb                    # < 100行のオーケストレーター
├── cli/
│   ├── options.rb           # オプション解析専用
│   ├── help_generator.rb    # ヘルプ生成
│   ├── input_processor.rb   # 入力処理統合
│   ├── error_handler.rb     # 高度なエラー処理
│   ├── command_cache.rb     # コマンドキャッシング
│   ├── plugin_priority.rb   # プラグイン優先度管理
│   ├── debug.rb            # デバッグ機能
│   ├── completion.rb       # シェル補完
│   ├── hooks.rb            # プラグインフック
│   └── configuration.rb    # 設定ファイル管理
```

#### 実装時の注意事項
1. **後方互換性の維持**: 既存のCLIインターフェースを保持
2. **段階的移行**: 一度に全てを変更せず、段階的に移行
3. **パフォーマンス考慮**: 遅延ロードとキャッシングを活用
4. **エラーメッセージの質**: ユーザーフレンドリーなメッセージと回復提案

#### プラグイン優先度管理
- **Core Commands**: 優先度 100（最高）
- **Official Plugins**: 優先度 80
- **Community Plugins**: 優先度 60
- **Local Plugins**: 優先度 40

競合時は優先度の高いコマンドが実行される。同一優先度の場合は名前空間プレフィックスで区別。

#### エラーハンドリングベストプラクティス
1. **コンテキスト情報の提供**: エラー発生時の状況を明確に
2. **回復可能性の提示**: 可能な場合は修正方法を提案
3. **対話的回復**: TTY環境では対話的に問題解決を支援
4. **ログ出力**: デバッグモードでは詳細なログを出力

**詳細な実装提案**: [ai-docs/CLI_IMPROVEMENT_PROPOSALS.md](ai-docs/CLI_IMPROVEMENT_PROPOSALS.md) 参照

## Important Reminders

- **RuboCop compliance**: MANDATORY `bundle exec rubocop` with zero violations before any commit
- **Auto-correction workflow**: Always run `bundle exec rubocop -a` first, then manual review
- **Commit messages**: Use `/project:commit-message` to generate messages ONLY - DO NOT auto-commit
- **Manual commits**: Only commit when user explicitly requests "commit" or "コミット"
- **Documentation**: **MANDATORY** - Update README.md features/usage AND ROADMAP.md phase status immediately after implementation. Never leave code changes without documentation updates. Follow Documentation Update Checklist above.
- **RSpec syntax**: Use `-e "pattern"` for test filtering
- **Mathematical precision**: Consider floating-point accuracy in tests
- **Japanese output**: Maintain Japanese labels for user-facing output

## Git Workflow Guidelines

**IMPORTANT: Commit Control**
- `/project:commit-message` or `/commit-message` = **Generate commit message ONLY**
- **NEVER auto-commit** unless user explicitly says "commit", "コミット", or "コミットして"
- Settings prohibit `git commit` commands for stability
- User must manually run `git commit` with generated message

## Project Status

**Current Development State**: Phase 8.0 Step 5 完了 + CLI Modularization Phase 1 完了 + CLI Refactoring Phase 2 完了 - プラグインシステム + 全29コマンド移行完了 + CLI完全モジュール化 - 詳細な開発履歴は [ai-docs/ROADMAP.md](ai-docs/ROADMAP.md) を参照

**Architecture Overview**: 完全モジュラー化達成（8統計モジュール構成、96.1%コード削減）+ CLI完全モジュール化達成（2094→138行、93%削減 + 3専門モジュール558行）+ 高度プラグインシステム（依存関係検証、エラーハンドリング強化、自動CLI統合）+ Command Pattern完全移行

## Phase 8.0 Development Status

### Phase 8.0 Step 1: Plugin System Foundation ✅ 完了

**基盤インフラストラクチャの実装完了**

- ✅ Plugin System Core (PluginSystem, PluginInterface, PluginLoader)  
- ✅ Dynamic Command Loading infrastructure
- ✅ Configuration Framework (plugins.yml)
- ✅ 45 comprehensive tests (plugin system foundation)
- ✅ Full backward compatibility (29 existing commands)

### Phase 8.0 Step 2: Basic Plugin Implementation ✅ 完了

**実働プラグイン実装の完全実現**

- ✅ 3つの実働プラグイン実装 (BasicStats, AdvancedStats, MathUtils)
- ✅ 自動CLI統合 (プラグインロード時の動的コマンド登録)
- ✅ プラグイン間依存関係管理 (AdvancedStats → BasicStats)
- ✅ 137テスト (統合最適化により効率化)
- ✅ 100%後方互換性維持
- ✅ ゼロRuboCop違反

### Phase 8.0 Step 3: Advanced Plugin Features ✅ 完了

**高度プラグイン機能の実現**

- ✅ 依存関係検証システム (DependencyResolver)
  - ✅ 循環依存検出 (TSort による位相ソート)
  - ✅ バージョン互換性検証 (~>, >=, >, <=, <, = 演算子対応)
  - ✅ 複雑な依存関係ツリー解決
- ✅ エラーハンドリング強化 (PluginErrorHandler)
  - ✅ 5つの回復戦略 (retry, fallback, disable, fail_fast, log_continue)
  - ✅ 指数バックオフによるリトライ機能
  - ✅ プラグインヘルス監視・統計
- ✅ 163テスト (26+29+18 新規テスト追加)
- ✅ エンタープライズ品質保証
- ✅ ゼロRuboCop違反

### Phase 8.0 Remaining Steps

**次のステップ**: Steps 3-5 実装 - 詳細計画は [ai-docs/PHASE_8_PLUGIN_SYSTEM_PLAN.md](ai-docs/PHASE_8_PLUGIN_SYSTEM_PLAN.md) を参照

### Phase 8.0 Features (計画)
- **Dynamic Command Loading**: 統計機能の動的ロード機能
- **Third-party Extension Support**: サードパーティ拡張機能対応
- **Configuration-based Plugin Management**: 設定ファイルによるプラグイン管理
- **Modular Architecture**: 完全モジュラー設計による拡張性

### Integration Possibilities
- **Web API Endpoints**: RESTful API提供機能

### Implementation Strategy
1. **Plugin Architecture Design**: プラグインシステムの設計
2. **Extension Point Definition**: 拡張ポイントの定義
3. **Configuration System**: プラグイン設定システム
4. **Compatibility Layer**: 既存機能との互換性保持


## Quick Reference

**Current State**: ✅ Phase 8.0 Step 5 完了 + CLI Modularization Phase 1 完了 + CLI Refactoring Phase 2 完了 + **Phase 9 CLI Ultimate Optimization 完了** - 全29コマンド移行済み + CLI完全モジュール化 + 智能エラー処理・パフォーマンス最適化 - 詳細は [ai-docs/ROADMAP.md](ai-docs/ROADMAP.md) を参照  
**Architecture**: 8 statistical modules + 6 CLI modules + comprehensive plugin infrastructure + CLI Command Pattern architecture, 96.1% code reduction achieved + CLI 95.1% reduction (2094→102 lines + 867 module lines)  
**Commands**: 29 core subcommands + 19 plugin commands, unified CommandRegistry architecture  
**Quality**: Zero RuboCop violations, comprehensive test suite (RSpec TypeError解決済み, Here Document改善10+箇所)  
**Achievement**: CLI Modularization Phase 1 + CLI Refactoring Phase 2 + **Phase 9 CLI Ultimate Optimization** **COMPLETE** - 全29コマンドのCommand Pattern移行完了 + CLI完全モジュール化達成（単一責任原則による6専門モジュール分離）+ 智能エラー処理・パフォーマンス最適化・スマートルーティング実装

## Documentation Structure

### Primary Documentation (責務分離)
- **CLAUDE.md** (this file): **開発ガイダンス特化** - Claude Code向けコマンド例、品質基準、ワークフロー
- **[ai-docs/ROADMAP.md](ai-docs/ROADMAP.md)**: **プロジェクト管理の単一情報源** - Phase履歴、メトリクス、次フェーズ計画
- **[README.md](README.md)**: ユーザー向けドキュメント、API参考

### Secondary Documentation  
- **[ai-docs/FEATURES.md](ai-docs/FEATURES.md)**: 機能の包括的ドキュメント
- **[ai-docs/ARCHITECTURE.md](ai-docs/ARCHITECTURE.md)**: 技術アーキテクチャ詳細
- **[ai-docs/REFACTORING_PLAN.md](ai-docs/REFACTORING_PLAN.md)**: Phase 7.7 基盤リファクタリング詳細計画

### 情報アクセスガイド
- **開発状況確認** → [ai-docs/ROADMAP.md](ai-docs/ROADMAP.md)
- **開発手順・品質基準** → CLAUDE.md (this file)
- **機能使用方法** → [README.md](README.md)