# `OutputFormatter` リファクタリング計画書

## 1. 目的

現在 `lib/number_analyzer/output_formatter.rb` に混在している多数の統計手法の表示ロジックを、`Presenter` パターンに移行する。
これにより、以下の改善を目指す。

- **設計の一貫性:** 出力フォーマットの責務を Presenter に統一し、コードベースの予測可能性を高める。
- **責務の分離:** 各統計手法の表示ロジックを独立したクラスに分割し、`OutputFormatter` の肥大化（神クラス化）を解消する。
- **拡張性と保守性の向上:** 新しい表示要件や統計手法の追加を容易にし、テストの独立性を確保する。

## 2. 基本方針

1.  `OutputFormatter` 内の各 `format_...` メソッドに対応する新しい `Presenter` クラスを `lib/number_analyzer/presenters/` 配下に作成する。
2.  各 `Presenter` は `BaseStatisticalPresenter` を継承し、`format_verbose`, `format_json`, `format_quiet` の各メソッドを実装する。
3.  ロジックとテストを `OutputFormatter` から新しい `Presenter` に移行する。
4.  `Presenter` の準備ができた各コマンドクラス（`lib/number_analyzer/cli/commands/`）を修正し、`OutputFormatter` の代わりに新しい `Presenter` を使用するように変更する。
5.  全てのロジックの移行が完了した後、`OutputFormatter` クラスを安全に削除する。

## 3. 移行対象と新しいPresenterのマッピング

| `OutputFormatter` のメソッド | 新しい Presenter クラス |
| :--- | :--- |
| `format_t_test` | `TTestPresenter` |
| `format_chi_square` | `ChiSquarePresenter` |
| `format_confidence_interval` | `ConfidenceIntervalPresenter` |
| `format_anova` | `AnovaPresenter` |
| `format_two_way_anova` | `TwoWayAnovaPresenter` |
| `format_post_hoc` | `PostHocPresenter` |
| `format_correlation` | `CorrelationPresenter` |
| `format_quartiles` | `QuartilesPresenter` |
| `format_mode` | `ModePresenter` |
| `format_outliers` | `OutliersPresenter` |
| `format_trend` | `TrendPresenter` |
| `format_moving_average` | `MovingAveragePresenter` |
| `format_growth_rate` | `GrowthRatePresenter` |
| `format_seasonal` | `SeasonalPresenter` |

---

## 4. 作業フェーズ

このリファクタリングは、メソッド単位で段階的に進めることができる。

### フェーズ 1: Presenter の新規作成とロジック移行

移行対象の各メソッドについて、以下の手順を繰り返す。(`t_test` を例とする)

1.  **Presenter ファイルの作成:**
    - `lib/number_analyzer/presenters/t_test_presenter.rb` を作成する。

2.  **クラスの定義:**
    - `BaseStatisticalPresenter` を継承した `TTestPresenter` クラスを定義する。

3.  **ロジックの移行:**
    - `OutputFormatter#format_t_test` のロジックを `TTestPresenter` の `format_verbose`, `format_json`, `format_quiet` メソッドに分割・移植する。
    - `apply_precision` などの共通ヘルパーは `BaseStatisticalPresenter` のメソッドを利用する。

4.  **テストの移行:**
    - `spec/number_analyzer/presenters/t_test_presenter_spec.rb` を作成する。
    - `output_formatter_spec.rb` から関連するテストケースを移植し、新しい Presenter が正しく動作することを確認する。

### フェーズ 2: コマンドクラスの更新

Presenter の準備ができ次第、対応するコマンドクラスを更新する。

1.  **コマンドファイルの特定:**
    - `lib/number_analyzer/cli/commands/t_test_command.rb` を特定する。

2.  **呼び出し部分の修正:**
    - `OutputFormatter.format_t_test(...)` の呼び出しを、`NumberAnalyzer::Presenters::TTestPresenter.new(result, options).format` に置き換える。

### フェーズ 3: 汎用フォーマッタの整理

`format_value` や `format_array` のような、特定の統計手法に依存しない汎用メソッドは、最終的に `OutputFormatter` から新しいユーティリティモジュールに移動させる。

1.  **新ユーティリティの作成:**
    - `lib/number_analyzer/formatting_utils.rb` のような新しいファイルを作成する。
2.  **メソッドの移動:**
    - `format_value`, `format_array` などを新しいモジュールに移動する。
3.  **呼び出し元の更新:**
    - これらのメソッドを使用している箇所を新しいモジュールを参照するように更新する。

### フェーズ 4: クリーンアップ

全ての `format_...` メソッドの移行が完了したら、以下の作業を行う。

1.  `lib/number_analyzer/output_formatter.rb` ファイルを削除する。
2.  `spec/number_analyzer/output_formatter_spec.rb` ファイルを削除する。
3.  プロジェクト全体で `OutputFormatter` への参照が残っていないことを確認する。

## 5. 影響範囲

このリファクタリングは主に以下のディレクトリに影響を与える。

- `lib/number_analyzer/presenters/` (ファイルの新規作成)
- `lib/number_analyzer/cli/commands/` (既存ファイルの修正)
- `spec/number_analyzer/presenters/` (テストの新規作成)
- `spec/number_analyzer/cli/commands/` (テストの修正)
- `lib/number_analyzer/output_formatter.rb` (最終的に削除)
- `spec/number_analyzer/output_formatter_spec.rb` (最終的に削除)

## 6. 完了の定義

