// コラム 17
// メソッド記法と部分型関係

type HasName = { name: string };
type HasNameAndAge = { name: string; age: number };
type Obj = {
  func: (arg: HasName) => string;
  method(arg: HasName): string;
}

const something: Obj = {
  func: user => user.name,
  method: user => user.name,
}

const getAge = (user: HasNameAndAge) => String(user.age);

// error TS2322: Type '(user: HasNameAndAge) => string' is not assignable to type '(arg: HasName) => string'.
//   Types of parameters 'user' and 'arg' are incompatible.
//     Property 'age' is missing in type 'HasName' but required in type 'HasNameAndAge'.
// something.func = getAge;

// method 記法だと代入できてしまう
something.method = getAge;

