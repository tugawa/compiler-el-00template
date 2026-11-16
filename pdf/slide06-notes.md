# page 1: プログラミング言語 処理系論 第7回

この補足のページ番号は、`slide06.pdf` の表紙を1ページ目とするPDFのページ番号です。`ml-practice` で学んだ再帰、レコード、ヴァリアント型、パターンマッチ、モジュールを、構文木の処理に結び付けて読み進めてください。まずスライドを一通り読み、30ページの「練習」に到達したところで、それまでの内容に対応する演習課題をまとめて行います。

課題の仕様・操作手順は README.md を使い、この補足では理解に必要な説明と訂正を扱います。スライドだけでは説明が足りない箇所があり、特に評価規則の誤記、配布コードとの表記の違い、コード生成に必要な命令の意味を補っています。確認結果の一覧は、同じディレクトリの `slide06-review.md` にあります。

Page numbers in these notes refer to PDF pages, counting the cover of `slide06.pdf` as page 1. Connect the recursion, records, variants, pattern matching, and modules learned in `ml-practice` to the processing of syntax trees. Read through the slides first. At the explicit exercise on page 30, complete the assignments covered up to that point.

Use README.md for assignment specifications and operating instructions. These notes provide explanations and corrections needed for understanding. The slides alone leave some gaps, particularly incorrect evaluation rules, differences from the supplied code, and the meaning of instructions needed for code generation. The accompanying `slide06-review.md` lists the review findings.

# page 2: 今日の内容

学習の軸は「構文木を再帰的にたどる」という共通の処理です。構文木の表示では文字列を、インタプリタでは整数値を、コンパイラではアセンブリの文字列を組み立てます。同じ木でも、各節点から返すものが違います。

3〜20ページでは式の意味と評価方法を、21〜29ページでは同じ計算を行うコードの生成方法を学びます。字句解析器と構文解析器は配布済みなので、まず「文字列から得られた構文木をどう処理するか」に注目してください。

The common operation throughout the lesson is recursively traversing a syntax tree. A tree printer builds a string, an interpreter computes an integer, and a compiler builds an assembly string. The tree can be the same while the result produced at each node differs.

Pages 3–20 explain expression meaning and evaluation; pages 21–29 explain how to generate code for the same computation. The lexer and parser are supplied, so focus first on processing the tree obtained from the source text.

# page 3: プログラムの実行

図の根は `Plus`、その右の子は `Minus` なので、対応する式は `10 + (5 - 2)` です。

「下から順に」とは、親の計算に必要な子の値を先に求めることです。実装では根でパターンマッチし、その枝から子へ再帰呼び出しを行い、子から戻った値で親の結果を求めます。

The root is `Plus`, and its right child is `Minus`, so the diagram represents `10 + (5 - 2)`.

“From the bottom up” means computing child values before the parent operation that needs them. An implementation matches the root, recursively processes its children, and computes the parent result from the returned values.

# page 4: プログラムの実行

赤枠の `10`、`5`、`2` は、それぞれの葉を評価して得た整数値です。

The red `10`, `5`, and `2` are integer results obtained by evaluating the leaves.

# page 5: プログラムの実行

`Minus` の部分木では、左の子から得た `5` と右の子から得た `2` を使って `5 - 2 = 3` を求めます。演算するのは節点そのものではなく、部分木の評価結果です。

左右は交換できません。加算では順序の誤りを見逃しやすいので、減算や除算でも「左の値を右の値で演算する」と追えることが大切です。

The `Minus` subtree uses `5` from its left child and `2` from its right child to compute `5 - 2 = 3`. Arithmetic operates on evaluated values, rather than on the tree nodes themselves.

The two sides cannot be exchanged. Addition can hide operand-order mistakes, so be able to trace subtraction and division as an operation on the left value using the right value.

# page 6: プログラムの実行

