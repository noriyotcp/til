# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NumberAnalyzer is a comprehensive statistical analysis tool built in Ruby. Originally started as a refactoring exercise from beginner-level code to professional Ruby Gem, it has evolved into an enterprise-ready statistical analysis library with data visualization capabilities.

**Current Status**: ✅ **Production Ready** - 15 statistical functions, 162 test cases, full CLI subcommand suite, enterprise-level code quality

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

**Development Tools**:
- `bundle install` - Install dependencies
- `rspec` - Run test suite (162 tests)
- `bundle exec rubocop` - Code style checking (MANDATORY: zero violations)
- `bundle exec rubocop -a` - Auto-fix style violations (run first)
- `bundle exec rubocop [file]` - Check specific file
- `/project:commit-message` - Generate commit messages
- `/project:gemini-search` - Web search integration

## Current Architecture

**Ruby Gem Structure** with clean separation of concerns:

```
lib/
├── number_analyzer.rb              # Core statistical calculations (69 tests)
└── number_analyzer/
    ├── cli.rb                      # CLI interface + 13 subcommands (56 tests)
    ├── file_reader.rb              # File input handling (27 tests)
    └── statistics_presenter.rb     # Output formatting (13 tests)
```

**Key Classes**:
- **NumberAnalyzer**: Pure statistical calculations (15 functions)
- **NumberAnalyzer::CLI**: Command-line argument processing + 13 subcommand routing
- **NumberAnalyzer::FileReader**: CSV/JSON/TXT file input
- **NumberAnalyzer::StatisticsPresenter**: Output formatting and histogram display

## Implemented Features

**Statistical Functions (15)**:
- Basic: sum, mean, min, max, median, mode
- Variability: variance, standard deviation, IQR
- Advanced: percentiles, quartiles, outliers, deviation scores
- Visualization: frequency distribution, ASCII histogram

**Input Support**: CLI arguments, CSV/JSON/TXT files (both full analysis and all subcommands)
**Output**: Comprehensive analysis OR individual statistics + visualization
**CLI Modes**: Full analysis (default) OR 13 individual subcommands (Phases 6.1 & 6.2)
**Subcommand Categories**: Basic statistics, advanced analysis, parameterized commands

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
5. **Test** - Ensure all 162+ tests pass
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
- **Commit messages**: Use markdown code blocks (recommend `/project:commit-message`)
- **Documentation**: Update README.md features/usage after changes
- **RSpec syntax**: Use `-e "pattern"` for test filtering
- **Mathematical precision**: Consider floating-point accuracy in tests
- **Japanese output**: Maintain Japanese labels for user-facing output

## Quick Reference

**Current State**: ✅ Phase 6.2 Complete (Advanced Statistics Subcommands)
**Next Phase**: Phase 6.3 - Output Format & Options (see `ai-docs/ROADMAP.md`)
**Test Count**: 162 total (69 core + 56 CLI/subcommands + 27 file + 13 presenter)
**RuboCop Status**: Full compliance (zero violations policy enforced)
**Subcommand Count**: 13 total (7 basic + 6 advanced statistical commands)

## Documentation Structure

- **CLAUDE.md** (this file): Development guidance for Claude Code
- **README.md**: User documentation and API reference
- **ai-docs/ROADMAP.md**: Development phases and future planning
- **ai-docs/FEATURES.md**: Comprehensive feature documentation
- **ai-docs/ARCHITECTURE.md**: Technical architecture details

For detailed information about specific aspects of the project, refer to the appropriate documentation file above.