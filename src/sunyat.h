/*
 * Name        : sunyat.h
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

#ifndef _SUNYAT_H_
#define _SUNYAT_H_

#include <ncurses.h>
#include <stdint.h>

/*
 * On read:  0 if no key, key code otherwise
 * On write: character output w/ cursor adjust
 */
#define IO_TERMINAL     0xFF



#define SIZE_APP_MSG    70 //Probably pointless

/**
 * Brief:
 *      This will be the size of the ram.
 */
#define SIZE_APP_RAM    0xFF

/**
 *  Brief:
 *      This will be the max size allowed for any load rom file.
 */
#define SIZE_APP_ROM    SIZE_APP_RAM + SIZE_APP_MSG   //APP_ROM_SIZE (APP_MSG_SIZE + APP_RAM_SIZE)


//System Registers
/**
 *  Brief:
 *      This register will contain the current program counter.
 */
#define REG_PC  0

/**
 *  Brief:
 *      This is the register containing the 8 high bits of the currently
 *          loaded instruction.
 */
#define REG_IRH 1

/**
 * Brief:
 *      This is the register containing the 8 low bits of the currently
 *          loaded instruction.
 */
#define REG_IRL 2

/**
 *  Brief:
 *      This register will contain the current starting position of the
 *          register window.
 */
#define REG_WIN 3

/**
 *  Brief:
 *      FILL IN
 */
#define REG_SP  4

/**
 *  Brief:
 *      This is the number of system registers.
 *          It will be used to figure out where the general purpose registers
 *          start.
 */
#define NUM_SYS_REG 5 //Number of system registers (0-4) used for referencing GPRs starting at 0.


//General Purpose Registars

/**
 *  Brief:
 *      This is the number of general purpose registers.
 */
#define NUM_GEN_REG 32

/**
 *  Brief:
 *      This is the total number of registers. It should be the total number
 *          of system registers plus the number of general purpose registers.
 */
#define SIZE_REG (NUM_SYS_REG + NUM_GEN_REG)

/**
 *  Brief:
 *      This is the starting point of the general purpose registers.
 */
#define REG_GEN_START NUM_SYS_REG

/**
 *  Brief:
 *      This is the ending index of the general purpose registers.
 */
#define REG_GEN_END SIZE_REG - 1

/**
 *  Brief:
 *      This is the size of the register window.
 */
#define SIZE_WIN 8

/**
 *  Brief:
 *      This is the greatest index that the start of the register window
 *          can be.
 */
#define MAX_WIN_INDEX SIZE_REG - SIZE_WIN





//opcodes

/*OPCODE 0: MOV (Register to Register)-----------------------------------
 *  Use:	MOV Reg_A Reg_B
 *  Brief:	Loads the immediate value into reg_A
 *
 *	Affected Flags: None
 */
#define OPCODE_MOV_RR   0
//-----------------------------------------------------------------------

/*OPCODE 1: MOV (Immediate To Register)----------------------------------
 *  Use:	MOV Reg_A Reg_B
 *  Brief:	Copies the value in reg_B into reg_A
 *
 *	Affected Flags: None
 */
#define OPCODE_MOV_RI   1
//-----------------------------------------------------------------------

