// 4.2.5 コールシグネチャによる関数型の表現

// object type として定義されているがプロパティの定義とコールシグネチャが同居している
type MyFunc = {
  isUsed?: boolean;
  (arg: number): void;
}

// isUsed は optional なのでそれを持っていないただの関数を MyFunc 型の値として認めてもらうことができる
const double: MyFunc = (arg: number) => {
  console.log(arg * 2);
}

double.isUsed = true;
console.log(double.isUsed);

double(1000);

// F, G は同じ意味
type F = (arg: string) => number;
// 関数型をコールシグネチャで表す
type G = { (arg: string): number; };
