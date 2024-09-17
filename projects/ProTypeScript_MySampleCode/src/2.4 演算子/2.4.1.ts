// 2.4.1 算術演算子(1)二項演算子

const addResult = 1024 + 314 + 500;
console.log(addResult);
const discounted = addResult * 0.7;
console.log(discounted);

const sqrt2 = 2 ** 0.5;
console.log(sqrt2);
console.log(sqrt2 - 1);

console.log(18 / 12);
console.log(18n / 12n); // 1n 少数は切り捨て

console.log(18 % 12);
console.log(18n % 12n);

const res1 = 5 - 1.86;
const res2 = 2n ** 5n; // res2 の型はbigint

const str: string = '123';
// The right-hand side of an arithmetic operation must be of type 'any', 'number', 'bigint' or an enum type.
// console.log(123 * str);

// 優先度、左から高い順
// **, * / %, + -

