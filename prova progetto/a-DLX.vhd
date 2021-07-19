library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity DLX is
  generic (
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    PC_SIZE      : integer := 32       -- Program Counter Size
    );       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk : in std_logic;
    Rst : in std_logic);                -- Active Low
end DLX;


-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
-- control unit (UNCOMPLETE)
--
architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------
  
  --Instruction Ram
  component IRAM
--     generic (
--       RAM_DEPTH : integer;
--       I_SIZE    : integer);
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(PC_SIZE - 1 downto 0);
      Dout : out std_logic_vector(IR_SIZE - 1 downto 0));
  end component;

  -- Data Ram (MISSING!You must include it in your final project!)

  -- Datapath 
component DATAPTH 
Generic (NBIT: integer:= numBit; REG_BIT: integer:= REG_SIZE);
	Port (	
		CLK:	in	std_logic;
		RST:	in	std_logic;
		PC: in	std_logic_vector(NBIT-1 downto 0);
		IR: in	std_logic_vector(NBIT-1 downto 0);
		PC_out: out	std_logic_vector(NBIT-1 downto 0); --pc_out
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
		lhi_sel: in	std_logic;
		jump_en:in	std_logic;
		branch_cond: in	std_logic;
		sb_op: in	std_logic;
		RM: in	std_logic;
		WM: in	std_logic;
		EN3: in	std_logic;
		S3: in	std_logic;
		--alu signals
		instruction_alu:  in aluOp;
		
		--data memory signals
		DATA_MEM_ADDR: out	std_logic_vector(NBIT-1 downto 0);
		DATA_MEM_IN: out	std_logic_vector(NBIT-1 downto 0);
		DATA_MEM_OUT: in	std_logic_vector(NBIT-1 downto 0);
		DATA_MEM_ENABLE: out	std_logic;
		DATA_MEM_RM: out	std_logic;
		DATA_MEM_WM: out	std_logic);
end component;
  
  -- Control Unit
  component dlx_cu
  generic (
    MICROCODE_MEM_SIZE :     integer := MEM_SIZE;  -- Microcode Memory Size
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    --ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 15);  -- Control Word Size
  port (
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    -- IF Control Signal
    IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : out std_logic;
    -- ID Control Signals
    RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable
    -- EX Control Signals
    MUXA_SEL           : out std_logic;  -- MUX-A Sel
    MUXB_SEL           : out std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
    EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
    -- ALU Operation Code
    ALU_OPCODE         : out aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
   
	signed_unsigned		: out std_logic;
    -- MEM Control Signals
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable
    -- WB Control signals
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic;
    lhi_sel: out	std_logic;
    sb_op: out	std_logic );  -- Register File Write Enable

  end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
  
  -- Instruction Register (IR) and Program Counter (PC) declaration
  signal IR : std_logic_vector(IR_SIZE - 1 downto 0);
  signal PC : std_logic_vector(PC_SIZE - 1 downto 0);

  -- Instruction Ram Bus signals
  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);

  -- Datapath Bus signals
  signal PC_BUS : std_logic_vector(PC_SIZE -1 downto 0);

  -- Control Unit Bus signals
  signal IR_LATCH_EN_i : std_logic;
  signal NPC_LATCH_EN_i : std_logic;
  signal RegA_LATCH_EN_i : std_logic;
  signal RegB_LATCH_EN_i : std_logic;
  signal RegIMM_LATCH_EN_i : std_logic;
  signal EQ_COND_i : std_logic;
  signal JUMP_EN_i : std_logic;
  signal ALU_OPCODE_i : aluOp;
  signal MUXA_SEL_i : std_logic;
  signal MUXB_SEL_i : std_logic;
  signal ALU_OUTREG_EN_i : std_logic;
  signal DRAM_WE_i : std_logic;
  signal LMD_LATCH_EN_i : std_logic;
  signal PC_LATCH_EN_i : std_logic;
  signal WB_MUX_SEL_i : std_logic;
  signal RF_WE_i : std_logic;
  signal lhi_sel_i: 	std_logic;
  signal  sb_op_i: 	std_logic;
  signal signed_unsigned_i: std_logic;


