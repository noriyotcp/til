// 3.2.5 任意のプロパティ名を許容する型（インデックスシグネチャ）

const propName: string = "foo";
// obj は { [x: string]: number; } 型
const obj = {
    [propName]: 123
};
// obj は foo というプロパティだけを持っているので「任意のプロパティ名が number 型」を持つ、ということにはなっていない
// propName をリテラル型やそのユニオン型にすれば、このような危険性はない
console.log(obj.foo); // 123

