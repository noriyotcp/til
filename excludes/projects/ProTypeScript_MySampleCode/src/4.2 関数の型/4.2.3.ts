// 4.2.3 返り値の型注釈は省略すべきか

function range(min: number, max: number): number[] {
  const result = [];
  for (let i = min; i <= max; i++) {
    result.push(i);
  }
// return を忘れるとコンパイル時にエラーが出る
// error TS2355: A function whose declared type is neither 'undefined', 'void', nor 'any' must return a value.

  return result;
}

const arr = range(5, 10);
// 型注釈をしていない場合、実行時にエラー
// TypeError: arr is not iterable
for (const value of arr) console.log(value);

