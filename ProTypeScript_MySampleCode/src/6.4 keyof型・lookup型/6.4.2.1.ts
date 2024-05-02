const mmConversionTable = {
  mm: 1,
  cm: 10, // 追加
  m: 1e3,
  km: 1e6,
};

// typeof mmConversionTable の型は { mm: number, m: number, km: number } となる
// keyof typeof mmConversionTable は "mm" | "m" | "km" となる
// このことにより、unit には "mm" | "m" | "km" のいずれかが入ることが保証される
function convertUnits(value: number, unit: keyof typeof mmConversionTable) {
  // 一旦 mm に直す
  // unit の型を string にするとエラーになる
  // error TS7053: Element implicitly has an 'any' type because expression of type 'string' can't be used to index type '{ mm: number; m: number; km: number; }'.
  // No index signature with a parameter of type 'string' was found on type '{ mm: number; m: number; km: number; }'.
  // mmConversionTable[unit] へのプロパティアクセスが可能な名前のみに制限される
  const mmValue = value * mmConversionTable[unit];
  // 再変換して返す
  return {
    mm: mmValue,
    cm: mmValue / 10, // 追加
    m: mmValue / 1e3,
    km: mmValue / 1e6
  };
};

// 5600m をそれぞれの単位に直して表示
console.log(convertUnits(5600, "m"));
// error TS2345: Argument of type '"kg"' is not assignable to parameter of type '"mm" | "m" | "km"'.
// console.log(convertUnits(5600, "kg"));

// { mm: 300000, m: 300, km: 0.3 }
console.log(convertUnits(30000, "cm"));

// cm も返すように変更した後だと、以下のようになる
// { mm: 5600000, cm: 560000, m: 5600, km: 5.6 }
// { mm: 300000, cm: 30000, m: 300, km: 0.3 }
