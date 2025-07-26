// 4.1.3 関数式で関数を作る
// 分割代入バージョン

// 関数式の場合、関数の宣言よりも前に呼び出すことはできません。
// ただの変数宣言と組み合わせて使うことができますが、その場合、まだ宣言されていない変数を使うことはできません
// error TS2448: Block-scoped variable 'calcBMI' used before its declaration.
// error TS2454: Variable 'calcBMI' is used before being assigned.
// const uhyo: Human = { height: 1.84, weight: 72 };
// console.log(calcBMI(uhyo));

type Human = {
  height: number;
  weight: number;
};

const calcBMI = function({ height, weight }: Human): number {
  return weight / height ** 2;
};

const uhyo: Human = { height: 1.84, weight: 72 };

console.log(calcBMI(uhyo));
