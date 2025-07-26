.global _start
.align 2

_start:
    mov X0, #8
    mov X1, #15
    add X2, X0, X1 // Calculate

    mov X0, X2      // 分割する文字
    mov X1, sp      // スタックポインタを X1 に保存
    mov X2, #10     // 割るときの分母

convert_loop:
    udiv X3, X0, X2     // 23 / 10 = 2
    msub X4, X3, X2, X0 // 23 - (2 * 10) = 23 - 20 = 3
    add X4, X4, #'0'    // その結果 3 に '0' を加算して '3' に変換

    strb W4, [X1, #-1]! // スタックポインタを1バイトデクリメントして移動し、文字をスタックに格納

    mov X0, X3            // 次のループ処理に備えて計算結果を更新
    cbnz X3, convert_loop // X3 がゼロでなければラベルが示すアドレスにジャンプ

print_string:
    mov X0, #1  // レジスタX0に1（文字列の「出力」）を代入
    mov X2, #2  // レジスタX2に2（文字列の長さ）を代入
    mov X16, #4 // レジスタX16に4（write システムコール番号）を代入
    svc #0x80   // Supervisor コール命令でシステムコールを実行

end:
    mov X0, #0  // レジスタX0に0（プログラムの終了コード）を代入
    mov X16, #1 // レジスタX16に1（exit システムコール番号）を代入
    svc #0x80   // Supervisor コール命令でシステムコールを実行
