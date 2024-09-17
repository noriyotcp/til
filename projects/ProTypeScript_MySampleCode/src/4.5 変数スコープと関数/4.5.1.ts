// モジュールスコープに属する変数
const repeatLength = 5;
const repeat = function<T>(element: T): T[] {
  // この変数 repeatLength は repeat の関数スコープに属する
  // for 文の中で使われる repeatLength はこの変数
  const repeatLength = 3;
  // この変数 result は repeat の変数スコープに属する
  const result: T[] = [];
  for (let i = 0; i < repeatLength; i++) {
    result.push(element);
  }

  // Cannot redeclare block-scoped variable 'result'.
  // const result = [];

  return result;
};

// 関数の外には変数 result は存在しない
// エラー： Cannot find name 'result'.
// console.log(result);
console.log(repeat("a")); // [ 'a', 'a', 'a' ]
console.log(repeatLength); // 5
