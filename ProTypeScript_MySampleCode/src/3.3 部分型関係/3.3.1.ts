// 3.3.1 部分型とは
// foo, bar 以外のことには言及していない
type FooBar = {
  foo: string;
  bar: number;
}

// FooBar の部分型である
type FooBarBaz = {
  foo: string;
  bar: number;
  baz: boolean;
}

const obj: FooBarBaz = {
  foo: "hi",
  bar: 1,
  baz: false
};

const obj2: FooBar = obj;

console.log(obj2);
