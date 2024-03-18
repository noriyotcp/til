// 4.6.3 コールバックの練習

function map<T>(array: T[], callback: (x: T) => T): T[] {
  const result: T[] = [];

  for (const i of array) {
    result.push(callback(i));
  }

  return result;
}

const data = [1, 1, 2, 3, 5, 8, 13];

const result = map(data, (x) => x * 10);
console.log(result);
