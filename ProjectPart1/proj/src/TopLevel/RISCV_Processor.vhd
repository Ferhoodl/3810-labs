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
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
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


  component andg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

begin
  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.
  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)

  -- TODO: Implement the rest of your processor below this comment! 

end structure;

