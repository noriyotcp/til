// コラム 19
// 型引数はどのように推論されるのか

function makeTriple<T>(x: T, y: T, z: T): T[] {
  return [x, y, z];
}

// T は string と推論される
const stringTriple = makeTriple("foo", "bar", "baz");
console.log(stringTriple);

// error TS2345: Argument of type 'number' is not assignable to parameter of type 'string'.
// 第1引数で string と推論されているので、第2引数の型が違うとエラー
// const mixed = makeTriple("foo", 123, false);

// 引数として与えられた関数を2回実行する関数を返す
function double<T>(func: (arg: T) => T): (arg: T) => T {
  return (arg) => func(func(arg));
}

// これにより double の型引数 T は number と推論される
type NumberToNumber = (arg: number) => number;

// 引数に +1 する関数を引数として与える
// plus2 は 引数として与えられた関数を2回実行する関数
// 与えられた引数 x => x + 1 から推論できないので文脈の情報を用いる
const plus2: NumberToNumber = double(x => x + 1);
// もしくは <number> という型引数を与える
// const plus2 = double<number>(x => x + 1);

// plus2 の型注釈を省略すると推論できる情報がない
// error TS18046: 'x' is of type 'unknown'.
// const plus2 = double(x => x + 1);

// 10 は x である。double(10 => 10 + 1); となる
console.log(plus2(10)); // 12

