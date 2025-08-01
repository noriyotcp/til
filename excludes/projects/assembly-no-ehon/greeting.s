.global _start
.align 2

_start:
    mov X0, #1 // レジスタX0に1を代入 標準出力 writeシステムコールの第1引数に渡す
    adr X1, greeting // レジスタX1にgreetingのアドレスを代入 writeシステムコールの第2引数に渡す
    mov X2, #16 // レジスタX2に16を代入 表示したい文字列の長さ。改行コードを1文字としてカウントする writeシステムコールの第3引数に渡す
    mov X16, #4 // レジスタX16に4を代入 writeシステムコールのシステムコール番号を代入
    svc #0x80 // Supervisor Callを実行

    mov X0, #0 // レジスタX0に0を代入 終了コードを0にする
    mov X16, #1 // レジスタX16に1を代入 exitシステムコールのシステムコール番号を代入
    svc #0x80 // Supervisor Callを実行

greeting: .ascii "Hello, world!\n" // 文字列を定義