根の `Plus` は、左の結果 `10` と右の部分木全体の結果 `3` を使って `13` を返します。各再帰呼び出しが「自分に渡された部分木の値を1つ返す」という約束を守れば、呼び出し側はその部分木の内部構造を気にせず計算できます。

図では結果を書き添えていますが、評価のために元の構文木を書き換える必要はありません。値は再帰呼び出しの戻り値として受け渡せます。

The root `Plus` combines its left result, `10`, with the result of the entire right subtree, `3`, to return `13`. If each recursive call returns one value for its subtree, its caller can use that value without knowing the subtree’s internal structure.

The diagram annotates nodes with results, but evaluation does not require modifying the original tree. Values can travel through recursive return values.

# page 7: インタプリタの設計図

`E[[ast]]ρ` は「構文木 `ast` を環境 `ρ` のもとで評価する」という数学的な記法です。二重括弧の中は評価対象であり、プログラムが扱うデータを人間が読める形で表現したものです。二重括弧の外は数学的な意味を定められた記号です。
`E` は評価、二重括弧の中は評価対象、`ρ` は変数名に対応する値を調べるための情報を表します。

 `ρ` は通常の文字で書けば `env` に相当します。変数参照を含む式は、構文木だけでは値を決められません。同じ木でも、環境が変われば結果が変わるため、評価関数には木と環境の両方を渡します。

`E[[ast]]ρ` is mathematical notation for evaluating tree `ast` in environment `ρ`. The content inside the double brackets is the subject of evaluation: a human-readable representation of the data handled by the program. The symbols outside the double brackets have defined mathematical meanings.
`E` denotes evaluation, the double brackets enclose its subject, and `ρ` supplies information for looking up variable values.

In ordinary code, `ρ` corresponds to `env`. A tree containing variable references does not determine a value by itself. The same tree can produce different results in different environments, so evaluation receives both the tree and an environment.

# page 8: Numの評価規則

リテラルとは、ソースコードに値を直接書いたものです。数字の列は字句解析の段階で整数へ変換され、`Num` の中に格納されます。評価時にもう一度文字列から整数へ変換する必要はありません。

[演習の注意] 配布された字句・構文規則には単項の負号がありません。したがって `-7` や `int x = -7; ...` は入力として受理されません。負の評価結果を確かめるときは `0 - 7` のような減算を使います。スライドの環境表に負の値があることと、負数リテラルを入力できることは別です。

A literal writes a value directly in source code. The lexer converts a sequence of digits into an integer, which is stored inside `Num`. Evaluation does not need to convert that value from a string again.

[Exercise note] The supplied lexer and grammar do not support unary minus. Inputs such as `-7` or `int x = -7; ...` are therefore rejected. Use subtraction, such as `0 - 7`, to obtain a negative evaluation result. A negative value in a slide’s environment table does not imply support for negative source literals.

# page 9: VarRefの評価規則

`VarRef "y"` が持つのは変数名の文字列であって、整数値 `10` ではありません。環境で名前を調べて初めて値が得られます。図の表は、この対応関係を見やすく描いたものです。

[演習の注意] 名前が環境に存在しない場合、配布コードでは `Undefined_variable` 例外を発生してエラーになります。コンパイラではコンパイルエラーになります。

`VarRef "y"` contains the variable’s name as a string, rather than the integer `10`. Its value is obtained by looking up that name in the environment. The table visualizes this mapping.

[Exercise note] If a name is absent from the environment, the supplied code raises `Undefined_variable` and reports an error. In the compiler, this is a compile-time error.

# page 10: 演算の評価規則

**訂正：このページでは加算と減算の記号が入れ替わっています。上の `Plus` の規則の右辺は `+`、下の `Minus` の規則の右辺は `-` です。** 13ページでは正しく書かれています。

`lhs` は left-hand side（左側）、`rhs` は right-hand side（右側）の略です。

**Correction: the addition and subtraction symbols are swapped on this page. The upper `Plus` rule must use `+` on the right, and the lower `Minus` rule must use `-`.** Page 13 gives the correct versions.

