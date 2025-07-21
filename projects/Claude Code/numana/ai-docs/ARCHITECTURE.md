# Technical Architecture

## Project Structure

### Directory Layout
```
number_analyzer/
├── lib/                           # Core library code
│   ├── number_analyzer.rb         # Main statistical analysis class
│   └── number_analyzer/           # Namespace modules
│       ├── cli.rb                 # Command-line interface
│       ├── file_reader.rb         # File input handling
│       └── statistics_presenter.rb # Output formatting
├── bin/                           # Executable files
│   └── number_analyzer            # CLI entry point
├── spec/                          # Test suite
│   ├── number_analyzer_spec.rb    # Core functionality tests (69 cases)
│   └── number_analyzer/           # Module tests
│       ├── cli_spec.rb            # CLI tests (15 cases)
│       ├── file_reader_spec.rb    # File reader tests (27 cases)
│       └── statistics_presenter_spec.rb # Presenter tests (13 cases)
├── ai-docs/                       # AI-Generated Documentation
│   ├── ROADMAP.md                 # Development planning
│   ├── FEATURES.md                # Feature documentation
│   └── ARCHITECTURE.md            # This file
├── spec/fixtures/                 # Test data files
│   ├── sample_data.csv
│   ├── sample_data.json
│   └── sample_data.txt
├── .claude/commands/              # Claude Code integration
├── Gemfile                        # Dependency management
├── number_analyzer.gemspec        # Gem specification
├── .rubocop.yml                   # Code style configuration
└── README.md                      # User documentation
```

## Class Architecture

### Core Components

#### 1. NumberAnalyzer (Core Domain Logic)
**Location**: `lib/number_analyzer.rb`  
**Responsibility**: Pure statistical calculations  
**Dependencies**: None (Pure Ruby)

```ruby
class NumberAnalyzer
  def initialize(numbers)
  
  # Basic Statistics
  def calculate_statistics  # Orchestrates full analysis
  def median = percentile(50)  # Endless method for elegance
  def mode
  def variance
  def standard_deviation
  
  # Advanced Statistics  
  def percentile(percentile_value)
  def quartiles
  def interquartile_range
  def outliers
  def deviation_scores
  
  # Data Analysis
  def frequency_distribution
  def display_histogram
  
  private
  def average_value  # Encapsulated calculation
end
```

**Design Principles**:
- **Single Responsibility**: Only statistical calculations
- **Pure Functions**: No side effects (except display_histogram)
- **Mathematical Accuracy**: Linear interpolation for percentiles
- **Edge Case Handling**: Robust handling of empty/single values

#### 2. NumberAnalyzer::CLI (Interface Layer)
**Location**: `lib/number_analyzer/cli.rb`  
**Responsibility**: Command-line argument processing  
**Dependencies**: NumberAnalyzer, FileReader

```ruby
class NumberAnalyzer::CLI
  def self.run(args)
  
  private
  def self.parse_arguments(args)
  def self.parse_numbers(args)
  def self.show_help
  def self.valid_number?(str)
end
```

**Features**:
- **Argument Parsing**: Handles file flags and numeric inputs
- **Input Validation**: Robust number parsing with error handling
- **Help System**: Built-in usage documentation
- **File Integration**: Seamless FileReader integration

#### 3. NumberAnalyzer::FileReader (Input Layer)
**Location**: `lib/number_analyzer/file_reader.rb`  
**Responsibility**: Multi-format file input handling  
**Dependencies**: CSV, JSON (Ruby standard library)

```ruby
class NumberAnalyzer::FileReader
  def self.read_from_file(file_path)
  
  private
  def self.read_csv(file_path)
  def self.try_read_without_header(file_path)  # Strategy 1
  def self.try_read_with_header(file_path)     # Strategy 2
  def self.parse_csv_value(value)              # Robust parsing
  
  def self.read_json(file_path)
  def self.extract_from_json_array(data)      # Array format
  def self.extract_from_json_object(data)     # Object format
  def self.find_numeric_array_in_object(hash) # Key discovery
  
  def self.read_txt(file_path)                 # Plain text parsing
end
```

**Design Features**:
- **Strategy Pattern**: Multiple parsing approaches for CSV
- **Format Detection**: Automatic file type recognition
- **Error Recovery**: Graceful handling of malformed data
- **Ruby Idioms**: `Float(exception: false)` for safe parsing

#### 4. NumberAnalyzer::StatisticsPresenter (Presentation Layer)
**Location**: `lib/number_analyzer/statistics_presenter.rb`  
**Responsibility**: Output formatting and display  
**Dependencies**: None

```ruby
class NumberAnalyzer::StatisticsPresenter
  def self.display_results(stats)
  def self.display_histogram(frequency_distribution)
  
  private
  def self.format_mode(mode_values)
  def self.format_outliers(outlier_values)
  def self.format_deviation_scores(deviation_scores)
end
```

**Presentation Features**:
- **Consistent Formatting**: Unified output style
- **Localization**: Japanese labels for accessibility
- **Histogram Integration**: ASCII art visualization
- **Null Handling**: Graceful handling of missing data

## Dependency Architecture

### Clean Dependency Flow
```
bin/number_analyzer
 ↓ requires
NumberAnalyzer::CLI
 ↓ requires
NumberAnalyzer ← StatisticsPresenter
 ↑ uses
NumberAnalyzer::FileReader
```

### Namespace Design
- **Root**: `NumberAnalyzer` (core domain)
- **Modules**: `NumberAnalyzer::*` (supporting functionality)
- **Isolation**: No circular dependencies
- **Extensibility**: Easy plugin addition via namespace

## Design Patterns

