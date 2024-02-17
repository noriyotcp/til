// 3.6.3 配列の分割代入

const arr = [1, 2, 4, 8, 16, 32];

// 配列パターンによる分割代入においても、変数に型注釈を与えることができない点は変わらない
// 配列パターンで分割代入される変数の型は、配列の要素型となる
// arrの型はnumber[]型でしたから、変数first, second, thirdはnumber型が与えられることになる
const [first, second, third] = arr;

console.log(first); // 1
console.log(second); // 2
console.log(third); // 4