`lhs` and `rhs` abbreviate left-hand side and right-hand side.

# page 11: テキストによる構文木の記法

木の図、S式、XML風の表記、JSON風の表記は、同じ親子関係を異なる形で表しています。式をそのまま文字列にしたものと異なり、木の表現では「どの演算のどちらの子か」が明示されます。

訂正: 図の `Nm` は `Num` の誤記です。また、JSONの欄は構造を示す略記で、キーの引用符やカンマなどを備えた厳密なJSONではありません。表記法の比較として読んでください。

The tree diagram, S-expression, XML-style notation, and JSON-style notation express the same parent–child relationships in different forms. Unlike a plain expression string, a tree representation makes each child’s position under an operation explicit.

Correction: the diagram’s `Nm` is a typo for `Num`. The JSON example is also schematic: it lacks details such as quoted keys and commas required by strict JSON. Read it as a comparison of structural representations.

# page 12: S式構文木の記法

1組の括弧が1つの節点に対応し、その内側の括弧が子の節点に対応します。左の部分木を書き終えてから右の部分木を書くので、木の左右関係も保存できます。

[演習の注意]ここでの `Minus` などは説明用の節点名です。課題で要求される出力表記・整形は README.md の指定に従ってください。

**[課題] 練習1 構文木をS式にして表示** を行ってください。

Each pair of parentheses represents one node, and nested pairs represent its children. Writing the left subtree before the right preserves their order.

[Exercise note] Names such as `Minus` are used here for explanation. Follow README.md for the assignment’s required output notation and formatting.

Complete **[Assignment] Exercise 1: Displaying the Syntax Tree as an S-expression**.

# page 13: 評価規則 (S式版)

**訂正：このページ以降の数式に出てくる `VarExp` は、これまでのページの `VarRef` のことです。演習の配布コードでも `VarRef` になっています。** 

右辺に現れる`+`, `-`, `*`, `/` は数学の加減乗除です。それをOCamlのインタプリタで実装するときにはOCamlの演算を使って実現し、x86アセンブラにコンパイルするときはx86の命令を使って実現します。

**Correction: `VarExp` in formulas on this and later pages means `VarRef` from the preceding pages. The supplied exercise code also uses `VarRef`.**

The `+`, `-`, `*`, and `/` symbols on the right-hand side denote mathematical addition, subtraction, multiplication, and division. When implementing these operations in an OCaml interpreter, use OCaml’s arithmetic operations; when compiling to x86 assembly, use x86 instructions.

# page 14: 評価の例

**訂正：冒頭の `5 + x - y` は、`5 + x - z` と読み替えてください。** 

まず外側の演算を部分式の評価に分解し、変数参照に達してから名前を表の値に置き換えています。

**Correction: read the opening `5 + x - y` as `5 + x - z`.**

The derivation first decomposes outer operations into evaluations of subexpressions, then replaces variable names with values from the table when it reaches variable references.

# page 15: OCamlによる構文木型の定義

上段の定義と下段の定義は、レコード部分に独立した型名を付けるかどうかが違います。配布された `ast.ml` は下段の形式です。`binop_body` が `expr` を参照し、`expr` も `binop_body` を参照するため、型の定義を `and` でつないでいます。

[演習の注意] 実際の `ast.ml` には式を表す `expr` とプログラム全体を表す `program` があります。両者を区別し、式の処理を、配布済みのプログラム全体の処理から呼び出す構成として捉えてください。

The two definitions differ in whether the record payload has a separate type name. The supplied `ast.ml` uses the lower form. Since `binop_body` refers to `expr` and `expr` refers back to `binop_body`, their definitions are connected with `and`.

[Exercise note] The actual `ast.ml` defines both expressions (`expr`) and whole programs (`program`). Keep these levels distinct: the supplied whole-program traversal calls the expression-processing function.

