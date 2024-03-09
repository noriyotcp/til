// 4.4.3 関数の型引数は省略できる

function repeat<T>(element: T, length: number): T[] {
  const result: T[] = [];
  for (let i = 0; i < length; i++) {
    result.push(element);
  }
  return result;
};

// result は string[] 型となる
console.log(repeat("a", 5));
