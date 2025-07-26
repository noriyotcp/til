// 4.2.1 関数型の記法
// 関数の型を書くときは引数の名前を意識して書くと、エディタの支援が受けられる
type F = (repeatNum: number) => string;
// 型が同じなら引数名が違っていても同じとみなされる
const xRepeat: F = (num: number): string => "x".repeat(num);
console.log(xRepeat(2));

type F2 = (arg: string, arg2: string) => boolean;
// error TS2322: Type '(num: number) => void' is not assignable to type 'F2'.
//   Types of parameters 'num' and 'arg' are incompatible.
//       Type 'string' is not assignable to type 'number'.
// const fun: F2 = (num: number): void => console.log(num);
