// 3.7.4 Map オブジェクト・Set オブジェクト

// Map<K, V> は、キーと値のペアを保持するコレクションです
const map: Map<string, number> = new Map();
map.set("foo", 1234);

console.log(map.get("foo")); // 1234
map.set("foo", 5678);
console.log(map.get("foo")); // 5678
console.log(map.get("bar")); // undefined
console.log(map.has("foo")); // true
console.log(map.has("bar")); // false

console.log(map.keys()); // MapIterator { 'foo' }
console.log(map.values()); // MapIterator { 5678 }
console.log(map.entries()); // MapIterator { [ 'foo', 5678 ] }

console.log(map.set("bar", 1234)); // Map(2) { 'foo' => 5678, 'bar' => 1234 }
console.log(map.delete("foo")); // true
console.log(map); // Map(1) { 'bar' => 1234 }
map.clear();
console.log(map); // Map(0) {}
