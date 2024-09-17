// 4.5.2 ブロックスコープと関数スコープ

function sabayomi(age: number) {
  if (age >= 20) {
    // if 文に付随するブロックの中で宣言されている
    const lie = age - 5;
    return lie;
  }

  return age;
}

console.log(sabayomi(19));
console.log(sabayomi(21));

function sum(arr: number[]) {
  let result = 0;
  for (let i = 0; i < arr.length; i++) {
    result += arr[i];
  }
  // error TS2304: Cannot find name 'i'.
  // console.log(i);
  return result;
}

console.log(sum([1,2,3,4,5,6,7,8,9]));

