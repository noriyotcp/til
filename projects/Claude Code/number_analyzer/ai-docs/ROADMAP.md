# Development Roadmap

## Completed Phases

### Phase 1: CLI機能追加 ✅ 完了
- [x] コマンドライン引数での数値入力対応
- [x] 入力検証とエラーハンドリング
- [x] デフォルト配列へのフォールバック機能
- [x] CLI機能の包括的テスト追加（15のテストケース）

### Phase 2: Ruby Gem構造化 ✅ 完了
- [x] 標準的なGem構造（lib/, bin/, spec/）への移行
- [x] 名前空間設計（NumberAnalyzer::CLI等）
- [x] 依存関係管理（gemspec）
- [x] `bundle exec number_analyzer`実行対応

### Phase 3: 統計機能拡張 ✅ 完了
- [x] 中央値、最頻値、分散、標準偏差
- [x] パーセンタイル、四分位数、四分位範囲
- [x] 外れ値検出、偏差値計算
- [x] 線形補間法による数学的正確性
- [x] TDD（Red-Green-Refactor）による段階的実装

### Phase 4: コード品質改善 ✅ 完了
- [x] 責任分離アーキテクチャ（StatisticsPresenter分離）
- [x] FileReader複雑度削減（メソッド分割）
- [x] RuboCop主要違反解消
- [x] テスタビリティ向上（独立テスト可能）

### Phase 5: データ可視化 ✅ 完了
- [x] 度数分布機能（Ruby `tally`メソッド活用）
- [x] ASCII artヒストグラム表示（■文字可視化）
- [x] StatisticsPresenterへの自動統合
- [x] 包括的テストスイート（12テストケース）

**現在の成果**: 121テストケース、15統計指標、企業レベル品質

---

## Phase 6: CLI Subcommands Implementation 🚀 計画中

### Overview
Transform the current monolithic output into focused, individual statistical analysis commands for enhanced usability and scriptability.

### Goals
- **Modularity**: Each statistic accessible individually
- **Scriptability**: Pipeline-friendly single-value outputs  
- **Usability**: Intuitive subcommand interface
- **Extensibility**: Foundation for future plugin system

## Implementation Phases

### 6.1 Basic Subcommands (Priority: High)
**Target**: Core statistics with simple, clean output

```bash
# Basic Statistics
bundle exec number_analyzer median 1 2 3 4 5      #=> 3.0
bundle exec number_analyzer mean 1 2 3 4 5        #=> 3.0  
bundle exec number_analyzer mode 1 2 2 3          #=> 2
bundle exec number_analyzer sum 1 2 3 4 5         #=> 15
bundle exec number_analyzer min 1 2 3 4 5         #=> 1
bundle exec number_analyzer max 1 2 3 4 5         #=> 5

# Data Visualization
bundle exec number_analyzer histogram 1 2 2 3 3 3 
# => 度数分布ヒストグラム:
# => 1: ■ (1)
# => 2: ■■ (2)
# => 3: ■■■ (3)
```

**Implementation**:
- Extend `NumberAnalyzer::CLI` with subcommand routing
- Maintain backward compatibility (no subcommand = full analysis)
- Add focused output methods for each statistic

### 6.2 Advanced Statistics (Priority: Medium)
**Target**: Complex calculations with detailed output options

```bash
# Advanced Analysis
bundle exec number_analyzer outliers 1 2 3 100    #=> [100]
bundle exec number_analyzer percentile 75 1 2 3 4 5 #=> 4.0
bundle exec number_analyzer quartiles 1 2 3 4 5   
# => Q1: 2.0
# => Q2: 3.0  
# => Q3: 4.0

bundle exec number_analyzer variance 1 2 3 4 5     #=> 2.0
bundle exec number_analyzer std 1 2 3 4 5          #=> 1.41
bundle exec number_analyzer deviation-scores 60 70 80 90 100
# => [35.86, 42.93, 50.0, 57.07, 64.14]
```

**Implementation**:
- Handle complex output formatting
- Support parameterized commands (percentile value)
- Add input validation per command

### 6.3 Output Format & Options (Priority: Low)
**Target**: Flexible output for different use cases

