// 3.4.2 型引数を持つ型を使用する
// 型引数を持つ型を使用するには、型名の後に<>を使って型引数を指定する
type Family<Parent, Child> = {
  mother: Parent;
  father: Parent;
  child: Child;
};

const obj: Family<number, string> = {
  mother: 1,
  father: 2,
  child: "3"
};

console.log(obj);

// Generic type 'Family' requires 2 type argument(s).
// const obj: Family = {
//   mother: 1,
//   father: 2,
//   child: "3",
// };
