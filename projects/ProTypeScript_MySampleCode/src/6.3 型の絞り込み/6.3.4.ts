// 6.3.4 switch 文でも型を絞り込める

type Animal = {
  tag: "animal";
  species: string;
}

type Human = {
  tag: "human";
  name: string;
}

type Robot = {
  tag: "robot";
  name: string;
}

type User = Animal | Human | Robot;

function getUserName1(user: User): string {
  if (user.tag === "human") {
    return user.name
  } else {
    return "名無し";
  }
}

// error TS2366: Function lacks ending return statement and return type does not include 'undefined'
// user.tag が robot である可能性があるのにその場合に関数が return しないことを検知してエラーになっている
// function getUserName2(user: User): string {
//   switch (user.tag) {
//     case "human":
//       return user.name
//     case "animal":
//       return "名無し";
//   }
// }

function getUserName2(user: User): string {
  switch (user.tag) {
    case "human":
      return user.name
    case "animal":
      return "名無し";
    case "robot":
      return `CPU ${user.name}`;
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

const akita: Robot = {
  tag: "robot",
  name: "akita",
}

// error TS1002: Unterminated string literal.
// const alien: User = {
//   tag: "alien",
//   name: 'gray",
// };

console.log(getUserName2(tama));
console.log(getUserName2(uhyo));
console.log(getUserName2(akita));
