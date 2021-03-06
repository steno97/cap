library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use work.myTypes.all;

entity IR_DECODE is
Generic (NBIT: integer:= numBit; opBIT: integer:= OP_CODE_SIZE; regBIT: integer:= REG_SIZE ); 
	Port (	
		IR_26:	in	std_logic_vector(NBIT-opBIT-1 downto 0); 
		OPCODE:	in	std_logic_vector(opBIT-1 downto 0); --OpCODE <= IR(6 bit)
		is_signed:	in	std_logic;
		RS1: out	std_logic_vector(regBIT-1 downto 0); --RS1 <= (5 bit)
		RS2: out	std_logic_vector(regBIT-1 downto 0); --RS2 <= (5 bit)
		RD: out	std_logic_vector(regBIT-1 downto 0); --RD <= (5 bit)
		IMMEDIATE: out	std_logic_vector(NBIT-1 downto 0)
		);
--IMMEDIATE <= imm16, imm26 or func(11)
--imm16 when i-type, imm26 (signed imm) when j-type, func when R type

end IR_DECODE;


architecture BEHAV of IR_DECODE is
--signals
 signal IMMEDIATE_5: std_logic_vector(NBIT-1 downto 0);
 signal IMMEDIATE_16: std_logic_vector(NBIT-1 downto 0);
 signal IMMEDIATE_26: std_logic_vector(NBIT-1 downto 0);
--constants
 constant rTYPE: std_logic_vector(opBIT-1 downto 0) :="000000";
 constant jTYPE: std_logic_vector(opBIT-1 downto 0) := "00001X";
 constant jrTYPE: std_logic_vector(opBIT-1 downto 0) := "01001X";
 --j=0x02='000010', jal=0x03='000011' 
 --jr=0x12='010010', jalr=0x13='010011' 
 
--components
	component sign_eval is
		generic (N_in: integer := numBit;
				  N_out: integer := numBit);
		port (
			IR_out: in std_logic_vector(N_in-1 downto 0);
			signed_val: in std_logic; 
			Immediate: out std_logic_vector (N_out-1 downto 0));
	end component;
--process
begin
		
	SIGN_EXTENSION_imm5: sign_eval
	generic map (5, NBIT)
	port map (IR_26(15 downto 11), is_signed, IMMEDIATE_5);

	SIGN_EXTENSION_imm16: sign_eval
	generic map (16, NBIT)
	port map (IR_26(15 downto 0), is_signed, IMMEDIATE_16);
	--beqz, bnez signed in teoria

	SIGN_EXTENSION_imm26: sign_eval
	generic map (NBIT-opBIT, NBIT)
	port map (IR_26, '1', IMMEDIATE_26);
	--j,jal (signed imm)
	--JR, JALR SONO DI TIPO I_TYPE 

	dec_IR : process(OPCODE)
	begin
	if (OPCODE = rTYPE)  then   
			RS1  <= IR_26(25 downto 21);
			RS2  <= IR_26(20 downto 16);
			RD   <= IR_26(15 downto 11);
			IMMEDIATE <= (others => '0'); --func (others => '0');
			

	elsif (OPCODE = jTYPE)  then 
			RS1  <= (others => '0');
			RS2  <= (others => '0');
			RD   <= (others => '1'); --R31
			IMMEDIATE <=IMMEDIATE_26;

	elsif (OPCODE = jrTYPE)  then 
			RS1  <= IR_26(25 downto 21);
			RS2  <= (others => '1');
			RD   <= (others => '1'); --R31
			IMMEDIATE <=IMMEDIATE_16;

	else
		--I-TYPE
			RS1  <= IR_26(25 downto 21);
			RD  <= IR_26(20 downto 16);
			RS2  <= IR_26(20 downto 16);
			IMMEDIATE <=IMMEDIATE_16;
end if;
	end process;
end architecture;

		
