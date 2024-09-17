// 3.7.2 正規表現オブジェクト（１）正規表現の基本

const r = /ab+c/;

// + は直前の文字が1回以上繰り返されることを表す
console.log(r.test("abbbbc")); // true
console.log(r.test("Hello, abc world!")); // true

// マッチする文字列はない
console.log(r.test("ABC")); // false
console.log(r.test("こんにちは")); // false

// 文字列の先頭にある abc にマッチする
const r2 = /^abc/;
console.log(r2.test("abcdefg")); // true
console.log(r2.test("Hello, abcdefg")); // false
