# p003-dev

GitHub Copilotを利用したサンプルコードです。

## プロジェクト利用の準備
`npm install`コマンドでライブラリーをインストールしてください。

## サンプルコードの実行方法

`npm run start`コマンドを実行します。最初に実行されるのは`index.js`ファイルです。

## 単体テストの実行方法

`npm test`コマンドを実行します。単体テストは`getPhoneBrand.test.js`ファイルに記述されています。

## 補足：プロジェクトにJestを設定する方法

プロジェクト未設定の場合、以下コマンドで設定します。

```
npm init -y
```

以下コマンドで、プロジェクトにJestを（開発用ライブラリーとして）インストールします。

```
npm install --save-dev jest
```

次に、package.jsonの`scripts`セクションに以下記述を追加します。

```json
"scripts": {
    "test": "jest"
}
```

以上の設定により、`npm test`コマンドでJestがプロジェクト内のテストを自動的に見つけて実行します。