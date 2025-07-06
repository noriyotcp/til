# NumberAnalyzer

A comprehensive statistical analysis tool for number arrays, implemented in Ruby.

## Features

NumberAnalyzer provides the following statistical calculations:

- **Sum** - Total of all numbers
- **Average** - Arithmetic mean
- **Maximum** - Largest value
- **Minimum** - Smallest value
- **Median** - Middle value (handles both odd/even array lengths)
- **Variance** - Measure of data variability (displayed to 2 decimal places)
- **Mode** - Most frequently occurring value(s)
- **Standard Deviation** - Square root of variance, measure of data spread
- **Percentile** - Any percentile value (0-100) using linear interpolation
- **Quartiles** - Q1, Q2, Q3 values returned as a hash
- **Interquartile Range (IQR)** - Q3-Q1, measure of data spread (middle 50%)
- **Outlier Detection** - Identifies outliers using IQR * 1.5 rule
- **Deviation Scores** - Standardized scores with mean=50, showing relative position of each value
- **Correlation Analysis** - Pearson correlation coefficient between two datasets with strength interpretation
- **Trend Analysis** - Linear regression analysis with slope, intercept, R², and direction (上昇/下降/横ばい)
- **Moving Average Analysis** - Time series smoothing with customizable window sizes
- **Growth Rate Analysis** - Period-over-period growth rates, CAGR, and average growth rate calculation  
- **Seasonal Pattern Analysis** - Seasonal decomposition, period detection, and seasonal strength measurement
- **T-Test Analysis** - Independent samples t-test (Welch's t-test), paired samples t-test, and one-sample t-test with statistical significance testing
- **Confidence Intervals** - Calculate confidence intervals for population mean using t-distribution (small samples) and normal approximation (large samples)
- **Chi-square Test** - Test for independence between categorical variables and goodness-of-fit to expected distributions with Cramér's V effect size
- **Analysis of Variance (ANOVA)** - One-way ANOVA for comparing means across multiple groups with F-statistic, p-value, and effect size measures (η², ω²)
- **Two-way ANOVA** - Factorial design analysis with two independent factors, main effects, and interaction effects with F-statistics, p-values, and partial eta squared effect sizes
- **Levene Test** - Test for variance homogeneity across multiple groups using Brown-Forsythe modification for robust variance equality testing
- **Bartlett Test** - Test for variance homogeneity with high precision under normality assumptions using chi-square distribution
- **Kruskal-Wallis Test** - Non-parametric test for comparing medians across multiple groups with H-statistic and chi-square distribution
- **Mann-Whitney U Test** - Non-parametric test for comparing two independent groups with U-statistic and normal approximation (Wilcoxon rank-sum test)
- **Wilcoxon Signed-Rank Test** - Non-parametric test for comparing paired samples with W-statistic and effect size calculation
- **Friedman Test** - Non-parametric test for repeated measures across multiple conditions with chi-square statistic and tie correction
- **Frequency Distribution** - Count occurrences of each value for data distribution analysis
- **Histogram Display** - ASCII art visualization of frequency distribution with automatic scaling
- **File Input Support** - Read data from CSV, JSON, and TXT files
- **Plugin API Framework** - Enterprise-ready plugin development framework with conflict resolution (Phase 8.0 Step 5):
  - **Plugin Registry**: Centralized plugin management with discovery and metadata validation
  - **Conflict Resolution System**: Automatic namespace generation and priority-based conflict resolution
    - **5-Tier Priority System**: Development(100) > Core(90) > Official(70) > ThirdParty(50) > Local(30)
    - **Automatic Namespace Generation**: Priority-aware prefixes (de_, co_, of_, th_, lo_) for conflict resolution
    - **Similarity Detection**: Levenshtein distance-based plugin name conflict detection (0.7 threshold)
    - **6 Resolution Strategies**: strict, warn_override, silent_override, namespace, interactive, auto
  - **Security Validation**: 76 dangerous pattern detection rules with 4-level risk assessment (low/medium/high/critical)
  - **Plugin Templates**: ERB-based standardized plugin generation for 5 plugin types
  - **Configuration Management**: Multi-layer configuration (default/file/environment) with security policies
  - **Sample Plugins**: 3 comprehensive examples demonstrating machine learning, data export, and visualization capabilities
  - **19 Plugin Commands**: `linear-regression`, `k-means`, `pca`, `export-csv`, `histogram`, `dashboard`, etc.
  - **Developer Tools**: Automated test generation, documentation creation, and security validation
  - **Enterprise Security**: Code integrity checking (SHA256), author verification, and risk-based loading
- **Command Pattern Architecture** - Modern CLI design with individual command classes for improved maintainability:
  - **29 Commands Fully Migrated**: All core statistical commands now use Command Pattern (Phase 2 complete)
  - **Template Method Pattern**: Consistent execution flow across all commands with BaseCommand inheritance
  - **Independent Testability**: Each command class is independently testable and maintainable (50-80 lines vs 2094-line monolith)
  - **CLI Lightweight Implementation**: Reduced from 2094 to 385 lines (81% reduction) with unified CommandRegistry architecture
  - **TDD Implementation**: Red-Green-Refactor development cycle with comprehensive test coverage
- **Enterprise Code Quality Standards** - Production-ready codebase with rigorous quality enforcement:
  - **✅ 100% RuboCop Compliance**: Zero violations across 116 files with automated style enforcement
  - **TDD Methodology**: Test-Driven Development with Red-Green-Refactor cycle for all new features
  - **Comprehensive Test Coverage**: Extensive test suite with 100% passing rate maintained throughout development
  - **Compact Style Consistency**: All files follow Ruby compact style (`NumberAnalyzer::ClassName`) for namespace clarity
  - **Automated Quality Gates**: RuboCop hooks integration for continuous code quality assurance

## Installation

### Local Development

1. Clone the repository and navigate to the directory
2. Install dependencies:
```bash
bundle install
```

### As a Local Gem

**Modern approach (recommended for 2025):**
```bash
# Build the gem using rake (creates gem in pkg/ directory)
rake build
gem install pkg/number_analyzer-*.gem

# Verify installation location
gem which number_analyzer
```

**Alternative build method:**
```bash
# Direct build (creates gem in current directory)
gem build number_analyzer.gemspec
gem install ./number_analyzer-*.gem
```

**For active development (most efficient):**
```bash
# Add to your project's Gemfile for immediate source changes reflection:
# gem 'number_analyzer', path: '/path/to/number_analyzer'
# Then run: bundle install

# No rebuilding needed - changes are immediately reflected
bundle exec number_analyzer
```

**Check installation:**
```bash
# Find where the gem is installed
gem environment
gem which number_analyzer

# List installed versions
gem list number_analyzer
```

## Usage

### Command Line Interface

#### Basic Usage

**Using bundle exec (recommended for development)**
```bash
# With default numbers (1-10)
bundle exec number_analyzer

# With custom numbers
bundle exec number_analyzer 1 2 3 4 5
bundle exec number_analyzer 10.5 20.3 15.7 8.2

# From files (CSV, JSON, TXT formats supported)
bundle exec number_analyzer --file data.csv
bundle exec number_analyzer -f numbers.json
bundle exec number_analyzer --file values.txt

# Correlation analysis with files
bundle exec number_analyzer correlation file1.csv file2.csv
bundle exec number_analyzer correlation --format=json file1.csv file2.csv

# Time series analysis
bundle exec number_analyzer trend 1 2 3 4 5
bundle exec number_analyzer trend --format=json --file sales.csv
bundle exec number_analyzer moving-average --window=5 1 2 3 4 5 6 7
bundle exec number_analyzer growth-rate 100 110 121 133
bundle exec number_analyzer seasonal 10 20 15 25 12 22 17 27

# Statistical hypothesis testing
bundle exec number_analyzer t-test group1.csv group2.csv
bundle exec number_analyzer t-test --paired before.csv after.csv
bundle exec number_analyzer t-test --one-sample --population-mean=100 data.csv

# Confidence interval analysis
bundle exec number_analyzer confidence-interval 95 1 2 3 4 5
bundle exec number_analyzer confidence-interval --level=90 --file data.csv
bundle exec number_analyzer confidence-interval --format=json --precision=2 10 20 30

# Chi-square test analysis
bundle exec number_analyzer chi-square --independence 30 20 -- 15 35
bundle exec number_analyzer chi-square --independence 10 20 30 -- 15 25 35 -- 20 30 40
bundle exec number_analyzer chi-square --goodness-of-fit 8 12 10 15 10 10 10 10
bundle exec number_analyzer chi-square --uniform 8 12 10 15 9 6
bundle exec number_analyzer chi-square --independence --file contingency_table.csv

# Wilcoxon signed-rank test (paired samples)
bundle exec number_analyzer wilcoxon 10 12 14 -- 15 18 20
bundle exec number_analyzer wilcoxon before.csv after.csv
bundle exec number_analyzer wilcoxon --format=json --precision=3 1 2 3 -- 4 5 6

# Friedman test (repeated measures across multiple conditions)
bundle exec number_analyzer friedman 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer friedman condition1.csv condition2.csv condition3.csv
bundle exec number_analyzer friedman --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
```

#### Using the bin file directly
```bash
ruby -Ilib bin/number_analyzer 1 2 3 4 5
```

#### As an installed gem
```bash
number_analyzer 1 2 3 4 5
```

#### Advanced Usage with Options (Phase 6.3)

NumberAnalyzer supports advanced output formatting and control options for all 29 core subcommands (plus additional plugin commands):

**JSON Output Format**
```bash
# Get JSON output for API integration
bundle exec number_analyzer median --format=json 1 2 3 4 5
#=> {"value":3.0,"dataset_size":5}

bundle exec number_analyzer quartiles --format=json 1 2 3 4 5
#=> {"q1":2.0,"q2":3.0,"q3":4.0,"dataset_size":5}

bundle exec number_analyzer outliers --format=json 1 2 3 100
#=> {"outliers":[100.0],"dataset_size":4}
```

**Precision Control**
```bash
# Control decimal places for output
bundle exec number_analyzer mean --precision=2 1.23456 2.34567
#=> 1.79

bundle exec number_analyzer variance --precision=1 1.1111 2.2222 3.3333
#=> 0.8

# Works with JSON format
bundle exec number_analyzer median --format=json --precision=1 1.234 2.567
#=> {"value":1.9,"dataset_size":2}
```

**Quiet Mode (Script-Friendly)**
```bash
# Minimal output for scripting
bundle exec number_analyzer median --quiet 1 2 3 4 5
#=> 3.0

bundle exec number_analyzer quartiles --quiet 1 2 3 4 5
#=> 2.0 3.0 4.0

bundle exec number_analyzer outliers --quiet 1 2 3 100
#=> 100.0
```

**Help System**
```bash
# Get help for any subcommand
bundle exec number_analyzer median --help
bundle exec number_analyzer percentile --help
bundle exec number_analyzer histogram --help
```

**Subcommands with Options**

All 29 core subcommands (plus plugin commands) support the new options:

```bash
# Basic Statistics with Options
bundle exec number_analyzer sum --format=json 1 2 3 4 5
bundle exec number_analyzer min --precision=3 1.123456 2.654321
bundle exec number_analyzer max --quiet 10 20 30 40 50

# Advanced Statistics with Options  
bundle exec number_analyzer variance --format=json --precision=2 1 2 3 4 5
bundle exec number_analyzer std --quiet 1.5 2.5 3.5 4.5
bundle exec number_analyzer deviation-scores --precision=1 60 70 80 90
bundle exec number_analyzer correlation 1 2 3 2 4 6
bundle exec number_analyzer correlation --format=json --precision=3 1 2 3 2 4 6

# Time Series Analysis
bundle exec number_analyzer trend 1 2 3 4 5
bundle exec number_analyzer moving-average --window=5 1 2 3 4 5 6 7 8
bundle exec number_analyzer growth-rate --format=json 100 110 121 133
bundle exec number_analyzer seasonal --period=4 10 20 15 25 12 22 17 27

# Statistical Tests
bundle exec number_analyzer t-test --format=json group1.csv group2.csv
bundle exec number_analyzer t-test --paired --precision=3 before.csv after.csv
bundle exec number_analyzer t-test --one-sample --population-mean=50 --quiet data.csv
bundle exec number_analyzer confidence-interval 95 --format=json 1 2 3 4 5
bundle exec number_analyzer confidence-interval --level=90 --precision=2 --file data.csv
bundle exec number_analyzer confidence-interval --quiet 99 10 20 30 40

# Chi-square Tests
bundle exec number_analyzer chi-square --independence 30 20 -- 15 35
bundle exec number_analyzer chi-square --goodness-of-fit 8 12 10 15 9 6 10 10 10 10 10 10
bundle exec number_analyzer chi-square --uniform --format=json 8 12 10 15 9 6

# Analysis of Variance (ANOVA)
bundle exec number_analyzer anova 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer anova --file group1.csv group2.csv group3.csv
bundle exec number_analyzer anova --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer anova --alpha=0.01 --quiet 1 2 3 -- 4 5 6 -- 7 8 9

# Two-way ANOVA (Factorial Design)
bundle exec number_analyzer two-way-anova --factor-a A1,A1,A2,A2 --factor-b B1,B2,B1,B2 10,12,20,22
bundle exec number_analyzer two-way-anova --file factorial_data.csv
bundle exec number_analyzer two-way-anova --format=json --precision=3 --factor-a Drug,Drug,Placebo,Placebo --factor-b Male,Female,Male,Female 5.2,7.1,3.8,4.5
bundle exec number_analyzer two-way-anova --quiet --factor-a Treatment,Treatment,Control,Control --factor-b Young,Old,Young,Old 15,18,12,14

# Levene Test for Variance Homogeneity  
bundle exec number_analyzer levene 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer levene --file group1.csv group2.csv group3.csv
bundle exec number_analyzer levene --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer levene --quiet 1 2 3 -- 4 5 6 -- 7 8 9

# Bartlett Test for Variance Homogeneity
bundle exec number_analyzer bartlett 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer bartlett --file group1.csv group2.csv group3.csv
bundle exec number_analyzer bartlett --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer bartlett --quiet 1 2 3 -- 4 5 6 -- 7 8 9

# Kruskal-Wallis Test (Non-parametric ANOVA)
bundle exec number_analyzer kruskal-wallis 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer kruskal-wallis --file group1.csv group2.csv group3.csv
bundle exec number_analyzer kruskal-wallis --format=json --precision=3 1 2 3 -- 4 5 6 -- 7 8 9
bundle exec number_analyzer kruskal-wallis --quiet 1 2 3 -- 4 5 6 -- 7 8 9

# Mann-Whitney U Test (Non-parametric t-test)
bundle exec number_analyzer mann-whitney 1 2 3 -- 4 5 6
bundle exec number_analyzer mann-whitney --file group1.csv group2.csv
bundle exec number_analyzer mann-whitney --format=json --precision=3 1 2 3 -- 6 7 8
bundle exec number_analyzer mann-whitney --quiet 10 20 30 -- 40 50 60

# Specialized Commands with Options
bundle exec number_analyzer percentile 75 --format=json 1 2 3 4 5
bundle exec number_analyzer histogram --quiet 1 2 2 3 3 3
```

**Combined Options**
```bash
# Multiple options can be combined
bundle exec number_analyzer mean --format=json --precision=2 --file data.csv
bundle exec number_analyzer outliers --quiet --precision=1 1 2 3 4 5 100
```

#### Plugin Management Commands (Phase 8.0 Step 5)

NumberAnalyzer provides comprehensive plugin management commands for discovering, managing, and resolving conflicts between plugins:

**List Plugins**
```bash
# List all loaded plugins
bundle exec number_analyzer plugins list

# List plugins with conflict detection
bundle exec number_analyzer plugins list --show-conflicts
```

**Detect Conflicts**
```bash
# Show all plugin conflicts
bundle exec number_analyzer plugins conflicts

# Alternative syntax
bundle exec number_analyzer plugins --conflicts
```

**Resolve Conflicts**
```bash
# Interactive conflict resolution (recommended)
bundle exec number_analyzer plugins resolve my_plugin --strategy=interactive

# Automatic namespace resolution
bundle exec number_analyzer plugins resolve my_plugin --strategy=namespace

# Priority-based resolution
bundle exec number_analyzer plugins resolve my_plugin --strategy=priority

# Disable conflicting plugin
bundle exec number_analyzer plugins resolve my_plugin --strategy=disable

# Force resolution without confirmation
bundle exec number_analyzer plugins resolve my_plugin --strategy=interactive --force
```

**Plugin Help**
```bash
# Get help for plugin commands
bundle exec number_analyzer plugins --help
bundle exec number_analyzer plugins help
```

**Plugin System Features**:
- **Automatic Conflict Detection**: Detects command and method overlaps between plugins
- **5-Tier Priority System**: Development(100) > Core(90) > Official(70) > ThirdParty(50) > Local(30)
- **Namespace Generation**: Automatic prefix generation (de_, co_, of_, th_, lo_) based on priority
- **Interactive Resolution**: Step-by-step conflict resolution with user guidance
- **Configuration Support**: Updates to plugins.yml for persistent resolution

### As a Ruby Library

```ruby
require 'number_analyzer'

# Create analyzer with number array
analyzer = NumberAnalyzer.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

# Calculate and display all statistics
analyzer.calculate_statistics

# Or access individual methods
puts analyzer.median          # => 5.5
puts analyzer.variance        # => 8.25
puts analyzer.mode            # => []
puts analyzer.standard_deviation  # => 2.87

# New percentile, quartiles, and IQR methods
puts analyzer.percentile(25)  # => 3.25
puts analyzer.percentile(95)  # => 9.55
puts analyzer.quartiles       # => {q1: 3.25, q2: 5.5, q3: 7.75}
puts analyzer.interquartile_range  # => 4.5

# Outlier detection and deviation scores
puts analyzer.outliers        # => []
puts analyzer.deviation_scores # => [34.33, 37.81, 41.3, 44.78, 48.26, 51.74, 55.22, 58.7, 62.19, 65.67]

# Correlation analysis
other_data = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
puts analyzer.correlation(other_data)  # => 1.0 (perfect positive correlation)

# T-test analysis (statistical hypothesis testing)
group1 = NumberAnalyzer.new([1, 2, 3, 4, 5])
group2 = [6, 7, 8, 9, 10]
puts group1.t_test(group2, type: :independent)
# => {test_type: "independent_samples", t_statistic: -5.0, degrees_of_freedom: 8.0, p_value: 0.0001794861, significant: true, ...}

# Paired t-test
before = NumberAnalyzer.new([10, 12, 14, 16, 18])
after = [11, 14, 15, 18, 22]
puts before.t_test(after, type: :paired)

# One-sample t-test
sample = NumberAnalyzer.new([18, 20, 22, 24, 26])
puts sample.t_test(nil, type: :one_sample, population_mean: 20)

# Confidence interval analysis
data = NumberAnalyzer.new([1, 2, 3, 4, 5])
puts data.confidence_interval(95)
# => {confidence_level: 95, lower_bound: 1.037, upper_bound: 4.963, point_estimate: 3.0, margin_of_error: 1.963, ...}

puts data.confidence_interval(90)  # 90% confidence interval
puts data.confidence_interval(99)  # 99% confidence interval

# One-way ANOVA analysis
analyzer = NumberAnalyzer.new([])  # Empty analyzer for ANOVA
group1 = [1, 2, 3]
group2 = [4, 5, 6] 
group3 = [7, 8, 9]
puts analyzer.one_way_anova(group1, group2, group3)
# => {f_statistic: 14.538462, p_value: 0.001, degrees_of_freedom: [2, 6], significant: true, 
#     effect_size: {eta_squared: 0.829, omega_squared: 0.744}, interpretation: "有意差あり (p = 0.001), 効果サイズ: 大 (η² = 0.829)", ...}

# Levene test for variance homogeneity (ANOVA prerequisite check)
puts analyzer.levene_test(group1, group2, group3)
# => {test_type: "Levene Test (Brown-Forsythe)", f_statistic: 0.0, p_value: 1.0, degrees_of_freedom: [2, 6], 
#     significant: false, interpretation: "分散の等質性仮説は棄却されない（各グループの分散は等しいと考えられる）"}

# Frequency distribution for data analysis (programmatic access)
puts analyzer.frequency_distribution # => {1=>1, 2=>1, 3=>1, 4=>1, 5=>1, 6=>1, 7=>1, 8=>1, 9=>1, 10=>1}

# Example with repeated values for histogram visualization
scores = NumberAnalyzer.new([85, 90, 85, 92, 88, 85, 90])
puts scores.frequency_distribution  # => {85=>3, 90=>2, 92=>1, 88=>1}

# Example with outliers
outlier_data = NumberAnalyzer.new([1, 2, 3, 4, 5, 100])
puts outlier_data.outliers  # => [100.0]

# Histogram display (automatically included in calculate_statistics output)
scores.display_histogram
# => 度数分布ヒストグラム:
# => 85: ■■■ (3)
# => 88: ■ (1)
# => 90: ■■ (2)
# => 92: ■ (1)

# Or read data from files
require 'number_analyzer/file_reader'

numbers = NumberAnalyzer::FileReader.read_from_file('data.csv')
analyzer = NumberAnalyzer.new(numbers)
analyzer.calculate_statistics
```

### Plugin System Foundation (Phase 8.0 Step 1)

NumberAnalyzer now includes foundational infrastructure for an extensible plugin system. This foundation provides the architecture for future plugin development and extensibility.

**Current Infrastructure:**
- **Plugin System Core**: Plugin registration, loading, and management system
- **Dynamic Command Loading**: Infrastructure for dynamically registering CLI commands
- **Configuration Framework**: YAML-based plugin configuration (`plugins.yml`)
- **Plugin Interfaces**: Base classes for different plugin types (statistics, CLI, file formats, output formats, validators)
- **Plugin Discovery**: Automatic plugin detection and loading capabilities

**Plugin Types Supported:**
- `statistics_module`: Statistical analysis plugins
- `cli_command`: Custom CLI command plugins  
- `file_format`: Data file format readers
- `output_format`: Custom output formatters
- `validator`: Data validation plugins

**Configuration Example:**
```yaml
# plugins.yml
plugins:
  enabled: []  # Plugin loading disabled by default
  paths:
    - './plugins'
    - './lib/number_analyzer/plugins'
  
plugin_config:
  # Future plugin configurations
```

## Example Output

```
合計: 55
平均: 5.5
最大値: 10
最小値: 1
中央値: 5.5
分散: 8.25
最頻値: なし
標準偏差: 2.87
四分位範囲(IQR): 4.5
外れ値: なし
偏差値: 34.33, 37.81, 41.3, 44.78, 48.26, 51.74, 55.22, 58.7, 62.19, 65.67

度数分布ヒストグラム:
1: ■ (1)
2: ■ (1)
3: ■ (1)
4: ■ (1)
5: ■ (1)
6: ■ (1)
7: ■ (1)
8: ■ (1)
9: ■ (1)
10: ■ (1)
```

### Histogram with Repeated Values

For data with repeated values, the histogram shows frequency patterns:

```bash
bundle exec number_analyzer 1 2 2 3 3 3 4 5
```

Output includes:
```
度数分布ヒストグラム:
1.0: ■ (1)
2.0: ■■ (2)
3.0: ■■■ (3)
4.0: ■ (1)
5.0: ■ (1)
```

## Supported File Formats

### CSV Files
```csv
numbers
1
2
3
4
5
```
- First column values are treated as numbers
- Headers are automatically detected and skipped
- Non-numeric rows are ignored

### JSON Files
```json
[1, 2, 3, 4, 5]
```
or
```json
{
  "numbers": [1, 2, 3, 4, 5]
}
```
- Array format: Direct numeric array
- Object format: Uses "numbers", "data", or first array value

### TXT Files
```
1 2 3 4 5
10, 20, 30
100
```
- Space or comma-separated values
- Multi-line support
- Non-numeric values are ignored

## Development

### Running Tests

```bash
bundle exec rspec  # Comprehensive test suite, 100% passing
```

### Code Style

```bash
bundle exec rubocop  # ✅ Zero violations achieved (116 files)
```

## Plugin Development

### Getting Started with Plugin API

NumberAnalyzer provides a comprehensive plugin framework for extending statistical capabilities. Create custom plugins for new algorithms, data formats, or visualization methods.

#### Creating a New Plugin

Generate a plugin template using the built-in generator:

```ruby
# Generate a statistics plugin template
NumberAnalyzer::PluginTemplate.generate('my_stats', :statistics, {
  author: 'Your Name',
  description: 'Custom statistical analysis methods'
})
```

#### Plugin Types Available

1. **Statistics Plugin** - Add new statistical methods
2. **CLI Command Plugin** - Create new command-line interfaces  
3. **File Format Plugin** - Support additional data input formats
4. **Output Format Plugin** - Add new export formats
5. **Validator Plugin** - Custom data validation rules

#### Sample Plugin Usage

```bash
# Machine Learning Plugin Commands
bundle exec number_analyzer linear-regression 1 2 3 4 5
bundle exec number_analyzer k-means --k=3 1 2 3 4 5 6 7 8 9
bundle exec number_analyzer pca --components=2 1 2 3 4 5

# Data Export Plugin Commands  
bundle exec number_analyzer export-csv --file data.txt
bundle exec number_analyzer export-json --precision=3 1 2 3 4 5
bundle exec number_analyzer export-profile --file results.csv

# Visualization Plugin Commands
bundle exec number_analyzer histogram --width=60 1 2 3 4 5
bundle exec number_analyzer dashboard 1 2 3 4 5 6 7 8 9 10
bundle exec number_analyzer scatter 1 2 3 4 5 -- 2 4 6 8 10
```

#### Plugin Security & Validation

All plugins undergo comprehensive security validation:

- **76 Security Patterns** detected (system calls, file operations, network access)
- **4-Level Risk Assessment** (low/medium/high/critical)
- **Code Integrity Verification** using SHA256 hashing
- **Author Trust System** with trusted developer lists
- **Sandboxed Loading** for high-risk plugins

#### Plugin Directory Structure

```
plugins/
├── my_plugin.rb                # Plugin implementation
├── spec/
│   └── my_plugin_spec.rb       # Plugin tests
└── README.md                   # Plugin documentation
```

#### Configuration Management

Configure plugins via `plugins.yml`:

```yaml
plugins:
  enabled:
    - machine_learning
    - data_export
    - visualization
  paths:
    - ./plugins
    - ~/.number_analyzer/plugins
security:
  sandbox_mode: standard
  allow_network_access: false
  trusted_authors:
    - "NumberAnalyzer Team"
```

## Project Structure

```
number_analyzer/
├── lib/
│   ├── number_analyzer.rb          # Core statistical calculations
│   └── number_analyzer/
│       ├── cli.rb                  # Lightweight CLI dispatcher (385 lines, 81% reduction from 2094 lines)
│       ├── cli/                    # CLI Refactoring Phase 2 ✅ Command Pattern + TDD Architecture
│       │   ├── base_command.rb     # Template Method Pattern base class
│       │   ├── command_registry.rb # Command registration and management
│       │   ├── commands.rb         # Auto-loader for all command classes  
│       │   ├── data_input_handler.rb # Unified file/CLI input processing
│       │   └── commands/           # Individual command implementations (29/29 migrated)
│       │       ├── *_command.rb    # 50-80 lines each vs 2094-line monolith
│       ├── file_reader.rb          # File input support (CSV/JSON/TXT)
│       ├── statistics_presenter.rb # Display and formatting logic
│       ├── output_formatter.rb     # Advanced output formatting (JSON, precision, quiet)
│       ├── plugin_system.rb        # Core plugin management system
│       ├── plugin_registry.rb      # Centralized plugin registration and discovery
│       ├── plugin_configuration.rb # Multi-layer configuration management
│       ├── plugin_validator.rb     # Security validation and integrity checking
│       ├── plugin_template.rb      # ERB-based plugin template generator
│       ├── plugin_loader.rb        # Secure plugin discovery and loading
│       └── statistics/             # Modular statistics (8 modules, 96.1% code reduction)
│           ├── basic_stats.rb      # BasicStats module
│           ├── advanced_stats.rb   # AdvancedStats module  
│           ├── math_utils.rb       # MathUtils module
│           ├── correlation_stats.rb # CorrelationStats module
│           ├── time_series_stats.rb # TimeSeriesStats module
│           ├── hypothesis_testing.rb # HypothesisTesting module
│           ├── anova_stats.rb      # ANOVAStats module
│           └── non_parametric_stats.rb # NonParametricStats module
├── plugins/
│   ├── machine_learning_plugin.rb # ML algorithms (regression, clustering, PCA)
│   ├── data_export_plugin.rb      # Data export (CSV, JSON, XML, YAML, TSV)
│   └── visualization_plugin.rb    # ASCII visualization (charts, plots, dashboard)
├── bin/
│   └── number_analyzer             # Executable file
├── spec/
│   ├── number_analyzer_spec.rb     # Core functionality tests
│   └── number_analyzer/
│       ├── cli_spec.rb             # CLI functionality tests
│       ├── file_reader_spec.rb     # File reader functionality tests
│       ├── statistics_presenter_spec.rb # Presentation logic tests
│       ├── output_formatter_spec.rb # Output formatting tests
│       ├── plugin_*_spec.rb        # Plugin system test suite
│       └── statistics/             # Modular statistics tests
├── number_analyzer.gemspec         # Gem specification
└── README.md                       # This file
```

## Architecture

The project follows clean architecture principles with separation of concerns:

### Core Components
- **NumberAnalyzer** - Pure statistical calculation library (8 modular components, 96.1% code reduction)
- **NumberAnalyzer::CLI** - Command line interface and argument parsing with 29 core subcommands plus plugin commands
- **NumberAnalyzer::CLI::StatisticalOutputFormatter** - Shared formatter for consistent statistical command output formatting
- **NumberAnalyzer::FileReader** - File input handling (CSV/JSON/TXT support)
- **NumberAnalyzer::StatisticsPresenter** - Display and formatting logic for full analysis
- **NumberAnalyzer::OutputFormatter** - Advanced output formatting (JSON, precision, quiet mode)

### Plugin API Framework
- **NumberAnalyzer::PluginSystem** - Core plugin management and lifecycle control
- **NumberAnalyzer::PluginRegistry** - Centralized plugin discovery and registration system
- **NumberAnalyzer::PluginConfiguration** - Multi-layer configuration management (default/file/environment)
- **NumberAnalyzer::PluginValidator** - Security validation with 76 dangerous pattern detection rules
- **NumberAnalyzer::PluginTemplate** - ERB-based standardized plugin generation for 5 plugin types
- **NumberAnalyzer::PluginLoader** - Secure plugin loading with risk-based strategies

### Modular Statistics (8 Extracted Modules)
- **BasicStats**, **AdvancedStats**, **MathUtils**, **CorrelationStats**
- **TimeSeriesStats**, **HypothesisTesting**, **ANOVAStats**, **NonParametricStats**

### Sample Plugins
- **MachineLearningPlugin** - Advanced ML algorithms (regression, clustering, PCA)
- **DataExportPlugin** - Multi-format data export with quality assessment
- **VisualizationPlugin** - ASCII visualization with statistical interpretation

This modular design enables independent use of statistical functionality while providing a secure, extensible plugin framework for third-party developers. The Phase 8.0 Step 4 plugin API standardization establishes NumberAnalyzer as a platform for statistical analysis extensions.

## License

MIT
