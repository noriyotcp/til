// 3.7.3 正規表現オブジェクト（２）正規表現を使う方法

console.log("Hello,    abbbbbbbc    world!    abbc".replace(/ab+c/, "foobar")); // Hello,    foobar    world!    abbc

console.log("Hello,    abbbbbbbc    world!    abbc".replace(/ab+c/g, "foobar")); // Hello,    foobar    world!    foobar

const result = "Hello, abbbbbbbc world! abbc".match(/a(b+)c/);

// 0番目：マッチした文字列全体
// 1番目：最初のキャプチャリンググループにマッチした文字列
// result は null になる可能性もある
if (result !== null) {
  console.log(result[0]); // abbbbbbbc
  console.log(result[1]); // bbbbbbb
}

const result2 = "Hello, abbbbbbbc world! abbc".match(/a(?<worldName>b+)c/);

if (result !== null) {
  console.log(result2!.groups); // [Object: null prototype] { worldName: 'bbbbbbb' }
}

// match メソッドに渡す正規表現に g フラグをつけると、マッチする文字列全てを配列で返す
const result3 = "Hello, abbbbbbbc world! abbc".match(/a(b+)c/g);
console.log(result3); // [ 'abbbbbbbc', 'abbc' ]
