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

let insn(operator, operand) =
  "\t" ^ operator ^ " " ^ operand ^ "\n"

let rec compile_program(prog, env, offset) =
  match prog with
  | VarDef {var = var; value = value; next = rest} ->
     let env = update_env(env, var, offset) in
     insn("pushq", "$" ^ (string_of_int value)) ^
       (compile_program(rest, env, (offset - 8)))
  | Expr expr ->
     compile_expr expr env
and compile_expr expr env =
  raise Not_implemented
  
let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.program Lexer.get_token lexbuf in
  let code = compile_program(ast, EmptyEnv, -8) in
  print_string ".text\n";
  print_string "\t.global _main\n";
  print_string "_main:\n";
  print_string (insn("pushq", "%rbp"));
  print_string (insn("movq", "%rsp, %rbp"));
  print_string (code ^ "\n");
  print_string (insn("popq", "%rax"));
  print_string (insn("movq", "%rbp, %rsp"));
  print_string (insn("popq", "%rbp"));
  print_string (insn("ret", ""))
