## 2.2 システムコールを把握する

本誌で紹介されている https://opensource.apple.com/source/xnu/xnu-1504.3.12/bsd/kern/syscalls.master はリンク切れになっていた

代わりに GitHub の `apple-oss-distributions/xnu` にあった

https://github.com/apple-oss-distributions/xnu/blob/8d741a5de7ff4191bf97d57b9f54c2f6d4a15585/bsd/kern/syscalls.master#L49

```
4	AUE_NULL	ALL	{ user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte); }
```

> 左から順にシステムコールナンバー、命令の追跡有無、対応プラットフォーム、命令のプロトタイプになります。

`ALL` なのでプラットフォームによる違いはない


```sh
$ man 2 write

SYNOPSIS
     #include <unistd.h>

     ssize_t
     pwrite(int fildes, const void *buf, size_t nbyte, off_t offset);

     ssize_t
     write(int fildes, const void *buf, size_t nbyte);

(...)

DESCRIPTION
     write() attempts to write nbyte of data to the object referenced by the descriptor fildes from the buffer pointed to by buf.  writev()
     performs the same action, but gathers the output data from the iovcnt buffers specified by the members of the iov array: iov[0], iov[1],
     ..., iov[iovcnt-1].  pwrite() and pwritev() perform the same functions, but write to the specified position in the file without modifying
     the file pointer.
```

### 2.2.1 システムコールを呼び出す方法

- `fd` : ファイルディスクリプタ
  - `0` : 標準入力
  - `1` : 標準出力
  - `2` : 標準エラー出力
- `cbuf` : 書き込むデータのアドレス
- `nbyte` : 書き込むデータのサイズ

## 2.3 レジスタに値を格納する

```as
adr X1, greeting // レジスタ X1 にラベル greeting のアドレスを設定する
```

> 2行目では adrという命令が利用されています。これは address の略で、シンボ
ルのアドレスをレジスタへ格納するためのものです。ここでは greetingという
ラベルを指定しており、メモリ上に展開された文字列を示すアドレスをレジスタ
の番地 X1に格納しているのだとわかります。つまり、文字列データ自体はメモ
リ上に格納されており、レジスタにはそれを示すアドレスのみが格納されている
ということになります。これが write システムコールの第二引数に渡したい値と
なります。

```as
// オペコード
// ↓
mov X0, #1 // レジスタ X0 に値 1 を設定する
14
アセンブリの慧本
adr X1, greeting
mov X2, #14
// ~~~~~~
// ↑
// オペランド
greeting: .ascii “Hello, World!\n”
```

- `mov` : レジスタに値を格納する
  - オペコード
- オペランド
  - `X0` : レジスタ
  - `#1` : 値

> 次に、オペコードの右側をオペランドと呼びます。このオペランドのシンタックスは CPU アーキテクチャ等によって異なります。今回ご紹介するのは AArch64 アセンブリ記法と呼ばれる記法で Arm アセンブリ記法の64bit 版です。




#### 📝 .ascii 擬似命令

こんな感じで文字列を定義できる

```as
greeting: .ascii "Hello, world!\n" // 文字列を定義
```

> アセンブリの行でピリオド（.）で始まるものは疑似命令です。例えば、.file、.ascii などが該当します。

