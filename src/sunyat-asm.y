%include {
	/*
	 * Name        : sunyat-asm.y
	 * Author      : William "Amos" Confer
	 *
     * License     : Copyright (c) 2008--2014 William "Amos" Confer
     *
     *    Permission is hereby granted, free of charge, to any person obtaining a
     *    copy of this software and associated documentation files (the "Software"),
     *    to deal in the Software without restriction, including without limitation
     *    the rights to use, copy, modify, merge, publish, distribute, sublicense,
     *    and/or sell copies of the Software, and to permit persons to whom the
     *    Software is furnished to do so, subject to the following conditions:
     *
     *    The above copyright notice and this permission notice shall be included in
     *    all copies or substantial portions of the Software.;
     *
     *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     *    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     *    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
     *    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     *    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
     *    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
     *    DEALINGS IN THE SOFTWARE.
	 */
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <assert.h>
    #include <stdint.h>

	#include "token.h"
	#include "sunyat.h"

	#define MAX_CNT 256

	extern int assembler_pass;	/* sunyat-asm.lex */
	extern char* filename;	/* sunyat-asm.lex */

	uint8_t high_opcode;
	uint8_t high_reg;
	uint8_t low;

	uint8_t msg_data [SIZE_APP_MSG];
	uint8_t ram_data [SIZE_APP_RAM];
	uint8_t address = 0;

	char *variables [MAX_CNT];
	uint8_t variable_addrs [MAX_CNT];
	int variable_cnt = 0;

	char *labels [MAX_CNT];
	uint8_t label_addrs [MAX_CNT];
	int label_cnt = 0;

	char *constants [MAX_CNT];
	uint8_t constant_values [MAX_CNT];
	int constant_cnt = 0;

	int errors_found = 0;

	void message (int err, Token t, const char *primary_err, const char *optional_err) {
		if (err) {
			fprintf (stderr, "Error, ");
		}
		else {
			fprintf (stderr, "Warning, ");
		}
		fprintf (stderr, "line %d:%d - %s", t.line_num, t.char_pos, primary_err);
		if (optional_err != NULL) {
			fprintf (stderr, ": \"%s\"", optional_err);
		}
		fprintf (stderr, "\n");
	}

	void error (Token t, const char *primary_err, const char *optional_err) {
		errors_found++;
		message (1, t, primary_err, optional_err);
	}

	void warning (Token t, const char *primary_warning, const char *optional_warning) {
		message (0, t, primary_warning, optional_warning);
	}

	int variable_pos (const char* s) {
		int result = 0;
		int found = 0;
		while (result < variable_cnt) {
			if (strcmp (variables [result], s) == 0) {
				found = 1;
				break;
			}
			result++;
		}
		if (!found) {
			result = -1;
		}
		return result;
	}

	int constant_pos (const char* s) {
		int result = 0;
		int found = 0;
		while (result < constant_cnt) {
			if (strcmp (constants [result], s) == 0) {
				found = 1;
				break;
			}
			result++;
		}
		if (!found) {
			result = -1;
		}
		return result;
	}

	int label_pos (const char* s) {
		int result = 0;
		int found = 0;
		while (result < label_cnt) {
			if (strcmp (labels [result], s) == 0) {
				found = 1;
				break;
			}
			result++;
		}
		if (!found) {
			result = -1;
		}
		return result;
	}

	void store_instruction () {
		ram_data [address++] = (high_opcode << 3) | (high_reg);
		ram_data [address++] = low;
	}

}

%start_symbol program

%token_type {Token}
%token_prefix {TOKEN_}

%syntax_error {
	fprintf (stderr, "Syntax error, line %d:%d - \"%s\"\n", TOKEN.line_num
	, TOKEN.char_pos, TOKEN.long_str);
	errors_found++;
}

%parse_failure {
	fprintf (stderr, "Giving up... the parser has gotten completely lost :-x\n");
}

%stack_overflow {
	fprintf (stderr, "Giving up... parser stack overflow :-x\n");
}

