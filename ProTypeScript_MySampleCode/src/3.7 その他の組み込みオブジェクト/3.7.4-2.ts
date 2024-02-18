// 3.7.4 Map オブジェクト・Set オブジェクト

const wm1 = new WeakMap(),
  wm2 = new WeakMap(),
  wm3 = new WeakMap();
const o1 = {},
  o2 = function () {},
  o3 = globalThis;

wm1.set(o1, 37);
wm1.set(o2, "azerty");
wm2.set(o1, o2); // 値はオブジェクトでも関数でも構いません
wm2.set(o3, undefined);
wm2.set(wm1, wm2); // WeakMap もキーにできます
console.log(wm1.get(o2)); // azerty
console.log(wm2.get(o2)); // undefined
console.log(wm2.get(o3)); // undefined
console.log(wm2.get(o1)); // [Function: o2]
console.log(wm2.get(wm1)); // WeakMap { <items unknown> }
// wm2 のキーは o1, o3, wm1
console.log(wm2.get(wm2)); // undefined

console.log(wm1.has(o2)); // true
console.log(wm2.has(o2)); // false
console.log(wm2.has(o3)); // 値が関連づけられているならば、undefined であっても true

console.log(wm3.set(o1, 37));
console.log(wm3.get(o1)); // 37

console.log(wm1.has(o1)); // true
wm1.delete(o1);
console.log(wm1.has(o1)); // false