# page 16: 評価規則のプログラムによる表現

[演習の注意] スライドは `eval_expr expr env` の形で二つの引数を受け取っていますが、配布された `interp.ml` は `eval_expr(expr, env)` という組を1つ受け取る形式です。

[Exercise note] The slides take two arguments in the form `eval_expr expr env`, whereas the supplied `interp.ml` takes one tuple argument in the form `eval_expr(expr, env)`.

# page 17: Num

評価規則に従って`E[[(Num n)]] env`は`n`に評価します。

According to the evaluation rule, `E[[(Num n)]] env` evaluates to `n`.

# page 18: Plus

評価規則に従って、部分式の評価を再帰的に呼び出します。このとき、同じ環境で評価することに注意してください。

Following the evaluation rule, evaluate the subexpressions through recursive calls. Take care to use the same environment for these evaluations.

# page 19: VarRef

ここで数式の `ρ(x)` を実現しているのが `apply_env` です。`VarRef` の中の名前を、現在の環境で検索します。スライドの `ρ` はコードでは `env` と読み替えます。

[演習の注意] `apply_env` は `Env` モジュールに定義されており、`interp.ml` は `open Env` によって名前を直接使えるようにしています。`open` はファイルを文字列として読み込む操作ではなく、モジュール内の名前を参照しやすくする指定です。

`apply_env` implements the mathematical lookup `ρ(x)`. It searches the current environment for the name contained in `VarRef`. Read the slide’s `ρ` as `env` in code.

[Exercise note] `apply_env` is defined in module `Env`. The supplied `interp.ml` uses `open Env` so that it can refer to that name directly. Opening a module makes its names available; it does not read a file as text.

# page 20: 環境の実現

`Binding` の列は連結リストと同じ構造です。`update_env` は既存の環境を書き換えず、新しい束縛を先頭に付けた環境を返します。戻り値を次の処理に渡す必要があります。同じ名前が複数あると先頭側のものが見つかるため、後から追加した定義が優先されます。更新前の環境は引き続き使えます。

[演習の注意] 配布された `env.ml` は、スライドの単相の `env` を一般化した `'a env` を使います。検索と更新の型はそれぞれ `'a env * string -> 'a` と `'a env * string * 'a -> 'a env` です。また、スライドの `Undef_var_err` に対応する例外名は、配布コードでは `Undefined_variable` です。

**[課題] 練習2 構文木をインタプリタ実行** を行ってください。

The chain of `Binding` nodes has the structure of a linked list. `update_env` returns a new environment with a binding at its head, leaving the previous environment intact. Pass the returned environment to subsequent processing. Lookup finds the first matching name, so a later addition shadows an earlier binding. The older environment remains usable.

[Exercise note] The supplied `env.ml` generalizes the slide’s monomorphic `env` to `'a env`. Lookup has type `'a env * string -> 'a`, and update has type `'a env * string * 'a -> 'a env`. The supplied exception corresponding to the slide’s `Undef_var_err` is named `Undefined_variable`.

Complete **[Assignment] Exercise 2: Executing the Syntax Tree with an Interpreter**.

# page 21: インタプリタからコンパイラへ

インタプリタは木をたどりながら整数を計算します。コンパイラも木をたどりますが、各演算を後で実行させる命令を出力します。コンパイル時に足し算の命令を書くことと、その足し算を実行することは別の段階です。

右側の `r1`〜`r5` は途中結果の保存先を説明するための名前です。実際の x86-64 レジスタ名ではありません。

An interpreter traverses the tree and computes integers. A compiler also traverses the tree, but emits instructions that will perform those operations later. Writing an addition instruction during compilation and executing that addition are different stages.

The names `r1`–`r5` illustrate intermediate storage locations; they are not actual x86-64 register names.

# page 22: コンパイル規則

