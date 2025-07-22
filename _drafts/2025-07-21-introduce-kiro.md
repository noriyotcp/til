---
title: "2025-07-21"
date: "2025-07-21 22:53:53 +0900"
last_modified_at: "2025-07-21 22:53:53 +0900"
---

# 2025-07-21
waitlist に登録してなくても `brew` で行けるで、とのことでやってみた  

https://formulae.brew.sh/cask/kiro#default

```sh
brew install --cask kiro
 ❯ brew install --cask kiro
==> Downloading https://prod.download.desktop.kiro.dev/releases/202507180243-Kiro-dmg-darwin-x64.dmg
######################################################################################################################################### 100.0%
==> Installing Cask kiro
==> Moving App 'Kiro.app' to '/Applications/Kiro.app'
🍺  kiro was successfully installed!
```

なんか重たい。一瞬これはエミュレートバージョンやで、的なメッセージが出る。そういえばダウンロードしたのが `darwin-x64.dmg` なんですけど。。。

プライベートのGoogle account でログインした。

VS Code の設定もインポートしてもらう。結構時間がかかった  

---

既存のプロジェクトの場合はポチると steering を作る。とは何か？  

spec でドキュメントとかを作る。新機能の追加をプロンプトから依頼するとそれに関する spec/ files を作る。requirements, design, tasks  

hooks 日本語で説明するとフックを作る .kiro/hooks  
ファイルを保存したら基本的なテストを追加して。もしなかったら各コンポーネント用のテストを作って  
component にコメントで Test comment とだけ追加して保存するとテストを作ってくれた。すごい  


