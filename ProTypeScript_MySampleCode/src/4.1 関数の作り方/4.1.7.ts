// 4.1.7 可変長引数の宣言

const sum = (...args: number[]): number => {
  let result = 0;
  for (const num of args) {
    result += num;
  }
  return result;
};

console.log(sum(1, 10, 100));
console.log(sum(123, 456));
console.log(sum());

const sum2 = (base: number, ...args: number[]): number => {
  let result = base * 1000;
  for (const num of args) {
    result += num;
  }
  return result;
};

console.log(sum2(1, 10, 100));
console.log(sum2(123, 456));
// Expected at least 1 arguments, but got 0.
// console.log(sum2());
