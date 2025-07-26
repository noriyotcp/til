// 2.4.8 代入演算子

import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question("名前を入力してください:", (name) => {
  if (name === '') {
    name = '名無し';
  }
  console.log(`こんにちは、${name}さん`);
  rl.close();
});

