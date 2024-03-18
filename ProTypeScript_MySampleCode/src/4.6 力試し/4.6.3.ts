// 4.6.3 コールバックの練習

function map(array: number[], callback: (x: number) => number): number[] {
  const result: number[] = [];

  for (const i of array) {
    result.push(callback(i));
  }

  return result;
}

const data = [1, 1, 2, 3, 5, 8, 13];

const result = map(data, (x) => x * 10);
console.log(result);

