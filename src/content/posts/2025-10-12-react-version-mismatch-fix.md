---
title: "react, react-dom のバージョン不一致エラーの対処メモ"
date: "2025-10-12 01:23:07 +0900"
last_modified_at: "2025-10-12 01:23:07 +0900"
tags: ["React", "dependabot"]
draft: false
---

拙作の Chrome 拡張、`lazycluster` の dependabot のプルリクが CI でこけてしまっていた。  

https://github.com/noriyotcp/lazycluster/pull/52
https://github.com/noriyotcp/lazycluster/actions/runs/18430799498/job/52517845189?pr=52

そもそも build できていない？けどローカルではビルドできた

build して拡張機能をリロードするとこんなエラーが

```
Uncaught Error: Incompatible React versions: The "react" and "react-dom" packages must have the exact same version. Instead got: - react: 19.2.0 - react-dom: 19.1.1 Learn more: https://react.dev/warnings/version-mismatch
```

react と react-dom のバージョンを合わせる必要がありそう。

`npm update react-dom` で合わせた。ついでに `dependabot.yml` にて更新のグループ化をした。

```yml
    groups:
      react:
        patterns:
          - "react*"
          - "@types/react*"
```

https://github.com/noriyotcp/lazycluster/pull/71/files
