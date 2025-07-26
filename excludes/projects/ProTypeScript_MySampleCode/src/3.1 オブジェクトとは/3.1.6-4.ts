// 3.1.6 オブジェクトはいつ同じなのか

const foo = { num: 1234 };
const bar = foo;
const baz = { num: 1234 };

console.log(foo === bar); // true
console.log(foo === baz); // false

