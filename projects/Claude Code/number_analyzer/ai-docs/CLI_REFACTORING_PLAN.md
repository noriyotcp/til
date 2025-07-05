# CLI.rb リファクタリング詳細計画

## 概要

`lib/number_analyzer/cli.rb` の2164行に及ぶ巨大なファイルを、保守性と拡張性の高い構造にリファクタリングする計画書。Command Patternを採用し、各コマンドを独立したクラスに分離することで、責任の明確化とテストの容易化を実現する。

## 現状分析

### ファイル構造の問題点

#### 1. **過大なファイルサイズ**
- **2164行**という単一クラスファイル
- 47個のコマンドハンドラーメソッドが1つのクラスに集中
- 可読性の著しい低下により、新規開発者の学習コストが増大

#### 2. **責務の混在**
現在のCLIクラスが担っている責務：
- コマンドライン引数の解析（OptionParser）
- 各統計機能の実行ロジック（47個の run_* メソッド）
- エラーハンドリングとメッセージ表示
- ヘルプメッセージの生成と表示
- プラグインシステムの管理
- ファイル入力の処理
- 出力フォーマットの制御
- 特殊な引数処理（'--'区切りのグループデータ）

#### 3. **重複コードパターン**

```ruby
# パターン1: 基本的なコマンド処理
private_class_method def self.run_median(args, options = {})
  if options[:help]
    show_help('median', 'Calculate the median (middle value) of numbers')
    return
  end
  
  numbers = parse_numbers_with_options(args, options)
  analyzer = NumberAnalyzer.new(numbers)
  result = analyzer.median
  
  options[:dataset_size] = numbers.size
  puts OutputFormatter.format_value(result, options)
end

# パターン2: グループデータを扱うコマンド
private_class_method def self.run_anova(args, options = {})
  # 特殊な '--' 区切り処理
  # オプション解析
  # グループパース
  # 実行と出力
end
```

#### 4. **テストの困難性**
- 巨大なクラスのため、モックやスタブの設定が複雑
- プライベートクラスメソッドのテストが困難
- 各コマンドの独立したテストが書きづらい

#### 5. **拡張性の問題**
- 新しいコマンドを追加するたびにファイルが肥大化
- プラグインシステムがあるにも関わらず、コアコマンドは全てハードコード
- コマンド間で共通処理を再利用しづらい

## アーキテクチャ設計

### Command Pattern の採用

```
lib/number_analyzer/
├── cli.rb                          # 軽量なCLIディスパッチャー（目標: 100行以下）
├── cli/
│   ├── base_command.rb            # 共通の基底クラス
│   ├── command_registry.rb        # コマンド登録と管理
│   ├── argument_parser.rb         # 引数解析の共通処理
│   ├── data_input_handler.rb      # ファイル/CLI入力の統一処理
│   └── commands/                  # 個別コマンドの実装
│       ├── basic/
│       │   ├── median_command.rb
│       │   ├── mean_command.rb
│       │   ├── mode_command.rb
│       │   ├── sum_command.rb
│       │   ├── min_command.rb
│       │   └── max_command.rb
│       ├── advanced/
│       │   ├── outliers_command.rb
│       │   ├── percentile_command.rb
│       │   ├── quartiles_command.rb
│       │   └── deviation_scores_command.rb
│       ├── analysis/
│       │   ├── correlation_command.rb
│       │   ├── trend_command.rb
│       │   ├── moving_average_command.rb
│       │   └── seasonal_command.rb
│       ├── testing/
│       │   ├── t_test_command.rb
│       │   ├── chi_square_command.rb
│       │   ├── anova_command.rb
│       │   └── confidence_interval_command.rb
│       └── plugin/
│           └── plugins_command.rb
```

### クラス設計

#### BaseCommand 基底クラス

```ruby
module NumberAnalyzer
  module CLI
    class BaseCommand
      attr_reader :name, :description, :options
      
      def initialize
        @name = self.class.command_name
        @description = self.class.description
        @options = default_options
      end
      
      # テンプレートメソッドパターン
      def execute(args, global_options = {})
        @options = @options.merge(global_options)
        
        return show_help if @options[:help]
        
        validate_arguments(args)
        data = parse_input(args)
        result = perform_calculation(data)
        output_result(result)
      rescue StandardError => e
        handle_error(e)
      end
      
      protected
      
      # サブクラスでオーバーライド
      def validate_arguments(args)
        # デフォルト実装
      end
      
      def parse_input(args)
        DataInputHandler.parse(args, @options)
      end
      
      def perform_calculation(data)
        raise NotImplementedError
      end
      
      def output_result(result)
        puts OutputFormatter.format(result, @options)
      end
      
      def handle_error(error)
        puts "エラー: #{error.message}"
        exit 1
      end
      
      private
      
      def default_options
        {
          format: nil,
          precision: nil,
          quiet: false,
          help: false,
          file: nil
        }
      end
      
      class << self
        attr_accessor :command_name, :description
        
        def command(name, description)
          @command_name = name
          @description = description
        end
      end
    end
  end
end
```

