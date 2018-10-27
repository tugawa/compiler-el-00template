{
  open Parser
  exception Lexer_error of string
}

let letter = ['a'-'z' 'A'-'Z' '_']
let digit = ['0'-'9']
let space = [' ' '\t' '\n']
let id = letter(digit|letter)*

rule get_token = parse
       | digit+      { NUM (int_of_string (Lexing.lexeme lexbuf)) }
       | id          { ID  (Lexing.lexeme lexbuf) }
       | '+'         { PLUS }
       | '-'         { MINUS }
       | '*'         { TIMES }
       | '/'         { DIV }
       | '('         { LP }
       | ')'         { RP }
       | '='         { EQ }
       | ';'         { SEMI }
       | eof         { EOF }
       | space       { get_token lexbuf }
       | _           { raise (Lexer_error ("Unknown token: "
					   ^ (Lexing.lexeme lexbuf))) }
  
