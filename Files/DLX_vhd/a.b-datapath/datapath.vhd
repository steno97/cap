--DATAPATH DLX GROUP_42
--stage 1: FETCH F
--stage 2: DECODE D
--stage 3: EXECUTE E
--stage 4: MEMORY M
--stage 5: WRITE BACK WB
library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use WORK.constants.all;
--use IEEE.std_logic_unsigned.all;
--ADD TO GLOBALS: REG_BIT=5, OP_BIT=6, BIT_DLX=32

entity DATAPTH is
Generic (NBIT: integer:= BIT_DLX);
	Port (	
		CLK:	in	std_logic;
		RST:	in	std_logic;
		PC: in	std_logic_vector(NBIT-1 downto 0);
		IR: in	std_logic_vector(NBIT-1 downto 0);
		--DTPTH_OUT: out std_logic_vector(NBIT-1 downto 0);
		
		--cu signals
		EN0: in	std_logic;
		signed_op: in	std_logic;
		RF1: in	std_logic;
		RF2: in	std_logic;
		WF1: in	std_logic; --sel WB
		EN1: in	std_logic;
		S1: in	std_logic; --sel A
		S2: in	std_logic; --sel B
		EN2: in	std_logic;
		jump_en:in	std_logic;
		branch_cond: in	std_logic;
		RM: in	std_logic;
		WM: in	std_logic;
		EN3: in	std_logic;
		S3: in	std_logic;
		--alu signals
		instruction_alu:  in TYPE_OP;
		
		--data memory signals
		DATA_MEM_ADDR: out	std_logic_vector(NBIT-1 downto 0);
		DATA_MEM_IN: out	std_logic_vector(NBIT-1 downto 0);
		DATA_MEM_OUT: in	std_logic_vector(NBIT-1 downto 0);
		DATA_MEM_ENABLE: out	std_logic;
		DATA_MEM_RM: out	std_logic; --segnale unico con WM?
		DATA_MEM_WM: out	std_logic);
end DATAPTH;


architecture STRUCTURAL of DATAPTH is 
--components: 
component MUX21_GENERIC is
	generic (NBIT: integer:=BIT_DLX);
	Port (	
		A:	In	std_logic_vector(NBIT-1 DOWNTO 0);
		B:	In	std_logic_vector(NBIT-1 DOWNTO 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 DOWNTO 0));
end component;

component FF is
	port (
		CLK, RESET, EN, D : in std_logic;
		Q : out std_logic
	);
end component;


component regFFD is
Generic (NBIT: integer:= BIT_DLX);
	Port (	
		CK:	In	std_logic;
		RESET:	In	std_logic;
		ENABLE: In 	std_logic;
		D:	In	std_logic_vector(NBIT-1 downto 0);
		Q:	Out	std_logic_vector(NBIT-1 downto 0));
end component;

component IR_DECODE is 
Generic (NBIT: integer:= BIT_DLX;opBIT: integer:= OP_BIT; regBIT: integer:= REG_BIT ); 
	Port (	
		IR_26:	in	std_logic_vector(NBIT-opBIT-1 downto 0); 
		OPCODE:	in	std_logic_vector(opBIT-1 downto 0); 
		is_signed:	in	std_logic;
		RS1: out	std_logic_vector(regBIT-1 downto 0); 
		RS2: out	std_logic_vector(regBIT-1 downto 0); 
		RD: out	std_logic_vector(regBIT-1 downto 0); 
		IMMEDIATE: out	std_logic_vector(NBIT-1 downto 0)
		);
end component;

component register_file is
 port ( 
	 CLK: 		IN std_logic;
	 RESET: 		IN std_logic;
	 ENABLE: 	IN std_logic;
	 RD1: 		IN std_logic;
	 RD2: 		IN std_logic;
	 WR: 			IN std_logic;
	 ADD_WR: 	IN std_logic_vector(REG_BIT-1 downto 0);
	 ADD_RD1: 	IN std_logic_vector(REG_BIT-1 downto 0);
	 ADD_RD2: 	IN std_logic_vector(REG_BIT-1 downto 0);
	 DATAIN: 	IN std_logic_vector(BIT_DLX-1 downto 0);
    OUT1: 		OUT std_logic_vector(BIT_DLX-1 downto 0);
	 OUT2: 		OUT std_logic_vector(BIT_DLX-1 downto 0));
