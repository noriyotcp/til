---
title: "zshの起動を60%以上速くした"
date: "2025-09-23 11:15:00 +0900"
last_modified_at: "2025-09-23 11:15:00 +0900"
draft: false
---

VS Codeのターミナルなどでzshを起動する際、プロンプトが表示されるまでに数秒待たされる問題に直面していた。

## 1. はじめに：問題の発覚

まず、現状の起動速度を計測した。以下のコマンドを10回実行し、その平均時間を確認する。

```zsh
for i in $(seq 1 10); do time zsh -i -c exit; done
```

計測の結果、キャッシュが効いた状態でも平均で **約3.6秒** かかっており、快適とは言えない状況だった。

```
zsh -i -c exit  1.51s user 1.06s system 82% cpu 3.132 total
zsh -i -c exit  1.48s user 1.06s system 80% cpu 3.153 total
...
```

## 2. 調査と試行錯誤の道のり

### プロファイリングの実施

次に、zshの組み込みプロファイラである`zprof`を使い、どの処理がボトルネックになっているかを調査した。`.zshenv`の最初と `.zshrc` の最後に以下のコードを追加した。

```zsh
# .zshenv
zmodload zsh/zprof && zprof
```

```zsh
# .zshrc
if (which zprof > /dev/null 2>&1) ;then
  zprof
fi
```

初期のプロファイル結果では、`compinit`（補完システムの初期化）が多くの時間を占めていることが分かった。

```
num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    2        1030.33   515.17   90.32%    521.13   260.57   45.68%  compinit
 2)    2         188.99    94.49   16.57%    188.99    94.49   16.57%  compaudit
 3)    1         184.26   184.26   16.15%    184.26   184.26   16.15%  compdump
 4)  944         135.96     0.14   11.92%    135.96     0.14   11.92%  compdef
```

### 最初の仮説と迷走

当初は`compinit`が主犯だと考え、キャッシュファイルの再作成や、`compinit`の非同期実行などを試みた。Preztoのモジュール依存関係によるエラー(`command not found: prompt`)などに直面し、根本的な解決には至らなかった。

### 方針転換と真犯人の特定

`compinit`だけに注目してもうまくいかず、改めてプロファイル全体を見直したところ、`compinit`以外にも常に上位にいる関数が見つかった。

- **`iterm2_print_user_vars`**: iTerm2連携機能 (~470ms)
- **`git-info`**: Preztoの`git`モジュールによるGit情報の取得 (~320ms)

一つずつ機能を無効化して計測した結果、これらが合計で1秒近い時間を消費していることを突き止めた。

## 3. 解決策：Powerlevel10kの導入

原因は、Preztoの`git`モジュールと`prompt`モジュールが、起動のたびに重い処理を実行していることであった。そこで、今まで使用していた `paradox` の代わりに [Powerlevel10k](https://github.com/romkatv/powerlevel10k) という zsh テーマを採用することにした。

### 最終的な設定

#### 1. Powerlevel10kのインストール
Homebrewを使い、簡単にインストールした。
```sh
brew install powerlevel10k
```

#### 2. `.zpreztorc` の修正
Powerlevel10kが役割を代替する、Preztoの`git`と`prompt`モジュールを無効化した。また、関連するテーマ設定も不要なためコメントアウトした。

```zsh
# .zpreztorc
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  # 'git' \        <- 無効化
  # 'prompt'     <- 無効化

# 以下のテーマ設定も不要なためコメントアウト
# zstyle ':prezto:module:prompt' theme 'paradox'
```

#### 3. `.zshrc` の整理と修正
複数の`compinit`の呼び出しや古い設定を削除し、Prezto の読み込み後に Powerlevel10k を読み込むように、設定を整理した。
この辺りは、Claude Code に整理してもらった。

```zsh
# .zshrc (最終的な抜粋)

# Preztoの読み込み
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Powerlevel10kの読み込み (Preztoの後)
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"

# --- (個人のエイリアスや他の設定が続く) ---
```

その他 p10k configure で [Instant Prompt](https://github.com/romkatv/powerlevel10k/blob/master/README.md#instant-prompt) を有効にした。

## 4. 結果

この最終構成で再度計測したところ、速度が改善した。

**最終計測結果:**

```
zsh -i -c exit  0.50s user 0.56s system 82% cpu 1.286 total
zsh -i -c exit  0.52s user 0.55s system 86% cpu 1.247 total
...
```

平均起動時間は **約1.35秒** となった。

- **対策前**: 約3.6秒
- **対策後**: 約1.35秒
- **改善幅**: **約2.25秒 (60%以上の高速化)**

## 5. まとめと教訓

- **闇雲な変更ではなく、計測と原因の切り分けが重要である。** 当初は `compinit` が原因だと思い込んでいたが、実際には複数の要因が絡み合っていた。
- **フレームワークのモジュール間には、予期せぬ依存関係がある。** `git` モジュールを無効化すると `prompt` モジュールが動かなくなるなど、一つを無効化することが他の機能の不具合に繋がるケースを学んだ。

参考：
- [zshの起動が遅いのでなんとかしたい #Mac - Qiita](https://qiita.com/vintersnow/items/7343b9bf60ea468a4180)
- [romkatv/powerlevel10k: A Zsh theme](https://github.com/romkatv/powerlevel10k)
