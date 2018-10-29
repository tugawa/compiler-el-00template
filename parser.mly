%{
  open Ast 
%}

%token<int> NUM
%token<string> ID
%token PLUS MINUS TIMES DIV LP RP EOF LS RS SEMI EQ INT

%type <Ast.expr> expr term factor
%type <Ast.program> program
			 
%start program

%%
program:
  | INT ID EQ NUM SEMI program  { VarDef {varname = $2; varvalue = $4; rest = $6} }
  | expr                { Expr $1 }
  ;

expr:
  | expr PLUS term      { Plus {lhs = $1; rhs = $3} }
  | expr MINUS term     { Minus {lhs = $1; rhs = $3} }
  | term                { $1 }
  ;

term:
  | term TIMES factor   { Times {lhs = $1; rhs = $3} }
  | term DIV factor     { Div {lhs = $1; rhs = $3} }
  | factor              { $1 }
  ;

factor:
  | ID                  { VarRef $1 }
  | NUM                 { Num $1 }
  | LP expr RP          { $2 }
  ;
