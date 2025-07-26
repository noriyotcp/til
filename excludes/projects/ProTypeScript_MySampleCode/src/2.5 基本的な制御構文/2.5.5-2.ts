// 2.5.5 while文によるループ

let sum = 0;
let i = 1;

while (true) {
  if (i > 100) {
    break;
  }
  sum += i;
  i++;
}

console.log(sum);


