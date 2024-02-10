// 3.4.3 部分型関係による型引数の制約

type HasName = {
  name: string;
};

type Family<Parent extends HasName, Child extends HasName> = {
  mother: Parent;
  father: Parent;
  child: Child;
};

// Type 'number' does not satisfy the constraint 'HasName'.
// type T = Family<number, string>;

type Animal = {
  name: string;
};

type Human = {
  name: string;
  age: number;
};

// Human, Animal は HasName を満たしているのでエラーにならない
type T = Family<Human, Animal>;
