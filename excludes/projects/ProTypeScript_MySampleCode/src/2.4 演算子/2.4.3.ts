// 2.4.3 文字列の結合を+演算子で行う

import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question("名前を入力してください:", (name) => {
  console.log("こんにちは、" + name + "さん！");
  rl.close();
});

