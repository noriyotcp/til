// 6.4.1 lookup 型とは

type Human = {
  type: "human";
  name: string;
  age: bigint; // ここを bigint に変更する
};

// age の型が自動的に bigint になる
function setAge(human: Human, age: Human["age"]) {
  return {
    ...human,
    age
  };
}

const uhyo: Human = {
  type: "human",
  name: "uhyo",
  age: 26n, // BigInt リテラルに変更する
};

// 第2引数も変更する
const uhyo2 = setAge(uhyo, 27n);
console.log(uhyo2);

