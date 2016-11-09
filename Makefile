# Name        : Makefile
# Author      : William "Amos" Confer
#
# License     : Copyright (c) 2008--2014 William "Amos" Confer
#
#    Permission is hereby granted, free of charge, to any person obtaining a
#    copy of this software and associated documentation files (the "Software"),
#    to deal in the Software without restriction, including without limitation
#    the rights to use, copy, modify, merge, publish, distribute, sublicense,
#    and/or sell copies of the Software, and to permit persons to whom the
#    Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in
#    all copies or substantial portions of the Software.;
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
#    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#    DEALINGS IN THE SOFTWARE.

all: sunyat-asm

sunyat-asm: lemon sunyat-asm.c lex.yy.c src/token.h src/sunyat.h
	gcc -g -o bin/sunyat-asm src/lex.yy.c src/sunyat-asm.c
	
lemon:
	gcc -o bin/lemon ./tools/lemon/lemon.c
	
lex.yy.c: src/sunyat-asm.lex
	flex src/sunyat-asm.lex
	mv lex.yy.c src/
	
sunyat-asm.h:
sunyat-asm.c: src/sunyat-asm.y sunyat-asm.h lemon
	./bin/lemon T=tools/lemon/lempar.c src/sunyat-asm.y
	
clean:
	rm -f ./bin/lemon ./bin/sunyat-asm src/lex.yy.c src/sunyat-asm.c src/sunyat-asm.out src/sunyat-asm.h
	find . -name "*.rom" -print0 | xargs -0 rm -f
