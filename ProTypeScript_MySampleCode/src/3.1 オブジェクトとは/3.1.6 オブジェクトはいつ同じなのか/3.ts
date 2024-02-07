const foo = { obj: { num: 1234 } };
const bar = { ...foo }; // foo はコピーされても foo.obj は同じオブジェクトを指している
bar.obj.num = 0;
// 同じオブジェクトを指しているので bar.obj.num の値が変更されれば foo.obj.num も変更される
console.log(foo.obj.num); // 0

