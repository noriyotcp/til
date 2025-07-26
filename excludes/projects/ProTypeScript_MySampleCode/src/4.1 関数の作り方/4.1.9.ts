// 4.1.9 オプショナル引数の宣言

const toLowerOrUpper = (str: string, upper?: boolean): string => {
  if (upper) {
    return str.toUpperCase();
  } else {
    return str.toLowerCase();
  }
}

console.log(toLowerOrUpper("Hello"));
console.log(toLowerOrUpper("Hello", false));
console.log(toLowerOrUpper("Hello", true));
console.log(toLowerOrUpper("Hello", undefined));

const toLowerOrUpper2 = (str: string, upper: boolean = false): string => {
  if (upper) {
    return str.toUpperCase();
  } else {
    return str.toLowerCase();
  }
}

console.log(toLowerOrUpper2("Hello"));
console.log(toLowerOrUpper2("Hello", false));
console.log(toLowerOrUpper2("Hello", true));
console.log(toLowerOrUpper2("Hello", undefined));

// A required parameter cannot follow an optional parameter.
// const toLowerOrUpper = (str?: string, upper: boolean): string
