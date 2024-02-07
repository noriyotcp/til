// インクリメント、デクリメント演算子
// 使用された時点で変数の値が書き変わるという副作用がある
let foo = 10;
foo++;
console.log(foo); // 11
--foo;
console.log(foo); // 10

// これらは式文である。返り値が存在する
foo = 10;
console.log(++foo); // 変更後の 11
console.log(foo--); // 変更前の 11

