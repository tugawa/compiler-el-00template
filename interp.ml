open Ast
exception Interp_error of string
exception Not_implemented

type env_body = {var: string; value: int; next: env}
 and env =
   | EmptyEnv
   | Binding of env_body

let rec apply_env(env, search_var) =
  match env with
  | EmptyEnv -> raise (Interp_error ("Undefined variable: " ^ search_var))
  | Binding {var = var; value = value; next = inner_env} ->
     if var = search_var then value
     else apply_env(inner_env, search_var)

let update_env(env, var, value) =
  Binding {var = var; value = value; next = env}

let rec eval_expr(expr, env) =
  raise Not_implemented
	  
let rec eval_program(prog, env) =
  match prog with
  | VarDef {var = var; value = value; next = rest} ->
     raise Not_implemented
  | Expr expr ->
     eval_expr(expr, env)

let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.program Lexer.get_token lexbuf in
  let answer = eval_program(ast, EmptyEnv) in
  print_int answer;
  print_string "\n"
