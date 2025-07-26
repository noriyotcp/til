// 3.4.1 型引数を持つ型を宣言する
// 宣言の中（type 分の = の右側）でだけ有効な型名として扱われる
// User は型引数 T を持つ型
// T は User のプロパティ child の型として使われる
// これらはジェネリック型と呼ばれる
type User<T> = {
  name: string;
  child: T;
};

type Family<Parent, Child> = {
  mother: Parent;
  father: Parent;
  child: Child;
};
