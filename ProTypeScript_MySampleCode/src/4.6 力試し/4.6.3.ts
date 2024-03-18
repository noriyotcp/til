// 4.6.3 コールバックの練習

function map<T, U>(array: T[], callback: (x: T) => U): U[] {
  const result: U[] = [];

  for (const i of array) {
    result.push(callback(i));
  }

  return result;
}

const data = [1, 1, 2, 3, 5, 8, 13];

const result = map(data, (x) => x * 10);
console.log(result);

const data2 = [1, -3, -2, 8, 0, -1];

const result2: boolean[] = map(data2, (x) => x >= 0);
console.log(result2);
