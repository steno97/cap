library ieee;
use ieee.std_logic_1164.all;

package myTypes is

	type aluOp is (
		NOP, ADDS, LLS, LRS, ADD, SUB, ANDR, ORR, XORR, SNE, SLE, SGE, BEQZ, BNEZ, SUBI, ANDI,
		ORI, XORI, SLLI, SRLI, SNEI, SLEI, SGEI, LW, SW --- to be completed
			);
			
	constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

-- R-Type instruction -> FUNC field
	LLS : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010000";   	-- 				 func 15
	LRS : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010001";   	--  			func 16
   
	ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010010";    -- ADD RS1,RS2,RD 	func 17
    SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010011";    -- SUB RS1,RS2,RD 	func 18
	ANDR : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000010100";    -- AND RA,RB,RC  	func 19
	ORR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010101";   	-- OR RA,RB,RC 	func 20
	XORR : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000010110";   	-- xOR RA,RB,RC func 21
    SNE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010111";   	-- 				func 22
    SLE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011000";   	-- 				func 23
    SGE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011001";   	-- 				func 24
    

-- I-Type instruction -> OPCODE field
	NOP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "000000"; 	-- NOP 						opcode 0 
	BEQZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";    --               			opcode 1
	BNEZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";	--               			opcode 2
	ADDS : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";    -- ADDI1 RS1,RD,INP1  		opcode 3
	SUBI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100"; 	-- SUBI1 RA,RB,INP1			opcode 4
	ANDI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";	-- ANDI1 RA,RB,INP1			opcode 5
	ORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=   "000110";		-- ORI1 RA,RB,INP1		opcode 6
	XORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";		-- xORI1 RA,RB,INP1		opcode 7
	SSLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";		--               		opcode 8
	SRLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";		--             			opcode 9
	SNEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";		--               		opcode 10
    SLEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";		--               		opcode 11
    SGEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";		--               		opcode 12
	LW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=    "001101";		--               		opcode 13
	SW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=    "001110";		--               		opcode 14
 
end myTypes;

