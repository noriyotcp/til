// 4.1.2 返り値がない関数を作る

function helloWorldNTimes(n: number): void {
  for (let i = 0; i < n; i++) {
    console.log("Hello, world!");
  }
}

helloWorldNTimes(5);

function helloWorldNTimes2(n: number): void {
  if (n >= 100) {
    console.log(`${n}回なんて無理です！！！`);
    return;
  }
  for (let i = 0; i < n; i++) {
    console.log("hello, world!");
  }
}

console.log(`-------------`);
helloWorldNTimes2(5);
helloWorldNTimes2(150);