`C[[ast]]ρ rd` は、結果を保存先 `rd` に置くコードを生成する、という記法です。式の値をその場で返す `E` と異なり、`C` の結果は命令列です。式の形に応じて、子のコードと親自身の命令を順に組み合わせます。

[演習の注意] ここでの `rd` はレジスタを保存先とする方式の引数です。25ページからは結果をスタックへ置く方式に変わるため、配布された `compile_expr` に `rd` 引数を追加する必要はありません。

`C[[ast]]ρ rd` denotes generating code that will place a result in destination `rd`. Unlike `E`, which yields an expression’s value, `C` yields instructions. The node’s shape determines how child code and the parent’s own instructions are combined.

[Exercise note] The destination argument `rd` belongs to the register-result approach shown here. From page 25 onward, results go on the stack, so the supplied `compile_expr` does not need an added `rd` argument.

# page 23: 値の保存場所

コンパイラを実行するプロセスと、生成されたプログラムを実行するプロセスでは、使っているメモリが異なります。コンパイラの OCaml 変数に実行時の値を保存しても、生成されたプログラムからその OCaml 変数を参照することはできません。コンパイラが生成したコードは、そのコードを実行するときに作られるスタックなどに保存します。

The compiler process and the generated program execute with different memory. A value stored in an OCaml variable inside the compiler cannot be accessed through that OCaml variable by the generated program. The code generated by the compiler stores values in a stack or other storage created when that code runs.

# page 24: 保存場所

この課題で中心となるのはスタックです。x86-64 の `pushq` では `%rsp` が8減り、新しい先頭位置に8バイトの値が置かれます。`popq` は先頭の値を取り出して `%rsp` を8増やします。スタックは低いアドレスへ伸びます。

`%rsp` は現在のスタックの先頭、`%rbp` はスタックの底です。式の途中結果を積み下ろすと `%rsp` は変わりますが、`%rbp` は同じままにするため、スタックにいくつ要素を積んでいるかに関係なく、`%rbp`からのオフセットで同じ変数にアクセスできます。

The stack is the main storage mechanism for this assignment. On x86-64, `pushq` decreases `%rsp` by eight and stores an eight-byte value at the new top. `popq` retrieves the top value and increases `%rsp` by eight. The stack grows toward lower addresses.

`%rsp` identifies the current top of the stack, and `%rbp` its base. Pushing and popping intermediate results changes `%rsp` but keeps `%rbp` fixed. An offset from `%rbp` therefore accesses the same variable regardless of how many elements are currently on the stack.

# page 25: 式のコード生成の方針

これまでは計算結果や途中結果をレジスタに保存していました。以降では、計算結果や途中結果をスタックに保存します。

式のコードに共通する約束は、「実行前から積まれていた値を必要なだけ取り出し、実行後には式の結果を1個だけ追加して残す」です。

右端をスタックの先頭として、左と右の結果を `L`、`R` と書くと、二項演算の変化は次のようになります。`S` は既存のスタック全体です。

```text
S  →  S, L  →  S, L, R  →  S, (L op R)
```

先に取り出せるのは右の値です。また、左の結果をレジスタだけに残して右のコードを実行すると、そのレジスタが上書きされるかもしれません。部分木同士で保存先の約束を共有することが、入れ子の式を正しく扱う鍵です。

So far, results and intermediate values have been stored in registers. From this point onward, they are stored on the stack.

The common contract for expression code is to pop as many previously stacked values as needed and leave exactly one new value, the expression’s result, on the stack afterward.

With the top on the right and operand results named `L` and `R`, a binary operation follows the stack transition shown above. `S` denotes the entire pre-existing stack.

The right value is available to pop first. Also, keeping the left result only in a register while running the right subtree’s code risks having that register overwritten. A shared storage contract between subtrees is what makes nested expressions work.

# page 26: 環境

インタプリタの環境が保持する整数は「変数の値」でしたが、コンパイラの環境が保持する整数は「変数の位置を表すスタックの底（`%rbp`）からのオフセット（バイト単位）」です。

