// 4.3.1 返り値の型による部分型関係

type HasName = {
  name: string;
}

// HasName の部分型
type HasNameAndAge = {
  name: string;
  age: number;
}

// (age: number) => HasNameAndAge は (age: number) => HasName の部分型
const fromAge = (age: number): HasNameAndAge => ({
  name: "John Smith",
  age,
});

// (age: number) => HasName の変数 f に代入することができる
const f: (age: number) => HasName = fromAge;
// obj に hasName 型を与えているが f, fromAge は同じ関数型なので name, age を持つオブジェクトを返す
// 型情報に比べてより情報の多いオブジェクトを返すことがある
// 型情報に合わせて情報が削られることはない
const obj: HasName = f(100);

