// 3.4.4 オプショナルな型引数

type Animal = {
  name: string;
}

type Family<Parent = Animal, Child = Animal> = {
  mother: Parent;
  father: Parent;
  child: Child;
}

// 通常通りの使い方
type S = Family<string, string>;

// T は Family<Animal, Animal> と同じ
type T = Family;

// U は Family<string, Animal> と同じ
// つまり Child にはデフォルトで Animal が入る
type U = Family<string>;
// 今の所、左側を省略し、右側だけを指定するということはできない
