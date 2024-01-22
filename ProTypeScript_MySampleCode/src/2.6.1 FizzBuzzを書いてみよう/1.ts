// FizzBuzzを書いてみよう
let message = [];
let i = 1;

while (i <= 100) {
  if (i % 3 === 0 && i % 5 === 0) {
    message.push(`FizzBuzz`);
  } else if (i % 3 === 0) {
    message.push(`Fizz`);
  } else if (i % 5 === 0) {
    message.push(`Buzz`);
  } else {
    message.push(i);
  }

  i++;
}

console.log(message.join(` `));
