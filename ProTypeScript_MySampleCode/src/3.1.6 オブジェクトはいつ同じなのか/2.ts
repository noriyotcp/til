const foo = { num: 1234 };
const bar = { ...foo }; // { num: 1234 }
console.log(bar.num); // 1234
bar.num = 0;
// 違うオブジェクトを指しているので bar.num の値が変更されても foo.num は変更されない
console.log(foo.num); // 1234

