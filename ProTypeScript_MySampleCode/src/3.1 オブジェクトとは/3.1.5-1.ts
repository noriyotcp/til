// 3.1.5 オブジェクトリテラル(3)スプレッド構文

const obj1 = {
  bar: 456,
  baz: 789
};

const obj2 = {
  foo: 123,
  ...obj1
};

console.log(obj2);


