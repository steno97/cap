library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.ALL;
package myTypes is

	type aluOp is (
		NOP, ADDS, LLS, LRS, ADD, SUB, ANDR, ORR, XORR, SNE, SLE, SGE, BEQZ, BNEZ, SUBI, ANDI,
		ORI, XORI, SLLI, SRLI, SNEI, SLEI, SGEI, LW, SW,SUBU,SUBUI,ADDU,ADDUI,SRA1,SEQ,SLT,SGT,
		SLTU,SGTU,SGEU,LHI,JR,JALR,SRAI,SEQI,SLTI,SGTI,LB,LBU,LHU,SB,SLTUI,SGTUI,SGEUI --- to be completed
			);--SRA1,SRAI
	constant MEM_SIZE : integer := 62; 
	constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size
	constant numBit : integer :=  32; 
	constant REG_SIZE : integer :=  5;
	
 
end myTypes;

