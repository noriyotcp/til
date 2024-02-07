import { createInterface } from "readline";

const rl = createInterface({
  input: process.stdin,
  output: process.stdout,
});

rl.question("名前を入力してください:", (name) => {
  const getDefaultName = () => "名無しなんですけど";
  const displayName = name || getDefaultName();

  console.log(`こんにちは、${displayName}さん`);
  rl.close();
});
