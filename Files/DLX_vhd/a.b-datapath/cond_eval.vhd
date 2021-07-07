library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use work.myTypes.all;

entity COND_BT is
Generic (NBIT: integer:= numBit); 
	Port (	
		ZERO_BIT:	in	std_logic;
		OPCODE_0:	in	std_logic; --OpCODE(0) <= IR(26)
		branch_op:	in	std_logic;
		con_sign: out	std_logic);
end COND_BT;


architecture BHV of COND_BT is 
	--beqz(0x4=000100), regA=0 (cioè ZERO_BIT=1)--> branch taken
	--bnez(0x5=000101), regA!=0 (ZERO_BIT=0) --> branch taken
begin	
	dec_cond: process (branch_op)
	begin
	if (branch_op='1') then 
			con_sign <= (OPCODE_0 xor ZERO_BIT);
		else 
			con_sign <= '0';
		end if;
	end process;
	
end BHV;

--branch taken--> cond_sign=1
-- bnot taken or not branch opcode-->cond_sign=0;
