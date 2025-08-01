// 6.1.1 ユニオン型の基本

type Animal = {
  species: string;
};

type Human = {
  name: string;
};

type User = Animal | Human;

// このオブジェクトは Animal 型なので User 型に代入可能
const tama: User = {
  species: "Felis silverstris catus"
};

// このオブジェクトは Human 型なので User 型に代入可能
const uhyo: User = {
  name: "uhyo"
};

// error TS2353: Object literal may only specify known properties, and 'title' does not exist in type 'User'.
// const book: User = {
//   title: "Software Design"
// };

// error TS2339: Property 'name' does not exist on type 'User'.
//   Property 'name' does not exist on type 'Animal'.
// そのままでは Animal か Human か判別できない
// function getName(user: User): string {
//   return user.name;
// }