#### 個別コマンドの実装例

```ruby
module NumberAnalyzer
  module CLI
    module Commands
      class MedianCommand < BaseCommand
        command 'median', 'Calculate the median (middle value) of numbers'
        
        protected
        
        def perform_calculation(data)
          analyzer = NumberAnalyzer.new(data)
          analyzer.median
        end
        
        def output_result(result)
          @options[:dataset_size] = @data.size
          super
        end
      end
    end
  end
end
```

#### CommandRegistry

```ruby
module NumberAnalyzer
  module CLI
    class CommandRegistry
      class << self
        def register(command_class)
          commands[command_class.command_name] = command_class
        end
        
        def get(command_name)
          commands[command_name]
        end
        
        def all
          commands.keys.sort
        end
        
        def execute(command_name, args, options = {})
          command_class = get(command_name)
          return nil unless command_class
          
          command = command_class.new
          command.execute(args, options)
        end
        
        private
        
        def commands
          @commands ||= {}
        end
      end
    end
  end
end
```

## TDD実装戦略

### TDD原則の遵守

このリファクタリングは**Test-Driven Development (TDD)**で実施します。TDD原則に従い、以下のサイクルを厳守します。

#### 1. Red-Green-Refactor サイクル
- **Red**: 失敗するテストを先に書く
- **Green**: テストを通す最小限の実装
- **Refactor**: コードの品質を改善（テストは常にグリーン維持）

#### 2. テストファースト開発フロー

```ruby
# Step 1: 失敗するテストを書く（RED）
RSpec.describe NumberAnalyzer::CLI::Commands::MedianCommand do
  it 'calculates median of odd number of elements' do
    command = described_class.new
    # この時点ではperform_calculationメソッドは存在しない
    expect(command.perform_calculation([1, 3, 5])).to eq(3.0)
  end
end

# Step 2: 最小限の実装（GREEN）
def perform_calculation(data)
  # 仮実装でテストを通す
  3.0
end

# Step 3: 正しい実装にリファクタリング（REFACTOR）
def perform_calculation(data)
  analyzer = NumberAnalyzer.new(data)
  analyzer.median
end
```

#### 3. 各コマンドのTDD実装手順
1. **テストケースの洗い出し**
   - 正常系（通常の使用ケース）
   - 異常系（エラーケース）
   - 境界値（空配列、単一要素、大量データ）

2. **インクリメンタルな実装**
   - 1つのテストケースを追加
   - そのテストを通す実装
   - リファクタリング
   - 次のテストケースへ

3. **共通処理の抽出**
   - 2つ以上のコマンドで重複が見つかったら抽出
   - DRY原則の適用

### 具体的なTDD実装例

#### MedianCommand のTDD実装

```ruby
# spec/number_analyzer/cli/commands/median_command_spec.rb

RSpec.describe NumberAnalyzer::CLI::Commands::MedianCommand do
  let(:command) { described_class.new }

  # Step 1: 基本的な計算のテスト（単体テスト）
  describe '#perform_calculation' do
    context '正常系' do
      it 'calculates median of odd number of elements' do
        # Arrange
        data = [1, 3, 5]
        
        # Act & Assert
        expect(command.perform_calculation(data)).to eq(3.0)
      end

      it 'calculates median of even number of elements' do
        expect(command.perform_calculation([1, 2, 3, 4])).to eq(2.5)
      end

      it 'handles single element' do
        expect(command.perform_calculation([42])).to eq(42.0)
      end

      it 'handles unsorted data' do
        expect(command.perform_calculation([5, 1, 3])).to eq(3.0)
      end
    end

    context '異常系' do
      it 'raises error for empty array' do
        expect { command.perform_calculation([]) }
          .to raise_error(ArgumentError, /空の配列/)
      end
    end
  end

  # Step 2: 引数解析のテスト
  describe '#validate_arguments' do
    context '正常系' do
      it 'accepts numeric strings' do
        expect { command.validate_arguments(['1', '2', '3']) }
          .not_to raise_error
      end

      it 'accepts floating point strings' do
        expect { command.validate_arguments(['1.5', '2.7', '3.14']) }
          .not_to raise_error
      end
    end

    context '異常系' do
      it 'rejects non-numeric strings' do
        expect { command.validate_arguments(['1', 'abc', '3']) }
          .to raise_error(ArgumentError, /無効な引数/)
      end

      it 'rejects empty arguments' do
        expect { command.validate_arguments([]) }
          .to raise_error(ArgumentError, /数値を指定/)
      end
    end
  end

  # Step 3: 出力フォーマットのテスト
  describe '#output_result' do
    let(:result) { 2.5 }

    it 'formats standard output' do
      expect { command.output_result(result) }
        .to output("2.5\n").to_stdout
    end

    it 'formats with precision' do
      command.instance_variable_set(:@options, { precision: 1 })
      expect { command.output_result(result) }
        .to output("2.5\n").to_stdout
    end

    it 'formats as JSON' do
      command.instance_variable_set(:@options, { format: 'json' })
      expect { command.output_result(result) }
        .to output(include('"median": 2.5')).to_stdout
    end
  end

  # Step 4: 統合テスト
  describe '#execute' do
    context 'コマンドライン引数' do
      it 'calculates median from arguments' do
        expect { command.execute(['1', '2', '3']) }
          .to output("2.0\n").to_stdout
      end

      it 'shows help with --help option' do
        expect { command.execute([], help: true) }
          .to output(include('Calculate the median')).to_stdout
      end
    end

    context 'ファイル入力' do
      let(:test_file) { 'spec/fixtures/test_data.csv' }

      before do
        File.write(test_file, "1\n2\n3\n4\n5")
      end

      after do
        File.delete(test_file) if File.exist?(test_file)
      end

      it 'reads data from file' do
        expect { command.execute([], file: test_file) }
          .to output("3.0\n").to_stdout
      end
    end

    context 'エラーハンドリング' do
      it 'handles invalid arguments gracefully' do
        expect { command.execute(['1', 'invalid', '3']) }
          .to output(include('エラー')).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end
end
```

