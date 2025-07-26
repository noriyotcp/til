// 4.4.1 関数の型引数とは

function repeat<T>(element: T, length: number): T[] {
  const result: T[] = [];
  for (let i = 0; i < length; i++) {
    result.push(element);
  }
  return result;
}

console.log(repeat<string>("a", 5));
console.log(repeat<number>(123, 3));

