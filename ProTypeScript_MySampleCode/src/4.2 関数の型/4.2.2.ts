// 4.2.2 返り値の型注釈は省略可能
type F = (repeatNum: number) => string;
// 関数の返り値の型注釈は省略可能
// 型推論によって返り値の型が決まる
const xRepeat = (num: number): string => "x".repeat(num);
console.log(xRepeat(2));

const g = (num: number) => {
  for (let i = 0; i < num; i++) {
    console.log(`Hello, world! ${i}回目`);
  }
}
console.log(g(1));
