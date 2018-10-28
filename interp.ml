open Ast
open Env

exception Not_implemented

let rec eval_expr(expr, env) =
  raise Not_implemented

let rec eval_program(prog, env) =
  match prog with
  | VarDef {var = var; value = value; next = rest} ->
     let env = update_env(env, var, value) in
     eval_program(rest, env)
  | Expr expr ->
     eval_expr(expr, env)
    
let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.program Lexer.get_token lexbuf in
  let answer = eval_program(ast, EmptyEnv) in
  print_int answer;
  print_string "\n"
