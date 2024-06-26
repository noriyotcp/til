// コラム29 ! を用いて null と undefined を無視する

type Human = {
  name: string;
  age: number;
}

function getOneUserName(user1?: Human, user2?: Human): string | undefined {
  if (user1 === undefined && user2 === undefined) {
    return undefined;
  }
  if (user1 !== undefined) {
    return user1.name;
  }

  // 'user2' is possibly 'undefined'.
  // user2 がある場合に限られているはずだが、TypeScript はそれを理解していない
  // user2 の型は Human | undefined
  // return user2.name;
}

function showOneUserName(user1?: Human, user2?: Human): string | undefined {
  if (user1 === undefined && user2 === undefined) {
    return undefined;
  }
  if (user1 !== undefined) {
    return user1.name;
  }

  // ! をつける
  return user2!.name;

  // as で大体可能
  return (user2 as Human).name;
}

console.log(showOneUserName({ name: "Taro", age: 25 }));
console.log(showOneUserName(undefined, undefined));
console.log(showOneUserName(undefined, { name: "Jiro", age: 30 }));

function showOneUserName2(user1?: Human, user2?: Human): string | undefined {
  return user1?.name ?? user2?.name;
}

console.log(showOneUserName({ name: "Taro", age: 25 }));
console.log(showOneUserName(undefined, { name: "Jiro", age: 30 }));
console.log(showOneUserName(undefined, undefined));
