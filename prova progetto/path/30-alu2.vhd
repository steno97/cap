library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_signed.all;
--use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
--use IEEE.std.standard.BOOLEAN;
use WORK.myTypes.all;
--use WORK.alu_type.all;

entity ALU is
  generic (N : integer := numBit);
  port 	 ( 	CLK:	in	std_logic;
			FUNC: IN aluOp;
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUT_ALU: OUT std_logic_vector(N-1 downto 0));
end ALU;



architecture Architectural of ALU is

component SHIFTER_GENERIC
	generic(N: integer :=numBit);
	port(	A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(4 downto 0);
		LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
		LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
		SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
		OUTPUT: out std_logic_vector(N-1 downto 0)
	);
end component;

component P4_ADDER
generic (
		NBIT :		integer := numBit);
	port (
		A :	in	std_logic_vector(N-1 downto 0);
		B :	in	std_logic_vector(N-1 downto 0);
		Cin :	in	std_logic;
		S :	out	std_logic_vector(N-1 downto 0);
		Cout :	out	std_logic);
end component;


component comparator
Port (	DATA1:	In	std_logic_vector(numBit-1 downto 0);
		DATA2i:	In	std_logic;
		tipo :In aluOp;
		OUTALU:	Out	std_logic_vector(numBit-1 downto 0));
end component;

signal Cin_i : std_logic;
signal LOGIC_ARITH_i : std_logic;
signal LEFT_RIGHT_i : std_logic;
signal SHIFT_ROTATE_i : std_logic;
signal OUTPUT1: std_logic_vector(N-1 downto 0);
signal OUTPUT2: std_logic_vector(N-1 downto 0);
signal data2i: std_logic_vector(N-1 downto 0);
signal data1i: std_logic_vector(N-1 downto 0);
signal OUTPUT3: std_logic_vector(N-1 downto 0);
signal OUTPUT_alu_i: std_logic_vector(N-1 downto 0);
signal Cout_i :  std_logic;
begin
  OUT_ALU<=OUTPUT_alu_i;
  comp: comparator
    port map (
		data1 => output2,
		data2i => Cout_i,
		tipo => func,
		OUTALU => output3);
    
  shifter:  SHIFTER_GENERIC
	port map(
		A 			=> 			DATA1,
		B 			=> 			DATA2(4 downto 0),
		LOGIC_ARITH =>			LOGIC_ARITH_i, --da inserire il segnale -- 1 = logic, 0 = arith
		LEFT_RIGHT 	=> 			LEFT_RIGHT_i , --da inserire il segnale	-- 1 = left, 0 = right
		SHIFT_ROTATE => 		SHIFT_ROTATE_i ,	--da inserire il segnale -- 1 = shift, 0 = rotate
		OUTPUT 		 => 		OUTPUT1);
     
  adder: p4_adder 
	port map (
		A 		=> DATA1i,
		B 		=> DATA2i,
		Cin 	=> Cin_i   , -- da inserire 0
		S 		=> OUTPUT2   ,  --da inserire 0
		Cout =>	Cout_i); -- open se non funge --we mantain the Cout signal for future implementation of the DLX with status flags

