-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  signal s_PC : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011 func3: 000 and func12: 000100000101 -- func12 is imm field from I-format)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated


  component add_sub is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
         i_C         : in std_logic;
         o_S         : out std_logic_vector(N-1 downto 0);
         o_C         : out std_logic);
  end component;

    component pc is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

  component control is
    port(i_opcode     : in std_logic_vector(6 downto 0);
         i_func7      : in std_logic_vector(6 downto 0);
         o_RegWrite   : out std_logic;
         o_MemWrite   : out std_logic;
         o_AddSub     : out std_logic;
         o_ALUSrc     : out std_logic;
         o_IMMSel     : out std_logic;
         o_MemToReg   : out std_logic);
  end component;

  component reg_file
    generic(N : integer := 32);
    port(i_CLK       : in std_logic;                            -- Clock input
         i_RST       : in std_logic;
         i_W_VAL     : in std_logic_vector(31 downto 0);        -- 32-bit write value
         i_W_ADDR    : in std_logic_vector(4 downto 0);         -- 5-bit write address
         i_W_EN      : in std_logic;                            -- line for write enable
         i_R_ADDR_A  : in std_logic_vector(4 downto 0);         -- 5-bit read address A
         i_R_ADDR_B  : in std_logic_vector(4 downto 0);         -- 5-bit read address B
         o_R_VAL_A   : out std_logic_vector(31 downto 0);       -- 32-bit read value A
         o_R_VAL_B   : out std_logic_vector(31 downto 0));      -- 32-bit read value B
  end component;


  component mem is
    generic(DATA_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 10);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;
    
  component mux2t1_N
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component zero_appender
      port(Z_APP_IN     : in std_logic_vector(19 downto 0);
           Z_APP_OUT    : out std_logic_vector(31 downto 0));
  end component;

  component sign_extender
      port(S_EXT_IN     : in std_logic_vector(11 downto 0);
           S_EXT_OUT    : out std_logic_vector(31 downto 0));
  end component;

  component adder_N
      port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B             : in std_logic_vector(N-1 downto 0);
       i_C             : in std_logic;
       o_S             : out std_logic_vector(N-1 downto 0);
       o_C             : out std_logic);
  end component;

  component andg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  signal MID_PC_OUT       : std_logic_vector(31 downto 0);
  signal MID_ADDSUB_OUT   : std_logic_vector(31 downto 0);
  signal MID_ALUMUX_OUT   : std_logic_vector(31 downto 0);
  signal MID_BOTMUX_OUT   : std_logic_vector(31 downto 0);
  signal MID_AND_OUT      : std_logic;
  signal MID_B_OUT        : std_logic_vector(31 downto 0);
  signal MID_A_OUT        : std_logic_vector(31 downto 0);
  signal MID_REG_A_OUT    : std_logic_vector(31 downto 0);
  signal MID_REG_B_OUT    : std_logic_vector(31 downto 0);
  signal MID_Z_APP_OUT    : std_logic_vector(31 downto 0);
  signal MID_S_EXT_OUT    : std_logic_vector(31 downto 0);
  signal MID_IMMMUX_OUT   : std_logic_vector(31 downto 0);
  signal MID_REGMUX_OUT   : std_logic_vector(31 downto 0);
  signal MID_MEM_OUT      : std_logic_vector(31 downto 0);
  signal MID_APP_OUT      : std_logic_vector(31 downto 0);
  signal MID_EXT_OUT      : std_logic_vector(31 downto 0);
  signal MID_PC_NEXT      : std_logic_vector(31 downto 0);
  signal MID_IMMEDIATE    : std_logic_vector(11 downto 0);
  signal MID_ADDSUB       : std_logic;
  signal MID_ALUSRC       : std_logic;
  signal MID_IMM_SEL      : std_logic;
  signal MID_MEMTOREG     : std_logic;
  signal MID_MEMWRITE     : std_logic;