end component;


component ALU is
  generic (N : integer := BIT_DLX);
  port 	 ( FUNC: IN TYPE_OP;
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end component;

component zero_eval is
  generic (NBIT:integer:= BIT_DLX);
  port (
    input: in  std_logic_vector(NBIT-1 downto 0);
    res: out std_logic );
end component;

component COND_BT is
	Port (	
		ZERO_BIT:	in	std_logic;
		OPCODE:	in	std_logic_vector(OP_BIT-1 downto 0);
		con_sign: out	std_logic);
end component;


--RIGUARDA TUTTI I MUXSELECT
--metti windowedRF (+ bypass+ read and write @same time ecc)

--signals
	--stage 1
	signal NPC: std_logic_vector(NBIT-1 downto 0);
	--pipe
	signal NPC_Dec: std_logic_vector(NBIT-1 downto 0);
	signal PC_Dec: std_logic_vector(NBIT-1 downto 0);
	signal IR_Dec: std_logic_vector(NBIT-1 downto 0);
	--stage 2
	signal RS1: std_logic_vector(REG_BIT-1 downto 0);
	signal RS2: std_logic_vector(REG_BIT-1 downto 0);
	signal RD: std_logic_vector(REG_BIT-1 downto 0);
	signal Imm: std_logic_vector(NBIT-1 downto 0);
	signal regA: std_logic_vector(NBIT-1 downto 0);
	signal regB: std_logic_vector(NBIT-1 downto 0);
	--pipe
	signal NPC_ex: std_logic_vector(NBIT-1 downto 0);
	signal regA_ex: std_logic_vector(NBIT-1 downto 0);
	signal regB_ex: std_logic_vector(NBIT-1 downto 0);
	signal Imm_ex: std_logic_vector(NBIT-1 downto 0);
	signal RD_ex: std_logic_vector(REG_BIT-1 downto 0);
	signal IR_ex: std_logic_vector(NBIT-1 downto 0);
	--stage 3
	signal input1_ALU: std_logic_vector(NBIT-1 downto 0);
	signal input2_ALU: std_logic_vector(NBIT-1 downto 0);
	signal ALU_out:  std_logic_vector(NBIT-1 downto 0);
	signal is_zero: std_logic;
	signal cond: std_logic; 
	--pipe
	signal NPC_mem: std_logic_vector(NBIT-1 downto 0);
	signal cond_mem: std_logic;
	signal ALU_mem: std_logic_vector(NBIT-1 downto 0);
	signal regB_mem: std_logic_vector(NBIT-1 downto 0);
	signal RD_mem: std_logic_vector(REG_BIT-1 downto 0);
	--stage 4:
	signal PC_fetch: std_logic_vector(NBIT-1 downto 0);
	--pipe
	signal ALU_wb: std_logic_vector(NBIT-1 downto 0);
	--pc?
	signal LMD_wb: std_logic_vector(NBIT-1 downto 0);
	signal RD_wb: std_logic_vector(REG_BIT-1 downto 0);
	signal WM_wb: std_logic;
	--stage 5
	signal OUT_wb: std_logic_vector(NBIT-1 downto 0);
	
begin
--stage 1-> inputs: PC; outputs: NPC, IR

	-- PC->PC+4->NPC
	NPC <= PC + std_logic_vector(to_unsigned(4,NBIT));  --PC_fetch from stage 4 (modify if more than 1 instruction must be executed)
	-- PC->INSTR. MEM(IRAM)-> IR 
	
	--pipeline signals (F->D)
	pipeline_newpc1: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN0, D=>NPC, Q=>NPC_Dec);
	pipeline_pc1:regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN0, D=>PC, Q=>PC_Dec);
	pipeline_IR1:regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN0, D=>IR, Q=>IR_Dec);
	
