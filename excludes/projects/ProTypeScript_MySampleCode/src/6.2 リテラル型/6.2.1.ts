// 6.2.1 4種類のリテラル型

// これは "foo" という文字列のみが属するリテラル型
type FooString = "foo";

// これは OK
// 文字列のリテラル型
const foo: FooString = "foo";

// Type '"bar"' is not assignable to type '"foo"'.
// const bar: FooString = "bar";

// 数値のリテラル型
const one: 1 = 1;

// 真偽値のリテラル型
const t: true = true;

// Bitint のリテラル型
const three: 3n = 3n;

// 変数 uhyoName は "uhyo" 型
const uhyoName = "uhyo";

// 変数 age は 26 型
const age = 26;
