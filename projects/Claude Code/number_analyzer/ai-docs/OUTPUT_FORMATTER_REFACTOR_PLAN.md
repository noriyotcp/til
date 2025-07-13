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

### Phase 1-4 ✅ 完全達成
- ✅ 14個のPresenterクラスが実装済み
- ✅ 全29コマンドがPresenter/FormattingUtils Patternに移行済み
- ✅ 220+包括的テストケース + FormattingUtils 33テスト完備
- ✅ Template Method Pattern統一アーキテクチャ
- ✅ OutputFormatter完全削除（1,031行→0行）
- ✅ FormattingUtils統一ユーティリティ（104行）
- ✅ RuboCop違反ゼロ維持

### Phase 4 完了達成 ✅
- ✅ FormattingUtils作成（format_value, format_array等の統合）- 104行実装
- ✅ OutputFormatter完全削除（1,031行→0行の完全クリーンアップ）
- ✅ 全29コマンドのFormattingUtils/Presenter Pattern統一

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

### Phase 1: 高頻度・高影響コマンド ✅ 完了
**優先度**: ★★★ 最高 - 使用頻度が高く削減効果も大きい

| Presenter | 削減見込み | 実際の実装 | 状況 |
|-----------|-----------|-----------|------|
| `TTestPresenter` | 100行 | 138行 | ✅ 完了 |
| `AnovaPresenter` | 120行 | 151行 | ✅ 完了 |
| `CorrelationPresenter` | 40行 | 42行 | ✅ 完了 |
| `QuartilesPresenter` | 30行 | 34行 | ✅ 完了 |

### Phase 2: 複雑・専門コマンド ✅ 完了
**優先度**: ★★☆ 高 - 複雑だが特定用途

| Presenter | 削減見込み | 実際の実装 | 状況 |
|-----------|-----------|-----------|------|
| `TwoWayAnovaPresenter` | 150行 | 234行 | ✅ 完了 |
| `ChiSquarePresenter` | 80行 | 91行 | ✅ 完了 |
| `ConfidenceIntervalPresenter` | 60行 | 63行 | ✅ 完了 |
| `PostHocPresenter` | 100行 | 127行 | ✅ 完了 |

### Phase 3: 時系列・その他 ✅ 完了
**優先度**: ★☆☆ 中 - 特殊用途だが完全性のため必要

| Presenter | 削減見込み | 実際の実装 | 状況 |
|-----------|-----------|-----------|------|
| `TrendPresenter` | 60行 | 50行 | ✅ 完了 |
| `MovingAveragePresenter` | 50行 | 60行 | ✅ 完了 |
| `GrowthRatePresenter` | 70行 | 134行 | ✅ 完了 |
| `SeasonalPresenter` | 60行 | 56行 | ✅ 完了 |
| `ModePresenter` | 20行 | 32行 | ✅ 完了 |
| `OutliersPresenter` | 20行 | 34行 | ✅ 完了 |

### Phase 4: 基本統計 & ユーティリティ統合 ✅ 完了
**優先度**: ★★☆ 高 - アーキテクチャの完成

#### 4.1 残存メソッド分析（Phase 1-3で未移行）

**① 基本統計メソッド（Presenter移行済みだがOutputFormatterに残存）:**
- `format_quartiles` (34行) - ✅ QuartilesPresenterで代替済み
- `format_mode` (13行) - ✅ ModePresenterで代替済み
- `format_outliers` (13行) - ✅ OutliersPresenterで代替済み
- `format_correlation` (18行) - ✅ CorrelationPresenterで代替済み

**② 時系列メソッド（Presenter移行済みだがOutputFormatterに残存）:**
- `format_trend` + 3プライベート (58行) - ✅ TrendPresenterで代替済み
- `format_moving_average` + 3プライベート (73行) - ✅ MovingAveragePresenterで代替済み
- `format_growth_rate` + 6プライベート (158行) - ✅ GrowthRatePresenterで代替済み

