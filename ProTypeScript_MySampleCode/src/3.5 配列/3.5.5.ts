// 3.5.5 配列の機能を使う

const arr: readonly number[] = [1, 10, 100];
// Property 'push' does not exist on type 'readonly number[]'.
// arr.push(1000);
console.log(arr);

// Argument of type 'string' is not assignable to parameter of type 'number'.
// arr.push("foobar");

console.log(arr.includes(100));
console.log(arr.includes(50));

// Argument of type 'string' is not assignable to parameter of type 'number'.
// console.log(arr.includes("foobar"));

console.log(arr.indexOf(100)); // 2
console.log(arr.indexOf(50)); // -1

// (start, end) -> start 以上 end 未満
console.log(arr.slice(1, 2)); // [ 10 ]

arr.forEach((item) => console.log(item)); // 1 10 100
console.log(arr.map((item) => item * 2)); // [ 2, 20, 200 ]
console.log(arr.filter((item) => item > 10)); // [ 100 ]

const arr1: number[] = [1, 10, 100];
console.log(arr1.length); // 3
arr1.push(1000);
console.log(arr1); // [ 1, 10, 100, 1000 ]
