// 6.5.1 型アサーションを用いて式の型をごまかす

function getFirstFiveLetters(strOrNum: string | number) {
  const str = strOrNum as string;
  return str.slice(0, 5);
}

console.log(getFirstFiveLetters("uhyohyohyo"));
// TypeError: str.slice is not a function
// console.log(getFirstFiveLetters(123));

type Animal = {
  tag: "animal";
  species: string;
}

type Human = {
  tag: "human";
  name: string;
}

type User = Animal | Human;

function getNamesIfAllHuman(users: readonly User[]): string[] | undefined {
  if (users.every(user => user.tag === "human")) {
    // ここでは users が Human[] であるはず。しかし、TypeScript はそれを理解していない
    // as によって強制的に型を Human[] としている
    return (users as Human[]).map(user => user.name);
  }

  return undefined;
}
