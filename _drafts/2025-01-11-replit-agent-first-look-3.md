---
title: "Replit Agent 触ってみた3"
date: "2025-01-11 13:04:58 +0900"
last_modified_at: "2025-01-11 13:04:58 +0900"
---

# Replit Agent 触ってみた3

前回： [Replit Agent 触ってみた2 - til](https://noriyotcp.github.io/til/2025/01/05/replit-agent-first-look-2.html)

今回は気ままに機能を追加していくぞ

## New Chat を始める

いくつか機能を提示されている。よし全マシでいこう！（アホ）

![スクリーンショット 2025-01-11 13.10.55]( {{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 13.10.55.png' | relative_url  }})

一旦 checkpoint を記録した上でプランを考えてくれる

---

Based on the BlogGuestBook application files and structure, I'll suggest some valuable features that could enhance user engagement and functionality:

提案された機能は以下の通り：

1. Real-time Social Features:
- Emoji reactions to entries (like, love, laugh, etc.)
- Reply threading to enable conversations
- @mentions to tag other users
- Rich text formatting with markdown support

2. User Experience Improvements:
- User profiles with customizable avatars
- Entry categorization with tags
- Search functionality with filters
- Dark/light theme toggle

3. Content Management:
- Image attachment support
- Entry moderation tools
- Spam protection
- Entry drafts and scheduling

4. Analytics and Engagement:
- View counts for entries
- Popular entries showcase
- User activity statistics
- Email notifications for replies

Would you like me to help implement any of these features to enhance the BlogGuestBook application?

---

必要な機能が過不足なく揃っているか、それが期待通りに動くか、などを確認しないといけないがどうすればいいだろうか？そしてめんどくさそう

## ユーザープロフィール画面の作成

![スクリーンショット 2025-01-11 13.22.42]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 13.22.42.png' | relative_url  }})

プランを立てるために結構考えている。都度ちゃんと何を考えているか、を伝えてくる。

`2. User Experience Improvements` の `User profiles with customizable avatars` から取り組んでいくようだ。またモリモリとファイルを作成していく

### schema.ts 更新

「スキーマ変わる前にデータベース作成しないといけない」って言ってる。前回作成したものだとダメなのかな？わからん

DB 作り直しつつ `users` テーブルを作成する

- `users` table を作成
- `User` 型の定義
- `GuestbookEntry` 型の定義を更新
  - `userId` を持つようにする
  - `User` 型の `user` も持つ

### エンドポイントの追加
routes.ts にユーザー関連のエンドポイントを追加していく `POST /api/users` とか

> Now that we have our database schema set up, let's update the routes.ts file to handle the new user-related endpoints and fix the existing entry creation to work with user IDs.

### 仮のユーザーを作成
まだ認証機能も実装していないんでとりあえず仮のユーザー作っておくで〜ってことで1人ユーザーを作成していた

```sql
INSERT INTO users (username, display_name) 
VALUES ('default_user', 'Guest User') 
RETURNING id;


id
1
INSERT 0 1
```

確かに1人ユーザーが作成されている。`avatar_url` はまだない

![スクリーンショット 2025-01-11 13.44.09]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 13.44.09.png' | relative_url  }})


### フロントエンドコンポーネント

`client/src/components/GuestbookForm.tsx`

zod によるバリデーションから `name` に対するバリデーションを取り除く。後々認証機能を実装する予定なので、投稿時に名前を入力するのはやめたため

エントリを載せるコンポーネントである `client/src/components/GuestbookEntries.tsx` に投稿したユーザーのアバター画像を表示するようにしている

---

### エントリをフェッチする際のエラーの修正

この時点でエラーが出ているので修正していく  
エントリをロードして表示することができていない

![スクリーンショット 2025-01-11 13.36.03]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 13.36.03.png' | relative_url  }})

---

```
4:19:20 AM [express] GET /api/entries 500 in 293ms :: {"message":"Failed to fetch entries"}
```

The error occurs when trying to fetch entries. This is likely because we need to:

1. Create the new users table first
2. Modify the guestbook_entries table to add the user_id foreign key
3. Update the reactions table schema


---

これはおそらく、次のことが必要なためです：

1. 最初に新しいusersテーブルを作成する
2. user_id外部キーを追加するためにguestbook_entriesテーブルを修正する
3. リアクションテーブルのスキーマを更新する

---

まあそうだろうなと。DBスキーマの更新は人間だったらもう少し事前に変更点を洗い出したりするものだが、修正のコストが安いのであれば、高速でトライ＆エラーを進めるほうが早いのかもしれない  
それでも適宜人間によるチェックは必要だろうけど

```sql
ALTER TABLE guestbook_entries 
DROP COLUMN IF EXISTS name,
ADD COLUMN IF NOT EXISTS user_id INTEGER REFERENCES users(id),
ALTER COLUMN user_id SET NOT NULL;

-- Make sure reactions table is properly set up
CREATE TABLE IF NOT EXISTS reactions (
    id SERIAL PRIMARY KEY,
    entry_id INTEGER NOT NULL REFERENCES guestbook_entries(id),
    emoji TEXT NOT NULL,
    count INTEGER NOT NULL DEFAULT 1
);


NOTICE:  relation "users" already exists, skipping
NOTICE:  relation "reactions" already exists, skipping
```

ここまで3分くらい

---

### エントリ部分でのアバター画像のプレースホルダ表示

> Implement user avatars and display names in guestbook entries, remove name field from guestbook form and entry, and add user model.

アバター画像をまだ登録していない仮のユーザーだけど、エントリ部分で画像表示できるんだろか、と投稿してみると…
なんか `GU` と表示されているぞ。なんだこれは

![スクリーンショット 2025-01-11 13.46.21]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 13.46.21.png' | relative_url  }})

`client/src/components/GuestbookEntries.tsx`

```tsx
  return (
    <div className="space-y-4">
      {entries.map((entry) => (
        <Card key={entry.id}>
          <CardContent className="p-4">
            <div className="flex items-start gap-4">
              <Avatar className="h-10 w-10">
                {entry.user.avatarUrl ? (
                  <AvatarImage src={entry.user.avatarUrl} alt={entry.user.displayName} />
                ) : (
                  <AvatarFallback>
                    {entry.user.displayName.slice(0, 2).toUpperCase()}
                  </AvatarFallback>
                )}
              </Avatar>
```

あーここか。 `avatarUrl` がない場合は `displayName` の先頭2文字を大文字で表示するようになっている  
出来上がってからはじめてコードをじっくり読む感じになるのか〜。でも人間相手のコードレビューでも同じことなのかもしれない

---

「エントリに画像表示されたか？メッセージ投稿できたか？ガンガン行くで〜」みたいなこと言ってる。やる気あるな

![スクリーンショット 2025-01-11 13.51.06]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 13.51.06.png' | relative_url  }})

## アバター画像付きのユーザープロフィールと編集可能なバイオセクションの追加

これは2分くらいでできた

### client/src/pages/UserProfile.tsx

Let's create a new UserProfile page component and a UserProfileEditor component to handle viewing and editing user profiles. We'll need:

1. A new route in App.tsx for the profile page
  - `/profile` というルーティングも追加する
  - ユーザーが見つからなかった場合の `NotFound` コンポーネントも作成する
2. A UserProfile page component
3. A UserProfileEditor component with a form for editing profile details
4. Navigation links to access the profile

```tsx
export function UserProfile() {
  const [isEditing, setIsEditing] = useState(false);
  const { data: user, isLoading, error } = useQuery<User>({
    queryKey: ["/api/users/1"], // Using user ID 1 for now
    // 一旦仮で入れたユーザーID 1 で取得している
  });

  // (snip)

  // プロフィール取得に失敗した時の処理。エラーメッセージと共に `Card` コンポーネントを表示する
  // (snip)

  return (
    <div className="min-h-screen bg-background">
      <div className="container max-w-2xl mx-auto px-4 py-8">
        {isEditing ? (
          <UserProfileEditor user={user} onCancel={() => setIsEditing(false)} />
        ) : (
          <Card>
            <CardContent className="p-6">
              <div className="text-center">
                <Avatar className="h-24 w-24 mx-auto mb-4">
                  {user.avatarUrl ? (
                    <AvatarImage src={user.avatarUrl} alt={user.displayName} />
                  ) : (
                    <AvatarFallback>
                      {user.displayName.slice(0, 2).toUpperCase()}
                    </AvatarFallback>
                  )}
                </Avatar>
                <h1 className="text-2xl font-bold mb-1">{user.displayName}</h1>
                <p className="text-muted-foreground mb-4">@{user.username}</p>
                {user.bio && (
                  <p className="text-lg mb-4 whitespace-pre-wrap">{user.bio}</p>
                )}
                <div className="text-sm text-muted-foreground mb-4">
                  Joined {format(new Date(user.createdAt), "MMMM yyyy")}
                </div>
                <Button onClick={() => setIsEditing(true)}>Edit Profile</Button>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
// (snip)
```

### client/src/components/UserProfileEditor.tsx
Let's create a new UserProfile page component and a UserProfileEditor component to handle viewing and editing user profiles. We'll need:

1. A new route in App.tsx for the profile page
2. A UserProfile page component
3. A UserProfileEditor component with a form for editing profile details
4. Navigation links to access the profile

---

`UserProfile` 作成時のリストと被っている部分はあるが、ここではプロフィール編集画面を作成する

まだホーム画面に導線を張っていなさそうだが、　`/profile` にアクセスするとプロフィール画面が表示されるようになる

編集してみよう。んんんん、ゲストユーザーは画像がなかったのでてっきり今は無くてもいいのかな、と思ったがちゃんとバリデーションを効かせているのだな

![スクリーンショット 2025-01-11 14.26.34]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 14.26.34.png' | relative_url  }})

とりあえずプレースホルダ用の画像 URL を登録しておく  
`https://placehold.co/100x100?text=Guest`

![スクリーンショット 2025-01-11 14.53.18]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 14.53.18.png' | relative_url  }})

### バリデーションの調整

formSchema にて avatarUrl はオプショナルなのだが空欄で入力できないな？

質問してみたところ `.or(z.literal(''))` で空文字列を許容するそうだ

`client/src/components/UserProfileEditor.tsx`

```tsx
const formSchema = z.object({
  displayName: z.string().min(1, "Display name is required").max(50),
  bio: z.string().max(500).optional(),
  avatarUrl: z.string().url("Must be a valid URL").optional().or(z.literal('')),
});
```

しかし空欄にしても保存に失敗してしまう。 `routes.ts` も修正しないといけなかった

```ts
    const schema = z.object({
      displayName: z.string().min(1).max(50),
      bio: z.string().optional(),
      avatarUrl: z.string().url().optional().or(z.literal('')),
    });
```

これで空欄で保存できるようになった  
プロフィール詳細でも、画像が無い場合は名前のはじめの2文字が表示される


![スクリーンショット 2025-01-11 15.30.06]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 15.30.06.png' | relative_url  }})

![スクリーンショット 2025-01-11 15.30.07]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 15.30.07.png' | relative_url  }})

### テストケースの作成
画像を登録して表示する。ということはできているので、テストケースを作成していく

---

#### 1回目のトライ
##### `test/components/GuestbookForm.test.tsx`

Let's create comprehensive test cases for:

1. UserProfile component - test profile viewing and editing functionality
2. GuestbookForm component - we already have a test file for this, but it needs updating for the new user system
3. GuestbookEntries component - test entry rendering with user information

- `name` に対するバリデーションはなくなったので、テストケースも削除する
- 空のメッセージに対するテストケースを追加する
  - メッセージが空欄のまま送信した場合のエラーメッセージの確認
- toast をモックしているようだがなぜなのか

##### `test/components/UserProfile.test.tsx`
Now let's create a test file for the UserProfile component.

うーん、モックユーザーを作成しているが `https://example.com/avatar.jpg` は画像は返ってこないね

何度もテストに失敗しては修正 -> 再挑戦している。やったるで！みたいな感じだがその分お金かかるんよ…

##### `test/components/GuestbookEntries.test.tsx`
Finally, let's create a test file for the GuestbookEntries component to test the rendering of entries with user information.


- `waitFor` でこけているなあ

これかなあ https://testing-library.com/docs/dom-testing-library/api-async/#waitfor


#### 2回目のトライ
`@testing-library/jest-dom` をインストールしている

`test/test-utils.tsx`

The test failures show that we have issues with the toast hook mock implementation. We need to:

1. Create a proper mock for the toast hook in a shared location
2. Fix the import paths for the toast hook in tests
3. Update the mock implementation to better match the actual hook behavior

1回目では `test/components/UserProfile.test.tsx` と `test/components/GuestbookForm.test.tsx` にてトーストのモックを作成していたが、それとは別に `test/test-utils.tsx` にてモックを作成するように変更している

`test/test-utils.tsx`


The test failures appear to be related to React import issues and useToast hook mocking. Let's fix these by:

1. Adding proper React imports to test files
2. Setting up better mock utilities for the toast functionality
3. Improving the test provider wrapper

`test/components/GuestbookEntries.test.tsx`

Now let's update the GuestbookEntries test file to use the proper React import and test utilities.

うーん、どうも `npm run test` でエラーが出ているし、アプリ自体が立ち上がっていないな


---

仕方ないのでポチってテストケース追加前まで戻した

これで新規作成されたテストファイルや更新されたコンフィグなどが元に戻ったが、それでもテストが落ちている

要するに以前からテストが落ちていたのかもしれない。この辺りは `npm run test` (vitest) で watch mode でずっと立ち上げておけばとりあえず気づくことはできそうだ

---

### テストケースの修正

`test/components/GuestbookForm.test.tsx`

1. Toaster コンポーネントを追加（トースト通知のために必要）
2. テストケースの期待値を更新（名前フィールドは不要になった）

![スクリーンショット 2025-01-11 16.08.23]( {{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 16.08.23.png' | relative_url  }})

---

### テストケースの警告に対応する

```tsx
expect(screen.getByRole("button", { name: /sign/i })).toBeInTheDocument();
```

```
Property 'toBeInTheDocument' does not exist on type 'Assertion<HTMLElement>'.
```

https://qiita.com/Sicut_study/items/6feb6e7a9a7450eeb509

まあこの記事を見ればわかるのだが、AI に修正してもらう

`CompilerOptions` に いくつか追加する

現在の設定

```
    "types": ["node", "vite/client"],
```

このように修正してくれた

![スクリーンショット 2025-01-11 16.36.38]({{ '/assets/images/2025-01-11-replit-agent-first-look-3/スクリーンショット 2025-01-11 16.36.38.png' | relative_url  }})

1. includeに `test/**/*` を追加
2. typesに `@testing-library/jest-dom` と `vitest/globals` を追加
3. excludeをシンプルに整理

tsconfig.jsonの変更:
- includeに`test/**/*`を追加: テストファイルをTypeScriptのコンパイル対象に含めるために必要でした
- typesに `@testing-library/jest-dom` と `vitest/globals` を追加: テストライブラリの型定義を認識させるために必要でした

これらの変更は、テストファイルで `toBeInTheDocument()` のような`@testing-library/jest-domのmatchers` を使用する際に、TypeScriptがそれらの型を認識できるようにするために必要でした。

### 感想
- うーむ、途中わけがわからなくなってしまったが、以前の checkpoint まで戻せるのは便利だ
- テストケースの修正が意外とうまくいかない

# 記事タイトル案

*   Replit Agent ファーストインプレッション：AIエージェントと作るブログゲストブック
*   Replit Agent 実践記：AIと進めるWebアプリ開発の可能性と課題
*   Replit Agent を使ってみた：AIによる開発支援の現状と未来
*   AIエージェント Replit Agent でどこまでできる？ブログゲストブック開発を通して検証

# 記事アウトライン

## 1. はじめに

*   自己紹介とブログ記事の目的
    *   Replit Agentに興味を持った背景
    *   今回の記事で伝えたいこと
*   Replit Agentとは？
    *   Replit Agentの概要と特徴
    *   AIエージェントが開発をどのように支援するのか
*   今回の検証内容
    *   ブログゲストブックアプリケーションを題材に、Replit Agentの機能を試す
    *   ユーザープロフィールの実装とテストケース作成に焦点を当てる

## 2. Replit Agentによる機能拡張

*   Replit Agentが提案した機能拡張
    *   ソーシャル機能、UX改善、コンテンツ管理、分析機能など
    *   提案内容の妥当性と実現可能性についての考察
*   今回の実装対象
    *   ユーザープロフィールの作成とアバターのカスタマイズ
    *   なぜこの機能を選んだのか

## 3. ユーザープロフィールの実装

*   データベースとスキーマの変更
    *   `users` テーブルの作成
    *   `User` 型と `GuestbookEntry` 型の更新
*   バックエンドの実装
    *   `routes.ts` にユーザー関連のエンドポイントを追加
    *   仮ユーザーの作成
*   フロントエンドの実装
    *   `GuestbookForm.tsx` の変更（名前入力欄の削除）
    *   `GuestbookEntries.tsx` の変更（アバター画像の表示）
*   実装を通して感じたこと
    *   Replit Agentのコード生成能力
    *   実装のスピード感

## 4. エラー発生と修正

*   エントリフェッチ時のエラー
    *   エラーの原因分析
    *   Replit Agentによる修正提案
*   テーブルスキーマの修正
    *   `ALTER TABLE` と `CREATE TABLE` の実行
*   エラー修正を通して感じたこと
    *   Replit Agentのデバッグ能力
    *   エラー発生後の対応の仕方

## 5. ユーザープロフィールの表示と編集

*   `UserProfile.tsx` の実装
    *   プロフィール表示機能の作成
*   `UserProfileEditor.tsx` の実装
    *   プロフィール編集機能の作成
*   ルーティングの設定
    *   `/profile` ルートの追加
*   アバター画像のプレースホルダ表示
*   アバターURLの空欄入力対応
*   実装を通して感じたこと
    *   Replit AgentのUI実装能力
    *   ユーザーエクスペリエンスへの配慮

## 6. テストケースの作成

*   **テストケース作成の背景:**
    *   なぜテストケースを作成する必要があるのか？
    *   どのようなテストケースを作成しようとしたのか？
        *   `GuestbookForm.test.tsx`: ゲストブックフォームの動作をテスト
            *   メッセージの送信、バリデーション、エラーハンドリングなど
        *   `UserProfile.test.tsx`: ユーザープロフィールの表示と編集機能をテスト
            *   プロフィールの表示、編集、保存など
        *   `GuestbookEntries.test.tsx`: ゲストブックエントリの表示をテスト
            *   ユーザー情報を含むエントリのレンダリングなど
*   **Replit Agentによるテストコード生成:**
    *   Replit Agentが生成したテストコードの例を提示
        *   具体的なコード例を引用し、どのようなテストケースが生成されたかを示す
        *   例：`expect(screen.getByRole("button", { name: /sign/i })).toBeInTheDocument();`
    *   生成されたテストコードの品質や、テスト対象の機能との適合性について評価
        *   テストコードの網羅性、可読性、保守性などを評価
        *   生成されたテストコードが、実際のアプリケーションの動作をどれだけ正確に反映しているかを評価
*   **テストケース作成で直面した課題:**
    *   トースト通知のモック実装で発生した問題
        *   なぜモックが必要だったのか？
            *   トースト通知がUIの一部であり、テスト環境で再現する必要があったため
        *   どのようにモックを実装しようとしたのか？
            *   当初は各テストファイルでモックを作成していた
            *   `test/test-utils.tsx` に共通のモックを作成するに至った経緯を説明
        *   モックの実装が不十分で、テストが失敗した
    *   テストの失敗と修正の繰り返し
        *   どのようなエラーが発生したのか？
            *   例：`Property 'toBeInTheDocument' does not exist on type 'Assertion<HTMLElement>'.`
        *   エラーの原因をどのように特定したのか？
            *   エラーメッセージを解析し、型定義の問題であることを特定
        *   `tsconfig.json` の修正に至った経緯
            *   `include` に `test/**/*` を追加
            *   `types` に `@testing-library/jest-dom` と `vitest/globals` を追加
    *   テストがうまく動作しなかった原因の考察
        *   Replit Agentのテストコード生成能力の限界
            *   複雑なモックや非同期処理を伴うテストケースの生成が苦手
        *   テスト環境の構築の難しさ
            *   テストライブラリの設定や、モックの実装に手間がかかる
*   **テストケース作成を通して感じたこと:**
    *   Replit Agentのテストコード生成能力に対する評価
        *   簡単なテストケースは生成できるが、複雑なテストケースは人間が手を加える必要がある
    *   テストの重要性と難しさ
        *   テストはアプリケーションの品質を保証するために不可欠だが、実装には専門的な知識と経験が必要
    *   テストケース作成における人間の役割
        *   テストケースの設計、モックの実装、エラーの修正など、人間が主体的に関わる必要がある

この内容をベースに、具体的なコード例やエラーメッセージ、Replit Agentの挙動などを交えながら記述を進めてください。

## 7. まとめ

*   Replit Agentの評価
    *   良かった点
        *   高速なプロトタイピング
        *   コード生成能力
        *   エラー修正能力
    *   課題点
        *   テストケースの作成
        *   エラー修正の精度
*   今後の展望
    *   Replit Agentの進化に期待すること
    *   AIエージェントによる開発支援の可能性
*   読者へのメッセージ
    *   Replit Agentを試してみることを推奨
    *   フィードバックのお願い

## 8. 付録

*   参考資料
    *   Replit Agentの公式ドキュメント
    *   関連する技術記事
*   ソースコード
    *   今回の実装で使用したコードへのリンク
