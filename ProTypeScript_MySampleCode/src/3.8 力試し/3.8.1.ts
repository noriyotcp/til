import assert from "assert";

type User = {
  name: string;
  age: number;
  premiumUser: boolean;
}

// 最後はプレミアムユーザー 1 -> プレミアムユーザー 0 -> プレミアムユーザーではない
const data: string = `
uhyo,26,1
John Smith,17,0
Mary Sue,14,1
`;

// ここにコードを足す
const users: User[] = data.trim().split("\n").map((line) => {
  const [name, ageString, premiumUserString] = line.split(",");
  const age = parseInt(ageString, 10);
  const premiumUser = premiumUserString === "1";
  return { name, age, premiumUser };
};

assert(users[0].name === "uhyo");
assert(users[0].age === 26);
assert(users[0].premiumUser === true);

for (const user of users) {
  if (user.premiumUser) {
    console.log(`${user.name}(${user.age}) はプレミアムユーザーです。`);
  } else {
    console.log(`${user.name}(${user.age}) はプレミアムユーザーではありません。`);
  }
}
