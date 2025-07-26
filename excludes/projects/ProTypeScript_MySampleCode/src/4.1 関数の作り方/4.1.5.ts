// 4.1.5 アロー関数式の省略形

type Human = {
  height: number;
  weight: number;
};

// const calcBMI = ({ height, weight }: Human): number => {
//   return weight / height ** 2
// };

// (引数リスト):返り値の型 => 式
const calcBMI = ({ height, weight }: Human): number => weight / height ** 2;

const uhyo: Human = { height: 1.84, weight: 72 };

console.log(calcBMI(uhyo));

type ReturnObj = {
  bmi: number;
};

// 返り値の式としてオブジェクトリテラルを使いたい場合
// オブジェクトリテラルを( )で囲む必要がある
// ( )で囲まないと=>の右の{ }がオブジェクトリテラルではなく通常の（省略形でない）アロー関数の中身を囲む{ }であると見なされてしまう
const calcBMIObject = ({ height, weight }: Human): ReturnObj => ({
  bmi: weight / height ** 2
});

console.log(calcBMIObject(uhyo));

// error TS2355: A function whose declared type is neither 'undefined', 'void', nor 'any' must return a value.
// const calcBMIObject2 = ({ height, weight }: Human): ReturnObj => { bmi: weight / height ** 2 };
