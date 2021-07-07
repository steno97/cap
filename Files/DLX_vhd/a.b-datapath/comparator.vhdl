library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use work.myTypes.all;


--devo fare il comparator
entity comparator is
	Port (	DATA1:	In	std_logic_vector(numBit-1 downto 0);
		DATA2i:	In	std_logic;
		tipo :In aluOp;
		Y:	Out	std_logic_vector(numBit-1 downto 0));
end ND2;

architecture Architectural of comparator is

--component P4_ADDER
--generic (
		--NBIT :		integer := numBit);
	--port (
		--A :	in	std_logic_vector(N-1 downto 0);
		--B :	in	std_logic_vector(N-1 downto 0);
		--Cin :	in	std_logic;
		--S :	out	std_logic_vector(N-1 downto 0);
		--Cout :	out	std_logic);
--end component;

--signal Cin_i: std_logic;
--signal Cout_i:std_logic
begin
 
 --adder: p4_adder 
	--port map (
		--A 		=> DATA1,
		--B 		=> DATA2i,
		--Cin 	=> Cin_i   , -- da inserire 0
		--S 		=> OUTPUT2   ,  --da inserire 0
		--Cout =>	Cout_i); --we mantain the Cout signal for future implementation of the DLX with status flags



comparator_proc: process (data1, data2, tipo)
signal s_i: std_logic := '0' ;
begin
	--Cin_i<='1';
	--data2i<= not(data2);
	gen_or1: for i in 0 to numbit-1 loop
			s_i <= s_i or data1(i);	--xor op
	end loop; 
	case tipo is
		when SEQ | SEQI => if s_i = '0' then 
							OUTALU<="00000000000000000000000000000001";
							else
								OUTALU<="00000000000000000000000000000000";
							end if;
		when SLT | SLTI | SLTU |SLTUI  => if data2i = '0' then 
							OUTALU<="00000000000000000000000000000001";
							else
								OUTALU<="00000000000000000000000000000000";
							end if;
		
		when SGT | SGTI | SGTUI |SGTU  =>  if data2i = '1' and s_i='1' then 
							OUTALU<="00000000000000000000000000000001";
							else
								OUTALU<="00000000000000000000000000000000";
							end if;
		
		when SGE| SGEI | SGEUI |SGEU=> if data2i = '1' then 
							OUTALU<="00000000000000000000000000000001";
							else
								OUTALU<="00000000000000000000000000000000";
							end if;
		
		when SNE | SNEI => if s_i = '1' then 
							OUTALU<="00000000000000000000000000000001";
							else
								OUTALU<="00000000000000000000000000000000";
							end if;
		
		when SLE | SLEI => if s_i = '0' and data2i = '1' then 
							OUTALU<="00000000000000000000000000000001";
							else
								OUTALU<="00000000000000000000000000000000";
							end if;
		when others => null;
    end case; 
 end process comparator_proc;
		
