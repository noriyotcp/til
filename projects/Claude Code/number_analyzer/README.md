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
```

## Development

### Running Tests

```bash
bundle exec rspec
```

### Code Style

```bash
bundle exec rubocop
```

## Project Structure

```
number_analyzer/
├── lib/
│   ├── number_analyzer.rb          # Core statistical calculations
│   └── number_analyzer/
│       └── cli.rb                  # Command line interface
├── bin/
│   └── number_analyzer             # Executable file
├── spec/
│   ├── number_analyzer_spec.rb     # Core functionality tests
│   └── number_analyzer/
│       └── cli_spec.rb             # CLI functionality tests
├── number_analyzer.gemspec         # Gem specification
└── README.md                       # This file
```

## Architecture

The project follows clean architecture principles:

- **NumberAnalyzer** - Pure statistical calculation library (no dependencies)
- **NumberAnalyzer::CLI** - Command line interface (depends on NumberAnalyzer)
- **bin/number_analyzer** - Executable entry point (depends on CLI)

This separation allows the core statistical functionality to be used independently of the command line interface.

## License

MIT