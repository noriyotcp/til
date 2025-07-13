# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NumberAnalyzer is a comprehensive statistical analysis tool built in Ruby. Originally started as a refactoring exercise from beginner-level code to professional Ruby Gem, it has evolved into an enterprise-ready statistical analysis library with data visualization capabilities.

**Current Status**: ✅ **Production Ready** - 33 statistical functions, comprehensive test suite, CLI Modularization Phase 1 **COMPLETE** + CLI Refactoring Phase 1-2 **COMPLETE** + **Phase 9 CLI Ultimate Optimization COMPLETE** with Command Pattern architecture (31/31 commands migrated) and fully modular architecture (8 modules extracted + 6 CLI modules), 96.1%+ code reduction achieved + CLI 95.1% reduction (2094→102 lines), **100% RuboCop compliance**, enterprise-level code quality with TDD methodology, intelligent error handling and performance optimization, English error messages for international accessibility

## Development Commands

**Essential CLI Patterns**:
```bash
# Basic execution
bundle exec number_analyzer                    # Show help
bundle exec number_analyzer <command> <data>   # Run analysis
bundle exec number_analyzer <command> --file data.csv  # File input

# Common options (available for all commands)
--format=json     # JSON output
--precision=2     # Decimal precision
--quiet          # Script-friendly output
--help           # Command help
```

**Core Statistical Commands**:
- Basic: `mean`, `median`, `mode`, `sum`, `min`, `max`, `variance`, `std`
- Advanced: `outliers`, `percentile`, `quartiles`, `correlation`, `t-test`, `anova`
- Time Series: `trend`, `moving-average`, `growth-rate`, `seasonal`
- Non-parametric: `kruskal-wallis`, `mann-whitney`, `wilcoxon`, `friedman`

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
- `rspec` - Run comprehensive test suite (TDD-based command tests included)
- `bundle exec rubocop` - Code style checking (**✅ ZERO VIOLATIONS ACHIEVED**)
- `bundle exec rubocop -a` - Auto-fix style violations (run first)
- `bundle exec rubocop [file]` - Check specific file
- `/project:commit-message` - Generate commit messages **ONLY** (no auto-commit)
- `/project:gemini-search` - Web search integration

**Plugin Commands**:
```bash
bundle exec number_analyzer plugins list       # List all plugins
bundle exec number_analyzer plugins conflicts  # Show conflicts
```

**Git Command Usage**:
- `/commit-message` = Message generation only (no commit execution)
- Explicit user request like "commit", "コミット", "コミットして" = Actual commit
- Settings prohibit auto-commits for stability

## Current Architecture

**Modular Ruby Gem Structure**:

```
lib/
├── number_analyzer.rb              # Core integration
└── number_analyzer/
    ├── cli.rb                      # CLI orchestrator
    ├── cli/                        # CLI modules
    │   ├── options.rb              # Option parsing
    │   ├── help_generator.rb       # Help generation
    │   ├── input_processor.rb      # Input processing
    │   ├── error_handler.rb        # Error handling
    │   ├── command_cache.rb        # Performance caching
    │   ├── plugin_router.rb        # Command routing
    │   └── commands/               # Individual commands (29 total)
    ├── file_reader.rb              # File input
    ├── statistics_presenter.rb     # Output formatting
    ├── plugin_system.rb            # Plugin core
    └── statistics/                 # Statistical modules (8 total)
        ├── basic_stats.rb          # Basic statistics
        ├── advanced_stats.rb       # Advanced analysis
        ├── correlation_stats.rb    # Correlation analysis
        ├── time_series_stats.rb    # Time series
        ├── hypothesis_testing.rb   # Statistical tests
        ├── anova_stats.rb          # ANOVA analysis
        └── non_parametric_stats.rb # Non-parametric tests
```

**Key Components**:
- **CLI**: Command Pattern architecture with modular design
- **Statistics Modules**: 8 specialized modules for different analysis types
- **Plugin System**: Dynamic command loading and conflict resolution
- **Command Registry**: Unified command management system

## Available Features

**Statistical Analysis**: 33+ statistical functions including basic statistics, hypothesis testing, ANOVA, correlation analysis, time series analysis, and non-parametric tests. See [README.md](README.md) for complete feature list and usage examples.

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

**External References**: [Ruby Style Guide](https://github.com/rubocop/ruby-style-guide), [RubyGuides](https://www.rubyguides.com/2018/11/attr_accessor/)

**Quality Checklist** (MANDATORY - Zero Tolerance Policy):
1. **RuboCop compliance** - REQUIRED: `bundle exec rubocop` must show zero violations
2. **Auto-correction applied** - REQUIRED: `bundle exec rubocop -a` before manual review
3. **Naming conventions** - REQUIRED: Follow Ruby naming conventions (getter methods match instance variables)
4. **Test coverage** - All new features require comprehensive tests
5. **Documentation updates** - REQUIRED: Update ALL relevant docs (see Documentation Update Checklist below)
6. **Mathematical accuracy** - Verify statistical correctness

### Documentation Requirements

**必須更新ファイル**:
- **[ai-docs/ROADMAP.md](ai-docs/ROADMAP.md)**: Phase状況・メトリクス更新
- **[README.md](README.md)**: ユーザー向け機能説明
- **CLAUDE.md**: 開発コマンド例（新CLI機能時のみ）

**完了基準**: Code + Tests + Documentation Updates + RuboCop compliance

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

### Command Pattern Implementation Notes

**Key Requirements for new commands**:
1. Register in CommandRegistry (`commands.rb`)
2. Remove from CORE_COMMANDS (avoid duplicates)
3. Test CLI integration thoroughly
4. Handle special argument patterns (`--` separators, multiple files)

See `ai-docs/CLI_REFACTORING_GUIDE.md` for detailed troubleshooting.

### Feature Implementation Workflow

**Required TODO Items**:
1. Core implementation
2. CLI integration  
3. Test suite creation
4. Documentation updates
5. RuboCop compliance

**Implementation Order**:
1. Plan with TodoWrite
2. TDD (failing tests first)
3. Core implementation
4. Documentation updates (README, ROADMAP)
5. CLI integration
6. Test completion
7. RuboCop compliance
8. Final verification

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

### CLI Optimization

**CLI Architecture**: Modular design with single responsibility principle. See [ai-docs/CLI_IMPROVEMENT_PROPOSALS.md](ai-docs/CLI_IMPROVEMENT_PROPOSALS.md) for detailed guidelines.

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

**Current State**: Enterprise-ready statistical analysis library with modular architecture, Command Pattern CLI, and comprehensive plugin system. See [ai-docs/ROADMAP.md](ai-docs/ROADMAP.md) for detailed development history.


## Quick Reference

**Current State**: Enterprise-ready statistical analysis library with modular architecture and plugin system.
**Architecture**: 8 statistical modules + 6 CLI modules + comprehensive plugin infrastructure
**Commands**: 29 core subcommands with unified Command Pattern architecture
**Quality**: Zero RuboCop violations, comprehensive test suite, TDD methodology

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