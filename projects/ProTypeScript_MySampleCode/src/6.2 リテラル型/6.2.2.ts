// 6.2.2 テンプレートリテラル型

// `Hello, ${文字列}!` の形をとる
function getHelloStr(): `Hello, ${string}!` {
  const rand = Math.random();
  if (rand < 0.3) {
    return "Hello, world!";
  } else if (rand < 0.6) {
    return "Hello, my world!";
  } else if (rand < 0.9) {
    // error TS2322: Type '"Hello, world"' is not assignable to type '`Hello, ${string}!`'.
    // return "Hello, world";
    return "Hello, world!";
  } else {
    // error TS2322: Type '"Hell, world!"' is not assignable to type '`Hello, ${string}!`'.
    // return "Hell, world!";
    return "Hello, world!";
  }
}

// 返り値の型が型推論され、`user:${T}` 型となる
function makeKey<T extends string>(userName: T) {
  return `user:${userName}` as const;
}

// この返り値は "user:uhyo" となる
const uhyoKey: "user:uhyo" = makeKey("uhyo");

function fromKey<T extends string>(key: `user:${T}`): T {
  // key の5文字目以降を取り出すとその型は string となってしまう
  // なので T であると認識させるために as が必要になる
  return key.slice(5) as T;
}

// T が "uhyo" であるという型推論が行われる
const user = fromKey("user:uhyo");