----------- questa parte poi è da levare
	signal DATA_MEM_ADDR_i: 	std_logic_vector(numBit-1 downto 0) := "00000000000000000000000000000000";
	signal DATA_MEM_IN_i: 	std_logic_vector(numBit-1 downto 0) := "00000000000000000000000000000000";
	signal DATA_MEM_OUT_i: 	std_logic_vector(numBit-1 downto 0):= "00000000000000000000000000000000" ;
	signal DATA_MEM_ENABLE_i:	std_logic := '0';
	signal DATA_MEM_RM_i: std_logic := '0';
	signal DATA_MEM_WM_i: std_logic := '0';
---------------questa parte poi è da levare 
  -- Data Ram Bus signals


  begin  -- DLX

    -- purpose: Instruction Register Process
    -- type   : sequential
    -- inputs : Clk, Rst, IRam_DOut, IR_LATCH_EN_i
    -- outputs: IR_IN_i
    IR_P: process (Clk, Rst)
    begin  -- process IR_P
      if Rst = '0' then                 -- asynchronous reset (active low)
        IR <= (others => '0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        if (IR_LATCH_EN_i = '1') then
          IR <= IRam_DOut;
        end if;
      end if;
    end process IR_P;


    -- purpose: Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, PC_BUS
    -- outputs: IRam_Addr
    PC_P: process (Clk, Rst)
    begin  -- process PC_P
      if Rst = '0' then                 -- asynchronous reset (active low)
        PC <= (others => '0');
      elsif Clk'event and Clk = '1' then  -- rising clock edge
        if (PC_LATCH_EN_i = '1') then
          PC <= PC_BUS;
        end if;
      end if;
    end process PC_P;

    -- Control Unit Instantiation
    CU_I: dlx_cu
      port map (
          Clk             => Clk,
          Rst             => Rst,
          IR_IN           => IR,
          IR_LATCH_EN     => IR_LATCH_EN_i,
          NPC_LATCH_EN    => NPC_LATCH_EN_i,
          RegA_LATCH_EN   => RegA_LATCH_EN_i,
          RegB_LATCH_EN   => RegB_LATCH_EN_i,
          RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
          MUXA_SEL        => MUXA_SEL_i,
          MUXB_SEL        => MUXB_SEL_i,
          ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
          EQ_COND         => EQ_COND_i,
          ALU_OPCODE      => ALU_OPCODE_i,
          DRAM_WE         => DRAM_WE_i,
          LMD_LATCH_EN    => LMD_LATCH_EN_i,
          JUMP_EN         => JUMP_EN_i,
          PC_LATCH_EN     => PC_LATCH_EN_i,
          WB_MUX_SEL      => WB_MUX_SEL_i,
          RF_WE           => RF_WE_i,
          lhi_sel		  => lhi_sel_i,
		  sb_op			  => sb_op_i,
		  signed_unsigned => signed_unsigned_i
          );

    -- Instruction Ram Instantiation
    IRAM_I: IRAM
      port map (
          Rst  => Rst,
          Addr => PC,
		  --Addr =>PC_out,
          Dout => IRam_DOut);

	    -- Datapath Instantiation
    DTPTH_I: DATAPTH
      port map (
          CLK => Clk,
          RST => Rst,
		  PC =>PC,
		  IR=>IR,
		  PC_out=>PC_BUS,
          EN0 => NPC_LATCH_EN_i,
		signed_op=> signed_unsigned_i, --metti
          RF1 => RegA_LATCH_EN_i,
          RF2 => RegB_LATCH_EN_i,
		  WF1 => RF_WE_i,
          EN1 => RegIMM_LATCH_EN_i,
          S1 => MUXA_SEL_i,
          S2 => MUXB_SEL_i,
          EN2 => ALU_OUTREG_EN_i,
		lhi_sel=> lhi_sel_i,--metti
		  jump_en => JUMP_EN_i,
          branch_cond => EQ_COND_i,
        sb_op=> sb_op_i,--metti
          RM => LMD_LATCH_EN_i,
          WM => DRAM_WE_i,
          EN3 => PC_LATCH_EN_i,
          S3 => WB_MUX_SEL_i,
          instruction_alu=> ALU_OPCODE_i,
		--metti per data memory
		DATA_MEM_ADDR=>DATA_MEM_ADDR_i,
		DATA_MEM_IN=>DATA_MEM_IN_i,
		DATA_MEM_OUT=>DATA_MEM_OUT_i,
		DATA_MEM_ENABLE=>DATA_MEM_ENABLE_i,
		DATA_MEM_RM=>DATA_MEM_RM_i,
		DATA_MEM_WM=>DATA_MEM_WM_i);
    
end dlx_rtl;
