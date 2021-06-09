
--Logical Shifts:
--Version 1: the first operand is shifted by one position
--Version 2: the first operand is shifted by a number of positions defined by the value of the second operand 

  
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use WORK.constants.all;
use WORK.alu_type.all;

entity ALU is
  generic (N : integer := numBit);
  port 	 ( FUNC: IN TYPE_OP;
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end ALU;



architecture Architectural of ALU is

component SHIFTER_GENERIC
	generic(N: integer);
	port(	A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(4 downto 0);
		LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
		LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
		SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
		OUTPUT: out std_logic_vector(N-1 downto 0)
	)
end component;

component P4_ADDER
generic (
		NBIT :		integer := Numbit);
	port (
		A :	in	std_logic_vector(NBIT-1 downto 0);
		B :	in	std_logic_vector(NBIT-1 downto 0);
		Cin :	in	std_logic;
		S :	out	std_logic_vector(NBIT-1 downto 0);
		Cout :	out	std_logic)
end component;

/*
component BOOTHMUL
GENERIC ( NBIT_A : integer := NumBit_A;
				 NBIT_B : integer := NumBit_B;
				 NBIT_P : integer := NumBit_P
				);
	
	PORT ( A 	: IN  std_logic_vector ( NBIT_A-1 downto 0);
	       B		: IN  std_logic_vector ( NBIT_B-1 downto 0);
			 P    : OUT std_logic_vector ( NBIT_P-1 downto 0)
		   )
end component;
*/

signal LOGIC_ARITH_i : std_logic;
signal LEFT_RIGHT_i : std_logic;
signal SHIFT_ROTATE_i : std_logic;
signal Cin_i: std_logic;

  shifter: SHIFTER_GENERIC
	generic(N: integer);
	port map(
		A 			=> 			DATA1,
		B 			=> 			DATA2,
		LOGIC_ARITH =>			LOGIC_ARITH_i, --da inserire il segnale -- 1 = logic, 0 = arith
		LEFT_RIGHT 	=> 			LEFT_RIGHT_i , --da inserire il segnale	-- 1 = left, 0 = right
		SHIFT_ROTATE => 		SHIFT_ROTATE_i ,	--da inserire il segnale -- 1 = shift, 0 = rotate
		OUTPUT 		 => 		OUTPUT);
     
     
  shifter: SHIFTER_GENERIC
    generic ( NBIT :		integer := Numbit);
	port map (
		A 		=> DATA1,
		B 		=> DATA2,
		Cin 	=> Cin_i   , -- da inserire 0
		S 		=> OUTPUT   ,  --da inserire 0
		Cout :	open); --we mantain the Cout signal for future implementation of the DLX with status flags


  
  
  
  
  
  
----da fare tutto il process
P_ALU: process (FUNC, DATA1, DATA2)
variable tmp_arithmetic: unsigned (N downto 0); --temporary signal for arithmetic computation

  begin
	
    case FUNC is
	when ADD 	=> tmp_arithmetic := (('0'& unsigned(DATA1))+('0' & unsigned(DATA2)));
                           if tmp_arithmetic(N)='1' then OUTALU <= (others => '1'); -- saturation (overflow management)
                           else OUTALU <= std_logic_vector(tmp_arithmetic(N-1 downto 0));
                           end if;
                           
        when SUB 	=> if unsigned(DATA1) < unsigned(DATA2) then OUTALU <= (others => '0'); -- saturation (underflow management)
                           else tmp_arithmetic := ( ('0' & unsigned(DATA1)) - ('0' & unsigned(DATA2)) ) ;
			 	OUTALU <= std_logic_vector(tmp_arithmetic(N-1 downto 0));
                           end if;
                                                                                 
	when MULT 	=>  if (N mod 2)=0  then tmp_arithmetic(N-1 downto 0) := unsigned(DATA1((N/2)-1 downto 0)) * unsigned(DATA2((N/2)-1 downto 0));
                    else tmp_arithmetic(N-1 downto 0) := '0' &(unsigned(DATA1((N/2)-1 downto 0)) * unsigned(DATA2((N/2)-1 downto 0))) ;
					end if;						
		-- if N%2==0 then multiplication is on N bit else N mul is on N-1 bit
 					OUTALU <= std_logic_vector (tmp_arithmetic(N-1 downto 0));
        -- bitwise operations 
                                                        
	when BITAND => gen_and: for i in 0 to N-1 loop
								OUTALU(i) <= DATA1(i) and DATA2(i); 	-- and op
						 end loop;  
	when BITOR  => gen_or: for i in 0 to N-1 loop
								OUTALU(i) <= DATA1(i) or DATA2(i);    	-- or op
						 end loop; 
	when BITXOR => gen_xor: for i in 0 to N-1 loop
								OUTALU(i) <= DATA1(i) xor DATA2(i);	--xor op
						 end loop; 
	-- Logical shifts (version 1)				 
	when FUNCLSL 	=> OUTALU <= DATA1(N-2 downto 0) & '0';	       	-- logical shift left
	when FUNCLSR 	=> OUTALU <= '0' & DATA1(N-1 downto 1);			-- logical shift right
	when FUNCRL 	=> OUTALU <= DATA1(N-2 downto 0) & DATA1(N-1);	-- rotate left
	when FUNCRR 	=> OUTALU <= DATA1(0) & DATA1(N-1 downto 1); 	-- rotate right
	when others => null;
    end case; 
  end process P_ALU;

end Architectural;
  

  


configuration CFG_ALU_Architectural of ALU is
  for Architectural
  end for;
end CFG_ALU_Architectural;

	

