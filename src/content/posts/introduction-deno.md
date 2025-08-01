---
title: "Deno入門"
date: "2024-11-09 04:26:49 +0900"
last_modified_at: "2024-12-03 00:29:33 +0900"
tags:
  - "Deno"
draft: false
---
# Deno入門
## Deno
突然だが Deno で CLI を作りたくなったよね

### 思いつきメモ
Tauri v2 になったことだし、夢のエディタ作りをしてもいいのでは  
その前にサッとメモできるような CLI を Deno で作ろう  

```
$ memmo
# これでタイムスタンプ付きのファイルを作る  
202411080115 みたいな感じでいい

設定 or options
- 保存する場所 絶対パスで
  - /Users/noriyo_tcp/MyPlayground/jibun とか
  - 末尾のスラッシュあってもなくてもうまく処理すること
  - `--path`, `-p`
- ファイルエクステンション .md とか
  - `--extension`, `--ext`
- エディタ 基本的には $EDITOR 環境変数を参照する
  - `--editor`

つまり内部的には $EDITOR /Users/noriyo_tcp/MyPlayground/jibun/202411080115.md みたいな感じでファイルを生成する  

$ memmo config
# ~/.memmoconfig みたいなファイルに書く、でいいのでは

$ memmo list
# 設定のパス配下にあるファイルをリストアップするだけ
# それでもタイムスタンプじゃわからん。grep で代替できるが

$ memmo search <term>
# 結果を grep みたいに出せればいい
# interactive mode で incremental search できたらかっこいい
```

とにかくやる。Cursor 使って


外部ドキュメントとして以下の2つを登録しておく

- https://docs.deno.com/runtime/
- https://docs.deno.com/api/deno/

https://www.rudrank.com/exploring-cursor-accessing-external-documentation-using-doc/

## Install Deno and setup your IDE

```sh
brew install deno
```

https://docs.deno.com/runtime/getting_started/setup_your_environment/#visual-studio-code


## とにかく

Cursor で出てきたコードをコピペして `main.ts`, `cli.ts` を作る

```
 ❯ deno run main.ts
 ┏ ⚠️  Deno requests env access to "HOME".
 ┠─ Learn more at: https://docs.deno.com/go/--allow-env
 ┠─ Run again with --allow-env to bypass this prompt.
 ┗ Allow? [y/n/A] (y = yes, allow; n = no, deny; A = allow all env permissions) >

# y を選択

 ❯ deno run main.ts
✅ Granted env access to "HOME".
┏ ⚠️  Deno requests write access to "/Users/noriyo_tcp/.memmo".
┠─ Requested by `Deno.mkdir()` API.
┠─ Learn more at: https://docs.deno.com/go/--allow-write
┠─ Run again with --allow-write to bypass this prompt.
┗ Allow? [y/n/A] (y = yes, allow; n = no, deny; A = allow all write permissions) >

# なんか ~/.memmo への書き込み権限を求めているな？
# これをやっているからか

const defaultPath = join(Deno.env.get("HOME") || "", ".memmo");

 ❯ deno run main.ts
✅ Granted env access to "HOME".
✅ Granted write access to "/Users/noriyo_tcp/.memmo".
┏ ⚠️  Deno requests read access to "/Users/noriyo_tcp/.memmo/20241108194051182Z.md".
┠─ Requested by `Deno.stat()` API.
┠─ Learn more at: https://docs.deno.com/go/--allow-read
┠─ Run again with --allow-read to bypass this prompt.
┗ Allow? [y/n/A] (y = yes, allow; n = no, deny; A = allow all read permissions) >

特定ファイルの読み込みを求めているなあ

 ❯ deno run main.ts
✅ Granted env access to "HOME".
✅ Granted write access to "/Users/noriyo_tcp/.memmo".
✅ Granted read access to "/Users/noriyo_tcp/.memmo/20241108194051182Z.md".
File already exists: /Users/noriyo_tcp/.memmo/20241108194051182Z.md

# うーん？わからん
```

```
 ❯ ls ~/.memmo
# お、何もないなあ
# とりま実行するときはこれでいいや
 ❯ deno run --allow-env --allow-write --allow-read main.ts
```

```
 ❯ deno run --allow-env --allow-write --allow-read main.ts
 ┏ ⚠️  Deno requests run access to "vim".
 ┠─ Requested by `Deno.Command().output()` API.
 ┠─ Learn more at: https://docs.deno.com/go/--allow-run
 ┠─ Run again with --allow-run to bypass this prompt.
 ┗ Allow? [y/n/A] (y = yes, allow; n = no, deny; A = allow all run permissions) >

vim を使用するかどうかですね

```

### --allow-run でコマンド実行も許可

```
 ❯ deno run --allow-env --allow-write --allow-read --allow-run main.ts
```

```ts

  try {
    await Deno.lstat(filepath);
    console.error(`File already exists: ${filepath}`);
  } catch (error) {
    const err = error as NodeJS.ErrnoException;

    if (err.code === "ENOENT") {
      const editor = Deno.env.get("EDITOR") || "vim";
      const command = new Deno.Command(editor, { args: [filepath] });
      command.spawn();
    } else {
      console.error(err);
      Deno.exit(4);
    }
  }
```

こんな感じ。editor でファイルを開いたあとはそのサブプロセスに制御を移す

config も `Deno.openKv()` 使って保存するようにした。SQL クライアントで中身を確認するなどしたい

---

## 11/10

だいぶできたかな。あとは

