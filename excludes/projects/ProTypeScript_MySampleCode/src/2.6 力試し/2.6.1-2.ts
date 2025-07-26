// 2.6.1 FizzBuzzを書いてみよう

// FizzBuzzを書いてみよう
let message = "";
let i = 1;

while (i <= 100) {
  if (i > 1) {
    message += ` `;
  }
  if (i % 3 === 0 && i % 5 === 0) {
    message += `FizzBuzz`;
  } else if (i % 3 === 0) {
    message += `Fizz`;
  } else if (i % 5 === 0) {
    message += `Buzz`;
  } else {
    message += String(i);
  }

  i++;
}

console.log(message);

