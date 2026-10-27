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
  signal s_PC : std_logic_vector(N-1 downto 0) := x"00400000"; -- TODO: use this signal as your intended final instruction memory address input.
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
    port(i_opcode        : in  std_logic_vector(6 downto 0);
         i_func3         : in  std_logic_vector(2 downto 0);
         i_func7         : in  std_logic_vector(6 downto 0);
         o_RegWrite      : out std_logic;
         o_MemWrite      : out std_logic;
         o_ALUSrcA       : out std_logic_vector(1 downto 0);
         o_ALUSrcB       : out std_logic;
         o_MemToReg      : out std_logic;
         o_Branch        : out std_logic;
         o_Jump          : out std_logic;
         o_AndLink       : out std_logic;
         o_AndLinkReg    : out std_logic; -- added
         o_ImmediateType : out std_logic_vector(2 downto 0);
         o_ALUControl    : out std_logic_vector(3 downto 0));
  end component;

  component alu is
    generic(N : integer := 32);
    port(i_A          : in  std_logic_vector(N-1 downto 0);
         i_B          : in  std_logic_vector(N-1 downto 0);
         i_ALUControl : in  std_logic_vector(3 downto 0);
         o_Result     : out std_logic_vector(N-1 downto 0);
         o_Zero       : out std_logic;
         o_CarryOut   : out std_logic;
         o_LT         : out std_logic;
         o_LTU        : out std_logic);
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
    
component barrelShifter is
  port(i_Data         : in std_logic_vector(31 downto 0);
       i_Shift         : in std_logic_vector(4 downto 0);
       i_arith         : in std_logic; -- 0 for SRL, 1 for SRA
       i_Dir         : in std_logic; -- 0 for right, 1 for left
       o_Shifted        : out std_logic_vector(31 downto 0)
       );
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
  
  component org2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment


  signal MID_ALUMUX_OUT           : std_logic_vector(31 downto 0);
  signal MID_ADDSUB_OUT           : std_logic_vector(31 downto 0);
  signal MID_BOTMUX_OUT           : std_logic_vector(31 downto 0);
  signal MID_REG_A_OUT            : std_logic_vector(31 downto 0);
  signal MID_REG_B_OUT            : std_logic_vector(31 downto 0);
  signal MID_REGMUX_OUT           : std_logic_vector(31 downto 0);
  signal MID_MEM_OUT              : std_logic_vector(31 downto 0);
  signal MID_PC_NEXT              : std_logic_vector(31 downto 0);
  signal MID_PC_NEXT_4            : std_logic_vector(31 downto 0);
  signal MID_PC_JUMP_REG          : std_logic_vector(31 downto 0);
  signal MID_PC_AND               : std_logic;
  signal MID_IMMEDIATE_FULL       : std_logic_vector(31 downto 0);
  signal MID_PC_MUX_SEL           : std_logic;
  signal MID_ALUSRCA              : std_logic_vector(1 downto 0);
  signal MID_ALUSRCB              : std_logic;
  signal MID_MEMTOREG             : std_logic;
  signal MID_MEMWRITE             : std_logic;
  signal MID_CONTROL_BRANCH       : std_logic;
  signal MID_CONTROL_JUMP         : std_logic;
  signal MID_CONTROL_ANDLINK      : std_logic;
  signal MID_CONTROL_ANDLINKREG   : std_logic;
  signal MID_CONTROL_IMMTYPE      : std_logic_vector(2 downto 0);
  signal MID_CONTROL_ALUCONTROL   : std_logic_vector(3 downto 0);
  signal MID_ALU_ZERO             : std_logic;
  signal MID_ALU_LT               : std_logic;
  signal MID_ALU_LTU              : std_logic;
  signal MID_BRANCH_COND          : std_logic;
  signal MID_BRANCH_TAKEN         : std_logic;
  signal MID_ALU_A_IN             : std_logic_vector(31 downto 0);
  signal MID_PC_BASE              : std_logic_vector(31 downto 0);
  signal MID_JALR_SEL             : std_logic;



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
             
-- Poor man's immgen for now: send the S-Type immediate for 'sw' when appropriate, otherwise send I-Type immediate
  with MID_CONTROL_IMMTYPE select
    MID_IMMEDIATE_FULL <= 
      (31 downto 12 => s_Inst(31)) & s_Inst(31 downto 25) & s_Inst(11 downto 7) when "001",                      -- S-type
      (31 downto 12 => s_Inst(31)) & s_Inst(7) & s_Inst(30 downto 25) & s_Inst(11 downto 8) & '0' when "010",    -- B-type
      s_Inst(31 downto 12) & x"000" when "011",                                                                  -- U-type
      (31 downto 20 => s_Inst(31)) & s_Inst(19 downto 12) & s_Inst(20) & s_Inst(30 downto 21) & '0' when "100",  -- J-type
      (31 downto 11 => s_Inst(31)) & s_Inst(30 downto 20) when others;                                           -- I-type
             
              
