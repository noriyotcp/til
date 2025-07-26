// 6.4.4 number 型もキーになれる？

type Obj = {
  0: string;
  1: number;
}

const obj: Obj = {
  0: "uhyo",
  "1": 26
};

obj["0"] = "john";
obj[1] = 15;

// OjbKeys は 0 | 1 型
type ObjKeys = keyof Obj;

// function get<T, K extends keyof T>(obj: T, key: K): T[K] {
  // Type 'string | number | symbol' is not assignable to type 'string'.
  // Type 'number' is not assignable to type 'string'.
  // T が不明なときに keyof T が文字列とは限らない
  // const keyName: string = key;
//   return obj[key];
// };

// K は string の部分型であるという制限を持つ
function get<T, K extends keyof T & string>(obj: T, key: K): T[K] {
  const keyName: string = key;
  return obj[key];
};