----da fare tutto il process
--P_ALU: process (FUNC, DATA1, DATA2)
--variable tmp_arithmetic: unsigned (N downto 0); --temporary signal for arithmetic computation
P_ALU: process (clk,FUNC, DATA1, DATA2)
  begin
	
    case func is
	
	when NOP => null;
		
	--sono da fare le istruzioni di branch-------------------------------------------------------------	
	
	when BEQZ => if (data1 /= data2) then
					OUTPUT_alu_i<="00000000000000000000000000000000";----snei
				end if;
				 if (data1 = data2) then
					OUTPUT_alu_i<="00000000000000000000000000000001";----snei
				end if;
	when BNEZ => if (data1 = data2) then
					OUTPUT_alu_i<="00000000000000000000000000000000";----snei
				end if;
				 if (data1 /= data2) then
					OUTPUT_alu_i<="00000000000000000000000000000001";----snei
				end if;	
	--sono da fare le istruzioni di branch-------------------------------------------------------------		
		
		
		
		
	when ADDS | ADDUI 	=>  Cin_i<='0';
					OUTPUT_alu_i<= output2;	
					data2i<=data2;
					data1i<=data1;
			
    --ricordarsi di gestire l"unsigned          
    when SUBI | SUBUI	=> 	Cin_i<='1';
					OUTPUT_alu_i<= OUTPUT2;
					data2i<=not(data2);
					data1i<=data1;	

	    --ricordarsi di gestire l"unsigned
    when ADD | ADDU	=> data2i<=data2;
						data1i<=data1;	
					Cin_i<='0';
					OUTPUT_alu_i<= OUTPUT2;
    when SUB | SUBU	=> 	Cin_i<='1';
					OUTPUT_alu_i<= OUTPUT2;
					data2i<= not(data2);
					data1i<=data1;	
	    --ricordarsi di gestire l"unsigned
      
    when sra1 => 	LOGIC_ARITH_i <='0'; --da inserire il segnale -- 1 = logic, '0' = arith
		 			LEFT_RIGHT_i  <='0'; --da inserire il segnale	-- 1 = left, '0' = right
					SHIFT_ROTATE_i <='1';
					OUTPUT_alu_i<= output1;  
     
    when srai => 	LOGIC_ARITH_i <='0'; --da inserire il segnale -- 1 = logic, '0' = arith
		 			LEFT_RIGHT_i  <='0'; --da inserire il segnale	-- 1 = left, '0' = right
					SHIFT_ROTATE_i <='1';
					OUTPUT_alu_i<= output1;    
      
	when SLLI => 	LOGIC_ARITH_i <='1'; --da inserire il segnale -- 1 = logic, '0' = arith
		 			LEFT_RIGHT_i  <='1'; --da inserire il segnale	-- 1 = left, '0' = right
					SHIFT_ROTATE_i <='1';
					OUTPUT_alu_i<= output1;
				 
	when SRLI => LOGIC_ARITH_i <='0'; --da inserire il segnale -- 1 = logic, '0' = arith
		 			LEFT_RIGHT_i  <='0'; --da inserire il segnale	-- 1 = left, '0' = right
					SHIFT_ROTATE_i <='1';
					OUTPUT_alu_i<= output1;
					
	when LLS => LOGIC_ARITH_i <='1'; --da inserire il segnale -- '1' = logic, '0' = arith
		 			LEFT_RIGHT_i  <='1'; --da inserire il segnale	-- '1' = left, '0' = right
					SHIFT_ROTATE_i <='1';
					OUTPUT_alu_i<= output1;
    
	when LRS => LOGIC_ARITH_i <='0'; --da inserire il segnale -- '1' = logic, '0' = arith
		 			LEFT_RIGHT_i  <='0'; --da inserire il segnale	-- '1' = left, '0' = right
					SHIFT_ROTATE_i <='1';
					OUTPUT_alu_i<= output1;
     
    ---------------------------------------------------------------------- logic                                                                              
	when ANDR => gen_and: for i in 0 to N-1 loop
								OUTPUT_alu_i(i) <= DATA1(i) and DATA2(i); 	-- and op
						 end loop;  
	when ORR  => gen_or: for i in 0 to N-1 loop
								OUTPUT_alu_i(i) <= DATA1(i) or DATA2(i);    	-- or op
						 end loop; 
	when XORR => gen_xor: for i in 0 to N-1 loop
								OUTPUT_alu_i(i) <= DATA1(i) xor DATA2(i);	--xor op
						 end loop; 
	when ANDI => gen_and1: for i in 0 to N-1 loop
								OUTPUT_alu_i(i) <= DATA1(i) and DATA2(i); 	-- and op
						 end loop;  
	when ORI  => gen_or1: for i in 0 to N-1 loop
								OUTPUT_alu_i(i) <= DATA1(i) or DATA2(i);    	-- or op
						 end loop; 
	when XORI => gen_xor1: for i in 0 to N-1 loop
								OUTPUT_alu_i(i) <= DATA1(i) xor DATA2(i);	--xor op
						 end loop; 
						 
	

	
	
	---------------------------- load and store 
	
	when LW	=> 	Cin_i<='0';
				OUTPUT_alu_i<= output2;
	when SW =>	Cin_i<='0';
				OUTPUT_alu_i<= output2;
	
	when LB	=> 	Cin_i<='0';
				OUTPUT_alu_i<= output2;
	when SB =>	Cin_i<='0';
				OUTPUT_alu_i<= output2;
	when LBU => 	Cin_i<='0';
				OUTPUT_alu_i<= output2;
	when LHU => Cin_i<='0';
				OUTPUT_alu_i<= output2;
	
	------------------------------  load and store
	when SEQ | SEQI | SLT | SLTI | SLTU |SLTUI | SGT | SGTI | SGTUI |SGTU | SGE | SGEI | SGEUI |SGEU |
			 SNE | SNEI | SLE | SLEI => Cin_i<='1';
										data2i<= not(data2);
										OUTPUT_alu_i <= output3;
							
	
--	when SEQ | SEQI =>  if (signed(data1) = signed(data2)) then
--					OUTPUT_alu_i<="00000000000000000000000000000001";----SEQ | SEQI
--				end if;
--				 if (signed(data1) /= signed(data2)) then
--					OUTPUT_alu_i<="00000000000000000000000000000000";----SEQ | SEQI
--				end if;
	
--	when SLT | SLTI  => if (signed(data1) >= signed(data2)) then
--					OUTPUT_alu_i<="00000000000000000000000000000000";----slei
--				end if;
--				 if (signed(data1) < signed(data2)) then
--					OUTPUT_alu_i<="00000000000000000000000000000001";----slei
--				end if;
--	when SLTU |SLTUI =>      if (unsigned(data1) >= unsigned(data2)) then
					
					--OUTPUT_alu_i<="00000000000000000000000000000000";----slei
				--end if;
				 --if (unsigned(data1) < unsigned(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----slei
				--end if;
	--when SGT | SGTI  =>    if (signed(data1) < signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000000";----slei
				--end if;
				 --if (signed(data1) > signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----slei
				--end if;
	 --when SGTUI |SGTU => if (unsigned(data1) < unsigned(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000000";----slei
				--end if;
				 --if (unsigned(data1) > unsigned(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----slei
				--end if;
		--when SGE| SGEI =>    if (signed(data1) < signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000000";----slei
				--end if;
				 --if (signed(data1) >= signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----slei
				--end if;
	--when  SGEUI |SGEU =>    if (unsigned(data1) < unsigned(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000000";----slei
				--end if;
				 --if (unsigned(data1) >= unsigned(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----slei
				--end if;
	--when SNE | SNEI => if (signed(data1) /= signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----snei
				--end if;
				 --if (signed(data1) = signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000000";----snei
				--end if;
				
	--when SLE | SLEI =>      if (signed(data1) > signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000000";----slei
				--end if;
				 --if (signed(data1) <= signed(data2)) then
					--OUTPUT_alu_i<="00000000000000000000000000000001";----slei
				--end if;
	when others => null;
    end case; 
  end process P_ALU;

end Architectural;
  

  


configuration CFG_ALU_Architectural of ALU is
  for Architectural
  end for;
end CFG_ALU_Architectural;

	

