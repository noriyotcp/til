# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NumberAnalyzer is a comprehensive statistical analysis tool built in Ruby. Originally started as a refactoring exercise from beginner-level code to professional Ruby Gem, it has evolved into an enterprise-ready statistical analysis library with data visualization capabilities.

**Current Status**: ✅ **Production Ready** - 28 statistical functions, 42+ test examples, Phase 7.4 Step 1 complete with One-way ANOVA analysis, enterprise-level code quality

## Development Commands

**Ruby Execution**:
- `bundle exec number_analyzer` (default dataset - full analysis)
- `bundle exec number_analyzer 1 2 3 4 5` (custom numbers - full analysis)
- `bundle exec number_analyzer --file data.csv` (file input - full analysis)

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
- All 19 subcommands support: `--format`, `--precision`, `--quiet`, `--help`, `--file`

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
- `bundle exec number_analyzer anova --post-hoc=tukey 1 2 3 -- 4 5 6 -- 7 8 9` (ANOVA with post-hoc tests - planned feature)
- `bundle exec number_analyzer anova --alpha=0.01 --quiet 1 2 3 -- 4 5 6 -- 7 8 9` (custom significance level, quiet output)

**Development Tools**:
- `bundle install` - Install dependencies
- `rspec` - Run test suite (42+ examples including 17 t-test + 10 confidence interval + 12 chi-square + ANOVA cases)
- `bundle exec rubocop` - Code style checking (MANDATORY: zero violations)
- `bundle exec rubocop -a` - Auto-fix style violations (run first)
- `bundle exec rubocop [file]` - Check specific file
- `/project:commit-message` - Generate commit messages **ONLY** (no auto-commit)
- `/project:gemini-search` - Web search integration

**Git Command Usage**:
- `/commit-message` = Message generation only (no commit execution)
- Explicit user request like "commit", "コミット", "コミットして" = Actual commit
- Settings prohibit auto-commits for stability

## Current Architecture

**Ruby Gem Structure** with clean separation of concerns:

```
lib/
├── number_analyzer.rb              # Core statistical calculations
└── number_analyzer/
    ├── cli.rb                      # CLI interface + 21 subcommands
    ├── file_reader.rb              # File input handling
    ├── statistics_presenter.rb     # Output formatting
    └── output_formatter.rb         # Advanced output formatting
```

**Key Classes**:
- **NumberAnalyzer**: Pure statistical calculations (19 functions)
- **NumberAnalyzer::CLI**: Command-line argument processing + 20 subcommand routing
- **NumberAnalyzer::FileReader**: CSV/JSON/TXT file input
- **NumberAnalyzer::StatisticsPresenter**: Output formatting and histogram display
- **NumberAnalyzer::OutputFormatter**: Advanced output formatting (JSON, precision, quiet mode)

## Implemented Features

