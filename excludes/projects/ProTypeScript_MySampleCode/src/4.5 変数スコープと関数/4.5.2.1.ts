// 4.5.2 ブロックスコープと関数スコープ

function sabayomi(age: number) {
  if (age >= 30) {
    // if 文に付随するブロックの中で宣言されている
    const lie = age - 10;
    return lie;
  }

  if (age >= 20) {
    // if 文に付随するブロックの中で宣言されている
    const lie = age - 5;
    return lie;
  }


  return age;
}

console.log(sabayomi(19));
console.log(sabayomi(20));
console.log(sabayomi(29));
console.log(sabayomi(30));

