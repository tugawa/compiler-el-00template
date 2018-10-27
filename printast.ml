let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.program Lexer.get_token lexbuf in
  print_string ((Ast.sexp_of_program ast) ^ "\n")