### 1. Single Responsibility Principle (SRP)
Each class has a single, well-defined responsibility:
- **NumberAnalyzer**: Statistical calculations only
- **CLI**: Command-line interface only  
- **FileReader**: File input only
- **StatisticsPresenter**: Output formatting only

### 2. Strategy Pattern (FileReader)
Multiple parsing strategies for different file formats and error conditions:
```ruby
# CSV parsing strategies
try_read_without_header(file_path)  # Assume all numeric
try_read_with_header(file_path)     # Skip header row

# JSON parsing strategies  
extract_from_json_array(data)       # Direct array
extract_from_json_object(data)      # Object with numeric array
```

### 3. Template Method Pattern (Statistical Analysis)
`calculate_statistics` orchestrates the full analysis workflow:
```ruby
def calculate_statistics
  stats = {
    total: @numbers.sum,
    average: average_value,
    # ... all statistics
    frequency_distribution: frequency_distribution
  }
  
  StatisticsPresenter.display_results(stats)
end
```

### 4. Factory Pattern (CLI Entry Point)
The CLI acts as a factory for creating NumberAnalyzer instances:
```ruby
def self.run(args)
  # Parse input (args or file)
  numbers = parse_input(args)
  
  # Create analyzer
  analyzer = NumberAnalyzer.new(numbers)
  
  # Execute analysis
  analyzer.calculate_statistics
end
```

## Data Flow Architecture

### Input Processing Flow
```
Command Line Args → CLI.parse_arguments → 
                                      ↓
File Path → FileReader.read_from_file → Numbers Array
                                      ↓
Numbers Array → NumberAnalyzer.new → Statistical Analysis
                                      ↓
Statistics Hash → StatisticsPresenter.display_results → Console Output
```

### Statistical Calculation Flow
```
Numbers Array → Basic Stats (sum, mean, min, max)
             → Distribution Stats (median, mode, variance)
             → Advanced Stats (percentiles, quartiles, IQR)
             → Analysis Stats (outliers, deviation scores)
             → Visualization (frequency distribution, histogram)
```

## Testing Architecture

### Test Structure Philosophy
- **Unit Tests**: Each class tested in isolation
- **Integration Tests**: Full CLI workflow testing
- **Edge Case Coverage**: Empty arrays, single values, extreme inputs
- **TDD Practice**: Tests written before implementation

### Test Categories

#### Core Statistical Tests (69 cases)
- **Basic Operations**: sum, mean, min, max
- **Distribution**: median, mode, variance, standard deviation
- **Advanced**: percentiles, quartiles, IQR, outliers, deviation scores
- **Visualization**: frequency distribution, histogram display
- **Edge Cases**: empty arrays, single values, identical values

#### CLI Integration Tests (15 cases)
- **Argument Parsing**: numeric inputs, file flags
- **Error Handling**: invalid inputs, missing files
- **Default Behavior**: fallback data handling
- **Help System**: documentation display

#### File Reader Tests (27 cases)
- **CSV Parsing**: with/without headers, malformed data
- **JSON Processing**: array/object formats, key discovery
- **TXT Handling**: space/comma separation, multi-line
- **Error Recovery**: invalid files, parsing failures

#### Presentation Tests (13 cases)
- **Output Formatting**: statistics display, histogram rendering
- **Edge Cases**: null values, empty distributions
- **Integration**: frequency distribution display

## Performance Characteristics

### Algorithmic Complexity
- **Basic Statistics**: O(n) - single pass calculations
- **Sorting Operations**: O(n log n) - median, quartiles, outliers
- **Frequency Distribution**: O(n) - Ruby `tally` method
- **Overall**: O(n log n) dominated by sorting requirements

### Memory Usage
- **Input Storage**: O(n) - stores original number array
- **Calculation**: O(1) additional space for most operations
- **Frequency Map**: O(k) where k = unique values
- **Optimized**: No unnecessary data duplication

### Ruby Optimization Strategies
- **Built-in Methods**: Leverages optimized Ruby methods (`sum`, `sort`, `tally`)
- **Lazy Evaluation**: Statistics calculated only when requested
- **Minimal Objects**: Avoids unnecessary object creation
- **Efficient Parsing**: `Float(exception: false)` for safe conversions

## Extension Architecture

### Plugin Readiness
The current architecture supports easy extension through:

#### 1. New Statistical Methods
Add to NumberAnalyzer class:
```ruby
def correlation(other_dataset)
  # Implementation
end
```

#### 2. New Input Formats
Add to FileReader:
```ruby
def self.read_xlsx(file_path)
  # Excel file support
end
```

#### 3. New Output Formats
Add to StatisticsPresenter:
```ruby
def self.display_json(stats)
  # JSON output format
end
```

#### 4. CLI Subcommands (Phase 6)
Extend CLI with command routing:
```ruby
COMMANDS = {
  'median' => :run_median,
  'histogram' => :run_histogram
}.freeze
```

### Future Architecture Considerations
- **Configuration System**: YAML/JSON config file support
- **Plugin Loading**: Dynamic module loading mechanism
- **API Layer**: HTTP API for web integration

## Quality Assurance

### Code Quality Metrics
- **RuboCop Compliance**: High adherence to Ruby style guide
- **Test Coverage**: 121 test cases across all components
- **Cyclomatic Complexity**: Low complexity through method decomposition
- **Maintainability**: Clear separation of concerns

### Design Quality
- **SOLID Principles**: All five principles consistently applied
- **DRY (Don't Repeat Yourself)**: Common functionality properly abstracted
- **YAGNI (You Aren't Gonna Need It)**: No speculative functionality
- **Clean Code**: Self-documenting code with meaningful names

This architecture provides a solid foundation for statistical analysis with excellent extensibility for future enhancements while maintaining clean, testable, and maintainable code.