CONTROL_UNIT: control
port MAP(i_opcode        => s_Inst(6 downto 0),
         i_func3         => s_Inst(14 downto 12),
         i_func7         => s_Inst(31 downto 25),
         o_RegWrite      => s_RegWr,
         o_MemWrite      => s_DMemWr,
         o_ALUSrcA       => MID_ALUSRCA,
         o_ALUSrcB       => MID_ALUSRCB,
         o_MemToReg      => MID_MEMTOREG,
         o_Branch        => MID_CONTROL_BRANCH,
         o_Jump          => MID_CONTROL_JUMP,
         o_AndLink       => MID_CONTROL_ANDLINK,
         o_AndLinkReg    => MID_CONTROL_ANDLINKREG,
         o_ImmediateType => MID_CONTROL_IMMTYPE,
         o_ALUControl    => MID_CONTROL_ALUCONTROL);

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


pc_add_four: add_sub
    generic MAP(N => N)
    port MAP(i_A  => s_PC,
             i_B  => x"00000004",
             i_C  => '0',
             o_S  => MID_PC_NEXT_4,
             o_C  => open);
             
  -- func3(2:1) picks the condition (beq/bne: zero, blt/bge: signed lt, bltu/bgeu: unsigned lt)
  -- and func3(0) inverts it (bne, bge, bgeu)
  with s_Inst(14 downto 13) select
    MID_BRANCH_COND <= MID_ALU_ZERO when "00",
                       MID_ALU_LT   when "10",
                       MID_ALU_LTU  when "11",
                       '0'          when others;

  MID_BRANCH_TAKEN <= MID_BRANCH_COND xor s_Inst(12);

  pc_and: andg2
    port MAP(i_A  => MID_CONTROL_BRANCH,
             i_B  => MID_BRANCH_TAKEN,
             o_F  => MID_PC_AND);
             
  pc_or: org2
    port MAP(i_A  => MID_CONTROL_JUMP, -- IDK ON THIS ONE
             i_B  => MID_PC_AND,
             o_F  => MID_PC_MUX_SEL);

  PC_BASE_MUX: mux2t1_N
    generic MAP(N => N)
    port MAP(i_S  => MID_CONTROL_ANDLINKREG,
             i_D0 => s_PC,
             i_D1 => MID_REG_A_OUT,
             o_O  => MID_PC_BASE);
             
  pc_add_jump_reg: add_sub
    generic MAP(N => N)
    port MAP(i_A  => MID_PC_BASE,
             i_B  => MID_IMMEDIATE_FULL,
             i_C  => '0',
             o_S  => MID_PC_JUMP_REG,
             o_C  => open);

  pc_mux: mux2t1_N
    generic MAP(N  => N)
    port MAP(i_S   => MID_PC_MUX_SEL,
         i_D0      => MID_PC_NEXT_4,
         i_D1      => MID_PC_JUMP_REG,
         o_O       => MID_PC_NEXT);
             
  PC_REG: pc
  generic MAP(N => N)
    port MAP(i_CLK => iCLK,
             i_RST => iRST,
             i_WE  => '1',
             i_D   => MID_PC_NEXT,
             o_Q   => s_PC);

  MY_ALU: alu
    generic MAP(N => N)
    port MAP(i_A          => MID_ALU_A_IN,
             i_B          => MID_ALUMUX_OUT,
             i_ALUControl => MID_CONTROL_ALUCONTROL,
             o_Result     => MID_ADDSUB_OUT,
             o_Zero       => MID_ALU_ZERO,
             o_CarryOut   => open,
             o_LT         => MID_ALU_LT,
             o_LTU        => MID_ALU_LTU);

  DMem: mem
    generic map(DATA_WIDTH => 32,
                ADDR_WIDTH => 10)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);


with MID_ALUSRCA select
    MID_ALU_A_IN <= s_PC          when "01",
                    x"00000000"   when "10",
                    MID_REG_A_OUT when others;

  ALU_SRC_B_MUX: mux2t1_N
    generic MAP(N => N) 
    port MAP(i_S  => MID_ALUSRCB,
             i_D0 => MID_REG_B_OUT,
             i_D1 => MID_IMMEDIATE_FULL,
             o_O  => MID_ALUMUX_OUT);

  AND_LINK_MUX: mux2t1_N
    generic MAP(N  => N)
    port MAP(i_S   => MID_CONTROL_ANDLINK,
         i_D0      => MID_PC_NEXT_4,
         i_D1      => MID_ADDSUB_OUT,
         o_O       => MID_BOTMUX_OUT);

  MEM_TO_REG_MUX: mux2t1_N
  generic MAP(N => N) 
    port MAP(i_S  => MID_MEMTOREG,
             i_D0 => MID_BOTMUX_OUT,
             i_D1 => s_DMemOut,
             o_O  => MID_REGMUX_OUT);


  s_RegWrAddr <= s_Inst(11 downto 7);
  s_RegWrData <= MID_REGMUX_OUT;
  s_DMemAddr <= MID_ADDSUB_OUT;
  s_DMemData <= MID_REG_B_OUT;
  oALUOut <= MID_ADDSUB_OUT;
end structure;

