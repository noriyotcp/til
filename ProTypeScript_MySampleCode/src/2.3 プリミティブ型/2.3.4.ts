// 2.3.4 任意精度整数(BigInt)

const bignum: bigint = (123n + 456n) * 2n; // Bigint リテラル、整数の後にnを書く
console.log(bignum); // 1158n と表示される

// BigInt 派生数のみしか扱えないので、除算の結果が小数になる場合は、小数点以下を切り捨てた整数になる
const result = 5n / 2n; // 2n と表示される
console.log(result);

// Operator '+' cannot be applied to types '100n' and '50'.
// const wrong = 100n + 50; // エラーになる

