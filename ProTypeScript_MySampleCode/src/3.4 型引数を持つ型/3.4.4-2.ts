// 3.4.4 オプショナルな型引数

type Animal = {
  name: string;
}

// Child のみオプショナル。デフォルトは Animal
// type Family<Parent, Child = Animal> = {
//   mother: Parent;
//   father: Parent;
//   child: Child;
// }

type HasName = {
  name: string;
};

// Parent は HasName の部分型である必要がある
// Child は HasName の部分型である必要があり、デフォルトは Animal
// つまり、Animal も HasName の部分型である必要がある、ということ？
type Family<Parent extends HasName, Child extends HasName = Animal> = {
  mother: Parent;
  father: Parent;
  child: Child;
};
