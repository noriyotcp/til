// 6.1.5 オプショナルプロパティ再訪

type Human = {
  name: string;
  age?: number;
};

const uhyo: Human = {
  name: "uhyo",
  age: 25
};

const john: Human = {
  name: "John Smith",
  age: undefined // 明示的に入れることもできる
};

type Human2 = {
  name: string;
  age: number | undefined;
};

// error TS2741: Property 'age' is missing in type '{ name: string; }' but required in type 'Human2'.
// 省略は不可
// const taro: Human2 = {
//   name: "Taro Yamada"
// };
