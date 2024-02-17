// 3.6.1 オブジェクトの分割代入(1)基本的なパターン

// const obj = { foo: "foo", bar: "bar" };
// const { foo, bar } = obj;
// console.log(foo, bar);

const obj = { foo: "foo", bar: "bar", "foo bar": "foobar" };
const {
  foo,
  bar: barVar,
  "foo bar": fooBar
} = obj;

// foo bar foobar
console.log(foo, barVar, fooBar);

// Property 'buzz' does not exist on type '{ foo: string; bar: string; "foo bar": string; }'.
// const {
//   buzz
// } = obj;

