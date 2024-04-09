// 6.3.1 等価演算子を用いる絞り込み

type SignType = "plus" | "minus";
function signNumber(type: SignType) {
  return type === "plus" ? 1 : -1;
}

function numberWithSign(num: number, type: SignType | "none") {
  if (type === "none") {
    // ここでは type は "none" 型
    return 0;
  } else {
    // ここでは type は SignType 型
    // "none" の可能性が除外されている
    return num * signNumber(type);
  }
}

function numberWithSign2(num: number, type: SignType | "none") {
  if (type === "none") {
    // ここでは type は "none" 型
    return 0;
  }
  // ここでは type は SignType 型
  // "none" の可能性が除外されている
  return num * signNumber(type);
}

function numberWithSign3(num: number, type: SignType | "none") {
  return type === "none" ? 0 : num * signNumber(type);
}

console.log(numberWithSign(5, "plus")); // 5
console.log(numberWithSign(5, "minus")); // -5
console.log(numberWithSign(5, "none")); // 0

console.log(numberWithSign2(5, "minus")); // -5
console.log(numberWithSign3(3, "plus")); // 3
