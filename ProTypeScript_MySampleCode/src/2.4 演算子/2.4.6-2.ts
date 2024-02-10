// 2.4.6 論理演算子(2)一般形と短絡評価

import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question("名前を入力してください:", (name) => {
  const displayName = name || "名無し";
  console.log(`こんにちは、${displayName}さん`);
  rl.close();
});

