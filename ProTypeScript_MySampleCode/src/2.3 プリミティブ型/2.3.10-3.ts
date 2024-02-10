// 2.3.10 プリミティブ型同士の変換(2)明示的な変換を行う

// 真偽値への型変換の例
console.log(Boolean(123)) // true
console.log(Boolean(0)) // false
console.log(Boolean(1n)) // true
console.log(Boolean(0n)) // false
console.log(Boolean("")) // false
console.log(Boolean("foobar")) // true
console.log(Boolean(null)) // false
console.log(Boolean(undefined)) // false

