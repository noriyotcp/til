// 2.4.6 論理演算子(2)一般形と短絡評価

// 環境変数 SECRET を取得。ただし存在しない場合は "default" を用いる
// SECRET が空文字の場合は "" となる
// ??演算子は左辺が null または undefined の場合に右辺を返す
const secret = process.env.SECRET ?? "default";
console.log(`secret: ${secret}`);