たとえば環境が名前を `-8` に対応付けている場合、変数の実行時の値は `%rbp - 8` のアドレスにあります。`-8` 自体をその変数の値として積むわけではありません。

[演習の注意] 変数用の領域の確保とオフセットの更新は、配布済みの `compile_program` が行います。式の途中結果はその先に積み、式を処理するコードから既存の変数領域や `%rbp` を壊さないようにします。

Integers in the interpreter’s environment are variable values. Integers in the compiler’s environment are byte offsets from the base of the stack (`%rbp`) that describe variable locations.

If a name maps to `-8`, its runtime value lives at address `%rbp - 8`. The offset `-8` itself is not the variable’s value to push.

[Exercise note] The supplied `compile_program` allocates variable storage and updates offsets. Expression results are pushed beyond that storage; expression code must preserve the existing variable area and `%rbp`.

# page 27: x86-64命令セット

この教材は x86-64 の AT&T 構文を使います。通常の2オペランド命令は「入力元、書き込み先」の順で、接尾辞 `q` は64ビット操作を表します。`(%rsp)` はスタックの先頭にあるメモリの値であり、`%rsp` 自体の値とは異なります。

| 命令の形 | 意味・制約 |
| --- | --- |
| `movq src, dst` | 値をコピーする。通常の形ではメモリ同士のコピーはできない。 |
| `addq src, dst` | `dst` を `dst + src` にする。 |
| `subq src, dst` | `dst` を `dst - src` にする。 |
| `pushq src` | 8バイトの値をスタックへ積む。 |
| `popq dst` | 8バイトの値をスタックから取り出す。 |
| `imulq src, reg` | 2オペランド形式の乗算。結果はレジスタ `reg` に入り、メモリをこの書き込み先にはできない。 |
| `cqto` | `%rax` の符号を `%rdx:%rax` へ拡張する。明示的なオペランドはない。 |
| `idivq divisor` | `%rdx:%rax` を符号付きの除数で割り、商を `%rax`、余りを `%rdx` に置く。除数はレジスタまたはメモリ。 |

符号付き除算では、被除数を `%rax` に置いてから `cqto` で上位部分を準備します。負の被除数に対して `%rdx` を単に0にする方法は使えません。除数も `cqto` が上書きする `%rdx` に置かないようにします。商の丸め方は13ページの整数除算と同じです。

「64ビット」という説明は、すべての命令が任意の64ビット即値を直接受け取れるという意味ではありません。`pushq $n` の即値は符号付き32ビットの範囲に制限されます。さらに、OCaml の通常の `int` と x86-64 の整数演算では整数幅が異なります。両者を比較するときは、リテラルを命令で表現でき、途中結果がどちらでもオーバーフローしない範囲を使います。

生成コードの実行には、x86-64 用のアセンブラ・リンカと、その実行形式を動かせる環境が必要です。Apple Silicon の標準のビルド対象は ARM64 なので、x86-64 を対象にする設定と対応する実行環境が必要になります。OCaml で作ったコンパイラ自体のビルド成功と、生成した機械語を実行できることは別に確認します。

The material uses x86-64 AT&T syntax. Ordinary two-operand instructions list the source before the destination; suffix `q` indicates a 64-bit operation. `(%rsp)` accesses the value in memory at the stack top, whereas `%rsp` denotes the pointer itself.

| Instruction form | Meaning and constraints |
| --- | --- |
| `movq src, dst` | Copy a value; the ordinary form cannot copy directly between two memory operands. |
| `addq src, dst` | Set `dst` to `dst + src`. |
| `subq src, dst` | Set `dst` to `dst - src`. |
| `pushq src` | Push an eight-byte value. |
| `popq dst` | Pop an eight-byte value. |
| `imulq src, reg` | Two-operand multiply, storing its result in register `reg`; this destination cannot be memory. |
| `cqto` | Sign-extend `%rax` into `%rdx:%rax`; there is no explicit operand. |
| `idivq divisor` | Signed division of `%rdx:%rax`, placing the quotient in `%rax` and remainder in `%rdx`; the divisor is a register or memory operand. |

