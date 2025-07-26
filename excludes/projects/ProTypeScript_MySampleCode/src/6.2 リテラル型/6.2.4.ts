// 6.2.4 リテラル型の widening

// 変数 uhyo1 は "uhyo" 型
const uhyo1 = "uhyo";

// 変数 uhyo2 は string 型
// letの場合は、変数の型がリテラル型に推論されそうな場合はプリミティブ型に変換するという処理が行われます。
// 後で再代入されることが期待されるから
let uhyo2 = "uhyo";

let uhyo: string | number = "uhyo";

uhyo = "john";
uhyo = 3.14;

// すべての文字列が代入できる訳ではないという場合は
// リテラル型のユニオン型が役立つ
// let uhyo: "uhyo" | "john" = "uhyo";

// uhyo3 の型は以下
// {
//   name: string;
//   age: number;
// }
// オブジェクトリテラルのプロパティ型はあとから書き換え可能なので windening が発生する
const uhyo3 = {
  name: "uhyo",
  age: 26
};

// あとから書き換えたくない場合は readonly を明示的に書く
// 型注釈を用意しない場合は as const が使える
type Human = {
  readonly name: string;
  readonly age: number;
};

const uhyo4: Human = {
  name: "uhyo",
  age: 26
};

// contextual typing
type Uhyo = {
  name: "uhyo";
  age: number;
};

// name が string に推論されてしまうように思われる
// でも Uhyo 型はプロパティが "uhyo" のみなので一般の string の可能性があるオブジェクトを受け入れられないはず
// しかし Uhyo 型がつくことが前提に型推論される
const uhyo5: Uhyo = {
  name: "uhyo",
  age: 26
};

function signNumber(type: "plus" | "minus") {
  return type === "plus" ? 1 : -1;
}

function useNumber(num: number) {
  return num > 0 ? "plus" : num < 0 ? "minus" : "zero";
}

// error TS2345: Argument of type '"uhyo"' is not assignable to parameter of type '"plus" | "minus"'.
// signNumber("uhyo");

// error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
// useNumber("uhyo");

