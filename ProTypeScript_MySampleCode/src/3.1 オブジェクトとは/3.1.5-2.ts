// 3.1.5 オブジェクトリテラル(3)スプレッド構文

const obj1 = {
  foo: 123,
  bar: 456,
  baz: 789
};

const obj2 = {
  ...obj1,
  foo: -9999,
};

// 'foo' is specified more than once, so this usage will be overwritten.
// const obj2 = {
//   foo: -9999,
//   ...obj1,
// };

// { foo: -9999, bar: 456, baz: 789 }
console.log(obj2);

