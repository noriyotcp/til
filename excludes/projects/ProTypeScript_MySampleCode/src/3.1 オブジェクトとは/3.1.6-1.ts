// 3.1.6 オブジェクトはいつ同じなのか

const foo = { num: 1234 };
const bar = foo; // 同じオブジェクトを指している
console.log(bar.num); // 1234
bar.num = 0;
// 同じオブジェクトを指しているので bar.num の値を変更すると foo.num も変更される
console.log(foo.num); // 0


