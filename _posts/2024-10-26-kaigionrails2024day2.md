---
title: "Kaigi on Rails 2024 Day2"
date: "2024-10-26 10:33:45 +0900"
last_modified_at: "2024-10-26 12:56:32 +0900"
---

# Kaigi on Rails 2024 Day2
## Cache to Your Advantage: フラグメントキャッシュの基本と応用
[Cache to Your Advantage: フラグメントキャッシュの基本と応用 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/tkawa/)

key-value

```rb
cache @product
```

### 不安
- キャッシュの消し忘れ
  - キーベースのキャッシュ失効
  - `[model_name]/id-updated_at`
  - `model_name/query-sqlhash-個数-最新のupdated_at`
- 他のユーザーに見えてしまう

ページ全体をキャッシュすればいいのでは？ということでスピーカー本人の gem が紹介されている

https://github.com/tkawa/rendering_caching

model 更新時にキャッシュも更新される

### 注意点
キャッシュ内で session, cookies を使わないように

## OmniAuthから学ぶOAuth 2.0
[OmniAuthから学ぶOAuth 2.0 | Kaigi on Rails 2024](https://kaigionrails.org/2024/talks/ykpythemind/)

OIDCによる認証フローの概要

1. クライアントから ID　プロバイダに認証リクエストを送る
- リダイレクト

GoogleOAuth2 strategy -> OAuth2 strategy

2. 認証レスポンスが返ってきたらトークンリクエストを送る
3. 返ってきた ID token を検証して認証。必要に応じてアクセストークンを発行

`OmuniAuth.config.test_mode`