```bash
# Output Formatting
bundle exec number_analyzer median --format=json 1 2 3  
#=> {"median": 2.0, "dataset_size": 3}

bundle exec number_analyzer mean --precision=4 1 2 3    
#=> 2.0000

bundle exec number_analyzer outliers --quiet 1 2 3 100  
#=> 100

# File Input Support (all subcommands)
bundle exec number_analyzer median --file data.csv
bundle exec number_analyzer histogram -f scores.json
```

**Implementation**:
- JSON output format option
- Precision control for decimal values
- Quiet mode for script integration
- Universal file input support

## Technical Design

### CLI Architecture Extension

```ruby
# lib/number_analyzer/cli.rb
class CLI
  COMMANDS = {
    'median' => :run_median,
    'mean' => :run_mean,
    'mode' => :run_mode,
    'sum' => :run_sum,
    'min' => :run_min,
    'max' => :run_max,
    'histogram' => :run_histogram,
    'outliers' => :run_outliers,
    'percentile' => :run_percentile,
    'quartiles' => :run_quartiles,
    'variance' => :run_variance,
    'std' => :run_standard_deviation,
    'deviation-scores' => :run_deviation_scores
  }.freeze
  
  def run_subcommand(command, args)
    return run_default(args) unless COMMANDS.key?(command)
    
    method_name = COMMANDS[command]
    send(method_name, args)
  end
  
  private
  
  def run_median(args)
    numbers = parse_numbers(args)
    analyzer = NumberAnalyzer.new(numbers)
    puts analyzer.median
  end
  
  # ... other command implementations
end
```

### Output Strategy

- **Default Mode**: Human-readable with context
- **JSON Mode**: Machine-readable structured data  
- **Quiet Mode**: Value only (pipeline-friendly)
- **Precision Control**: Configurable decimal places

### Backward Compatibility

```bash
# Current behavior (preserved)
bundle exec number_analyzer 1 2 3 4 5
# => Full statistical analysis with histogram

# New subcommand behavior
bundle exec number_analyzer median 1 2 3 4 5  
# => 3.0
```

## Benefits

### For Users
- **Learning Tool**: Focus on individual statistical concepts
- **Script Integration**: Easy CI/CD and automation use
- **Performance**: Avoid unnecessary calculations
- **Flexibility**: Choose relevant analysis methods

### For Developers
- **Extensibility**: Easy to add new statistical methods
- **Testing**: Isolated testing of individual commands
- **Maintenance**: Clear separation of concerns
- **Plugin Foundation**: Framework for future extensions

## Implementation Timeline

### Week 1: Foundation (6.1 Basic Commands)
- [ ] CLI routing architecture
- [ ] Core statistics: median, mean, mode, sum, min, max
- [ ] Basic histogram command
- [ ] Backward compatibility testing

### Week 2: Advanced Features (6.2)
- [ ] Complex statistics: outliers, percentiles, quartiles
- [ ] Parameterized commands (percentile value input)
- [ ] Variance, standard deviation, deviation scores
- [ ] Advanced input validation

### Week 3: Output Enhancement (6.3)
- [ ] JSON output format option
- [ ] Precision control implementation
- [ ] Quiet mode for scripting
- [ ] Universal file input support

### Week 4: Polish & Documentation
- [ ] Comprehensive help system (`--help` per command)
- [ ] Error handling improvement
- [ ] Performance optimization
- [ ] Documentation updates (README.md)
- [ ] Release preparation

## Success Metrics

- **All existing tests pass** (121 test cases maintained)
- **New subcommand tests** (target: 20+ additional test cases)
- **Performance improvement** for single-statistic use cases
- **User experience enhancement** measured by usage simplicity
- **Plugin readiness** for future extension development

## Future Considerations (Phase 7+)

### Plugin System Architecture
- Dynamic command loading
- Third-party extension support
- Configuration-based plugin management

### Advanced Features
- **Correlation analysis**: `bundle exec number_analyzer correlation x.csv y.csv`
- **Time series**: `bundle exec number_analyzer trend data.csv --column=sales`
- **Statistical tests**: `bundle exec number_analyzer t-test group1.csv group2.csv`

### Integration Possibilities
- R/Python interoperability
- Database connectivity
- Web API endpoints
- Jupyter notebook integration