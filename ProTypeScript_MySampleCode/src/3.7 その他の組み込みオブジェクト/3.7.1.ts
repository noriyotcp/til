// 3.7.1 Date オブジェクト

// const d = new Date();
// 9時間オフセットを持つ日付を作成する
const d = new Date("2020-02-03T15:00:00+09:00");
console.log(d);

const date = new Date("2020-02-03T15:00:00+09:00");
const timeNum = date.getTime();
console.log(timeNum); // 1580709600000

const date2 = new Date(timeNum);
console.log(date2); // 2020-02-03T06:00:00.000Z

// 現在時刻を数値表現で得るメソッド
console.log(Date.now());
