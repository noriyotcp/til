// 6.1.3 インターセクション型とは

type Animal = {
  species: string;
  age: number;
};

// Human は Animal の部分型
type Human = Animal & {
  name: string;
};

const tama: Animal = {
  species: "Felis silverstris catus",
  age: 3
};

const uhyo: Human = {
  species: "Homo sapiens sapiens",
  age: 26,
  name: "uhyo"
};

// 異なるプリミティブ型同士のインターセクション型を作った場合は never 型
type StringAndNumber = string & number;

// オブジェクト型にプリミティブ値が当てはまることがあるので「オブジェクト ＆ プリミティブ」でも即座に never にはならない
// Type 'string' is not assignable to type 'Animal & string'.
// Type 'string' is not assignable to type 'Animal'.
// const cat1: Animal & string = "cat";

// Type '{ species: string; age: number; }' is not assignable to type 'Animal & string'.
  // Type '{ species: string; age: number; }' is not assignable to type 'string'.
// const cat2: Animal & string = {
//   species: "Felis sivestris catus",
//   age: 3
// }
