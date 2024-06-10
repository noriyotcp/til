// https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Functions/Arrow_functions

const materials = ['Hydrogen', 'Helium', 'Lithium', 'Beryllium'];
console.log(materials.map((material) => material.length));
// [ 8, 6, 7, 9 ]

// 従来の無名関数
(function (a) {
  return a + 100;
});

// function を削除。引数と本体の間に矢印を配置
(a) => {
  return a + 100;
};

// 本体の中括弧を削除。return を削除。return はすでに含まれている
// 直接式を返す場合だけ中括弧を削除できる
(a) => a + 100;

// 引数の括弧を削除
a => a + 100;

// 従来の関数
(function (a, b) {
  const chuck = 42;
  return a + b + chuck;
});

// アロー関数
(a, b) => {
  const chuck = 42;
  return a + b + chuck;
};

// アロー関数は常に無名
// 従来の関数
function bob(a) {
  return a + 100;
}

// アロー関数
// 変数に代入して名前をつける
const bob2 = a => a + 100;

const func = () => { foo: 1 };
console.log(func()); // undefined

// const func2 = () => { foo: function () {} };
// console.log(func2());
// SyntaxError: Function statements require a function name

// const func3 = () => { foo() {} };
// console.log(func3());
// SyntaxError: Unexpected token '{'

// これは、 JavaScript がアロー関数を簡潔文体とみなすのは、アローに続くトークンが左中括弧でない場合のみであるため、中括弧 ({}) 内のコードは一連の文として解釈され、 foo はオブジェクトリテラルのキーではなく、ラベルとなります。
//
//オブジェクトリテラルを括弧で囲む
const func4 = () => ({ foo: 1});
console.log(func4());

