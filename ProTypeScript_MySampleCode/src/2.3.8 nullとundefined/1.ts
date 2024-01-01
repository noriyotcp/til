// undefinedを中心とするのを推奨しています。その理由は、TypeScriptの言語仕様上ではundefinedのほうがサポートが厚い

const val1: null = null;
const val2: undefined = undefined;

console.log(val1, val2);
