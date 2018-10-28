PRINTAST_FILES = lexer.cmo parser.cmo ast.cmo printast.cmo
INTERP_FILES =  lexer.cmo parser.cmo ast.cmo interp.cmo
COMP_FILES =  lexer.cmo parser.cmo ast.cmo comp.cmo

all: printast interp comp

%.cmo: %.ml
	ocamlc -c $<

%.cmi: %.mli
	ocamlc -c parser.mli

parser.mli parser.ml: parser.mly
	ocamlyacc $<

lexer.ml: lexer.mll
	ocamllex $<

parser.cmo: parser.cmi
parser.cmi: ast.cmo
lexer.cmo: parser.cmo

printast: $(PRINTAST_FILES)
	ocamlc -o $@ $(PRINTAST_FILES)

interp: $(INTERP_FILES)
	ocamlc -o $@ $(INTERP_FILES)

comp: $(COMP_FILES)
	ocamlc -o $@ $(COMP_FILES)


clean:
	rm -f *.cmi *.cmo parser.ml parser.mli lexer.ml printast interp comp *~ #*
