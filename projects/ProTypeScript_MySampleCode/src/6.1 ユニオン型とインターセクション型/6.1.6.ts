// 6.1.6 オプショナルチェイニングによるプロパティアクセス

type Human = {
  name: string;
  age: number;
};


function useMaybeHuman(human: Human | undefined) {
  // Optional chaining でプロパティアクセス
  return human?.["age"];
  // return human?.age;
}

console.log(useMaybeHuman(undefined)); // undefined

type GetTimeFunc = () => Date;

function useTime(getTimeFunc: GetTimeFunc | undefined) {
  // const timeOrUndefined: Date | undefined
  // 関数呼び出しでオプショナルチェイニングを使う
  // getTimeFunc が null or undefined でない時に getTimeFunc() を呼び出す
  // 一見 getTimeFunc() が undefined なら toString() を呼び出せないように見えるが
  // ?. はそれ以降のプロパティアクセス・関数呼び出し・メソッド呼び出しをまとめて飛ばす
  // Ruby の safe guard navigation とは違うんだな
  const timeOrUndefined = getTimeFunc?.().toString();
  return timeOrUndefined;
}

type User = {
  isAdult(): boolean;
}

function checkForAdultUser(user: User | null) {
  if (user?.isAdult()) {
    // showSpecialContents(user);
  }
}