### TDD品質ゲート

#### 各フェーズの完了条件
1. **テストカバレッジ**
   - 新規コードは100%カバレッジ必須
   - 既存コードは95%以上を維持
   - カバレッジレポートの自動生成

2. **テスト粒度**
   - ユニットテスト: メソッド単位の振る舞い
   - 統合テスト: コマンド全体の動作
   - E2Eテスト: CLIからの実行

3. **テストの品質基準**
   - **独立性**: 各テストは他のテストに依存しない
   - **速度**: 単体テストは1秒以内に完了
   - **明確性**: テスト名から何をテストしているか明確
   - **AAA原則**: Arrange-Act-Assert構造の遵守

4. **継続的インテグレーション**
   - プッシュ時に全テスト自動実行
   - テスト失敗時はマージ不可
   - カバレッジ低下時は警告

### TDD実装の利点

1. **設計の改善**
   - テストしやすい設計は良い設計
   - 依存関係の明確化
   - インターフェースの洗練

2. **リグレッション防止**
   - 既存機能の破壊を即座に検出
   - 安心してリファクタリング可能

3. **ドキュメント効果**
   - テストコードが仕様書として機能
   - 使用例が明確

4. **開発速度向上**
   - デバッグ時間の削減
   - 手戻りの最小化

## 実装計画

### Phase 1: 基盤構築（推定: 2-3日）

#### Step 1.1: ディレクトリ構造の作成
```bash
mkdir -p lib/number_analyzer/cli/commands/{basic,advanced,analysis,testing,plugin}
```

#### Step 1.2: BaseCommand クラスの実装
- 共通インターフェースの定義
- エラーハンドリングの標準化
- ヘルプ表示の共通化

#### Step 1.3: CommandRegistry の実装
- コマンドの登録機能
- コマンドの検索と実行
- プラグインシステムとの統合準備

#### Step 1.4: 共通ユーティリティの実装
- ArgumentParser: 引数解析の共通処理
- DataInputHandler: ファイル/CLI入力の統一処理
- ErrorHandler: エラー処理の標準化

### Phase 2: シンプルコマンドの移行（推定: 3-4日）

#### Step 2.1: 基本統計コマンドの移行
対象コマンド（6個）:
- median, mean, mode, sum, min, max

各コマンドについて：
1. 個別コマンドクラスの作成
2. 既存ロジックの移植
3. 単体テストの追加
4. 統合テストでの動作確認

#### Step 2.2: ヒストグラムコマンドの移行
- 特殊な出力形式への対応
- JSON/quiet フォーマットのサポート

### Phase 3: 複雑コマンドの移行（推定: 5-7日）

#### Step 3.1: グループデータを扱うコマンド
対象コマンド:
- anova, chi-square, levene, bartlett, kruskal-wallis
- mann-whitney, wilcoxon, friedman

課題：
- '--' 区切りによるグループデータの解析
- 複数ファイル入力のサポート
- 特殊なオプション処理

#### Step 3.2: パラメータ付きコマンド
対象コマンド:
- percentile (パーセンタイル値の指定)
- confidence-interval (信頼水準の指定)
- moving-average (ウィンドウサイズの指定)

#### Step 3.3: 複雑なオプションを持つコマンド
対象コマンド:
- t-test (paired, one-sample, independent)
- two-way-anova (factor-a, factor-b)