/*OPCODE 2: ADD (Register to Register)-----------------------------------
 *  Use:	ADD Reg_A Reg_B
 *  Brief:	Adds reg_B to reg_A, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_ADD_RR   2
//-----------------------------------------------------------------------

/*OPCODE 3: MOV (Immediate To Register)----------------------------------
 *  Use:	ADD Reg_A Imm
 *  Brief:	Adds immediate to reg_A, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_ADD_RI   3
//-----------------------------------------------------------------------

/*OPCODE 4: SUB (Register to Register)-----------------------------------
 *  Use:	SUB Reg_A Reg_B
 *  Brief:	Subtracts reg_B from reg_A, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_SUB_RR   4
//-----------------------------------------------------------------------

/*OPCODE 5: MUL (Register to Register)-----------------------------------
 *  Use:	MUL Reg_A Reg_B
 *  Brief:	Multiply reg_B and reg_A, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_MUL_RR   5
//-----------------------------------------------------------------------

/*OPCODE 6: MUL (Immediate to Register)----------------------------------
 *  Use:	MUL Reg_A Imm
 *  Brief:	Multiply reg_B and Imm, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_MUL_RI   6
//-----------------------------------------------------------------------

/*OPCODE 7: DIV (Register to Register)-----------------------------------
 *  Use:	DIV Reg_A Reg_B
 *  Brief:	Divides Reg_A by Reg_B, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_DIV_RR   7
//-----------------------------------------------------------------------

/*OPCODE 8: DIV (Immediate to Register)----------------------------------
 *  Use:	DIV Reg_A Imm
 *  Brief:	Divides Reg_A by Imm, storing the result in reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_DIV_RI   8
//-----------------------------------------------------------------------

/*OPCODE 9: CMP (Register to Register)-----------------------------------
 *  Use:	CMP Reg_A Reg_B
 *  Brief:	Compares the two register values via subtraction but does not
 *			store the result. However, the flags are set based on the result
 *			of the subtraction.
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_CMP_RR   9
//-----------------------------------------------------------------------

/*OPCODE 10: CMP (Immediate to Register)---------------------------------
 *  Use:	CMP Reg_A Imm
 *  Brief:	Compares the register value and immediate via subtraction
 *			but does not store the result. However, the flags are set based
 *			on the result of the subtraction.
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_CMP_RI   10
//-----------------------------------------------------------------------

/*OPCODE 11: JMP --------------------------------------------------------
 *  Use:	JMP !address
 *  Brief:	Jump (branch) unconditionally to the code beginning at
 *			address. Sets the PC to address. The address will typically be
 *			provided as a label, but can be written as an immediate, as
 *			well.
 *
 *	Affected Flags: None
 */
#define OPCODE_JMP_M    11
//-----------------------------------------------------------------------

/*OPCODE 12: JEQ --------------------------------------------------------
 *  Use:	JEQ !address
 *  Brief:	Jump (branch) to the code beginning at address if the previous
 *			CMP found an equality or if an ALU instruction's result was
 *			zero... in either case the Zero flag would be high. Sets the PC
 *			to address. The address will typically be provided as a label,
 *			but can be written as an immediate, as well.
 *
 *	Affected Flags: None
 */
#define OPCODE_JEQ_M    12
//-----------------------------------------------------------------------

/*OPCODE 13: JNE --------------------------------------------------------
 *  Use:	JNE !address
 *  Brief:	Jump (branch) to the code beginning at address if the previous
 *			CMP found an inequality or if an ALU instruction's result was
 *			not zero... in either case the Zero flag would be low. Sets the
 *			PC to address. The address will typically be provided as a
 *			label, but can be written as an immediate, as well.
 *
 *	Affected Flags: None
 */
#define OPCODE_JNE_M    13
//-----------------------------------------------------------------------

/*OPCODE 14: JGR --------------------------------------------------------
 *  Use:	JGR !address
 *  Brief:	Jump (branch) to the code beginning at address if the previous
 *			CMP found the left operand to be greater than the right or if an
 *			ALU instruction's result was positive but not zero... in either
 *			case the Zero flag would be low and the Sign flag low. Sets the
 *			PC to address. The address will typically be provided as a
 *			label, but can be written as an immediate, as well.
 *
 *	Affected Flags: None
 */
#define OPCODE_JGR_M    14
//-----------------------------------------------------------------------

/*OPCODE 15: JGR --------------------------------------------------------
 *  Use:	JLS !address
 *  Brief:	Jump (branch) to the code beginning at address if the previous
 *			CMP found the left operand to be less than the right or if an
 *			ALU instruction's result was negative... in either case the Sign
 *			flag would be high. Sets the PC to address. The address will
 *			typically be provided as a label, but can be written as an
 *			immediate, as well.
 *
 *	Affected Flags: None
 */
#define OPCODE_JLS_M    15
//-----------------------------------------------------------------------

/*OPCODE 16: CALL -------------------------------------------------------
 *  Use:	CALL !address
 *  Brief:	Call function beginning at address. This pushes the address
 *			after the CALLing line of code to the system stack, and then
 *			sets the PC to address. The address will typically be provided
 *			as a label, but can be written as an immediate, as well.
 *
 *	Affected Flags: None
 */
