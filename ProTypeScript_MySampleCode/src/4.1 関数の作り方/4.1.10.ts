// 4.1.10 コールバック関数を使ってみる
// コールバック関数を引数として受け取るような関数は高階関数 (higher-order function) と呼ばれる

type User = { name: string; age: number };
const getName = (u: User): string => u.name;
const users: User[] = [
  { name: "uhyo", age: 26 },
  { name: "John Smith", age: 15 }
];

let names = users.map(getName);
console.log(names);

const getNameWithLog = (u: User): string => {
  console.log("u is", u);
  return u.name;
};

names = users.map(getNameWithLog);
console.log(names);

names = users.map((u: User): string => u.name);
console.log(names);

const adultUsers = users.filter((user: User) => user.age >= 20);
console.log(adultUsers);

const allAdult = users.every((user: User) => user.age >= 20);
console.log(allAdult);

const seniorExists = users.some((user: User) => user.age >= 60);
console.log(seniorExists);

const john = users.find((user: User) => user.name.startsWith("John"));
console.log(john);
