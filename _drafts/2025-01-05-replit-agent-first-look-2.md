---
title: "Replit Agent 触ってみた2"
date: "2025-01-05 23:07:21 +0900"
last_modified_at: "2025-01-05 23:07:21 +0900"
tags:
  - Replit
  - Replit Agent
---

## Databases tab からデータベースの再作成

前回ビビって消してしまったので再作成する

Create Database を押す
See Database Contents があってポスグレのクエリを打てっていうけどどういうことだ

しょうがないからテーブルを作ってもらう

```
データベースを一旦削除してしまいました。空のデータベースは作成しましたので、テーブルを作成してください
```

いやほんとすみません…という気持ちになりながらお願いする  

ちゃんとできてる！  

空の場合は `No entries yet. ~` と表示するようにしているのは前回気づかなかった。やるやんけ

## バリデーションを確認する

前回は作ることに気を取られてバリデーションを確認していなかった  

`GuestbookForm.tsx`

```ts
const formSchema = z.object({
  name: z.string().min(1, "Name is required").max(50, "Name must be less than 50 characters"),
  message: z.string().min(1, "Message is required").max(500, "Message must be less than 500 characters")
});
```

多分ここら辺

```
名前：最低1文字。最大で50文字
メッセージ：最低1文字。最大で500文字
```

内容は合っているが表現が気になる `less than` は「未満」になってしまうのでは？

`Modify with Assistant` を使う

`コマンド + S` で保存するとフォーマットもかかる

変更したはいいがこれをどうコミットすればいいのだ  

とりあえず `Generate (command + i)` してみるのだがうーんなんか違うな

しょうがないから Agent に聞くのだが直接アクセスできないです〜みたいなこと言ってる。代わりになんかまたデータベース作り直し始めたんだけど  
よっしゃまたやり直しましょうや…みたいな感じなのか？勢いよすぎるぞ

別に変わりないように見えるが… Checkpoint を作って`Improve GuestbookForm styling and error handling, ~` とか言っているのでコミットはしてるのかな？

`git log -p` してみると確かに差分をコミットしてくれていたぞ。うむ、いいんだけどちょっとめんどくさいかなあ


Assistant を開くと Advanced (Claude 3.5 Sonnet V2) になっている  

## test 環境整えるぞ
`vitest` setup してね、とお願いすると  
react コンポーネント用のパッケージと共に `vitest` 入れ始めたぞ  
 を作ったぞ、手際良すぎんだろ  

### `npm run test` するとこけてしまったぞ？


直してくれた。セットアップが間違っていたらしい。ちゃんと `npm run test` してテストがパスすることもやってくれた、えらいぞ  
そのあとまたいちいちデータベースを作り直していた。真面目やな…

### `GuestbookForm.test.tsx`

みたところテキストやフィールドの有無をチェックしているくらいか  

```tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { GuestbookForm } from '../../client/src/components/GuestbookForm';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

// Create a new QueryClient for testing
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

// Wrap component with required providers
const renderWithProviders = (ui: React.ReactElement) => {
  return render(
    <QueryClientProvider client={queryClient}>
      {ui}
    </QueryClientProvider>
  );
};

describe('GuestbookForm', () => {
  it('renders form fields correctly', () => {
    renderWithProviders(<GuestbookForm />);

    // Check if form elements are present
    expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/message/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign guestbook/i })).toBeInTheDocument();
  });
});
```

チャットが長すぎるんで新しく作ってくれ、とメッセージが出ている。ちょうどいいから今日はここまでかな

## Usage

`checkpoint` が前回の分も合わせて6回で `$1.50`  
Deployment での PostgreSQL Storage で `$0.05` かかっている。これは多分前回デプロイした時のものかなと  

よって Monthly credits を `$1.55` 分消費している

