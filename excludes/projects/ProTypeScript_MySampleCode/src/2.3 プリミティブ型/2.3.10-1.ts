// 2.3.10 プリミティブ型同士の変換(2)明示的な変換を行う

// なお、数値への変換を扱う際にはNaNに注意しなければいけません。NaNは数値型の特殊な値であり、数値が必要な場面で数値が得られなかった場合に出現します。文字列から数値への変換において、数値として解釈できないような文字列が与えられた場合というのもそのひとつです。たとえば今回のプログラムにfoobarという文字列を入力した場合はNumber(line)の結果（返り値）がNaNになります。また、数値計算においてNaNが絡む計算の結果はNaNになるので、NaN + 1000はNaNです。よって、console.logで表示されるのはNaNとなります。実際のプログラムでは、NaNが得られた場合にどうするかということも考えなければいけないでしょう。

import { createInterface } from 'readline';

const rl = createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question('数値を入力してください:', (line) => {
  const num = Number(line);
  console.log(num + 1000);
  rl.close();
});