#define OPCODE_CALL_M   16
//-----------------------------------------------------------------------

/*OPCODE 17: RET --------------------------------------------------------
 *  Use:	RET
 *  Brief:	Returns from a function call. This pops the top of the system
 *			stack into the PC... presuming this was the address pushed to
 *			the stack by a previous CALL. RETurning when the stack is
 *			empty is the signal to halt the VM and print the total number
 *			of clock cycles executed by the application.
 *
 *	Affected Flags: None
 */
#define OPCODE_RET      17
//-----------------------------------------------------------------------

/*OPCODE 18: AND (Register to Register) ---------------------------------
 *  Use:	AND Reg_A Reg_B
 *  Brief:	Perform a bitwise AND on reg_A and reg_B, storing the result in
 *			reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_AND_RR   18
//-----------------------------------------------------------------------

/*OPCODE 19: AND (Immediate to Register) --------------------------------
 *  Use:	AND Reg_A Imm
 *  Brief:	Perform a bitwise AND on reg_A and Imm, storing the result in
 *			reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_AND_RI   19
//-----------------------------------------------------------------------

/*OPCODE 20: OR (Register to Register) ----------------------------------
 *  Use:	OR Reg_A Reg_B
 *  Brief:	Perform a bitwise OR on reg_A and reg_B, storing the result in
 *			reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_OR_RR    20
//-----------------------------------------------------------------------

/*OPCODE 21: OR (Immediate to Register) ---------------------------------
 *  Use:	OR Reg_A Imm
 *  Brief:	Perform a bitwise OR on reg_A and Imm, storing the result in
 *			reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_OR_RI    21
//-----------------------------------------------------------------------

/*OPCODE 22: XOR (Register to Register) ---------------------------------
 *  Use:	XOR Reg_A Reg_B
 *  Brief:	Perform a bitwise XOR on reg_A and Imm, storing the result in
 *			reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_XOR_RR   22
//-----------------------------------------------------------------------

/*OPCODE 23: XOR (Immediate to Register) --------------------------------
 *  Use:	XOR Reg_A Imm
 *  Brief:	Perform a bitwise XOR on reg_A and Imm, storing the result in
 *			reg_A
 *
 *	Affected Flags: Zero and Sign
 */
#define OPCODE_XOR_RI   23
//-----------------------------------------------------------------------

/*OPCODE 24: LOAD -------------------------------------------------------
 *  Use:	LOAD Reg_A !Address
 *  Brief:	Loads (copies) a value from the given memory address into
 *			reg_A.
 *
 *	Affected Flags: None
 */
#define OPCODE_LOAD_RM  24
//-----------------------------------------------------------------------

/*OPCODE 25: LOADP ------------------------------------------------------
 *  Use:	LOADP Reg_A Reg_B
 *  Brief:	Loads (copies) a value from the memory address in reg_B into
 *	a reg_A.
 *
 *	Affected Flags: None
 */
#define OPCODE_LOADP_RR 25
//-----------------------------------------------------------------------

/*OPCODE 26: STOR -------------------------------------------------------
 *  Use:	STOR !Address Reg_A
 *  Brief:	Stores (copies) the value from reg_A to the given memory
 *			address.
 *
 *	Affected Flags: None
 */
#define OPCODE_STOR_MR  26
//-----------------------------------------------------------------------

/*OPCODE 27: STORP ------------------------------------------------------
 *  Use:	STORP Reg_A Reg_B
 *  Brief:	Stores (copies) a value from reg_B into the memory address in
 *			reg_A.
 *
 *	Affected Flags: None
 */
#define OPCODE_STORP_RR 27
//-----------------------------------------------------------------------

/*OPCODE 28: PUSH -------------------------------------------------------
 *  Use:	PUSH Reg_A
 *  Brief:	Pushes (copies) the value in reg_A to the top of the system
 *			stack. This is accomplished by first decrementing SP and then
 *			storing the at the new address in SP.
 *
 *	Affected Flags: None
 */
//#define OPCODE_PUSH_R   28
//-----------------------------------------------------------------------

