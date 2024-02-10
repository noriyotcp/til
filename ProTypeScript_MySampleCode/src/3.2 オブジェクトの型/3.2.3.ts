// 3.2.3 type文で型に別名をつける

// type文はどんな型にも別名をつけられる
// あくまで型に別名をつけるだけである
// type文は決して「新たに型を作って利用可能にする」ものではなく、「すでにある型に別名をつける」だけのものである

// FooBarObj を宣言する前に使ってもOK
const obj: FooBarObj = {
  foo: 123,
  bar: "Hello World!"
}

type FooBarObj = {
  foo: number;
  bar: string;
}

console.log(obj);


