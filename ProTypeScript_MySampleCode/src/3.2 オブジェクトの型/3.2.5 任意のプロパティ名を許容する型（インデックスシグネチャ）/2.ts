// 任意のプロパティがあるオブジェクト型（インデックスシグネチャ）
// どんなプロパティにアクセスしても number 型を持つ
type MyObj = { [key: string]: number };
const obj: MyObj = { foo: 123 };

// しかし、プロパティにアクセスすると undefined が返る。number 型ではない
// obj が持っているプロパティは foo のみなので、bar にアクセスすると undefined が返る
// 存在しないプロパティにアクセスするのはそもそもコンパイルエラーになるはずだが、それを可能にしてしまうのがインデックスシグネチャ
const num: number = obj.bar;
console.log(num); // undefined
