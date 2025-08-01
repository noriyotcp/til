# StatisticsPresenter Refactoring Plan

## Overview

This document outlines the refactoring plan for `lib/numana/statistics_presenter.rb`, which has grown to 593 lines and violates the Single Responsibility Principle.

## Current State Analysis

### Problem Statement
- **File Size**: 593 lines (too large for a single responsibility)
- **Responsibilities**: Handles formatting for ALL statistical tests
  - Basic statistics (lines 13-62)
  - Levene test (lines 63-123)
  - Bartlett test (lines 125-209)
  - Kruskal-Wallis test (lines 211-288)
  - Mann-Whitney test (lines 290-386)
  - Wilcoxon test (lines 388-485)
  - Friedman test (lines 487-569)
- **Pattern Duplication**: Each test has 3 format methods (verbose, JSON, quiet)
- **Maintenance Issues**: Adding new tests increases file size linearly

### Code Smell Indicators
```ruby
# Repeated pattern for each test:
def self.format_[test_name](result, options = {})
  case options[:format]
  when 'json'   -> format_[test_name]_json(...)
  when 'quiet'  -> format_[test_name]_quiet(...)
  else          -> format_[test_name]_verbose(...)
  end
end
```

## Refactoring Design

### Strategy: Extract Test-Specific Presenters

Using the **Template Method Pattern** to create a hierarchy of presenters with shared behavior.

### Directory Structure
```
lib/numana/
├── presenters/
│   ├── base_statistical_presenter.rb      # Abstract base class
│   ├── levene_test_presenter.rb          # ~60 lines
│   ├── bartlett_test_presenter.rb        # ~85 lines
│   ├── kruskal_wallis_test_presenter.rb  # ~78 lines
│   ├── mann_whitney_test_presenter.rb    # ~97 lines
│   ├── wilcoxon_test_presenter.rb        # ~98 lines
│   └── friedman_test_presenter.rb        # ~83 lines
└── statistics_presenter.rb               # Reduced to ~100 lines
```

### Base Class Design

```ruby
# lib/numana/presenters/base_statistical_presenter.rb
module NumberAnalyzer
  module Presenters
    class BaseStatisticalPresenter
      def initialize(result, options = {})
        @result = result
        @options = options
        @precision = options[:precision] || 6
      end

      def format
        case @options[:format]
        when 'json'
          format_json
        when 'quiet'
          format_quiet
        else
          format_verbose
        end
      end

      protected

      def format_json
        JSON.generate(json_fields)
      end

      def round_value(value)
        value.round(@precision)
      end

      def format_significance(significant)
        significant ? '**Significant**' : 'Not significant'
      end

      # Abstract methods - must be implemented by subclasses
      def json_fields
        raise NotImplementedError, "Subclass must implement json_fields"
      end

      def format_quiet
        raise NotImplementedError, "Subclass must implement format_quiet"
      end

      def format_verbose
        raise NotImplementedError, "Subclass must implement format_verbose"
      end
    end
  end
end
```

### Example Presenter Implementation

```ruby
# lib/numana/presenters/levene_test_presenter.rb
module NumberAnalyzer
  module Presenters
    class LeveneTestPresenter < BaseStatisticalPresenter
      private

      def json_fields
        {
          test_type: @result[:test_type],
          f_statistic: round_value(@result[:f_statistic]),
          p_value: round_value(@result[:p_value]),
          degrees_of_freedom: @result[:degrees_of_freedom],
          significant: @result[:significant],
          interpretation: @result[:interpretation]
        }
      end

      def format_quiet
        f_stat = round_value(@result[:f_statistic])
        p_value = round_value(@result[:p_value])
        "#{f_stat} #{p_value}"
      end

      def format_verbose
        build_sections.join("\n")
      end

      def build_sections
        [
          header_section,
          statistics_section,
          decision_section,
          interpretation_section,
          notes_section
        ]
      end

      def header_section
        "=== Levene Test Results (Brown-Forsythe Modified) ==="
      end

      def statistics_section
        [
          "",
          "Test Statistics:",
          "  F-statistic: #{round_value(@result[:f_statistic])}",
          "  p-value: #{round_value(@result[:p_value])}",
          "  Degrees of Freedom: #{@result[:degrees_of_freedom].join(', ')}"
        ].join("\n")
      end

      def decision_section
        [
          "",
          "Statistical Decision:",
          if @result[:significant]
            "  Result: **Significant difference** (p < 0.05)\n" \
            "  Conclusion: Group variances are not equal"
          else
            "  Result: No significant difference (p ≥ 0.05)\n" \
            "  Conclusion: Group variances are considered equal"
          end
        ].join("\n")
      end

      def interpretation_section
        [
          "",
          "Interpretation:",
          "  #{@result[:interpretation]}"
        ].join("\n")
      end

      def notes_section
        [
          "",
          "Notes:",
          "  - Brown-Forsythe modification is robust against outliers",
          "  - This test is used to check ANOVA assumptions"
        ].join("\n")
      end
    end
  end
end
```

