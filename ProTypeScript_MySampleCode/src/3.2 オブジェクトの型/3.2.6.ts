// 3.2.6 オプショナルなプロパティの宣言

type MyObj = {
  foo: boolean;
  bar: boolean;
  baz?: number;
}

const obj: MyObj = { foo: false, bar: true };
const obj2: MyObj = { foo: true, bar: false, baz: 1234 }

console.log(obj.baz); // undefined
console.log(obj2.baz); // 1234

// console.log(obj2.baz * 1000); // これはコンパイルエラー

if (obj2.baz !== undefined) {
  console.log(obj2.baz * 1000); // 1234000
}