**Statistical Functions (28)**:
- Basic: sum, mean, min, max, median, mode
- Variability: variance, standard deviation, IQR
- Advanced: percentiles, quartiles, outliers, deviation scores
- Relationships: Pearson correlation coefficient
- Time Series: linear trend analysis (slope, intercept, R², direction), moving averages, growth rate analysis (period-over-period, CAGR, average growth rate), seasonal pattern analysis (decomposition, period detection, seasonal strength)
- Statistical Tests: independent samples t-test (Welch's t-test), paired samples t-test, one-sample t-test with p-value and significance testing, confidence intervals for population mean (t-distribution and normal approximation), chi-square test for independence and goodness-of-fit with Cramér's V effect size
- Analysis of Variance: one-way ANOVA with F-statistic, p-value calculation, effect size measures (η², ω²), statistical interpretation, and comprehensive ANOVA table output
- Visualization: frequency distribution, ASCII histogram

**Input Support**: CLI arguments, CSV/JSON/TXT files (both full analysis and all subcommands)
**Output**: Comprehensive analysis OR individual statistics + visualization
**CLI Modes**: Full analysis (default) OR 22 individual subcommands (Phases 6.1, 6.2, 7.1, 7.2, 7.3, 7.4)
**Subcommand Categories**: Basic statistics, advanced analysis, parameterized commands, correlation analysis, time series analysis, statistical inference, analysis of variance
**Output Options (Phase 6.3)**: JSON format, precision control, quiet mode, help system
**Correlation Analysis (Phase 7.1)**: Dual dataset input, mathematical interpretation, file/numeric support
**Time Series Analysis (Phase 7.2)**: Linear trend analysis, moving averages with customizable window sizes, growth rate analysis with CAGR calculation, seasonal pattern analysis with automatic period detection
**Statistical Tests (Phase 7.3)**: T-test analysis with all three types (independent, paired, one-sample), confidence intervals for population mean using t-distribution, chi-square test for independence and goodness-of-fit with categorical data analysis, mathematical accuracy with Welch's formula and chi-square distribution, two-tailed p-values and significance interpretation
**Analysis of Variance (Phase 7.4)**: One-way ANOVA with F-distribution p-value calculation, comprehensive effect size analysis (eta squared and omega squared), statistical interpretation with significance testing, and detailed ANOVA table output with sum of squares decomposition

## Code Quality Standards

**Architecture Principles**:
- **Single Responsibility Principle**: Each class has one clear purpose
- **Clean Dependencies**: `bin → CLI → NumberAnalyzer ← StatisticsPresenter`
- **Ruby Idioms**: Effective use of `sum`, `tally`, `sort`, endless methods
- **TDD Practice**: Red-Green-Refactor cycle for all new features

**Code Quality Enforcement (ZERO TOLERANCE)**:
- **RuboCop Gate**: No code changes allowed without zero RuboCop violations
- **Style Consistency**: All code must conform to project's .rubocop.yml configuration
- **Auto-correction First**: Always apply `bundle exec rubocop -a` before manual fixes
- **Configuration Changes**: RuboCop config modifications require documentation update

**Quality Checklist** (MANDATORY - Zero Tolerance Policy):
1. **RuboCop compliance** - REQUIRED: `bundle exec rubocop` must show zero violations
2. **Auto-correction applied** - REQUIRED: `bundle exec rubocop -a` before manual review
3. **Test coverage** - All new features require comprehensive tests
4. **Documentation updates** - Update relevant docs (README.md, etc.)
5. **Mathematical accuracy** - Verify statistical correctness

## Development Guidelines

### Mandatory RuboCop Workflow (REQUIRED FOR ALL CHANGES)
**Pre-Development Check**:
```bash
bundle exec rubocop  # Must show zero violations before starting
```

**During Development** (after each change):
```bash
bundle exec rubocop          # Check violations
bundle exec rubocop -a       # Auto-fix correctable issues
bundle exec rubocop          # Verify zero violations
rspec                        # Ensure tests pass
```

**Pre-Commit Gate** (MANDATORY):
```bash
bundle exec rubocop          # MUST be zero violations
rspec                        # MUST be all tests passing
```

### New Feature Implementation
1. **Plan** - Document in `ai-docs/ROADMAP.md` if significant
2. **TDD** - Write failing tests first
3. **Implement** - Follow existing patterns and Ruby conventions
4. **RuboCop Check** - Run `bundle exec rubocop` after each significant change
5. **Test** - Ensure all 193+ tests pass
6. **Final RuboCop** - `bundle exec rubocop -a` then verify zero violations
7. **Document** - Update README.md and relevant documentation

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

## Important Reminders

- **RuboCop compliance**: MANDATORY `bundle exec rubocop` with zero violations before any commit
- **Auto-correction workflow**: Always run `bundle exec rubocop -a` first, then manual review
- **Commit messages**: Use `/project:commit-message` to generate messages ONLY - DO NOT auto-commit
- **Manual commits**: Only commit when user explicitly requests "commit" or "コミット"
- **Documentation**: Update README.md features/usage after changes
- **RSpec syntax**: Use `-e "pattern"` for test filtering
- **Mathematical precision**: Consider floating-point accuracy in tests
- **Japanese output**: Maintain Japanese labels for user-facing output

## Git Workflow Guidelines

**IMPORTANT: Commit Control**
- `/project:commit-message` or `/commit-message` = **Generate commit message ONLY**
- **NEVER auto-commit** unless user explicitly says "commit", "コミット", or "コミットして"
- Settings prohibit `git commit` commands for stability
- User must manually run `git commit` with generated message

## Quick Reference

**Current State**: ✅ Phase 7.4 Step 1 Complete (One-way ANOVA)
**Next Phase**: Phase 7.4 Step 2 - Post-hoc Tests (see `ai-docs/ROADMAP.md`)
**Test Count**: 42+ examples total
**RuboCop Status**: ✅ Zero violations (statistical methods properly excluded for mathematical complexity)
**Subcommand Count**: 22 total (7 basic + 6 advanced + 1 correlation + 4 time series + 3 statistical test + 1 ANOVA commands)
**CLI Options**: 16 advanced options (JSON, precision, quiet, help, window, period, paired, one-sample, population-mean, mu, level, independence, goodness-of-fit, uniform, post-hoc, alpha) across all subcommands

## Documentation Structure

- **CLAUDE.md** (this file): Development guidance for Claude Code
- **README.md**: User documentation and API reference
- **ai-docs/ROADMAP.md**: Development phases and future planning
- **ai-docs/FEATURES.md**: Comprehensive feature documentation
- **ai-docs/ARCHITECTURE.md**: Technical architecture details

For detailed information about specific aspects of the project, refer to the appropriate documentation file above.