## Implementation Plan

### Step 1: Create Infrastructure
1. Create `presenters/` directory
2. Implement `BaseStatisticalPresenter` class
3. Add require statements to main library file

### Step 2: Extract Test Presenters (Priority Order)
1. **LeveneTestPresenter** - Simplest structure
2. **BartlettTestPresenter** - Similar to Levene
3. **KruskalWallisTestPresenter** - Non-parametric tests
4. **MannWhitneyTestPresenter** - Includes effect size
5. **WilcoxonTestPresenter** - Paired test formatting
6. **FriedmanTestPresenter** - Repeated measures

### Step 3: Update StatisticsPresenter
1. Keep only basic statistics methods (display_results, display_histogram)
2. Add delegation methods for backward compatibility:
```ruby
def self.format_levene_test(result, options = {})
  NumberAnalyzer::Presenters::LeveneTestPresenter.new(result, options).format
end
```

### Step 4: Update Command Classes
1. Update each command to use new presenter directly
2. Example change:
```ruby
# Before
puts NumberAnalyzer::StatisticsPresenter.format_levene_test(result, @options)

# After
puts NumberAnalyzer::Presenters::LeveneTestPresenter.new(result, @options).format
```

### Step 5: Testing & Validation
1. Run existing test suite to ensure backward compatibility
2. Add unit tests for each new presenter
3. Verify output format consistency

## Expected Benefits

### Code Quality Improvements
- **Single Responsibility**: Each presenter handles one test type
- **File Size**: ~100 lines per file vs 593-line monolith
- **Maintainability**: Easy to locate and modify specific test formatting
- **Extensibility**: Simple to add new test formatters

### Development Benefits
- **Testability**: Each presenter can be tested in isolation
- **Code Reuse**: Common formatting logic in base class
- **Clarity**: Clear separation of concerns
- **Discoverability**: Easy to find formatter for specific test

### Performance Benefits
- **Lazy Loading**: Only load presenters that are actually used
- **Memory**: Smaller class definitions
- **Startup Time**: Potential for on-demand requires

## Migration Strategy

### Phase 1: Parallel Implementation (No Breaking Changes)
1. Create new presenter structure
2. Keep StatisticsPresenter methods as delegators
3. Test thoroughly

### Phase 2: Direct Usage (Optional Future Enhancement)
1. Update command classes to use presenters directly
2. Mark StatisticsPresenter methods as deprecated
3. Remove delegation methods in major version update

## Risk Assessment

### Low Risk
- Backward compatibility maintained through delegation
- Existing tests provide safety net
- Incremental implementation possible

### Mitigation Strategies
- Keep original methods during transition
- Comprehensive test coverage
- Gradual rollout (one presenter at a time)

## Success Metrics

1. **Code Reduction**: StatisticsPresenter reduced from 593 to ~100 lines
2. **Test Coverage**: 100% coverage maintained
3. **Performance**: No regression in execution time
4. **Maintainability**: Each presenter under 100 lines

## Timeline Estimate

- Infrastructure setup: 1 hour
- Each presenter extraction: 30-45 minutes
- Testing and validation: 2 hours
- Documentation updates: 30 minutes

**Total estimated time**: 6-8 hours

## Conclusion

This refactoring will significantly improve code maintainability while preserving all existing functionality. The Template Method pattern provides a clean abstraction for the common formatting logic while allowing test-specific customization.