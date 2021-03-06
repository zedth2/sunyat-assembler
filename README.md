# sunyat-assembler
This is the original SunyAT assembler written in C. This version was originally written by William "Amos" Confer and further modified by me, Zachary Harvey. This version is built to work with the window registering version of the [SunyAT](https://fossil.cs.sunyit.edu/cgi-bin/fossil/sunyat_wr.fossil/wiki?name=SUNYAT+w/+Register+Windows) and is being put here to be used for further testing with the SunyAT Rust version.

## Files

    * sunyat-asm.lex 
     		lexical/token analyzer... uses flex
    * sunyat-asm.y 
     		grammar/semantic analyser... uses the Lemon parser
            generator whose source is included (lemon.c and lempar.c)
    * token.h 
     		definition of the assembler token structure shared 
            between the lexer and parser
## Building

You'll need make, GCC, and flex. [Flex](https://github.com/westes/flex) can be found at this link. [Lemon](https://www.sqlite.org/src/doc/trunk/doc/lemon.html) is also a dependency but it's source file is carried in the repository.

#### Arch Linux Instructions (Not fully tested)

```sh
git clone https://github.com/zedth2/sunyat-assembler.git
pacman -S base-devel flex
cd sunyat-assembler
make
./bin/sunyat-asm examples/protoShell.asm
```