program ::= lines. {
	if (errors_found == 0) {
		if (assembler_pass == 2) {
			FILE *outfile = fopen (filename, "wb");
			if (outfile == NULL) {
				fprintf (stderr, "Error - could not open output file for writing.\n");
			}
			else {
				fwrite (msg_data, sizeof (char), SIZE_APP_MSG, outfile);
				fwrite (ram_data, sizeof (char), SIZE_APP_RAM, outfile);
				fclose (outfile);
			}
		}
	}
	else {
		fprintf (stderr, "%d errors found.  No output file generated.\n", errors_found);
	}
}
lines ::= lines line EOL.
lines ::= lines error EOL.
lines ::= .

line ::= message_line.
line ::= address_line.
line ::= variable_line.
line ::= constant_line.
line ::= label_line.
line ::= code_line.{
	if (assembler_pass == 1) {
		address += 2;
	}
}
line ::= .

message_line ::= MESSAGE(msg).	{
	if (assembler_pass == 1) {
		if (msg.token_str == NULL) {

			warning (msg, ".MESSAGE string is empty... ignoring.", NULL);
		}
		else if (strlen (msg.token_str) > SIZE_APP_MSG) {
			char s[100];
			sprintf (s, ".MESSAGE string longer than %d characters.", SIZE_APP_MSG);
			warning (msg, s, NULL);
			memcpy (msg_data, msg.token_str, SIZE_APP_MSG);
		}
		else {
			int i;
			memcpy (msg_data, msg.token_str, strlen (msg.token_str));
			for (i = strlen (msg.token_str); i < SIZE_APP_MSG; i++) {
				msg_data [i] = '\0';
			}
		}
	}
}

address_line ::= ADDR_DIRECTIVE immediate(immed).	{
	if ((uint8_t)immed.data >= SIZE_APP_RAM) {
		if (assembler_pass == 1) {
			warning (immed, ".ADDRESS must be no greater than 253 (inclusive)... ignoring", NULL);
		}
	}
	else {
		address = immed.data;
	}
}
immediate(val) ::= IMMEDIATE(immed). {
	memcpy (&val, &immed, sizeof (Token));
}
immediate(val) ::= IDENTIFIER(const). {
//	if (assembler_pass == 2) {
		int pos = constant_pos (const.token_str);
		if (pos < 0) {
			error (const, "No such constant defined.", const.token_str);
			val.data = 0x00;
		}
		else {
			val.data = constant_values [pos];
		}
//	}
}
immediate(val) ::= LABEL_DIRECTIVE IDENTIFIER(id). {
	if (assembler_pass == 2) {
		int pos = label_pos (id.token_str);
		if (pos < 0) {
			error (id, "No such label defined.", id.token_str);
			val.data = 0x00;
		}
		else {
			val.data = label_addrs [pos];
		}
        //printf("DOING LABEL %s %X \n", id.token_str, label_addrs [pos]) ;
	}
}
immediate(val) ::= CHARACTER(ch). {
	//if (assembler_pass == 2) {
		val.data = ch.data;
	//}
}

variable_line ::= VAR_DIRECTIVE IDENTIFIER(id) var_value(val).	{
	if (assembler_pass == 1) {
		int pos = variable_pos (id.token_str);
		if (pos >= 0) {
			char s[100];
			sprintf (s, "Variable already defined at address 0x%X.", variable_addrs [pos]);
			error (id, s, variables [pos]);
		}
		else if (variable_cnt >= MAX_CNT) {
			error (id, "Too many variables defined.", id.token_str);
		}
		else if ((pos = constant_pos (id.token_str)) >= 0 ) {
			char s[100];
			sprintf (s, "Variable name inuse by constant with value 0x%X.", constant_values [pos]);
			error (id, s, NULL);
		}
		else {
			/* new variable defined */
			int len = strlen (id.token_str) + 1;
			variables [variable_cnt] = malloc (sizeof (char) * len);
			strcpy (variables [variable_cnt], id.token_str);
			variable_addrs [variable_cnt] = address;

			variable_cnt++;
			address++;
		}
	}
	else {
        ram_data [address] = val.data;
		address++;
	}
}
var_value(val) ::= immediate(immed).	{
	val.data = immed.data;
}
var_value(val) ::= .	{
	val.data = 0x00;
}

