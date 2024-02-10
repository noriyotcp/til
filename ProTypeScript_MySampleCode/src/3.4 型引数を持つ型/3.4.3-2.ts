// 3.4.3 部分型関係による型引数の制約

type HasName = {
  name: string;
};

// Parent は HasName の部分型である必要がある
// Child はさらに Parent の部分型である必要がある
type Family<Parent extends HasName, Child extends Parent> = {
  mother: Parent;
  father: Parent;
  child: Child;
};

type Animal = {
  name: string;
};

type Human = {
  name: string;
  age: number;
};

// Aminal は HasName の部分型である
// Human はさらに Aminal の部分型である
// つまり Human は HasName の部分型である。name: string を持っていなければならない
type S = Family<Animal, Human>;

// Type 'Animal' does not satisfy the constraint 'Human'.
// Property 'age' is missing in type 'Animal' but required in type 'Human'.
// Aminal は Human の部分型でないといけない。age: number を持っていなければならない
// type T = Family<Human, Animal>;
