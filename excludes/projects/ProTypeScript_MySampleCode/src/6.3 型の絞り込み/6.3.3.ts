// 6.3.3 代数的データ型をユニオン型で実現するテクニック

type Animal = {
  tag: "animal";
  species: string;
}

type Human = {
  tag: "human";
  name: string;
}

type User = Animal | Human;

function getUserName(user: User) {
  if (user.tag === "human") {
    return user.name;
  } else {
    return "名無し";
  }
}

const tama: User = {
  tag: "animal",
  species: "Felis sivestris catus",
};

const uhyo: User = {
  tag: "human",
  name: "uhyo",
};

// error TS1002: Unterminated string literal.
// const alien: User = {
//   tag: "alien",
//   name: 'gray",
// };

console.log(getUserName(tama));
console.log(getUserName(uhyo));

