// 3.5.4 readonly 配列型

const arr: readonly number[] = [1, 10, 100];

// Index signature in type 'readonly number[]' only permits reading.
// 配列の要素も readonly になる
// arr[1] = -500;
