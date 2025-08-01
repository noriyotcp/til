// 3.1.4 プロパティアクセス:値の取得と代入

import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

const messages = {
  good: "0 以上の数値が入力されました！",
  bad: "負の数値を入力しないでください！",
}

rl.question("数値を入力してください:", (line) => {
  const num = Number(line);
  if (Number.isNaN(num)) {
    console.log("数値ではありません。");
    rl.close();
    return;
  }
  console.log(messages[num >= 0 ? "good" : "bad"]);
  rl.close();
});

