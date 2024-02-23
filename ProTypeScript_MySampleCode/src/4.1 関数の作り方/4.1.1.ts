// 4.1.1 関数宣言で関数を作る

function range(min: number, max: number): number[] {
  const result = [];
  for (let i = min; i <= max; i++) {
    result.push(i);
  }

  // error TS2322: Type 'number' is not assignable to type 'number[]'.
  // return max;
  return result;
}

console.log(range(5, 10));

// error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
// error TS2554: Expected 2 arguments, but got 1.
// range("5", "10");
// range(5);

