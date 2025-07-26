// 3.5.1 配列リテラルで配列を作成する

const arr = [0, 123, -456 * 100];
console.log(arr);

const arr2 = [100, "文字列", false];
console.log(arr2);

const arr3 = [4, 5, 6];
const arr4 = [1, 2, 3, ...arr3]; // [ 1, 2, 3, 4, 5, 6 ]
console.log(arr4);
