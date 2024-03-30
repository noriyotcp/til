// 6.2.3 ユニオン型とリテラル型を組み合わせて使うケース

function signNumber(type: "plus" | "minus") {
  return type === "plus" ? 1 : -1;
}

console.log(signNumber("plus"));
console.log(signNumber("minus"));

// error TS2345: Argument of type '"uhyo"' is not assignable to parameter of type '"plus" | "minus"'.
// console.log(signNumber("uhyo"));

