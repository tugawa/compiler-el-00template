exception Not_implemented

type vardef_body = {var: string; value: int; next: program}
 and program =
   | VarDef of vardef_body
   | Expr of expr
 and binop_body = {lhs: expr; rhs: expr}
 and expr =
   | Plus of binop_body
   | Minus of binop_body
   | Times of binop_body
   | Div of binop_body
   | VarRef of string
   | Num of int

let rec sexp_of_expr expr =
  raise Not_implemented

let rec sexp_of_program prog =
  match prog with
  | VarDef {var = var; value = value; next = rest} ->
     "(var " ^ var ^ " " ^ (string_of_int value) ^ "\n" ^ (sexp_of_program rest) ^ ")"
  | Expr expr ->
     sexp_of_expr expr
