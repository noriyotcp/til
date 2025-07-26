// 4.1.6 メソッド記法で関数を作る

const obj = {
  // メソッド記法
  // プロパティ名(引数リスト): 返り値の型 { 中身 }
  double(num: number): number {
    return num * 2;
  },
  // 通常の記法 + アロー関数
  double2: (num: number): number => num * 2,
};

console.log(obj.double(100));
console.log(obj.double2(-50));