For signed division, put the dividend in `%rax`, then prepare its upper half with `cqto`. Simply zeroing `%rdx` is incorrect for a negative dividend. Do not keep the divisor in `%rdx`, which `cqto` overwrites. Quotient rounding matches the integer division described on page 13.

“64-bit” does not mean every instruction accepts an arbitrary 64-bit immediate. The immediate in `pushq $n` must fit a signed 32-bit value. Ordinary OCaml `int` arithmetic and x86-64 arithmetic also have different integer widths. Compare them using representable literals and intermediate results that do not overflow either representation.

Running generated code requires an x86-64 assembler and linker plus an environment able to execute the resulting binary format. Apple Silicon normally targets ARM64, so it requires an x86-64 target configuration and a compatible execution environment. Building the OCaml compiler and executing its generated machine code are separate checks.

# page 28: コンパイル規則

**訂正：このページの `Int` は配布コードでは `Num`、`VarExp` は `VarRef` と読み替えます。**

加算の例を25ページの約束と照合してください。左右のコードを実行した直後は先頭に右の値、その次に左の値があります。右の値を `%rax` へ取り出すと、`(%rsp)` は左の値を指します。続く加算がその場所を書き換えるので、結果をあらためて積み直す必要はありません。

これは「2つ取り出して1つ積む」という抽象的な処理を、メモリ上の値の更新も使って実現したものです。抽象的なスタック変化と、実際の命令数が一致する必要はありません。

**Correction: on this page, `Int` corresponds to `Num` and `VarExp` to `VarRef` in the supplied code.**

Check the addition example against page 25’s contract. After both child code sequences execute, the right value is on top and the left value is immediately below it. Popping the right value into `%rax` makes `(%rsp)` refer to the left value. Addition updates that location, so the result is already on the stack and needs no extra push.

This implements the abstract “pop two, push one” transition partly by updating memory. The number of actual instructions need not match the number of abstract stack operations.

# page 29: OCamlのプログラム

`compile_expr` は整数ではなくアセンブリ文字列を返し、期待される型は `Ast.expr -> int Env.env -> string` です。こちらはスライドと配布コードの両方が `compile_expr expr env` の形式です。16ページの `eval_expr` とは引数形式が異なります。一方、`insn` と環境操作は組引数です。

`^` は文字列の連結で、生成される命令の並びを決めます。`lhs_code ^ rhs_code` なら、生成プログラムは左のコードを先に実行します。OCaml が文字列を組み立てること自体は、生成プログラムの加算やスタック操作を実行しません。

スライド中の一部の文字列には `“` や `”` という引用符が使われています。コードに入力する場合は半角の `"` を使ってください。`insn` はタブと改行を付ける補助関数なので、各命令の文字列にそれらを二重に付ける必要はありません。

`compile_expr` returns assembly text, with intended type `Ast.expr -> int Env.env -> string`. Both the slides and supplied code use `compile_expr expr env`. This differs from the tuple convention of `eval_expr` on page 16. Meanwhile, `insn` and the environment operations take tuple arguments.

The operator `^` concatenates strings and determines the emitted instruction order. With `lhs_code ^ rhs_code`, the generated program executes the left code first. Constructing strings in OCaml does not itself execute the generated program’s addition or stack operations.

Some strings on the slide use curly quotation marks, `“` or `”`. Use ordinary ASCII `"` when entering code. The helper `insn` adds a tab and newline, so individual instruction strings do not need to add them again.

# page 30: 練習

この練習を紙の上で行った後、**##[課題] 練習3 構文木のコンパイル** を行ってください。

After completing this exercise on paper, do **[Assignment] Exercise 3: Compiling the Syntax Tree**.
