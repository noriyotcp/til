// 3.6.2 オブジェクトの分割代入(2)ネストしたパターン

const nested = {
  num: 123,
  obj: {
    foo: "hello",
    bar: "world"
  }
}

const { num, obj: { foo } } = nested;

console.log(num);
console.log(foo);
