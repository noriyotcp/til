# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NumberAnalyzer is a comprehensive statistical analysis tool built in Ruby. Originally started as a refactoring exercise from beginner-level code to professional Ruby Gem, it has evolved into an enterprise-ready statistical analysis library with data visualization capabilities.

**Current Status**: ✅ **Production Ready** - 32 statistical functions, 138+ test examples, Phase 7.7 Step 1 complete with modular BasicStats architecture and comprehensive non-parametric tests (Kruskal-Wallis + Mann-Whitney), enterprise-level code quality

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

**Development Tools**:
- `bundle install` - Install dependencies
- `rspec` - Run test suite (138+ examples including 32 BasicStats unit tests + 17 t-test + 10 confidence interval + 12 chi-square + ANOVA + 15 Levene + 16 Bartlett + 16 Kruskal-Wallis + 17 Mann-Whitney test cases)
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

**Enhanced Ruby Gem Structure** with modular BasicStats extraction:

```
lib/
├── number_analyzer.rb              # Core statistical calculations (1,710 lines)
└── number_analyzer/
    ├── cli.rb                      # CLI interface + 26 subcommands
    ├── file_reader.rb              # File input handling
    ├── statistics_presenter.rb     # Output formatting
    ├── output_formatter.rb         # Advanced output formatting
    └── statistics/                 # NEW: Modular statistics components
        └── basic_stats.rb          # BasicStats module (sum, mean, mode, variance, std_dev)
```

**Key Classes**:
- **NumberAnalyzer**: Pure statistical calculations (27 functions) + BasicStats module integration
- **BasicStats**: Modular basic statistics (sum, mean, mode, variance, standard_deviation)
- **NumberAnalyzer::CLI**: Command-line argument processing + 26 subcommand routing
- **NumberAnalyzer::FileReader**: CSV/JSON/TXT file input
- **NumberAnalyzer::StatisticsPresenter**: Output formatting and histogram display
- **NumberAnalyzer::OutputFormatter**: Advanced output formatting (JSON, precision, quiet mode)

## Implemented Features

