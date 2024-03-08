// 4.3.2 引数の型による部分型関係

type HasName = {
  name: string;
}

// HasName の部分型
type HasNameAndAge = {
  name: string;
  age: number;
}

const showName = (obj: HasName) => {
  console.log(obj.name);
};

// HasName の部分型である HasNameAndAge を引数にとる関数
// (obj: HasName) => void は (obj: HasNameAndAge) => void として扱うことができる
const g: (obj: HasNameAndAge) => void = showName;

g({
  name: "uhyo",
  age: 26,
});