- [x] subcommand にする
  - [ ] サーチなんかは細かいオプションが欲しい
  - [x] となると `--search` よりも `search` subcommand のほうが良さそう
  - [x] https://cliffy.io/docs@v1.0.0-rc.7/command cliffy というパッケージがある
  - [ ] features/ は commands/ なのかな
    - [ ] cliffy の `new Command()` をcommands/ 配下の各ファイルに切り出そうかな
  - [ ] `--config` はまだ設定を表示するのみなので設定できるようにしたい
    - [ ] interactive なほうが良さそう. それも cliffy の prompt を使えばできるようだ

---

次はプロンプトを試してみる

- [x] list での絞り込み
  - [x] まずは絞れるだけでも
  - [x] 選んだらそれを開く

- [ ] maxRows option を config で設定できるようにしたい
- cliffy の Select でのサーチが日本語化けるなあ

---

## 11/20

コンパイルしてみよーと思ったらこけちゃったよ

```
 noriyo_tcp@MacBook-Air  ~/M/memmo   main 
 ❯ deno compile --allow-env --allow-write --allow-read --allow-run --unstable-kv cli.ts --output memmo
Check file:///Users/noriyo_tcp/MyPlayground/memmo/cli.ts
error: TS2345 [ERROR]: Argument of type '(options: ConfigCommandOptions, _args_0: string, _args_1?: string | undefined) => void' is not assignable to parameter of type 'ActionHandler<{ edit?: true | undefined; }, [], void, void, { number: number; integer: number; string: string; boolean: boolean; file: string; }, void, void, undefined>'.
  Target signature provides too few arguments. Expected 2 or more, but got 1.
    .action((options: ConfigCommandOptions, ..._args: Arguments) => {
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    at file:///Users/noriyo_tcp/MyPlayground/memmo/main.ts:19:13

TS2345 [ERROR]: Argument of type '(options: listCommandOptions, _args_0: string, _args_1?: string | undefined) => Promise<void>' is not assignable to parameter of type 'ActionHandler<{ path?: (StringType & string) | undefined; } & { select?: true | undefined; }, [], void, void, { number: number; integer: number; string: string; boolean: boolean; file: string; }, void, void, undefined>'.
  Target signature provides too few arguments. Expected 2 or more, but got 1.
    .action(async (options: listCommandOptions, ..._args: Arguments) => {
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    at file:///Users/noriyo_tcp/MyPlayground/memmo/main.ts:27:13

TS2345 [ERROR]: Argument of type '(options: CommandOptions, term_0: string, term_1?: string | undefined) => Promise<void>' is not assignable to parameter of type 'ActionHandler<{ path?: (StringType & string) | undefined; }, [string], void, void, { number: number; integer: number; string: string; boolean: boolean; file: string; }, void, void, undefined>'.
  Types of parameters 'options' and 'options' are incompatible.
    Property 'extension' is missing in type '{ path?: string | undefined; }' but required in type 'MemmoConfig'.
    .action(async (options: CommandOptions, ...term: Arguments) => {
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    at file:///Users/noriyo_tcp/MyPlayground/memmo/main.ts:36:13

    'extension' is declared here.
      extension: string;
      ~~~~~~~~~
        at file:///Users/noriyo_tcp/MyPlayground/memmo/types.ts:3:3

TS2345 [ERROR]: Argument of type '(options: CommandOptions, args_0: string, args_1?: string | undefined) => Promise<void>' is not assignable to parameter of type 'ActionHandler<{ path?: (StringType & string) | undefined; } & { extension?: (StringType & string) | undefined; }, [string], void, void, { number: number; integer: number; string: string; boolean: boolean; file: string; }, void, void, undefined>'.
  Types of parameters 'options' and 'options' are incompatible.
    Type '{ path?: string | undefined; extension?: string | undefined; }' is not assignable to type 'MemmoConfig'.
      Types of property 'path' are incompatible.
        Type 'string | undefined' is not assignable to type 'string'.
          Type 'undefined' is not assignable to type 'string'.
    .action(async (options: CommandOptions, ...args: Arguments) => {
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    at file:///Users/noriyo_tcp/MyPlayground/memmo/main.ts:46:13

TS2345 [ERROR]: Argument of type '(options: CommandOptions, _args_0: string, _args_1?: string | undefined) => Promise<void>' is not assignable to parameter of type 'ActionHandler<{ path?: (StringType & string) | undefined; } & { extension?: (StringType & string) | undefined; }, [], void, void, { number: number; integer: number; string: string; boolean: boolean; file: string; }, void, void, undefined>'.
  Target signature provides too few arguments. Expected 2 or more, but got 1.
    .action(async (options: CommandOptions, ..._args: Arguments) => {
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    at file:///Users/noriyo_tcp/MyPlayground/memmo/main.ts:60:13

Found 5 errors.
```

直したあと、これで良さそうだった  
これでカレントディレクトリに `memmo` という名前の実行ファイルが生成される

```sh
deno compile --allow-env --allow-write --allow-read --allow-run --unstable-kv cli.ts
```

後ろに `--output memmo` を付けてしまうと実行ファイルの実行時に `--output` オプションをつけることを期待してこけてしまうな？

```sh
# これでもよい。オプションは先につけて、コンパイル対象のファイルは一番最後に指定する
 ❯ deno compile --allow-env --allow-write --allow-read --allow-run --unstable-kv --output memmo cli.ts
 Compile file:///Users/noriyo_tcp/MyPlayground/memmo/cli.ts to memmo
```

---

### 構造

commands (sub commands) 主体でいくなら。。。

- commands
  - config
    - command.ts
    - feature.ts
    - options.ts

みたいな形になるのかなあ

---

- [ ] Custom path mappings の設定
  - [ ] https://docs.deno.com/runtime/fundamentals/configuration/#custom-path-mappings
- [ ] Knip 使ってみる
  - [ ] https://tech.basemachina.jp/entry/introduction-knip
  - いや無理っぽいかなあ
