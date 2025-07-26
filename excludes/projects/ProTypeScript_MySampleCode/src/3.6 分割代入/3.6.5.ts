// 3.6.5 rest パターンでオブジェクトの残りを取得する

const obj = {
  foo: 123,
  bar: "string",
  baz: false,
};

const { foo, ...restObj } = obj;

console.log(foo); // 123
// restパターンは、イミュータブルな方法でオブジェクトを操作するのに活躍する
// 上の例ではrestObjは「objからプロパティfooを取り除いたオブジェクト」であると見なせる
// このオブジェクトは新しいオブジェクトであり、もともとのオブジェクトobjには影響を与えることなく作られる
console.log(restObj); // { bar: "string", baz: false }

const arr = [1, 1, 2, 3, 5, 8, 13];

const [first, second, third, ...restArr] = arr;
console.log(first); // 1
console.log(second); // 1
console.log(third); // 2
console.log(restArr); // [3, 5, 8, 13]
