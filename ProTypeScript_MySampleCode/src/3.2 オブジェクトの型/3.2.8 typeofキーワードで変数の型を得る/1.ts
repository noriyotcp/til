const num: number = 0;
// 型 Tは変数 num の型、number型を持つ
type T = typeof num;
// 変数fooは型 T、つまり number型を持つ
const foo: T = 123;
console.log(foo);

// 型推論により、変数objは{ foo: number; bar: string; }型を持つ
const obj = {
  foo: 123,
  bar: "hi"
};

type MyObj = typeof obj;

const obj2: MyObj = {
  foo: -50,
  bar: ""
};

console.log(obj2);
