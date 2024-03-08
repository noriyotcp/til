// 4.3.3 引数の数による部分型関係

type UnaryFunc = (arg: number) => number;
type BinaryFunc = (left: number, right: number) => number;

const double: UnaryFunc = arg => arg * 2;
const add: BinaryFunc = (left, right) => left + right;

// UnaryFunc を BinaryFunc として扱うことができる
const bin: BinaryFunc = double;

// 20 が表示される
// bin に入っている関数は arg => arg * 2
// なので第1引数しか受け取らない
console.log(bin(10, 100));

