// 4.6.1 簡単な関数を書いてみよう

for (let i = 1; i <= 100; i++) {
  const message = getFizzBuzzString(i);
  console.log(message);
}

function getFizzBuzzString(i: number): string {
  if (i % 3 === 0 && i % 5 === 0) {
    return "FizzBuzz";
  } else if (i % 3 === 0) {
    return "Fizz";
  } else if (i % 5 === 0) {
    return "Buzz";
  } else {
    return String(i);
  }
}
