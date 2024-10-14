---
title: "React 研修"
date: "2024-10-12 16:33:38 +0900"
last_modified_at: "2024-10-15 02:23:50 +0900"
tags:
  - React
---

# React 研修
https://speakerdeck.com/recruitengineers/react-yan-xiu-2024

内部的な todoList とそれを表示するための別のステートが必要になるのか？  

todoList の更新に伴ってその表示用のステートも変化させる必要があるか
-> `todoList`, `initialTodoList` と分けることにした

- `todoList` は表示用のもの
- `initialTodoList` は実体、という感じ

どちらも操作によって更新されることは同じ。フィルタリングの際に違いがある  
`todoList` はフィルタリングによって更新されるが（そのことにより表示が変わる） 実体である `initialTodoList` は変わらない

https://github.com/noriyotcp/react-training-2024/pull/8

## 4-4
`useReducer` を使う

todoList の管理

- 新しいアイテムの追加
  - 'Add'
- アイテムの削除
  - 'Remove'
- 完了・未完了にする
  - 'Complete'
  - 'Incomplete'

下書き。その他のペイロードを定義していない

```tsx
// state
// todoList

type Add = {
  type: 'Add';
}

type Remove = {
  type: 'Remove';
}

type Complete = {
  type: 'Complete';
}

type Incomplete = {
  type: 'Incomplete';
}
```

StackBlitz がだいぶ重たいのでローカルでの開発にしようかなあ

一旦 `TodoList.tsx` を作成してそこにごちゃっとまとめる形にした。あとでリファクタリングしたい

- [ ] もう少し Reducer に対する理解を深めたい

---

`AddTodoItem` でインプットが空の時は追加ボタンを無効状態にしている  
以下のように変更するか？

- ボタンに ref を張る
- インプットの状態(state) によって `buttonRef.current.disabled = true;` みたいな感じ？

### 10/14
ひとまず演習5-3 までは進んだ。`useEffect()` が出てくる  
やっぱり `useReducer()`, `useEffect()` から難易度がぐっと上がる感じだ  
じっくり取り組んでいこう

