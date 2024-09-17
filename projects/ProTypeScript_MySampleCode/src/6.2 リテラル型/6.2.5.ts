// 6.2.5 widening されるリテラル型・widening されないリテラル型

// widening される "uhyo" 型
// 型注釈がないので "uhyo" という式の型がそのまま uhyo1 の型になる
// "uhyo" というリテラル型が推論される
const uhyo1 = "uhyo";
// widening されない "uhyo" 型
// "uhyo" 型が明示的に書かれている
const uhyo2: "uhyo" = "uhyo";

// string 型
// windening が発生する
let uhyo3 = uhyo1;
// "uhyo" 型
// windening が発生しない
let uhyo4 = uhyo2;
