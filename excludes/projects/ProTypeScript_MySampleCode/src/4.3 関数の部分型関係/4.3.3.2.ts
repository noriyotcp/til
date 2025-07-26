// コラム 18
// 読み取り専用プロパティの部分型について

// 普通の配列は読み取り専用配列の部分型になる
// 型T に対して、T[] は readonly T[] の部分型になる。T[] のほうができることが多い
// sum 関数は与えられた配列から読み取りのみ行う
function sum(nums: readonly number[]): number {
  let result = 0;
  for (const num of nums) {
    result += num;
  }
  return result;
}

// sum には readonly number[] 型を与えることができる
const nums1: readonly number[] = [1, 10, 100];
console.log(sum(nums1));

const nums2: number[] = [1, 1, 2, 3, 5, 8];
console.log(sum(nums2));

function fillZero(nums: number[]): void {
  for (let i = 0; i < nums.length; i++) {
    nums[i] = 0;
  }
}

// fillZero には number[] 型を与えることができる
const nums3: number[] = [1, 10, 100];
fillZero(nums3);
console.log(nums3);

// fillZero に readonly number[] 型を与えるのはエラー
const nums4: readonly number[] = [1, 1, 2, 3, 5, 8];
// error TS2345: Argument of type 'readonly number[]' is not assignable to parameter of type 'number[]'.
// The type 'readonly number[]' is 'readonly' and cannot be assigned to the mutable type 'number[]'.
// fillZero(nums4);

type User = { name: string };
type ReadOnlyUser = { readonly name: string };

// User は ReadOnlyUser の部分型
const uhyoify = (user: User) => {
  user.name = "uhyo";
}

const john: ReadOnlyUser = { name: "John Smith" };

// john.name = "Nanashi"; // error TS2540: Cannot assign to 'name' because it is a read-only property.

// readonly なのに書き換えてしまう
uhyoify(john);
console.log(john.name); // uhyo