begin
  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.
  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
      iInstAddr when others;

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100) STUDENT COMMENT: I think opcode 01 0100 is from mips and not riscv

  -- halt when wfi instruction is seen
  s_Halt <= '1' when s_Inst = x"10500073" else '0';

  -- TODO: Implement the rest of your processor below this comment! 


  IMem: mem
    generic map(DATA_WIDTH => 32,
                ADDR_WIDTH => 10)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);

  pc_add_four: add_sub
    generic MAP(N => N)
    port MAP(i_A  => s_PC,
             i_B  => x"00000004",
             i_C  => '0',
             o_S  => MID_PC_NEXT,
             o_C  => open);
             
  PC_REG: pc
  generic MAP(N => N)
    port MAP(i_CLK => iCLK,
             i_RST => iRST,
             i_WE  => '1',
             i_D   => MID_PC_NEXT,
             o_Q   => s_PC);

  CONTROL_UNIT: control
    port MAP(i_opcode   => s_Inst(6 downto 0),
             i_func7    => s_Inst(31 downto 25),
             o_RegWrite => s_RegWr,
             o_MemWrite => s_DMemWr,
             o_AddSub   => MID_ADDSUB,
             o_ALUSrc   => MID_ALUSRC,
             o_IMMSel   => MID_IMM_SEL,
             o_MemToReg => MID_MEMTOREG);

  REGISTER_FILE: reg_file
generic MAP(N => N)
    port MAP(i_CLK       => iCLK,
             i_RST       => iRST,
             i_W_VAL     => s_RegWrData,
             i_W_ADDR    => s_RegWrAddr,
             i_W_EN      => s_RegWr,
             i_R_ADDR_A  => s_Inst(19 downto 15), -- clip the rs1 from instruction
             i_R_ADDR_B  => s_Inst(24 downto 20), -- clip the rs2 from instruction
             o_R_VAL_A   => MID_REG_A_OUT,
             o_R_VAL_B   => MID_REG_B_OUT);

  -- Poor man's immgen for now: send the S-Type immediate for 'sw' when appropriate, otherwise send I-Type immediate
  MID_IMMEDIATE <= s_Inst(31 downto 25) & s_Inst(11 downto 7) when s_Inst(6 downto 0) = "0100011" else 
              s_Inst(31 downto 20);

  z_app: zero_appender
    port MAP(Z_APP_IN  => s_Inst(31 downto 12),
             Z_APP_OUT => MID_APP_OUT);

  s_ext: sign_extender
    port MAP(S_EXT_IN => MID_IMMEDIATE,
             S_EXT_OUT => MID_EXT_OUT);


  immmux: mux2t1_N
    generic MAP(N => N) 
    port MAP(i_S  => MID_IMM_SEL,
             i_D0 => MID_APP_OUT,
             i_D1 => MID_EXT_OUT,
             o_O  => MID_IMMMUX_OUT);

  ALU: add_sub
    generic MAP(N => N)
    port MAP(i_A  => MID_REG_A_OUT,
             i_B  => MID_ALUMUX_OUT,
             i_C  => MID_ADDSUB,
             o_S  => MID_ADDSUB_OUT,
             o_C  => open);

  DMem: mem
    generic map(DATA_WIDTH => 32,
                ADDR_WIDTH => 10)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  alumux: mux2t1_N
    generic MAP(N => N) 
    port MAP(i_S  => MID_ALUSRC,
         i_D0 => MID_REG_B_OUT,
         i_D1 => MID_IMMMUX_OUT,
         o_O  => MID_ALUMUX_OUT);

  botmux: mux2t1_N
    generic MAP(N  => N)
    port MAP(i_S   => MID_AND_OUT,
         i_D0      => MID_ADDSUB_OUT,
         i_D1      => MID_IMMMUX_OUT,
         o_O       => MID_BOTMUX_OUT);

  regmux: mux2t1_N
  generic MAP(N => N) 
    port MAP(i_S  => MID_MEMTOREG,
             i_D0 => MID_BOTMUX_OUT,
             i_D1 => s_DMemOut,
             o_O  => MID_REGMUX_OUT);


  andy: andg2
    port MAP(i_A  => MID_ALUSRC,
             i_B  => MID_ADDSUB,
             o_F  =>  MID_AND_OUT);

  s_RegWrAddr <= s_Inst(11 downto 7);
  s_RegWrData <= MID_REGMUX_OUT;
  s_DMemAddr <= MID_ADDSUB_OUT;
  s_DMemData <= MID_REG_B_OUT;
  oALUOut <= MID_ADDSUB_OUT;
end structure;

