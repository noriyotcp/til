// 3.5.2 配列の要素にアクセスする

const arr = [0, 123, -456 * 100];
console.log(arr[0]);
console.log(arr[1]);

console.log(arr);
// arr は const で宣言されているが、その要素に再代入は可能
// arr は同じオブジェクトのままなので
arr[1] = 5400;
console.log(arr); // [ 0, 5400, -45600 ]

// Cannot assign to 'arr' because it is a constant.
// arr = [1, 2, 345, 67];
