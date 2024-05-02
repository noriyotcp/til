// 6.4.2 keyof 型とは

type Human = {
  name: string;
  age: number;
};

// HumanKeys は Human のプロパティ名を表す文字列リテラル型のユニオン型
// "name" | "age"
type HumanKeys = keyof Human;

let key: HumanKeys = "name";
key = "age";
console.log(key); // "age"

// error TS2322: Type '"hoge"' is not assignable to type 'keyof Human'.
// key = "hoge";
