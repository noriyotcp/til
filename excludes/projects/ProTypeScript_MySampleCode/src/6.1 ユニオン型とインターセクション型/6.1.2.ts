// 6.1.2 伝播するユニオン型

type Animal = {
  species: string;
  age: string;
};

type Human = {
  name: string;
  age: number;
};

type User = Animal | Human;

// このオブジェクトは Animal 型なので User 型に代入可能
const tama: User = {
  species: "Felis silverstris catus",
  age: "永遠の17歳"
};

// このオブジェクトは Human 型なので User 型に代入可能
const uhyo: User = {
  name: "uhyo",
  age: 26
};

function showAge(user: User): User["age"] {
  const age = user.age;
  return age;
}

console.log(showAge(tama));
console.log(showAge(uhyo));

type MysteryFunc =
  | ((str: string) => string)
  | ((str: string) => number)

function useFunc(func: MysteryFunc) {
  const result =  func("Hello");
  console.log(result);
}

useFunc((str: string) => str);

type MaybeFunc =
  | ((str: string) => string)
  | string;

// This expression is not callable.
// Not all constituents of type 'MaybeFunc' are callable.
//   Type 'string' has no call signatures.ts(2349)
// ユニオンの構成要素に関数でない（コールシグネチャを持たない）型が混ざっているので呼び出すことができない
// function useMaybeFunc(func: MaybeFunc) {
//   const result = func("uhyo");
// }
