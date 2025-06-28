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
- **Frequency Distribution** - Count occurrences of each value for data distribution analysis
- **Histogram Display** - ASCII art visualization of frequency distribution with automatic scaling
- **File Input Support** - Read data from CSV, JSON, and TXT files

## Installation

### Local Development

1. Clone the repository and navigate to the directory
2. Install dependencies:
   ```bash
   bundle install
   ```

### As a Local Gem

Build and install the gem locally:
```bash
gem build number_analyzer.gemspec
gem install ./number_analyzer-1.0.0.gem
```

## Usage

### Command Line Interface

#### Using bundle exec (recommended for development)
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
```

#### Using the bin file directly
```bash
ruby -Ilib bin/number_analyzer 1 2 3 4 5
```

#### As an installed gem
```bash
number_analyzer 1 2 3 4 5
```

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
bundle exec rspec
```

### Code Style

```bash
bundle exec rubocop
```

## Documentation

### Complete Documentation
- **[FEATURES.md](ai-docs/FEATURES.md)** - Comprehensive feature documentation and technical specifications
- **[ARCHITECTURE.md](ai-docs/ARCHITECTURE.md)** - Technical architecture, design patterns, and system structure  
- **[ROADMAP.md](ai-docs/ROADMAP.md)** - Development phases, future plans, and Phase 6 CLI subcommands design

### For Developers
- **[CLAUDE.md](CLAUDE.md)** - Development guidance for Claude Code integration

## Project Structure

```
number_analyzer/
├── lib/
│   ├── number_analyzer.rb          # Core statistical calculations
│   └── number_analyzer/
│       ├── cli.rb                  # Command line interface
│       ├── file_reader.rb          # File input support (CSV/JSON/TXT)
│       └── statistics_presenter.rb # Display and formatting logic
├── bin/
│   └── number_analyzer             # Executable file
├── spec/
│   ├── number_analyzer_spec.rb     # Core functionality tests
│   └── number_analyzer/
│       ├── cli_spec.rb             # CLI functionality tests
│       ├── file_reader_spec.rb     # File reader functionality tests
│       └── statistics_presenter_spec.rb # Presentation logic tests
├── number_analyzer.gemspec         # Gem specification
└── README.md                       # This file
```

## Architecture

The project follows clean architecture principles with separation of concerns:

- **NumberAnalyzer** - Pure statistical calculation library (no dependencies)
- **NumberAnalyzer::CLI** - Command line interface and argument parsing
- **NumberAnalyzer::FileReader** - File input handling (CSV/JSON/TXT support)
- **NumberAnalyzer::StatisticsPresenter** - Display and formatting logic
- **bin/number_analyzer** - Executable entry point

This modular design allows the core statistical functionality to be used independently, while maintaining clear responsibilities for each component.

## License

MIT