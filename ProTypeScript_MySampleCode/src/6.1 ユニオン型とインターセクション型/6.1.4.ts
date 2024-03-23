// 6.1.4 ユニオン型とインターセクション型の表裏一体な関係

type Human = { name: string };
type Animal = { species: string };

function getName(human: Human) {
  return human.name
}

function getSpecies(animal: Animal) {
  return animal.species;
}

// getName か getSpecies を受け取るかわからない
const mysteryFunc = Math.random() < 0.5 ? getName : getSpecies;

// const uhyo: Human = {
//   name: "uhyo"
// };

// Argument of type 'Human' is not assignable to parameter of type 'Human & Animal'.
  // Property 'species' is missing in type 'Human' but required in type 'Animal'.
// uhyo は Human 型だけど Animal 型のプロパティがない
// mysteryFunc(uhyo);

// 関数同士のユニオン型を作り、それを関数として呼び出す場合
// 引数の型としてインターセクション型が現れる
const uhyo: Human & Animal = {
  name: "uhyo",
  species: "Homo sapiens sapiens"
};

// const mysteryFunc: (arg0: Human & Animal) => string
// 関数同士のユニオン型が再解釈され1つの関数型に合成された
const value = mysteryFunc(uhyo);
console.log(value);