--stage 2-> in: NPC, IR, PC; out: NPC, A, B, Imm

	-- IR assignement
	IR_OP:IR_DECODE
	Generic map (NBIT)
	Port map(IR_26=>IR_Dec(NBIT-OP_BIT-1 downto 0), OPCODE=>IR_Dec(NBIT downto NBIT-OP_BIT),is_signed=>signed_op, RS1=>RS1, RS2=>RS2, RD=>RD, IMMEDIATE=>Imm);

	--RF mapping
	 RF: register_file
	 port map (CLK, RST, EN1, RF1, RF2, WF1, RD_wb, RS1, RS2, OUT_wb, regA, regB);
	
	--pipeline signals (D->E)
	pipeline_newpc2: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN1, D=>NPC_Dec, Q=>NPC_ex);
	pipeline_A2: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN1, D=>regA, Q=>regA_ex);
	pipeline_B2: regFFD Generic map (NBIT) Port map(CLK=>CLK, RESET=>RST,ENABLE=>EN1, D=>regB, Q=>regB_ex);
	pipeline_IMM2: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=EN1, D=>Imm, Q=>Imm_ex);
	pipeline_RD2: regFFD Generic map (REG_BIT) Port map(CK=>CLK, RESET=>RST,ENABLE=EN1, D=>RD, Q=>RD_ex);
	pipeline_IR2:regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN1, D=>IR_Dec, Q=>IR_ex);
	
--stage 3-> in: NPC, A, B, Imm, PC; out: NPC, cond, alu_out, B

	MUX_ALU_A: MUX21_GENERIC 
	Port Map (NPC_ex, regA_ex, S1, input1_ALU);
	MUX_ALU_B: MUX21_GENERIC 
	Port Map (regB_ex, Imm_ex, S2, input2_ALU);
	
	ALU_OP: ALU
	generic map(NBIT)
	port map(instruction_alu, input1_ALU, input2_ALU,ALU_out);
	
	ZERO_OP: zero_eval
	  generic map (NBIT)
	  port map (regA_ex, is_zero); --reg1=0--> is_zero=1
	  
	COND_OP: COND_BT
	generic map (NBIT)
	  port map (is_zero, IR(26),branch_cond, cond); 
	--branch taken--> cond_sign=1; bnot taken or not branch opcode-->cond_sign=0;
	--- IF JUMP OR BRANCH TAKEN=> NPC=ALUOUT fai nop delle istruzioni 


--pipeline signals (E->M)
	pipeline_newpc3: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN2, D=>NPC_ex, Q=>NPC_mem);
	pipeline_cond3: FF Port map(CK=>CLK, RESET=>RST,EN=>EN2, D=>cond, Q=>cond_mem);
	pipeline_alu3:regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=> EN2, D=>ALU_out, Q=>ALU_mem);
	pipeline_B3: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN2, D=>regB_ex, Q=>regB_mem);
   pipeline_RD3: regFFD Generic map (REG_BIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN2, D=>RD_ex, Q=>RD_mem);

--	stage 4-> in: NPC, cond, alu_out, B; out: PC, ALU_out, LMD_out
	MUX_PC: MUX21_GENERIC 
	Port Map (NPC_mem, ALU_mem, cond_mem or jump_en, PC_fetch); 
	--if branch taken or jump instruction-> pc =alu_out
	
	--data_memory -- guarda dov'è sta cazzo di data memory
	DATA_MEM_ADDR<= ALU_mem;
	DATA_MEM_IN<= regB_mem;
	DATA_MEM_RM<=RM; --read=load op
	DATA_MEM_WM<=WM; --write= store op
	DATA_MEM_ENABLE<=EN3;
	
	--pipeline signals (M->W)
	pipeline_alu4:regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN3, D=>ALU_mem, Q=>ALU_wb);
	pipeline_LMD4: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN3, D=>DATA_MEM_OUT, Q=>LMD_wb);
	pipeline_RD4: regFFD Generic map (REG_BIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN3, D=>RD_mem, Q=>RD_wb);
	pipeline_WM: regFFD Generic map (NBIT) Port map(CK=>CLK, RESET=>RST,ENABLE=>EN3, D=>WM, Q=>WM_wb);
	
--	stage 5-> in: ALU_out, LMD_out, out: OUT_WB
	MUX_WB: MUX21_GENERIC 
	Port Map (LMD_wb, ALU_wb, S3, OUT_wb);-- sel_WB==S3
   --DTPTH_OUT<=OUT_wb;
	-- WF1 disponibile
	
end architecture;
