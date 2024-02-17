// 3.6.4 分割代入のデフォルト値

// foo はオプショナル
type Obj = { foo?: number }
const obj1: Obj = {};
const obj2: Obj = { foo: -1234 };

// foo が undefined なら 500 が代入される
// foo の型は number 型
// obj1.foo; は number | undefined 型
// デフォルト値の指定があるのとで undefined が代入されることはない
const { foo = 500 } = obj1;
console.log(foo); // 500
// foo が undefined でないならその値が代入される
const { foo: bar = 500 } = obj2;
console.log(bar); // -1234

// デフォルト値は　undefined のみに対して適用される
const obj = { foonull: null };
const { foonull = 123 } = obj;
console.log(foonull); // null

type NestedObj = { obj?: { foo: number } };
const nested1: NestedObj = {
  obj: { foo: 123 }
};
const nested2: NestedObj = {};

// foo1 には 123 が代入される
const { obj: { foo: foo1 } = { foo: 500 } } = nested1;
console.log(foo1); // 123

// nested2.obj が undefined なのでデフォルト値が代入される
// foo2 には 500 が代入される
const { obj: { foo: foo2 } = { foo: 500 } } = nested2;
console.log(foo2); // 500
