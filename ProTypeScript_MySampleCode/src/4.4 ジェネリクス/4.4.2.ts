// 4.4.2 関数の型引数を宣言する方法

// function 関数式の名前がない
const repeat = function <T>(element: T, length: number): T[] {
  const result: T[] = [];
  for (let i = 0; i < length; i++) {
    result.push(element);
  }
  return result;
};

// アロー関数式
const repeat2 = <T>(element: T, length: number): T[] => {
  const result: T[] = [];
  for (let i = 0; i < length; i++) {
    result.push(element);
  }
  return result;
};

// メソッド記法
const utils = {
  repeat<T>(element: T, length: number): T[] {
    const result: T[] = [];
    for (let i = 0; i < length; i++) {
      result.push(element);
    }
    return result;
  },
};

const pair = <Left, Right>(left: Left, right: Right): [Left, Right] => [
  left,
  right,
];

// 型引数リストが複数の場合
const p = pair<string, number>("uhyo", 26);
console.log(p);

const repeat3 = <T extends { name: string }>(
  element: T,
  length: number
): T[] => {
  const result: T[] = [];
  for (let i = 0; i < length; i++) {
    result.push(element);
  }
  return result;
};

type HasNameAndAge = {
  name: string;
  age: number;
};

console.log(
  repeat3<HasNameAndAge>(
    {
      name: "uhyo",
      age: 26,
    },
    3
  )
);

// error TS2344: Type 'string' does not satisfy the constraint '{ name: string; }'.
// T は { name: string; } 型の部分型でなければならない
// console.log(repeat3<string>("uhyo", 3));
