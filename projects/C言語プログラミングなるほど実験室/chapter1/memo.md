# 第1章 2進数に関する実験
## 1-1 10進数を2進数に変換する
コンパイルはとりあえず VS Code でやっている

### 1.1.2 10で割った余りを求める

結果だけを記す。10で割った余りが順に下位桁から求められる。2進数も同様。

```sh
 ❯ ./decDiv10
Enter a decimal number: 456
456 / 10 = 45, remainder = 6
45 / 10 = 4, remainder = 5
4 / 10 = 0, remainder = 4
```

## 1-2 2進数を10進数に変換する
桁の重みと桁の数値をかけて集計する

（図も載っているのでスクショ撮っておくといいかもなあ）

10進数の例：  
456 = 4 * 10^2 + 5 * 10^1 + 6 * 10^0

2進数の例：
1011 = 1 * 2^3 + 0 * 2^2 + 1 * 2^1 + 1 * 2^0 =  8 + 0 + 2 + 1 = 11

### 1.2.1 2進数を10進数に変換するプログラム [binToDec.c]

```c
#include <stdio.h>
#include <string.h>

int main() {
    char binary[32];
    int weight; // 2進数の桁の重み
    int pos; // binary[] の桁の位置
    int val; // binary[] の桁の位置の値
    int sum; // 集計された値（変換後の10進数）

    printf("Enter a binary number: ");
    fgets(binary, sizeof(binary), stdin);

    // fgets() で読み込んだ改行文字を削除
    binary[strcspn(binary, "\n")] = '\0';

    // 2進数を10進数に変換
    sum = 0;
    weight = 1;
    for (pos = strlen(binary) - 1; pos >= 0; pos--) {
        val = binary[pos] - '0'; // 文字を数値に変換
        printf("桁の重み: %d x 桁の数値%d = %d\n", weight, val, weight * val);
        sum += weight * val;
        weight *= 2; // 次の桁の重み。2をかける
    }

    printf("変換後の10進数: %d\n", sum);

    return 0;
}
```

当初 `gets()` を使っていたが、`gets()` は非推奨のため `fgets()` に変更したら期待しない結果になってしまった。  
以下が AI による解説。

### 解説
はい、`fgets()` の使い方に少し問題があります。`fgets()` は改行文字 (`\n`) も読み込んでしまうため、それが原因で期待と異なる結果になっています。

`fgets()` で読み込んだ文字列から改行文字を削除するために、`strcspn(binary, "\n")` を使用して改行文字の位置を特定し、その位置にヌル文字 (`\0`) を代入しています。これにより、文字列の末尾が正しく処理されるようになります。

例えば、`10110101` と入力した場合、`binary` 配列には `10110101\n` が格納されます。この状態で `strlen(binary)` を実行すると、改行文字を含めた長さが返されるため、ループの開始位置がずれてしまいます。また、`binary[pos] - '0'` の計算時に、改行文字が数値に変換されようとして、予期しない値（例：-38）になってしまいます。

`strcspn(binary, "\n")` は、`binary` 文字列の中で、`\n` が最初に現れる位置を返します。その位置に `\0` を代入することで、改行文字を削除し、文字列の終端を正しく設定できます。

---

:memo: assembly に変換するのは１通りやってからでも良さそう

`.gitignore` 一旦全部無視して、C言語ファイルとマークダウンファイルだけは無視しないよってやる  
実行可能ファイルとか `*.dSYM` などは無視したい

```
*
!*.c
!*.md
```

---

## 1-3 符号ありデータと符号なしデータ

### 1.3.1

| Data Type        | Description                | Range         |
|------------------|----------------------------|---------------|
| signed char      | 符号あり8ビット整数型       | -128 ～ 127   |
| unsigned char    | 符号なし8ビット整数型       | 0 ～ 255      |

### 1.3.2
最上位桁がゼロならプラス、1ならマイナス -> 符号ビット

### 1.5.2

大きなデータ型から小さなデータ型への変換

```sh
❯ ./1-5-2-bigToSmall
long = 12345678
short = 5678 # 下位16ビットだけが抽出される
char = 78 # 下位8ビットだけが抽出される
```
