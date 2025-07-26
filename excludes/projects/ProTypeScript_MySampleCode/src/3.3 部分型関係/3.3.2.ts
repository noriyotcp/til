// 3.3.2 プロパティの包含関係による部分型関係の発生
// 1.Tが持つプロパティはすべてSにも存在する。
// 2.条件1の各プロパティについて、Sにおけるそのプロパティの型はTにおけるプロパティの型の部分型（または同じ型）である。

// T
type Animal = {
  age: number;
};

// S
type Human = {
  age: number; // Animal にもある。同じ型
  name: string;
};

type AnimalFamily = {
  familyName: string;
  mother: Animal;
  father: Animal;
  child: Animal;
};

// AnimalFamily の部分型
type HumanFamily = {
  familyName: string; // Animal にもある。同じ型
  mother: Human; // Human は Animal の部分型
  father: Human;
  child: Human;
};
