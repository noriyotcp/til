// 4.2.4 引数の型注釈が省略可能な場合

// 式から型が推論される。xRepeat は (arg: number): string と判定される
const xRepeat = (arg: number): string => "x".repeat(arg);

// 逆方向の型推論。式の型を元に内部に対して推論が働く
// F の定義により num は number であると推論される
type F = (arg: number) => string;
const xRepeat2: F = (num) => "x".repeat(num);

const nums = [1, 2, 3, 4, 5 ,6, 7, 8, 9];
// filter のコールバック関数が受け取る x に型注釈はついていない
// filter のコールバック関数の型が先に判明している
const arr2 = nums.filter((x) => x % 3 === 0);
console.log(arr2);

// 
type Greetable = {
  greet: (str: string) => string;
}
// オブジェクトリテラルの中の関数式へと文脈が伝播している
// greee property は (str) => string を持つだろうと推論される
const obj: Greetable = {
  greet: (str) => `Hello, ${str}!`
};

// error TS7006: Parameter 'num' implicitly has an 'any' type.
// const f = (num) => num * 2;