constant_line ::= CONST_DIRECTIVE IDENTIFIER(id) immediate(immed). {
	if (assembler_pass == 1) {
		int pos = constant_pos (id.token_str);
		if (pos >= 0) {
			char s[100];
			sprintf (s, "Constant already defined as 0x%X.", constant_values [pos]);
			error (id, s, NULL);
		}
		else if (constant_cnt >= MAX_CNT) {
			error (id, "Too many constants defined.", id.token_str);
		}
		else if ((pos = variable_pos (id.token_str)) >= 0 ) {
			char s[100];
			sprintf (s, "Constant name inuse by variable at address 0x%X.", variable_addrs [pos]);
			error (id, s, NULL);
		}
		else {
			/* new const defined */
			int len = strlen (id.token_str) + 1;
			constants [constant_cnt] = malloc (sizeof (char) * len);
			strcpy (constants [constant_cnt], id.token_str);
			constant_values [constant_cnt] = immed.data;
			constant_cnt++;
		}
	}
}

label_line ::= LABEL_DIRECTIVE IDENTIFIER(id). {
	if (assembler_pass == 1) {
		int pos = label_pos (id.token_str);
		if (pos >= 0) {
			char s[100];
			sprintf (s, "Label already defined at address 0x%X.", label_addrs [pos]);
			error (id, s, id.token_str);
		}
		else if (label_cnt >= MAX_CNT) {
			error (id, "Too many labels defined.", id.token_str);
		}
		else {
			/* new label defined */
			int len = strlen (id.token_str) + 1;
			labels [label_cnt] = malloc (sizeof (char) * len);
			strcpy (labels [label_cnt], id.token_str);
			label_addrs [label_cnt] = address;
			label_cnt++;
		}
	}
}

code_line ::= NOP.{
	if (assembler_pass == 2) {
		/* same as JMP to next line */
		high_opcode = OPCODE_JMP_M;
		high_reg = 0;
		low = address + 2;
		store_instruction ();
	}
}

code_line ::= MOV REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_MOV_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= MOV REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_MOV_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= ADD REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_ADD_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= ADD REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_ADD_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= SWR immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_SWR_I;
		high_reg = 0 ;
		if (MAX_WIN_INDEX < src.data) {
            error (src, "The register window location you gave was to large.", src.token_str) ;
        } else if (0 > src.data) {
            error (src, "SWR only accepts positive integers.", src.token_str) ;
        }
        low = (uint8_t)src.data ;
		store_instruction ();
	}
}

code_line ::= AWR immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_AWR_I;
		high_reg = 0 ; //dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}


code_line ::= SUB REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_SUB_RR;
		high_reg = dst.data;
		low = src.data;
		store_instruction ();
	}
}

    //OPCODE_SUB_RI + OPCODE_NEG_R were removed to make room for OPCODE_SWR + AWR (windowing)
	// They were put back in as pseudo-instructions at a later point.
code_line ::= SUB REGISTER(dst) immediate(src).{ //THIS IS A PSEUDO-INSTRUCTION
	if (assembler_pass == 2) {
		high_opcode = OPCODE_ADD_RI;
		high_reg = dst.data;
		low = (uint8_t)(-src.data);
		store_instruction ();
	}
}

code_line ::= MUL REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_MUL_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= MUL REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_MUL_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= DIV REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_DIV_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= DIV REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_DIV_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= CMP REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_CMP_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= CMP REGISTER(dst) immediate(src). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_CMP_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= JMP memory(addr).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_JMP_M;
		high_reg = 0;
		low = addr.data;
		store_instruction ();
	}
}

code_line ::= JEQ memory(addr). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_JEQ_M;
		high_reg = 0;
		low = (uint8_t)addr.data;
		store_instruction ();
	}
}

