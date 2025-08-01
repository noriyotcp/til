// 3.5.3 配列型の記法

const arr: number[] = [1, 10, 100];
// Type 'number' is not assignable to type 'string'.
// const arr2: string[] = [123, -456];

const arr1: boolean[] = [false, true];

const arr2: Array<{
  name: string;
}> = [
  { name: "山田さん" },
  { name: "田中さん" },
  { name: "鈴木さん" },
];

console.log(arr);
console.log(arr1);
console.log(arr2);

// 配列の要素には異なる型を混在させることができる
// (number | string | boolean)[] という型
const arr3 = [100, "文字列", true];
