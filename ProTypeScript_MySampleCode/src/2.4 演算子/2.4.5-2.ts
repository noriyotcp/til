// 2.4.5 論理演算子(1)真偽値の演算

import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question("数値を入力してください:", (line) => {
  const num = Number(line);
  if (Number.isNaN(num)) {
    console.log(`${num}は数値にしてください`);
  } else if (0 <= num && num < 100) {
    console.log(`${num}は0以上100未満です`);
  } else {
    console.log(`${num}は0以上100未満ではありません`);
  }
  rl.close();
});

