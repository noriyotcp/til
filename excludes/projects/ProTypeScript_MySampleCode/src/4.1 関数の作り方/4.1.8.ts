// 4.1.8 関数呼び出しにおけるスプレッド構文

const sum = (...args: number[]): number => {
  let result = 0;
  for (const num of args) {
    result += num;
  }
  return result;
};

const nums = [1, 2, 3, 4, 5];
console.log(sum(...nums));

const sum3 = (a: number, b: number, c: number) => a + b + c;
// number[] である nums の要素は3つとは限らない
// 一見3つに見えるが number[] にその情報は載っていない

// const nums3 = [1, 2, 3]

// sum3(...nums3) の型チェックでは nums3 は要素数不明の何らかの配列という扱いになる
// A spread argument must either have a tuple type or be passed to a rest parameter.

const nums3: [number, number, number] = [1, 2, 3];
console.log(sum3(...nums3));