code_line ::= JNE memory(addr). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_JNE_M;
		high_reg = 0;
		low = (uint8_t)addr.data;
		store_instruction ();
	}
}

code_line ::= JGR memory(addr). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_JGR_M;
		high_reg = 0;
		low = (uint8_t)addr.data;
		store_instruction ();
	}
}

code_line ::= JLS memory(addr). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_JLS_M;
		high_reg = 0;
		low = (uint8_t)addr.data;
		store_instruction ();
	}
}

code_line ::= CALL memory(addr). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_CALL_M;
		high_reg = 0;
		low = (uint8_t)addr.data;
		store_instruction ();
	}
}

code_line ::= RET. {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_RET;
		high_reg = 0;
		low = 0;
		store_instruction ();
	}
}

code_line ::= AND REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_AND_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= AND REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_AND_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= OR REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_OR_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= OR REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_OR_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= XOR REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_XOR_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= XOR REGISTER(dst) immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_XOR_RI;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= NOT REGISTER(dst).{
	if (assembler_pass == 2) {
		/* same as XOR REG 0xFF */
		high_opcode = OPCODE_XOR_RI;
		high_reg = dst.data;
		low = 0xFF;
		store_instruction ();
	}
}

// OPCODE_SUB_RI + OPCODE_NEG_R were removed to make room for OPCODE_SWR + AWR (windowing)
// They were put back in as pseudo-instructions at a later point.
code_line ::= NEG REGISTER(dst).{ //THIS IS A PSEUDO-INSTRUCTION
	if (assembler_pass == 2) {
		high_opcode = OPCODE_MUL_RI;
		high_reg = dst.data;
		low = -1;
		store_instruction ();
	}
}

code_line ::= LOAD REGISTER(dst) memory(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_LOAD_RM;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= LOADP REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_LOADP_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= STOR memory(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_STOR_MR;
		high_reg = src.data; /* src and dst are reverse in the encoding */
		low = (uint8_t)dst.data;
		store_instruction ();
	}
}

code_line ::= STORP REGISTER(dst) REGISTER(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_STORP_RR;
		high_reg = dst.data;
		low = (uint8_t)src.data;
		store_instruction ();
	}
}

code_line ::= PUSH REGISTER(dst). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_STACKER_R;
		high_reg = dst.data;
		low = 0;
		store_instruction ();
	}
}

code_line ::= POP REGISTER(dst). {
	if (assembler_pass == 2) {
		high_opcode = OPCODE_STACKER_R;
		high_reg = dst.data;
		low = 1;
		store_instruction ();
	}
}
//Auxiliary-----------------------------------------------------------------------
code_line ::= AUX immediate(src).{
	if (assembler_pass == 2) {
		high_opcode = OPCODE_AUX_I;
		high_reg = 0 ; //dst.data;
		if (src.data < 0 || src.data > 7) {
            error (src, "0-7 are acceptable values.", src.token_str) ;
        }
        low = (uint8_t)src.data ;
		store_instruction ();
	}
}
//Auxiliary-----------------------------------------------------------------------


memory(val) ::= IDENTIFIER(id). {
	if (assembler_pass == 2) {
		int pos = variable_pos (id.token_str);
		if (pos < 0) {
			/* not a var, check for const */
			pos = constant_pos (id.token_str);
			if (pos < 0) {
				error (id, "No such variable or constant defined.", id.token_str);
				val.data = 0x00;
			}
			else {
				val.data = constant_values [pos];
			}
		}
		else {
			val.data = variable_addrs [pos];
		}
	}
}
memory(val) ::= LABEL_DIRECTIVE IDENTIFIER(id). {
	if (assembler_pass == 2) {
		int pos = label_pos (id.token_str);
		if (pos < 0) {
			error (id, "No such label defined.", id.token_str);
			val.data = 0x00;
		}
		else {
			val.data = label_addrs [pos];
		}
	}
}
memory(val) ::= IMMEDIATE(immed).{
	val.data = immed.data;
}