- `OutputFormatter` クラスがプロジェクトから完全に削除されている。
- `OutputFormatter` が担っていた全ての表示機能が、対応する `Presenter` クラスによって実現されている。
- 全てのテストがパスし、既存のコマンドの出力形式が維持されている。
- 全29コマンドが統一されたPresenter Patternを使用している。
- RuboCop違反ゼロが維持されている。

## 7. 現状分析と統合戦略

### 7.1 既存アーキテクチャの問題点

**OutputFormatter の問題:**
- **神クラス化**: 1,090行、87メソッドの巨大クラス
- **責任過多**: 14種類の統計手法の表示ロジックが混在
- **重複コード**: 同一パターンの繰り返し（format_*_json, format_*_quiet, format_*_default）
- **テスト困難**: 巨大すぎて独立したテストが困難

**現在の二重システム:**
- **Presenter**: 6つのノンパラメトリック検定専用（607行）
- **OutputFormatter**: 20+コマンド用（1,090行）
- **不整合**: 同じ責務で異なるAPI設計

### 7.2 統合戦略

1. **アーキテクチャ統一**: 全29コマンドをPresenter Patternに統一
2. **段階的移行**: 既存Presenterとの競合を避けた移行計画
3. **共通化**: BaseStatisticalPresenterによる共通ロジック統合
4. **品質向上**: Template Method Patternによる一貫した設計

## 8. 優先度付き実装ロードマップ

### Phase 1: 高頻度・高影響コマンド（1-2週間）
**優先度**: ★★★ 最高 - 使用頻度が高く削減効果も大きい

| Presenter | 削減見込み | 理由 |
|-----------|-----------|------|
| `TTestPresenter` | 100行 | 最も複雑で使用頻度が高い |
| `AnovaPresenter` | 120行 | ANOVA表の複雑な表示ロジック |
| `CorrelationPresenter` | 40行 | 基本統計で使用頻度高 |
| `QuartilesPresenter` | 30行 | 基本統計コマンド |

### Phase 2: 複雑・専門コマンド（2-3週間）
**優先度**: ★★☆ 高 - 複雑だが特定用途

| Presenter | 削減見込み | 理由 |
|-----------|-----------|------|
| `TwoWayAnovaPresenter` | 150行 | 最も複雑な表示ロジック |
| `ChiSquarePresenter` | 80行 | 分割表の複雑な表示 |
| `ConfidenceIntervalPresenter` | 60行 | 統計検定の基本 |
| `PostHocPresenter` | 100行 | ANOVA後の多重比較 |

### Phase 3: 時系列・その他（1-2週間）
**優先度**: ★☆☆ 中 - 特殊用途だが完全性のため必要

| Presenter | 削減見込み | 理由 |
|-----------|-----------|------|
| `TrendPresenter` | 60行 | 時系列分析 |
| `MovingAveragePresenter` | 50行 | 時系列分析 |
| `GrowthRatePresenter` | 70行 | 成長率計算の複雑ロジック |
| `SeasonalPresenter` | 60行 | 季節性分析 |
| `ModePresenter` | 20行 | 基本統計 |
| `OutliersPresenter` | 20行 | 基本統計 |

### Phase 4: 統合・クリーンアップ（1週間）
**優先度**: ★★☆ 高 - アーキテクチャの完成

1. **FormattingUtils作成**: `format_value`, `format_array`, `apply_precision`等を統合
2. **OutputFormatter完全削除**: 1,090行の完全削除
3. **テスト統合**: 分散したテストの統合と最適化

## 9. 削減効果見積もり

### コード削減効果
- **OutputFormatter削除**: 1,090行 → 0行（100%削減）
- **新Presenter作成**: 約14クラス × 70行 = 980行
- **純削減効果**: 110行 + 重複ロジック除去による品質向上

### アーキテクチャ改善効果
- **統一性**: 29コマンド全てが統一Presenter Pattern
- **保守性**: 各統計機能50-100行の独立クラス
- **テスト性**: 独立した単体テスト可能
- **拡張性**: 新統計機能追加の簡易化

## 10. 既存Presenterとの統合方針

### 10.1 現在のPresenter（維持）
- `LeveneTestPresenter` (99行)
- `BartlettTestPresenter` (93行)
- `KruskalWallisTestPresenter` (76行)
- `MannWhitneyTestPresenter` (100行)
- `WilcoxonTestPresenter` (101行)
- `FriedmanTestPresenter` (81行)

### 10.2 統合ポイント
1. **BaseStatisticalPresenter共通化**: 既存の優秀な基底クラスを活用
2. **ヘルパーメソッド統一**: `round_value`, `format_significance`等を全Presenterで共有
3. **FormattingUtils活用**: 精度制御やJSON生成の共通化
4. **テストパターン統一**: 既存Presenterのテストパターンを新規Presenterに適用

## 11. リスク管理と品質保証

### 11.1 移行リスク
- **後方互換性**: CLI出力フォーマットの完全維持
- **テスト品質**: 移行前後でテスト成功率100%維持
- **段階的移行**: 各Presenter完成後に即座にCommand統合

### 11.2 品質保証基準
- **RuboCop準拠**: ゼロ違反維持
- **テストカバレッジ**: 各Presenterで100%カバレッジ
- **コードレビュー**: Template Method Pattern準拠確認
- **パフォーマンス**: 既存と同等以上の実行速度維持

### 11.3 最初の実装ターゲット
**推奨開始点**: `TTestPresenter`
- 最も複雑で影響範囲が大きい
- 成功すれば他のPresenterの良いテンプレートになる
- 削減効果も100行と大きい
