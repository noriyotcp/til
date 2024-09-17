// 3.3.3 余剰プロパティに対する型エラー

// 部分型関係により、この代入は問題ないはず
// だがエラーになるのはミスを防ぐため
// telNumber にアクセスすることはできないので代入しても意味がない
// type User = { name: string; age: number };
// const u: User = {
//   name: "noriyo",
//   age: 26,
//   telNumber: "000-1234-5678" // Error: Object literal may only specify known properties, and 'telNumber' does not exist in type 'User'.
// }

type User = { name: string, age: number };
// obj は型推論により { name: string, age: number, telNumber: string } となる
const obj = {
  name: "noriyo",
  age: 26,
  telNumber: "000-1234-5678"
};
// { name: string, age: number, telNumber: string } は User の部分型である
const u: User = obj;
console.log(u);
