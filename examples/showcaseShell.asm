;Author: Ben Foster
.constant	TERM 	0xFF
.constant	CR	0xD
.constant	LF	0xA


	jmp	!main
!cmdTable
	.variable	cmdTable0	!incReg0
	.variable	cmdTable1	!incReg1
	.variable	cmdTable2	!incReg2
	.variable	cmdTable3	!incReg3
	.variable	cmdTable4	!incReg4
	.variable	cmdTable5	!incReg5
	.variable	cmdTable6	!incReg6
	.variable	cmdTable7	!incReg7
	.variable	cmdTable8	!awrdown
	.variable	cmdTable9	!awrup

	.variable	cmdTable10	!savestate ;a
	;.variable	cmdTable11	!
	;.variable	cmdTable12	!
	;.variable	cmdTable13	!
	;.variable	cmdTable14	!
	;.variable	cmdTable15	!
	;.variable	cmdTable16	!
	;.variable	cmdTable17	!
	;.variable	cmdTable18	!
	;.variable	cmdTable19	!
	;.variable	cmdTable20	!
	;.variable	cmdTable21	!
	;.variable	cmdTable22	!
	;.variable	cmdTable23	!
	;.variable	cmdTable24	!
	;.variable	cmdTable25	!
	;.variable	cmdTable26	!
	;.variable	cmdTable27	!
	;.variable	cmdTable28	!
	;.variable	cmdTable29	!
	;.variable	cmdTable30	!
	;.variable	cmdTable31	!
	;.variable	cmdTable32	!
	;.variable	cmdTable33	!
	;.variable	cmdTable34	!
	;.variable	cmdTable35	!	;z

!crlf
	.variable	crlf0	CR
	.variable	crlf1	LF
	.variable	crlf2	0x00

!prompt
	.variable prompt0 '['
	.variable prompt1 'm'
	.variable prompt2 'e'
	.variable prompt3 '@'
	.variable prompt4 'S'
	.variable prompt5 'U'
	.variable prompt6 'N'
	.variable prompt7 'Y'
	.variable prompt8 'A'
	.variable prompt9 'T'
	.variable prompt10 ']'
	.variable prompt11 0x00

;-!main------------------------------------------------------------------------------------------
!main
	mov R0 !prompt
	call !print ;print the prompt
	call !get_character ;get a character (command) and executes it if it's 0-7
	call !print_line
	jmp !main ;back to the top
	!quit_shell
	ret
!main_end
;------------------------------------------------------------------------------------------------

;-!get_character---------------------------------------------------------------------------------
!get_character ;gc
	load R0 TERM
		cmp R0 0xFF ;Not just ncurses dumping stuff
		jeq !get_character

		cmp R0 0x30 ;The character '0'
		jls !get_character
		cmp R0 0x3A ;The character ':' (direclyt after 9 in ascii)
		jls !numberCmd ;user entered a value 0 - 9

		cmp R0 0x61 ;The character 'a'
		jls !get_character
		cmp R0 0x7A ;the character 'z'
		jls !letterCmd ;user entered a value a - z
		jgr !get_character

		!numberCmd
		add R0 -46	;get the cmd location from !cmdTable (starts at mem loc 2)
		loadp R1 R0
		push R1
		ret			;go to the cmd location. Cmd executes and jumps back to get_character

		!letterCmd
		add R0 -85	;get the cmd location from !cmdTable (starts at mem loc 2)
		loadp R1 R0
		push R1
		ret			;go to the cmd location

!get_character_end
ret
;------------------------------------------------------------------------------------------------

;-!print-----------------------------------------------------------------------------------------
!print
	!while_PP
		loadp R1 R0 ;Load character at address R0 into R1. R0 is an array pointer.
		cmp R1 0x00
		jeq !while_PP_end ;If the character is 0x00 stop printing.
		stor TERM R1 ;print character
		add R0 1 ;Increment array pointer
		jmp !while_PP ;keep printing
	!while_PP_end
	ret
!print_end
;------------------------------------------------------------------------------------------------

;-!print_line------------------------------------------------------------------------------------
!print_line
	mov R0 !crlf
	call !print
	ret
!print_line_end
;------------------------------------------------------------------------------------------------

;-Command Execution------------------------------------------------------------------------------
;0-9
!incReg0
	add R0 1
	jmp !get_character
!incReg1
	add R1 1
	jmp !get_character
!incReg2
	add R2 1
	jmp !get_character
!incReg3
	add R3 1
	jmp !get_character
!incReg4
	add R4 1
	jmp !get_character
!incReg5
	add R5 1
	jmp !get_character
!incReg6
	add R6 1
	jmp !get_character
!incReg7
	add R7 1
	jmp !get_character

!awrdown	;8
	awr -1
	jmp !get_character

!awrup	;9
	awr 1
	jmp !get_character

;a-z
!savestate ;a
	aux 0 ;savestate
	jmp !get_character


;------------------------------------------------------------------------------------------------