**③ 統計検定メソッド（Presenter移行済みだがOutputFormatterに残存）:**
- `format_t_test` + 3プライベート (145行) - ✅ TTestPresenterで代替済み
- `format_confidence_interval` + 3プライベート (58行) - ✅ ConfidenceIntervalPresenterで代替済み
- `format_chi_square` + 3プライベート (93行) - ✅ ChiSquarePresenterで代替済み
- `format_anova` + 3プライベート (85行) - ✅ AnovaPresenterで代替済み
- `format_two_way_anova` + 6プライベート (178行) - ✅ TwoWayAnovaPresenterで代替済み
- `format_post_hoc` + 3プライベート (48行) - ✅ PostHocPresenterで代替済み

**④ 共通ユーティリティ（FormattingUtils移行対象）:**
- `format_value` (9行) - 全Presenterで使用中
- `format_array` (12行) - 全Presenterで使用中
- `apply_precision` (6行) - 全Presenterで使用中
- `dataset_metadata` (6行) - JSON出力で使用中
- `format_json_value`, `format_json_array` (12行) - JSON出力用

#### 4.2 Phase 4実装完了結果 ✅
1. ✅ **FormattingUtilsモジュール作成**: 共通ユーティリティの統合 (104行実装)
2. ✅ **代替済みメソッド削除**: Presenter実装済みの重複メソッド削除 (1,031行削減)
3. ✅ **OutputFormatter完全削除**: 1,031行→0行の完全削除達成
4. ✅ **参照更新**: プロジェクト全体でOutputFormatter参照をFormattingUtilsに変更完了

## 9. 削減効果見積もり

### コード削減効果
- **Phase 1-3実績**: 1,090行 → 1,031行（59行削減確認済み）
- **新Presenter作成**: 14クラス 1,246行実装済み（Phase 1-3完了）
- **実際の削減効果**: ~1,020行抽出 + 重複ロジック除去、品質向上
- **Phase 4実績**: 1,031行完全削除 + FormattingUtils統合でOutputFormatter完全削除達成

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

### 11.3 Phase 1-3実装完了メトリクス
**実装結果**: ✅ 全Phase計画を上回る達成

| Phase | 計画 | 実装 | 達成率 |
|-------|------|------|--------|
| Phase 1 | 4クラス 290行 | 4クラス 365行 | 126% |
| Phase 2 | 4クラス 390行 | 4クラス 515行 | 132% |
| Phase 3 | 6クラス 280行 | 6クラス 366行 | 131% |
| **合計** | **14クラス 960行** | **14クラス 1,246行** | **130%** |

**品質向上**: Template Method Pattern統一、220+テスト、RuboCopゼロ違反、CLI統合完備

## 12. Phase 4準備ガイド

### 12.1 次のステップ
1. **FormattingUtilsモジュール設計**
   - `format_value`, `format_array`, `apply_precision`の統合
   - 全Presenterで共通利用できるユーティリティモジュール

2. **残存メソッドの安全な削除**
   - ✅ Presenterで代替済みのメソッドの段階的削除
   - CLIコマンドでの参照確認と更新

3. **最終クリーンアップ**
   - OutputFormatterファイルの完全削除
   - プロジェクト全体での参照更新
   - テストスイートの最終検証

### 12.2 リスク管理
- **下位互換性**: 既存CLIコマンドの完全な動作維持
- **段階的削除**: 一度に大量削除せず、段階的に安全に進める
- **テスト驗証**: 各ステップで全テストケースの成功を確認

### 12.3 Phase 4完了時の達成結果 ✅
- ✅ OutputFormatterファイルの完全削除（1,031行→0行）
- ✅ FormattingUtilsモジュールによる統一ユーティリティ（104行実装）
- ✅ 29コマンド全てがPresenter Pattern使用
- ✅ アーキテクチャの完全な統一とクリーンアップ達成
- ✅ 33包括的テストケースによるFormattingUtils品質保証
