const num1 = Number(true);
console.log(num1); // 1

const num2 = Number(false);
console.log(num2); // 0

const num3 = Number(null);
console.log(num3); // 0

const num4 = Number(undefined);
console.log(num4); // NaN

const bigint1 = BigInt("1234");
console.log(bigint1); // 1234n

const bigint2 = BigInt(500);
console.log(bigint2); // 500n

const bigint3 = BigInt(true);
console.log(bigint3); // 1n

// SyntaxError: Cannot convert fooooo to a BigInt
// const bigint = BigInt("fooooo");
// console.log("bigint is ", bigint);

const str1 = String(1234.5); // 1234.5 という文字列
console.log(str1);

const str2 = String(true); // true という文字列
console.log(str2);

const str3 = String(null); // null という文字列
const str4 = String(undefined); // undefined という文字列
console.log(str3, str4);