/*OPCODE 29: POP --------------------------------------------------------
 *  Use:	POP Reg_A
 *  Brief:	Pops (copies) the value at the top of the system stack into
 *			reg_A. This is accomplished by first copying the value at the
 *			address in SP and then incrementing SP.
 *
 *	Affected Flags: None
 */
//#define OPCODE_POP_R    29
//-----------------------------------------------------------------------


/**OPCODE 28
 *  USE:    NONE
 *  Brief:  This replaces push and pop, if the low bits are zero then
 *          it's a push, if not pop.
 *
 *	Affected Flags: ???
 */
#define OPCODE_STACKER_R 28



/*OPCODE 29: SWR --------------------------------------------------------
 *  Use:	SWR Imm
 *  Brief:	Copies value of Imm into the "Window" System Register. For Register Windowing.
 *
 *	Affected Flags: None
 */
#define OPCODE_SWR_I	29
//-----------------------------------------------------------------------

/*OPCODE 30: AWR --------------------------------------------------------
 *  Use:	AWR Imm
 *  Brief:	Increments the "Window" System Register by Imm. For Register Windowing.
 *
 *	Affected Flags: None
 */
#define OPCODE_AWR_I	30
//-----------------------------------------------------------------------

/*OPCODE 31: AUX --------------------------------------------------------
 *  Use:	AUX Imm
 *
 *	0: Save State
 *	1: Pause
 *	2:
 *	3
 *	4
 *	5
 *	6
 *	7
 *
 *	Affected Flags: None
 */
#define OPCODE_AUX_I	31
//-----------------------------------------------------------------------


//Exit Code Errors

/**
 *  Brief:
 *      This will get thrown if the system wasn't given any rom file, or
 *          such, to load in.
 */
#define EXT_ERR_NO_FILE_ARG       1

/**
 *  Brief:
 *      This will get thrown if the ROM provided is to large.
 */
#define EXT_ERR_ROM_BIG           2

/**
 *  Brief: //Look at sunyat.c:213
 *      This will get thrown if after reading t
 */
#define EXT_ERR_BYTE_SIZE         3

/**
 *  Brief:
 *      The provided file could not be open.
 */
#define EXT_ERR_FILE_NOT_OPEN     4

/**
 *  Brief:
 *      Will be thrown when theres an error in ncurses.
 */
#define EXT_ERR_NCURSES			5 //This should be expand to cover all ncurses errors.

/**
 *	Brief:
 *		Defines size of a savestate file.
 *
 */
#define SIZE_APP_SAVESTATE		SIZE_APP_RAM + SIZE_REG



/**
 *  Brief:
 *      This is the save state command line switch.
 */
#define SAVE_STATE_SWITCH   "-s\0"

/**
 *  Brief:
 *      This is the debugger switch.
 */
#define DEBUGGER_SWITCH     "-d\0"


#ifndef true
#define true TRUE
#endif /* true */

#ifndef false
#define false FALSE
#endif /* false */

#define STARTUP_PAUSE       3

/**
 *  Brief:
 *      Use this in order to get a specific register.
 *
 *  Parameters:
 *      imm : int
 *
 *  Returns : A number between NUM_SYS_REG and SIZE_REG
 */

#define HIGH_OR_LOW(imm)    (((0 > imm) * (imm - (NUM_GEN_REG * (imm / NUM_GEN_REG)))) + ((0 < imm) * (NUM_GEN_REG * (imm / NUM_GEN_REG) + imm) % 32))
#define GET_GRWP(imm)       ((((sunyat_regs[REG_WIN] - NUM_SYS_REG) + (NUM_GEN_REG + HIGH_OR_LOW(imm))) % NUM_GEN_REG) + NUM_SYS_REG)

//Function Prototypes...
int start_sunyat(char *rom, int lState, bool lDebug);
uint8_t get_opcode (uint8_t highBits) ;
uint8_t get_dreg (uint8_t highBits) ;
uint8_t get_sreg (uint8_t lowBits) ;
uint8_t get_mem (uint8_t lowBits) ;
int8_t get_imm (int8_t lowBits) ;

static void sunyat_execute (WINDOW *win);
static void set_flags (int8_t result);



#endif /* _SUNYAT_H_ */
