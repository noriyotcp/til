// 2.3.9 プリミティブ型同士の変換(1)暗黙の変換を体験する

import { createInterface } from 'readline';

const rl = createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('文字列を入力してください:', (line) => {
  // line is string
  console.log(line + 1000);
  rl.close();
});

