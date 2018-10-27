# el 言語

整数の四則演算からなる式のプログラム．式の前に変数（代入できないので
文字定数と同じ）を定義できる．変数の定義には整数しか使えない．

例
```
x = 3; y = 5; x + 2 * y
```

## リポジトリの更新のしかた
```
> git remote add template https://github.com/kut-info-compiler/compiler-el-00template.git    <--- 最初だけ
> git fetch template
> git merge template/master
```

## 文法と構文木

[parser.mly](parser.mly)を参照

## 意味

```
E[[ (VarDef var val prog) ]] rho = E[[ prog ]] rho'
  ただし，
     rho'(x) = var     (x == varのとき)
     rho'(x) = rho(x)  (そうでないとき)

E[[ (+ lhs rhs) ]] rho = E[[ lhs ]] rho + E[[ rhs ]] rho

E[[ (- lhs rhs) ]] rho = E[[ lhs ]] rho - E[[ rhs ]] rho

E[[ (* lhs rhs) ]] rho = E[[ lhs ]] rho * E[[ rhs ]] rho

E[[ (/ lhs rhs) ]] rho = E[[ lhs ]] rho / E[[ rhs ]] rho

E[[ (VarRef var) ]] rho = rho(var)

E[[ (Num n) ]] rho = n
```

## [課題] 練習1 構文木をS式にして表示

[ast.ml](ast.ml)の未実装部分（`raise Not_implemented`になっている）
2箇所を正しく実装して，構文木をS式にして表示すプログラムを完成させなさい．
完成すると，`make`によって標準入力からプログラムを受けとってS式を表示する
プログラム`printast`が作られる．

  * 構文木の節点を表す記号は，`VarDef`，`+`，`-`，`*`，`/`，`VarRef`，`Num`にすること．
    * `(VarDef <変数> <値>[改行]<続きのプログラムのS式)` (変数定義)
    * `(+ <左辺のS式> <右辺のS式>)`
    * `(- <左辺のS式> <右辺のS式>)`
    * `(* <左辺のS式> <右辺のS式>)`
    * `(/ <左辺のS式> <右辺のS式>)`
    * `(VarRef <変数>)` (変数参照)
    * `(Num <値>)` (整数)
  * `program`のコンストラクタが`Expr`のときは中身（`expr`）に対応するS式だけを表示すること．

### 実行例

入力: x = 3; y = 5; x + 2 * y
```
(VarDef x 3
(VarDef y 5
(+ (VarRef x) (* (Num 2) (VarRef y)))))
```

## [課題] 練習2 構文木をインタプリタ実行

[interp.ml](interp.ml)の未実装部分（`raise Not_implemented`になっている）
2箇所を正しく実装して，構文木をS式にして表示すプログラムを完成させなさい．
完成すると，`make`によって標準入力からプログラムを受けとってS式を表示する

プログラム`interp`が作られる．

### 実行例

入力: x = 3; y = 5; x + 2 * y
```
13
```

## 練習3 構文木のコンパイル

[comp.ml](comp.ml)の未実装部分（`raise Not_implemented`になっている）
を正しく実装して，構文木をS式にして表示すプログラムを完成させなさい．
完成すると，`make`によって標準入力からプログラムを受けとってS式を表示する

プログラム`comp`が作られる．

### 実行例

入力: x = 3; y = 5; x + 2 * y
```
.text
	.global _main
_main:
	pushq %rbp
	movq %rsp, %rbp
	pushq $3               <-- compile_program で作られる
	pushq $5               <-- compile_program で作られる
	movq -8(%rbp), %rax    <-- ここから compile_expr で作られる
	pushq %rax
	pushq $2
	movq -16(%rbp), %rax
	pushq %rax
	popq %rax
	imulq (%rsp), %rax
	movq %rax, (%rsp)
	popq %rax
	addq %rax, (%rsp)      <-- ここまで compile_expr で作られる

	popq %rax
	movq %rbp, %rsp
	popq %rbp
	ret 
```

### 使い方
```
$ echo "x = 3; y = 5; x + 2 * y" | ./comp > a.s   <--- コンパイル
$ gcc a.s    <--- アセンブル
$ ./a.out    <--- 実行
$ echo $?    <--- 実行結果（終了コード）の表示
13
```
