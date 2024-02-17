// 3.5.6 for-of 文によるループ

const arr = [1, 10, 100];

// 実際には、各ループで変数が作りなおされるのでconstで問題ない
for (const elm of arr) {
  console.log(elm);
}

// ループ内で変数elmに対して再代入を行っても問題ない
// このようにelmを書き換えても配列arr本体には影響しない
// このプログラムを実行したあとでも配列arrは[1, 10, 100]のまま
// この変数elmはあくまでarrの各要素が毎回代入されているだけで、arrの中身そのものを参照しているわけではない。
for (let elm of arr) {
  elm *= 10;
  console.log(elm);
}
