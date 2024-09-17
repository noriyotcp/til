// 2.4.4 比較演算子と等価演算子

import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question("パスワードを入力してください:", (password) => {
  if (password === 'hogehoge') {
    console.log('ようこそ');
  } else {
    console.log('誰だ');
  }
  rl.close();
});

