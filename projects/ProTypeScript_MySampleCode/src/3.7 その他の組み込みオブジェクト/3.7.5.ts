// 3.7.5 プリミティブなのにプロパティがある？

// 厳密な説明としては、実はプリミティブに対してプロパティアクセスを行うたびに一時的にオブジェクトが作られます
// 文字列のlengthプロパティやmatchメソッドなどは、厳密にはこの一時的なオブジェクトが持つプロパティです
// この一時的なオブジェクトは、プロパティアクセスが終了したら消えます
const str = "Hello, world!";
console.log(str.length);

// 擬似的にプロパティを持つという性質により、TypeScriptの型システム上ではプリミティブがオブジェクト型に適合することがあります。たとえば文字列（string型）はlengthプロパティを持っていますから、次のように定義されたHasLength型の変数に文字列を代入することができます
type HasLength = { length: number };
const obj: HasLength = "foobar";
console.log(obj);
console.log(obj.length);
// TypeScriptのオブジェクト型は実はその中身が本当にオブジェクトである保証をしないのです。HasLength型は実は「number型のlengthプロパティを持つ値の型」であり、オブジェクトに制限されていません。もし真にオブジェクトである値のみを取り扱いたい場合にはobject型を用いることになります。

// {} という型はプロパティが1つもないオブジェクト型
// TypeScript は構造的部分型を採用しているため、何かプロパティがあるオブジェクトでも {} 型の値として認められる
// {} 型は値に何の制限もかけていない
// null, undefined 以外のあらゆる型を受け入れる
let val: {} = 123;
val = "foobar";
val = { num: 1234 };

// error TS2322: Type 'null' is not assignable to type '{}'.
// error TS2322: Type 'undefined' is not assignable to type '{}'.
// val = null;
// val = undefined;
