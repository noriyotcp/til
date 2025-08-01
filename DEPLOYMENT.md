# GitHub Pages デプロイメント設定

このプロジェクトはGitHub Actionsを使用してGitHub Pagesに自動デプロイされます。

## 初回設定手順

1. **GitHub リポジトリの設定**
   - GitHubでリポジトリの **Settings** タブに移動
   - 左サイドバーの **Pages** セクションを選択
   - **Source** として **GitHub Actions** を選択

2. **ワークフローファイル**
   - `.github/workflows/deploy.yml` が既に設定済み
   - `main` ブランチへのプッシュで自動デプロイが実行される
   - 手動実行も可能（Actions タブから）

3. **設定確認**
   - `astro.config.mjs` で以下が設定されていることを確認：
     ```javascript
     export default defineConfig({
       site: 'https://noriyotcp.github.io/til/',
       base: '/til',
       // ...
     })
     ```

## デプロイプロセス

1. `astro-migration` ブランチにコードをプッシュ（現在の設定）
2. GitHub Actions が自動的に実行される：
   - Node.js 20 環境をセットアップ
   - npm で依存関係をインストール
   - Astro サイトをビルド
   - GitHub Pages にデプロイ
3. デプロイ完了後、サイトが https://noriyotcp.github.io/til/ で利用可能

## ブランチ設定について

現在は `astro-migration` ブランチでの開発・テスト用に設定されています。
最終的にmainブランチに移行する際は：

1. `.github/workflows/deploy.yml` の `branches: [ astro-migration ]` を `branches: [ main ]` に変更
2. 変更をコミット・プッシュ

## トラブルシューティング

- **ビルドエラー**: Actions タブでログを確認
- **404エラー**: `base` 設定が正しいか確認
- **権限エラー**: リポジトリの Pages 設定を確認

## ローカル開発

```bash
cd astro-site
npm install
npm run dev
```

本番ビルドのテスト：

```bash
npm run build
npm run preview
```
