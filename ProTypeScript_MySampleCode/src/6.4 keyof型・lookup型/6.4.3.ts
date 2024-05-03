// 6.4.3 keyof 型・lookup 型とジェネリクス

function get<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
};

type Human = {
  name: string;
  age: number;
}

const uhyo: Human = {
  name: "uhyo",
  age: 26,
};

// uhyoName は string 型
const uhyoName = get(uhyo, "name");
// uhyoAge は number 型
const uhyoAge = get(uhyo, "age");

// error TS2345: Argument of type '"gender"' is not assignable to parameter of type 'keyof Human'.
// const uhyoGender = get(uhyo, "gender");

console.log(uhyoName);
console.log(uhyoAge);
