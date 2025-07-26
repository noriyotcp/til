---
title: "Replit Agent 触ってみた2"
date: "2025-01-05 23:07:21 +0900"
last_modified_at: "2025-03-12 23:55:19 +0900"
tags:
  - "Replit"
  - "Replit Agent"
---
## Databases tab からデータベースの再作成

前回の記事: [Replit Agent 触ってみた - til](https://noriyotcp.github.io/til/2025/01/03/replit-agent-first-look.html)

前回ビビって消してしまったので再作成する

Database タブにて `Create Database` を押す
`See Database Contents` とあるので見てみると…ポスグレのクエリを打てっていうけど期待してたのとはちょっと違うかな

![スクリーンショット 2025-01-05 12.58.43]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 12.58.43.png' | relative_url }})



しょうがないからテーブルを作ってもらう。いやほんとすみません…という気持ちになりながらお願いする  

```
データベースを一旦削除してしまいました。空のデータベースは作成しましたので、テーブルを作成してください
```

![スクリーンショット 2025-01-05 13.01.49]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.01.49.png' | relative_url }})

ちゃんとできてる！  

![スクリーンショット 2025-01-05 13.02.24]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.02.24.png' | relative_url }})

空の場合は `No entries yet. ~` と表示するようにしているのは前回気づかなかった。やるやんけ

![スクリーンショット 2025-01-05 13.02.59]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.02.59.png' | relative_url }})

## バリデーションを確認する

前回は作ることに気を取られてバリデーションを確認していなかった  

`GuestbookForm.tsx` の多分ここら辺

```ts
const formSchema = z.object({
  name: z.string().min(1, "Name is required").max(50, "Name must be less than 50 characters"),
  message: z.string().min(1, "Message is required").max(500, "Message must be less than 500 characters")
});
```

```
名前：最低1文字。最大で50文字
メッセージ：最低1文字。最大で500文字
```

### 何も入力せずに Submit すると

![スクリーンショット 2025-01-05 13.09.18]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.09.18.png' | relative_url }})

### 最大文字数を超えると

![スクリーンショット 2025-01-05 13.14.47]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.14.47.png' | relative_url }})

内容は合っているが表現が気になる `less than` は「未満」になってしまうのでは？

## `Modify with Assistant` を使う
自分で直してもいいが、極力 AI にやってもらうことにする

`Assistant` を開くと `Advanced (Claude 3.5 Sonnet V2)` になっている  

![スクリーンショット 2025-01-05 13.29.17]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.29.17.png' | relative_url }})

![スクリーンショット 2025-01-05 13.19.43]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.19.43.png' | relative_url }})

![スクリーンショット 2025-01-05 13.21.14]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.21.14.png' | relative_url }})

`⌘ + S` で保存するとフォーマットもかかる。変更したはいいがこれをどうコミットすればいいのだ  

![スクリーンショット 2025-01-05 13.23.40]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.23.40.png' | relative_url }})

とりあえず `Generate (command + i)` して「変更をコミットしてください」とお願いしてみるとコマンドの候補を出してくれるのだがなんか違うな

しょうがないから Agent に聞くのだが「version control commands に直接アクセスできないです〜」みたいなこと言ってる。代わりにちゃんと正しく動いてるか変更をレビューしてあげるで、みたいなことを言っている

そしてデータベースを作り直し始めたのだが…「よっしゃまたやり直しましょうや…」みたいな感じなのか？勢いよすぎるぞ

![スクリーンショット 2025-01-05 13.43.30]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.43.30.png' | relative_url }})

別に変わりないように見えるが… Checkpoint を作って`Improve GuestbookForm styling and error handling, ~` とか言っているのでコミットはしてるのかな？

![スクリーンショット 2025-01-05 13.43.39]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.43.39.png' | relative_url }})

`git log -p` してみると確かに差分をコミットしてくれていたぞ。うむ、いいんだけどちょっとめんどくさいかなあ

## test 環境整えるぞ
`vitest` setup してね、とお願いすると  
React コンポーネント用のパッケージと共に `vitest` 入れ始めたぞ  

![スクリーンショット 2025-01-05 13.56.37]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 13.56.37.png' | relative_url }})

### `npm run test` するとこけてしまったぞ？

![スクリーンショット 2025-01-05 14.07.07]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 14.07.07.png' | relative_url }})

エラーメッセージのスクショと共に「直してくれ〜」とお願いしたら見事に直してくれた。セットアップが間違っていたらしい

![スクリーンショット 2025-01-05 14.13.27]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 14.13.27.png' | relative_url }})

![スクリーンショット 2025-01-05 14.13.52]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 14.13.52.png' | relative_url }})

![スクリーンショット 2025-01-05 14.14.21]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 14.14.21.png' | relative_url }})


ちゃんと `npm run test` してテストがパスすることもやってくれた、えらいぞ  

![スクリーンショット 2025-01-05 14.14.49]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 14.14.49.png' | relative_url }})

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

![スクリーンショット 2025-01-05 14.17.01]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 14.17.01.png' | relative_url }})

## Usage

`checkpoint` が前回の分も合わせて6回で `$1.50`  
Deployment での PostgreSQL Storage で `$0.05` かかっている。これは多分前回デプロイした時のものかなと  

よって Monthly credits を `$1.55` 分消費している

![スクリーンショット 2025-01-05 22.57.23]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 22.57.23.png' | relative_url }})

![スクリーンショット 2025-01-05 23.01.10]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 23.01.10.png' | relative_url }})

![スクリーンショット 2025-01-05 23.01.25]({{ '/assets/images/2025-01-05-replit-agent-first-look2/スクリーンショット 2025-01-05 23.01.25.png' | relative_url }})
