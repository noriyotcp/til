// 3.5.7 タプル型

// 要素数は固定されている
// 各要素に異なる型を与える事ができる
let tuple: [string, number] = ["foo", 0];
tuple = ["aiueo", -555];

console.log(tuple);

const str = tuple[0];
const num = tuple[1];
console.log(str, num);

// Tuple type '[string, number]' of length '2' has no element at index '2'.
// const nothing = tuple[2];

// TypeScript ではタプル型は配列型の一種となっている
// 今のところ土台となるJavaScriptがタプルという概念を持っておらず、配列で代用しているため
// 上の例にもあるようにタプル型の値を作る際は配列リテラルを使用する

// object type との違いはタプルは各データに名前をつけない。インデックスアクセスをする

// ラベル付きタプル型
type User = [name: string, age: number];
const uhyo: User = ["uhyo", 26];
console.log(uhyo[1]); // 26
// 結局インデックスアクセスになるのでオブジェクト型で良さげ

// オプショナルな要素を持つタプル
let tupleWithOptional: [string, number, string?] = ["aiueo", -555];
console.log(tupleWithOptional);

tupleWithOptional = ["aiueo", -555, "kakikukeko"];
console.log(tupleWithOptional);
