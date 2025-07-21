# CLI Refactoring Guide

このドキュメントは、NumberAnalyzer の CLI を Command Pattern へ移行する際の知見をまとめたものです。

## 概要

CLI Refactoring は、2185行の巨大な `cli.rb` ファイルを、Command Pattern を使用した小さな独立したコマンドクラスに分割するプロジェクトです。

## 移行時の注意点

### 1. CommandRegistry 統合の落とし穴

#### 問題
新しくCommand Patternで実装したコマンドをCLIから実行すると、以下のエラーが発生することがあります：
```
Unknown command: correlation
```

#### 原因
`CLI.rb` の `commands` メソッドが、CommandRegistry に登録されたコマンドを認識していないため。

#### 解決策
`lib/number_analyzer/cli.rb` の `commands` メソッドを以下のように修正：

```ruby
# Get all available commands (core + plugin + command registry)
def commands
  all_commands = CORE_COMMANDS.merge(plugin_commands)
  
  # Add commands from CommandRegistry
  Commands::CommandRegistry.all.each do |cmd|
    all_commands[cmd] ||= :run_from_registry
  end
  
  all_commands
end
```

### 2. 特殊な引数処理

以下のコマンドは特殊な引数処理が必要です：

#### `--` 区切りを使うコマンド
- chi-square
- anova
- levene
- bartlett
- kruskal-wallis
- mann-whitney
- wilcoxon
- friedman
- correlation (※ただしCommand Pattern実装では不要)

これらのコマンドは `run_subcommand` メソッドで特別な処理を受けます。

#### 複数ファイル入力を受け付けるコマンド
- correlation (2つのデータセット)
- t-test (2つのグループ)
- two-way-anova (factor データ)

#### サブコマンドを持つコマンド
- plugins (list, conflicts, resolve)

### 3. 移行チェックリスト

新しいコマンドを Command Pattern で実装する際の手順：

- [ ] **TDD**: 失敗するテストを書く（RED）
- [ ] **実装**: 最小限のコードでテストを通す（GREEN）
- [ ] **リファクタリング**: コード品質を改善（REFACTOR）
- [ ] **CommandRegistry への登録**: `commands.rb` でコマンドを登録
- [ ] **CORE_COMMANDS からの削除**: 重複を避ける
- [ ] **CLI統合テスト**: 実際のCLI経由での動作確認
- [ ] **特殊処理の確認**: 必要に応じて `run_subcommand` を修正
- [ ] **RuboCop**: ゼロ違反を確認
- [ ] **ドキュメント更新**: README.md, ROADMAP.md

### 4. トラブルシューティング

#### "Unknown command" エラー
1. CommandRegistry に登録されているか確認：
   ```ruby
   bundle exec ruby -e "require_relative 'lib/number_analyzer/cli'; puts NumberAnalyzer::Commands::CommandRegistry.all.inspect"
   ```

2. CLI.rb の commands メソッドが CommandRegistry を含んでいるか確認

#### 引数が正しく渡されない
1. `run_subcommand` の特殊処理を確認
2. BaseCommand の `parse_input` メソッドをオーバーライドする必要があるか確認

#### テストは通るがCLIから動作しない
1. 統合テストを追加：
   ```ruby
   it "works via CLI" do
     output = `bundle exec number_analyzer #{command} #{args}`
     expect($?.success?).to be true
   end
   ```

## Command Pattern 実装例

### 基本的なコマンド（例：mean）
```ruby
class MeanCommand < BaseCommand
  command 'mean', 'Calculate the arithmetic mean'
  
  private
  
  def perform_calculation(data)
    data.sum.to_f / data.size
  end
end
```

### 複雑な入力を扱うコマンド（例：correlation）
```ruby
class CorrelationCommand < BaseCommand
  command 'correlation', 'Calculate Pearson correlation coefficient'
  
  private
  
  def parse_input(args)
    if args.include?('--')
      parse_numeric_datasets(args)
    elsif args.all? { |arg| arg.end_with?('.csv') }
      parse_file_datasets(args)
    else
      raise ArgumentError, "Invalid input format"
    end
  end
  
  def perform_calculation(data)
    dataset1, dataset2 = data
    # 相関係数の計算
  end
end
```

## ベストプラクティス

1. **小さく始める**: 最も単純なコマンドから移行を開始
2. **一貫性を保つ**: 既存のCommand Pattern実装を参考にする
3. **テストファースト**: 必ずテストを先に書く
4. **段階的移行**: CORE_COMMANDS との重複を一時的に許容
5. **CLIレベルでの確認**: 単体テストだけでなく、実際のCLI経由での動作を確認

## テストファイル管理

### Fixtures の使用（推奨）
テスト用のデータファイルは `spec/fixtures/` ディレクトリに配置し、動的作成を避ける：

```ruby
# ❌ 悪い例: 動的ファイル作成
before do
  File.write('data1.csv', "1\n2\n3")
  File.write('data2.csv', "2\n4\n6")
end

# ✅ 良い例: fixtures使用
let(:fixture_path) { File.join(__dir__, '..', '..', '..', 'fixtures') }
let(:data1_path) { File.join(fixture_path, 'correlation_data1.csv') }
```

### 一時ファイルの処理
どうしても動的ファイル作成が必要な場合は、確実にクリーンアップする：

```ruby
after do
  File.delete('temp_file.csv') if File.exist?('temp_file.csv')
end
```

### .gitignore への追加
テスト時に作成される可能性のあるファイルパターンを追加：
```
# Test temporary files
/data*.csv
/test*.csv
/temp*.csv
```

## 参考資料

- Phase 1 実装済みコマンド: `lib/number_analyzer/cli/commands/` ディレクトリ
- BaseCommand 実装: `lib/number_analyzer/cli/base_command.rb`
- CommandRegistry: `lib/number_analyzer/cli/command_registry.rb`