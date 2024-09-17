// 3.1.3 オブジェクトリテラル(2)プロパティ名の種々の指定方法

const propName = "buzz";

const obj = {
  "foo": 123,
  "foo bar": -500,
  '↑↓↑↓': "",
  1: "one",
  2.05: "two point o five",
  [propName]: 456,
};

console.log(obj.foo);
console.log(obj["foo bar"]);
console.log(obj['↑↓↑↓']);
console.log(obj["1"]);
console.log(obj["2.05"]);
console.log(obj.buzz);