**Statistical Functions (30)**:
- Basic: sum, mean, min, max, median, mode
- Variability: variance, standard deviation, IQR
- Advanced: percentiles, quartiles, outliers, deviation scores
- Relationships: Pearson correlation coefficient
- Time Series: linear trend analysis (slope, intercept, R², direction), moving averages, growth rate analysis (period-over-period, CAGR, average growth rate), seasonal pattern analysis (decomposition, period detection, seasonal strength)
- Statistical Tests: independent samples t-test (Welch's t-test), paired samples t-test, one-sample t-test with p-value and significance testing, confidence intervals for population mean (t-distribution and normal approximation), chi-square test for independence and goodness-of-fit with Cramér's V effect size
- Analysis of Variance: one-way ANOVA with F-statistic, p-value calculation, effect size measures (η², ω²), statistical interpretation, comprehensive ANOVA table output, post-hoc tests (Tukey HSD, Bonferroni correction) for multiple pairwise comparisons
- Variance Homogeneity: Levene test with Brown-Forsythe modification for robust variance equality testing, Bartlett test for high-precision variance equality testing under normality assumptions, ANOVA prerequisite checking, outlier-resistant analysis
- Visualization: frequency distribution, ASCII histogram

**Input Support**: CLI arguments, CSV/JSON/TXT files (both full analysis and all subcommands)
**Output**: Comprehensive analysis OR individual statistics + visualization
**CLI Modes**: Full analysis (default) OR 24 individual subcommands (Phases 6.1, 6.2, 7.1, 7.2, 7.3, 7.4, 7.5)
**Subcommand Categories**: Basic statistics, advanced analysis, parameterized commands, correlation analysis, time series analysis, statistical inference, analysis of variance, variance homogeneity tests
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

### New Feature Implementation (MANDATORY PROCESS)

**重要**: 実装とドキュメント更新は一体のプロセスです。コード動作確認だけでは「未完了」です。

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
- **README.md**: Features section + CLI examples + subcommand count update
- **ROADMAP.md**: Phase status complete + checkbox [x] updates + achievement numbers
- **CLAUDE.md**: Command examples (通常は実装中に既に更新済み)

#### 完了基準の再定義
- ✅ **完了** = Code + Tests + Documentation Updates + RuboCop compliance
- ❌ **未完了** = 動くけどドキュメント未更新の状態

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
- **Documentation**: **MANDATORY** - Update README.md features/usage AND ROADMAP.md phase status immediately after implementation. Never leave code changes without documentation updates.
- **RSpec syntax**: Use `-e "pattern"` for test filtering
- **Mathematical precision**: Consider floating-point accuracy in tests
- **Japanese output**: Maintain Japanese labels for user-facing output

## Git Workflow Guidelines

**IMPORTANT: Commit Control**
- `/project:commit-message` or `/commit-message` = **Generate commit message ONLY**
- **NEVER auto-commit** unless user explicitly says "commit", "コミット", or "コミットして"
- Settings prohibit `git commit` commands for stability
- User must manually run `git commit` with generated message

## Next Development Phase - Phase 7.7

**Phase 7.7 Goal**: 基盤リファクタリング (Plugin System Architecture 準備段階)

### 現在の課題
- **1,710行のモノリシックファイル**: `lib/number_analyzer.rb` の可読性・保守性限界 (BasicStats抽出により17行削減済み)
- **メソッド重複リスク**: standard_normal_cdf, erf等の重複による保守負荷  
- **単一責任原則違反**: 32個の統計機能が1クラスに集約、拡張性限界

### Phase 7.7 Step 1: BasicStats モジュール抽出 ✅ 完了
**最初のモジュール分割テスト - 成功**
- **Target**: `lib/number_analyzer/statistics/basic_stats.rb` 作成完了
- **Extracted Methods**: sum, mean, mode, variance, standard_deviation (median は percentile 依存のため保留)
- **Integration**: NumberAnalyzer クラスに `include BasicStats` 追加完了
- **Quality Gate**: 既存106テスト + 新規32テスト = 138テスト全通過確認（API変更なし）
- **Architecture**: 17行削減 (1,727 → 1,710 lines), 51行の BasicStats モジュール作成
- **Test Coverage**: 包括的ユニットテスト追加 (`spec/number_analyzer/statistics/basic_stats_spec.rb`)

### Phase 7.7 Benefits
- **可読性向上**: 各ファイル200-300行程度に分割
- **保守性向上**: 統計分野ごとの責任分離
- **拡張性向上**: 新機能追加時の影響範囲限定
- **将来性**: Plugin System Architecture (Phase 8.0) への自然な移行パス
- **安全性**: 既存API完全保持、106テスト全通過維持

### Implementation Strategy
1. **段階的実装**: BasicStats → MathUtils → 他のモジュール順次抽出
2. **API完全保持**: NumberAnalyzer.new(...).median 等の既存呼び出し維持
3. **品質保証**: 各段階で全テスト通過、RuboCop違反ゼロ維持

## Completed Phase - Phase 7.6

### Phase 7.6 Step 1: Mann-Whitney U Test ✅ 完了
**Target**: 最も基本的なノンパラメトリック2群比較検定
- **Statistical Function**: Mann-Whitney U検定 (Wilcoxon rank-sum testとも呼ばれる)
- **Use Case**: t検定のノンパラメトリック版、2つの独立グループの分布比較
- **Implementation**: Kruskal-Wallisのランク計算ロジック直接応用で実装完了
- **CLI Command**: `bundle exec number_analyzer mann-whitney group1.csv group2.csv`
- **Features**: U統計量、z統計量、タイ補正、連続性補正、効果サイズ計算

### Phase 7.6 Benefits ✅ 達成
- **26個目のサブコマンド**: ノンパラメトリック検定の基礎完成
- **実用性向上**: 最も頻繁に使用される2群比較検定の実装完了
- **統計的完成度**: パラメトリック(t-test) + ノンパラメトリック(Mann-Whitney)の両方対応
- **テスト品質**: 106テストケース到達（17 Mann-Whitney追加）

## Quick Reference

**Current State**: ✅ Phase 7.7 Step 1 Complete (BasicStats Module Architecture + Non-parametric Test Suite)
**Next Phase**: Phase 7.7 Step 2 - MathUtils モジュール抽出 (基盤リファクタリング継続)
**Test Count**: 138+ examples total (32 BasicStats unit tests + 15 Levene + 16 Bartlett + 16 Kruskal-Wallis + 17 Mann-Whitney + integration test cases)
**RuboCop Status**: ✅ Zero violations (BasicStats module + Mann-Whitney implementation with modular architecture)
**Subcommand Count**: 26 total (7 basic + 6 advanced + 1 correlation + 4 time series + 3 statistical test + 1 ANOVA + 2 variance homogeneity + 2 non-parametric commands)
**CLI Options**: 16 advanced options (JSON, precision, quiet, help, window, period, paired, one-sample, population-mean, mu, level, independence, goodness-of-fit, uniform, post-hoc, alpha) across all subcommands

## Documentation Structure

- **CLAUDE.md** (this file): Development guidance for Claude Code
- **README.md**: User documentation and API reference
- **ai-docs/ROADMAP.md**: Development phases and future planning
- **ai-docs/FEATURES.md**: Comprehensive feature documentation
- **ai-docs/ARCHITECTURE.md**: Technical architecture details
- **ai-docs/REFACTORING_PLAN.md**: Phase 7.7 基盤リファクタリング詳細計画

For detailed information about specific aspects of the project, refer to the appropriate documentation file above.