// !!式 !(!式)
const input1 = "123", input2 = "";

const input1isNotEmpty = !!input1;
console.log(input1isNotEmpty);

// 空文字なのでfalse
const input2isNotEmpty = !!input2;
console.log(input2isNotEmpty);

// "bar" が出力される。"foo" は true なので && の右側の値が返される
console.log("foo" && "bar");
// 0 が出力される。0 は false なので && の左側の値が返される
console.log(0 && 123);

// "foo" が出力される。"foo" は true なので || の左側の値が返される
console.log("foo" || "bar");
// 123 が出力される。123 は true なので || の左側の値が返される
console.log(0 || 123);
