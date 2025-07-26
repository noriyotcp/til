// https://speakerdeck.com/recruitengineers/react-yan-xiu-2024?slide=123
function f(m) {
  return (n) => m + n; // closure 外側の変数をキャプチャ
}

const add1 = f(1); // m == 1
console.log(add1(2));

const add2 = f(2); // m == 2
console.log(add2(2));

// ソース上では同じ関数だが実行時は異なる関数オブジェクト
console.log(add1 == add2); // false

