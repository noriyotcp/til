// 6.3.2 typeof 演算子を用いる絞り込み

// typeof の結果をテーブルで示す
// | 式の評価結果 | typeof の結果 |
// | ------------- | ------------- |
// | 文字列        | "string"      |
// | 数値          | "number"      |
// | 真偽値        | "boolean"     |
// | BigInt        | "bigint"      |
// | シンボル      | "symbol"      |
// | null          | "object"      |
// | undefined     | "undefined"   |
// | オブジェクト（関数以外）  | "object" |
// | 関数          | "function"    |

console.log(typeof "uhyo"); // string
console.log(typeof 26); // number
console.log(typeof {}); // object
console.log(typeof undefined); // undefined

function formatNumberOrString(value: string | number) {
  if (typeof value === "number") {
    // ここでは value は number 型
    return value.toFixed(3);
  } else {
    // ここでは value は string 型
    return value;
  }
}

console.log(formatNumberOrString(3.14)); // 3.140
console.log(formatNumberOrString("uhyo")); // uhyo
