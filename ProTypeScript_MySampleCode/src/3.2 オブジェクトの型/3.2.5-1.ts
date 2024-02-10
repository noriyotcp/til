// 3.2.5 任意のプロパティ名を許容する型（インデックスシグネチャ）

type PriceData = {
  [key: string]: number;
}

const data: PriceData = {
  apple: 220,
  coffee: 120,
  bento: 500
};

// 新たなプロパティを使って代入することもできる
data.chicken = 250;

// - error TS2322: Type 'string' is not assignable to type 'number'.
// でも実行はできるのだな？ { apple: 220, coffee: 120, bento: 500, chicken: 250, '弁当': 'foo' }
data.弁当 = "foo";

console.log(data);

