# Gem Rename Plan: number_analyzer → numana

**Project**: ✅ NumberAnalyzer → Numana  
**Date**: 2025-07-20  
**Status**: ✅ **COMPLETE** - All phases implemented successfully  
**Complexity**: High (100+ files affected)

## Overview

Complete gem rename from `number_analyzer` to `numana` affecting entire codebase infrastructure, namespace, and documentation.

## Name Analysis: numana

**Evaluation**: ⭐⭐⭐⭐⭐ Excellent Choice

**Strengths**:
- Short and memorable for CLI usage
- Clear abbreviation: num(ber) + ana(lyzer)
- Easy pronunciation: "ヌマナ"
- Follows Ruby gem naming conventions
- Appropriate length for command-line tool

**Considerations**:
- Check RubyGems.org for name availability
- Verify no conflicts in international contexts

**Alternative Options Considered**:
- `numstat` (number statistics)
- `statnum` (statistics for numbers)
- `numan` (number analyzer - shorter)
- `analynum` (analyze numbers)

## Rename Impact Analysis

### Files Requiring Changes
- **Gemspec**: 1 file (rename + content update)
- **Binary files**: 1 file (`bin/number_analyzer` → `bin/numana`)
- **Ruby modules**: 100+ files (namespace changes)
- **Test files**: 50+ spec files
- **Documentation**: 18+ markdown files
- **Configuration**: plugins.yml, Gemfile references

### Namespace Changes Required
- `NumberAnalyzer` → `Numana` (main class)
- `NumberAnalyzer::CLI` → `Numana::CLI`
- `NumberAnalyzer::PluginSystem` → `Numana::PluginSystem`
- All submodules and presenters

## Implementation Plan

### Phase 1: Core Infrastructure (High Priority)
1. **Rename gemspec file**
   - `number_analyzer.gemspec` → `numana.gemspec`
   - Update gem name, description, homepage URLs
   - Update executable name reference

2. **Update binary command**
   - `bin/number_analyzer` → `bin/numana`
   - Update shebang and require paths

3. **Rename main module**
   - `class NumberAnalyzer` → `class Numana`
   - Update all include/extend statements

### Phase 2: Directory Restructure (High Priority)
4. **Move library structure**
   - `lib/number_analyzer/` → `lib/numana/`
   - Update main entry point: `lib/number_analyzer.rb` → `lib/numana.rb`

5. **Move test structure**
   - `spec/number_analyzer/` → `spec/numana/`
   - Update all require_relative paths

6. **Update require statements**
   - ~200+ require_relative statements to update
   - Maintain relative path structure within new namespace

### Phase 3: Namespace Updates (Critical)
7. **Update all class declarations**
   - 50+ files with `NumberAnalyzer::` references
   - CLI commands, presenters, statistics modules
   - Plugin system components

8. **Update module references**
   - All include/extend statements
   - Constant references and class instantiation
   - Method calls and inheritance

9. **Update plugin system**
   - Plugin interface definitions
   - Plugin loader and registry
   - Example plugins and templates

### Phase 4: Documentation & Configuration (Medium Priority)
10. **Update primary documentation**
    - README.md: Installation, usage examples
    - CLAUDE.md: Development commands, CLI examples
    - All ai-docs/*.md files (18 files)

11. **Update CLI help and examples**
    - Command help text throughout codebase
    - Usage examples in documentation
    - Error messages and user-facing text

12. **Update configuration files**
    - plugins.yml plugin definitions
    - Gemfile and Gemfile.lock
    - Any CI/CD configurations

### Phase 5: Testing & Validation (Critical)
13. **Comprehensive test execution**
    - Run full RSpec test suite
    - Verify all 29+ CLI commands function
    - Test plugin system functionality

14. **Code quality validation**
    - RuboCop compliance check (maintain zero violations)
    - Apply auto-corrections: `bundle exec rubocop -a`
    - Manual review of any remaining issues

15. **Functional verification**
    - CLI integration testing
    - Plugin loading and conflict resolution
    - Statistical calculation accuracy

### Phase 6: Final Updates (Low Priority)
16. **Version and metadata**
    - Bump version number appropriately
    - Update changelog with breaking changes
    - Review and update gem metadata

17. **Documentation finalization**
    - Update installation instructions
    - Verify all examples work with new name
    - Update any external references

## Risk Assessment

### High Risk Areas
- **Namespace conflicts**: Systematic replacement required to avoid partial renames
- **Plugin compatibility**: External plugins may need updates
- **Test coverage**: Ensure comprehensive testing after rename

### Mitigation Strategies
- **Systematic approach**: Complete each phase fully before proceeding
- **Backup creation**: Create backup before starting
- **Incremental testing**: Test after each major phase
- **Version control**: Commit frequently with descriptive messages

## Breaking Changes Notice

This rename constitutes a **major breaking change**:
- All external references to `number_analyzer` must be updated
- Import statements change from `require 'number_analyzer'` to `require 'numana'`
- CLI command changes from `number_analyzer` to `numana`
- Gem installation changes from `gem install number_analyzer` to `gem install numana`

## Success Criteria

- [x] All tests pass with new namespace
- [x] CLI functionality fully operational
- [x] Zero RuboCop violations maintained
- [x] Documentation accurately reflects new naming
- [x] Plugin system functions correctly
- [x] No broken require statements or missing files

## Estimated Effort

**Time Estimate**: 4-6 hours for complete implementation and testing  
**Complexity Level**: High (due to extensive namespace changes)  
**Risk Level**: Medium (systematic approach mitigates most risks)

## Post-Rename Actions

1. **Gem publishing**: Publish new `numana` gem to RubyGems.org
2. **Deprecation notice**: Add deprecation notice to old `number_analyzer` gem
3. **Documentation updates**: Update any external references or tutorials
4. **Community notification**: Inform users of the rename and migration path

---

**Next Steps**: Await user confirmation before proceeding with implementation.