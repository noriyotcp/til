// 4.4.4 型引数を持つ関数型

// <T>(element: T, length: number) => T[]
type Func = <T>(arg: T, num: number) => T[]

const repeat: Func = (element, length) => {
  const result = [];
  for (let i = 0; i < length; i++) {
    result.push(element);
  }
  return result;
};

console.log(repeat("a", 5));