### Phase 4: プラグイン管理コマンドの独立化（推定: 2日）

#### Step 4.1: PluginsCommand の実装
- list, resolve, conflicts サブコマンドの実装
- 対話的な処理のサポート

#### Step 4.2: プラグインシステムとの統合
- 動的コマンド登録の改善
- コマンド衝突の検出と解決

### Phase 5: CLI.rb の軽量化（推定: 1-2日）

#### Step 5.1: レガシーコードの削除
- 移行済みコマンドの削除
- 不要になった共通処理の削除

#### Step 5.2: ディスパッチャーとしての最適化
```ruby
module NumberAnalyzer
  class CLI
    def self.run(argv = ARGV)
      # プラグインの初期化
      initialize_plugins
      
      # コマンドの解析と実行
      command_name = argv.first
      
      if command_name.nil? || command_name.start_with?('-')
        # フル解析モード
        run_full_analysis(argv)
      elsif CommandRegistry.exists?(command_name)
        # コマンド実行
        CommandRegistry.execute(command_name, argv[1..])
      else
        puts "Unknown command: #{command_name}"
        exit 1
      end
    end
  end
end
```

## 品質保証戦略

### 1. 後方互換性の維持
- 既存のCLIインターフェースを完全に保持
- 全てのオプションと引数形式をサポート
- 出力フォーマットの完全な互換性

### 2. テスト戦略

#### 単体テスト
```ruby
RSpec.describe NumberAnalyzer::CLI::Commands::MedianCommand do
  let(:command) { described_class.new }
  
  describe '#execute' do
    it 'calculates median correctly' do
      expect { command.execute(['1', '2', '3']) }
        .to output("2.0\n").to_stdout
    end
    
    it 'handles file input' do
      expect { command.execute([], file: 'data.csv') }
        .to output(/\d+\.\d+\n/).to_stdout
    end
  end
end
```

#### 統合テスト
- 既存の統合テストをすべて通過させる
- コマンドライン経由での実行テスト
- エンドツーエンドのシナリオテスト

### 3. 段階的リリース

#### リリース戦略
1. **Phase 1-2 完了後**: ベータ版として一部コマンドを新実装に切り替え
2. **Phase 3 完了後**: 全コマンドの新実装への切り替え
3. **Phase 4-5 完了後**: レガシーコードの完全削除

#### ロールバック計画
- 各フェーズごとにGitタグを作成
- 問題発生時は即座に前バージョンに戻せる体制

## 期待される効果

### 1. 保守性の向上
- **変更の局所化**: 各コマンドが独立しているため、変更の影響範囲が限定
- **理解しやすさ**: 各ファイルが100-200行程度になり、理解が容易
- **デバッグの容易さ**: 問題の切り分けが簡単

### 2. テスト性の向上
- **単体テストの書きやすさ**: 各コマンドを独立してテスト可能
- **モックの簡略化**: 依存関係が明確で、モックが簡単
- **カバレッジの向上**: 各コマンドのエッジケースをテストしやすい

### 3. 拡張性の向上
- **新規コマンドの追加**: BaseCommandを継承するだけで簡単に追加
- **プラグイン化**: 既存コマンドもプラグインとして扱える
- **機能の組み合わせ**: コマンド間での機能共有が容易

### 4. 開発効率の改善
- **並行開発**: 複数の開発者が異なるコマンドを同時に開発可能
- **レビューの効率化**: 小さなファイル単位でのレビューが可能
- **オンボーディング**: 新規開発者が特定のコマンドから理解を始められる

## リスクと対策

### 1. 実装リスク
- **既存機能の破壊**: 段階的な移行と包括的なテストで対策
- **パフォーマンスの低下**: ベンチマークテストで監視
- **複雑性の増加**: 明確なディレクトリ構造とドキュメントで対策

### 2. 移行リスク
- **並行開発との競合**: feature ブランチでの開発と定期的なマージ
- **ユーザーへの影響**: 段階的リリースと十分なテスト期間の確保

## 実装優先順位

1. **高優先度**: 基盤構築（Phase 1）とシンプルコマンド（Phase 2）
2. **中優先度**: 使用頻度の高い複雑コマンド（Phase 3の一部）
3. **低優先度**: 使用頻度の低いコマンドとクリーンアップ（Phase 4-5）

## 成功指標

1. **コード品質**
   - CLI.rb が100行以下に削減
   - 各コマンドファイルが200行以下
   - RuboCop違反ゼロ

2. **テスト品質**
   - 既存の統合テスト100%通過
   - 各コマンドの単体テストカバレッジ90%以上
   - E2Eテストの追加

3. **開発効率**
   - 新規コマンド追加時間の50%削減
   - コードレビュー時間の30%削減
   - バグ修正時間の40%削減