[X86アセンブラ/GASでの文法 - Wikibooks](https://ja.wikibooks.org/wiki/X86%E3%82%A2%E3%82%BB%E3%83%B3%E3%83%96%E3%83%A9/GAS%E3%81%A7%E3%81%AE%E6%96%87%E6%B3%95)


## 2.7 プログラムを機械語に変換する
### 検証環境
- Apple M3
- Sequoia 15.0.1
- Xcode 16.2

本書と違って `Makefile` を用意してみた

```Makefile
greeting: greeting.o
	ld -o greeting \
		-lSystem \
		-syslibroot `xcrun -sdk macosx --show-sdk-path` \
		-e _start \
		-arch arm64 \
		greeting.o

greeting.o: greeting.s
	as -arch arm64 \
		-o greeting.o \
		greeting.s

clean:
	rm -f greeting greeting.o calculate calculate.o countdown countdown.o

.PHONY: clean
```

### 📝 `as` コマンドのオプションなど

```sh
 ❯ as --help
OVERVIEW: clang LLVM compiler

USAGE: clang [options] file...

OPTIONS:
(めっちゃたくさんある)

# output option
  -o <file>               Write output to <file>
```

`-arch` option がなさそう？

ここには書いている  
https://clang.llvm.org/docs/ClangCommandLineReference.html#cmdoption-clang-arch

```sh
-arch <arg>
```

```sh
 ❯ as -mcpu=help
Apple clang version 16.0.0 (clang-1600.0.26.6)
Target: x86_64-apple-darwin24.0.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

# arm64 はなさそう
Available CPUs for this target:

	alderlake
	amdfam10
	athlon
	athlon-4
	athlon-fx
	athlon-mp
	athlon-tbird
	athlon-xp
	athlon64
	athlon64-sse3
	atom
	atom_sse4_2
	atom_sse4_2_movbe
	barcelona
	bdver1
	bdver2
	bdver3
	bdver4
	bonnell
	broadwell
	btver1
	btver2
	c3
	c3-2
	cannonlake
	cascadelake
	cooperlake
	core-avx-i
	core-avx2
	core2
	core_2_duo_sse4_1
	core_2_duo_ssse3
	core_2nd_gen_avx
	core_3rd_gen_avx
	core_4th_gen_avx
	core_4th_gen_avx_tsx
	core_5th_gen_avx
	core_5th_gen_avx_tsx
	core_aes_pclmulqdq
	core_i7_sse4_2
	corei7
	corei7-avx
	emeraldrapids
	generic
	geode
	goldmont
	goldmont-plus
	goldmont_plus
	grandridge
	graniterapids
	graniterapids-d
	graniterapids_d
	haswell
	i386
	i486
	i586
	i686
	icelake-client
	icelake-server
	icelake_client
	icelake_server
	ivybridge
	k6
	k6-2
	k6-3
	k8
	k8-sse3
	knl
	knm
	lakemont
	meteorlake
	mic_avx512
	nehalem
	nocona
	opteron
	opteron-sse3
	penryn
	pentium
	pentium-m
	pentium-mmx
	pentium2
	pentium3
	pentium3m
	pentium4
	pentium4m
	pentium_4
	pentium_4_sse3
	pentium_ii
	pentium_iii
	pentium_iii_no_xmm_regs
	pentium_m
	pentium_mmx
	pentium_pro
	pentiumpro
	prescott
	raptorlake
	rocketlake
	sandybridge
	sapphirerapids
	sierraforest
	silvermont
	skx
	skylake
	skylake-avx512
	skylake_avx512
	slm
	tigerlake
	tremont
	westmere
	winchip-c6
	winchip2
	x86-64
	x86-64-v2
	x86-64-v3
	x86-64-v4
	yonah
	znver1
	znver2
	znver3
	znver4

Use -mcpu or -mtune to specify the target's processor.
For example, clang --target=aarch64-unknown-linux-gnu -mcpu=cortex-a35
```

### 📝 `ld` コマンドのオプションなど

```sh
# o: 出力ファイル名を指定
# lSystem option: システムライブラリをリンク
# syslibroot option: SDK パスを指定
# e option: エントリーポイントを _start に設定
# arch option: アーキテクチャを arm64 に指定
# 最後にリンク対象のファイルを指定
greeting: greeting.o
	ld -o greeting \
		-lSystem \
		-syslibroot `xcrun -sdk macosx --show-sdk-path` \
		-e _start \
		-arch arm64 \
		greeting.o
```

```less
$ man ld
OPTIONS
   Options that control the kind of output
(...)
     -arch arch_name
             Specifies which architecture (e.g. ppc, ppc64, i386, x86_64) the
             output file should be.

     -o path
             Specifies the name and location of the output file.  If not
             specified, `a.out' is used.

   Options that control libraries
     -lx     This option tells the linker to search for libx.dylib or libx.a
             in the library search path.  If string x is of the form y.o, then
             that file is searched for in the same places, but without
             prepending `lib' or appending `.a' or `.dylib' to the filename.
(...)
  Rarely used Options
     -e symbol_name
             Specifies the entry point of a main executable.  By default the
             entry name is "start" which is found in crt1.o which contains the
             glue code need to set up and call main().

(...)
   Search paths
     ld maintains a list of directories to search for a library or framework
     to use.  The default library search path is /usr/lib then /usr/local/lib.
     The -L option will add a new library search path.  The default framework
     search path is /Library/Frameworks then /System/Library/Frameworks.
     (Note: previously, /Network/Library/Frameworks was at the end of the
     default path.  If you need that functionality, you need to explicitly add
     -F/Network/Library/Frameworks).  The -F option will add a new framework
     search path.  The -Z option will remove the standard search paths.  The
     -syslibroot option will prepend a prefix to all search paths.
```

## 3.1 アセンブリで四則演算を行う
（補数がわからん）

Google の検索結果

> 補数（ほすう）とは、ある数と足したときに桁上がりする最小の数、または桁上がりしない最大の数のことです。
> 補数は、コンピューターで負の数を表現したり、減算を加算に置き換えて処理したりするために使用されます。
> 補数には、次のような種類があります。
> 1の補数：2進数で、各桁の0と1を入れ替えることで求められます。たとえば、1010の1の補数は0101です。
> 2の補数：2進数で、（決められた桁数で表せる最大値+1）を基準とする補数の2進数表現です。たとえば、2進4桁で1010の2の補数は0110です。
> 10の補数：10進数で、減基数の補数です。
> 補数を使うことで、マイナス記号を使わずに負の数を表現することができます。たとえば、97-97 = 0 という減算処理を 97+(-97) = 0 という加算処理で行うことができます。

あとはこの記事が良かった  
https://freelance.shiftinc.jp/column/2-complement


> 先ほど解説したように減算は加算命令で処理可能なため、一見すると符号ありでも正しく計算できそうにも感じます。しかし、分母もしくは分子がマイナスの値となると減算の回数で乗算が表現できなくなるのです。このように、除算は符号の有無が重要になる計算であるため、符号なし除算命令を示す udivと符号あり除算命令を示す sdiv*1に命令が分かれているのです。

## 3.2 演算結果を ASCII コードに変換する

```as
mov X0, #5
mov X1, #4
add X2, X0, X1 // 加算の例
add X2, X2, #'0' // X2 の値に文字 '0' の ASCIIコード （48） を加算
mov W3, W2 // 32ビットの W2レジスタの値を W3レジスタにコピー
strb W3, [sp] // W3の下位8ビットをスタックポインタの指すメモリアドレスにストア
```

- '0' の ASCII コードは 48 それを加算することで数字の文字列に変換できる
- その結果が格納されているレジスタ `X2` の下位8ビットをメモリにストアする
  - 一旦 32ビットのレジスタ `W2` から 作業領域 `W3` にコピーしている
  - `W2` は `X2` に対応している
- `strb` : バイトストア命令 Store Register Byte
  - 第１オペランドでは32ビットレジスタを指定する必要がある

# 第4章 複数桁の計算結果を文字列出力
## 4.1 実装方針
- まず、複数桁の整数値を整数値のまま1桁ずつバラバラする
- これらの整数値に対して ASCII コードへの変換処理をそれぞれ施し、連続する ASCII コード として出力することで複数桁の計算結果を文字列として出力する

## 4.2 剰余を求める
- 複数桁で構成される計算結果を1文字ずつ分割していく
- ここで取り扱う計算結果は10進数なので、10で割ることで下一桁を除外した値
が求められ、余りとして下一桁を取得することができる

## 4.4 スタックポインタを操作する
スタックポインタはデータが格納されているメモリ上のアドレスを管理している  
そのまま参照するのではなく、他の文字を保存している領域を上書きしないように、保存先のアドレスをずらす必要がある

```as
_start:
  mov X0, #2024
  mov X1, sp
  add X2, #10

convert_loop:
  udiv X3, X0, X2
  msub X4, X3, X2, X0
  add X4, X4, #'0'
  
  sub X1, X1, #1
  strb W4, [X1] // [X1] は sp のアドレスが入っている。それをずらしていく

  mov X0, X3
  cbnz X3, convert_loop
```

> ここで重要なのは、スタックポインタを直接書き換えずに、X1番地に保存されたアドレスに対して変更を加えているということです。今回の実装では、あくまでも保存先を示すアドレスを移動したいだけであって、スタックポインタに直接変更を加えたいわけではないのです。

> 次に、アドレス移動が sub命令、つまり減算によって行われているのはなぜでしょうか。これはスタックの仕組みが関係しており、データをスタックにプッシュするとスタックポインタが指し示すアドレス値は下り、データをポップするとアドレス値が上がるという特性によるものです。したがって、スタックに文字列を保存する際に、保存先アドレスを1バイト分減らすという操作を行なっているのです。

