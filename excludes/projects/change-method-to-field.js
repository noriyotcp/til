// https://typescriptbook.jp/reference/values-types-variables/object/properties-of-objects

const calculator = {
  sum(a, b) {
    return a + b;
  },
};

console.log(calculator.sum(1, 1));
// 2

calculator.sum = null;
// console.log(calculator.sum(1, 1));
// TypeError: calculator.sum is not a function

calculator.sum = 10;
console.log(calculator.sum);
// 10

