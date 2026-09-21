-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- reg_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation for a
-- register file.
--
-- 09/20/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_file is
  generic(N : integer := 32);
  port(i_CLK       : in std_logic;                            -- Clock input
       i_RST       : in std_logic;
       i_W_VAL     : in std_logic_vector(31 downto 0);        -- 32-bit write value
       i_W_ADDR    : in std_logic_vector(4 downto 0);         -- 5-bit write address
       i_W_EN      : in std_logic;                            -- line for write enable
       i_R_ADDR_A  : in std_logic_vector(4 downto 0);         -- 5-bit read address A
       i_R_ADDR_B  : in std_logic_vector(4 downto 0);         -- 5-bit read address B
       o_R_VAL_A   : out std_logic_vector(31 downto 0);       -- 32-bit read value A
       o_R_VAL_B   : out std_logic_vector(31 downto 0);       -- 32-bit read value B
end reg_file

architecture structure of reg_file is
  
  -- Describe the component entities as defined in their
  -- respective .vhd files.


  component reg
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

  component decoder_5t32
    port(DC_IN     : in std_logic_vector(4 downto 0);
         DC_EN     : in std_logic;
         DC_OUT    : out std_logic_vector(31 downto 0));
  end component;

  component mux2t1_N
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component mux32t1_32
    port(i_S          : in std_logic_vector(4 downto 0);
         i_D00         : in std_logic_vector(31 downto 0);
         i_D01         : in std_logic_vector(31 downto 0);
         i_D02         : in std_logic_vector(31 downto 0);
         i_D03         : in std_logic_vector(31 downto 0);
         i_D04         : in std_logic_vector(31 downto 0);
         i_D05         : in std_logic_vector(31 downto 0);
         i_D06         : in std_logic_vector(31 downto 0);
         i_D07         : in std_logic_vector(31 downto 0);
         i_D08         : in std_logic_vector(31 downto 0);
         i_D09         : in std_logic_vector(31 downto 0);
         i_D10         : in std_logic_vector(31 downto 0);
         i_D11         : in std_logic_vector(31 downto 0);
         i_D12         : in std_logic_vector(31 downto 0);
         i_D13         : in std_logic_vector(31 downto 0);
         i_D14         : in std_logic_vector(31 downto 0);
         i_D15         : in std_logic_vector(31 downto 0);
         i_D16         : in std_logic_vector(31 downto 0);
         i_D17         : in std_logic_vector(31 downto 0);
         i_D18         : in std_logic_vector(31 downto 0);
         i_D19         : in std_logic_vector(31 downto 0);
         i_D20         : in std_logic_vector(31 downto 0);
         i_D21         : in std_logic_vector(31 downto 0);
         i_D22         : in std_logic_vector(31 downto 0);
         i_D23         : in std_logic_vector(31 downto 0);
         i_D24         : in std_logic_vector(31 downto 0);
         i_D25         : in std_logic_vector(31 downto 0);
         i_D26         : in std_logic_vector(31 downto 0);
         i_D27         : in std_logic_vector(31 downto 0);
         i_D28         : in std_logic_vector(31 downto 0);
         i_D29         : in std_logic_vector(31 downto 0);
         i_D30         : in std_logic_vector(31 downto 0);
         i_D31         : in std_logic_vector(31 downto 0);
         o_O          : out std_logic_vector(31 downto 0));
  end component;


  -- line to carry output of decoder
  signal MID_DEC_OUT                : std_logic_vector(31 downto 0);

  -- line to carry outputs of muxes in front of registers (muxes that decide to write or not)
  signal MID_MUX_2T1_00_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_01_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_02_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_03_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_04_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_05_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_06_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_07_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_08_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_09_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_10_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_11_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_12_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_13_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_14_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_15_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_16_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_17_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_18_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_19_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_20_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_21_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_22_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_23_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_24_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_25_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_26_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_27_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_28_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_29_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_30_OUT         : std_logic_vector(31 downto 0);
  signal MID_MUX_2T1_31_OUT         : std_logic_vector(31 downto 0);

  signal MID_REG_00_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_01_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_02_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_03_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_04_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_05_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_06_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_07_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_08_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_09_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_10_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_11_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_12_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_13_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_14_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_15_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_16_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_17_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_18_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_19_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_20_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_21_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_22_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_23_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_24_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_25_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_26_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_27_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_28_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_29_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_30_OUT             : std_logic_vector(31 downto 0);
  signal MID_REG_31_OUT             : std_logic_vector(31 downto 0);


begin

  decoder : decoder_5t32
    port MAP(DC_IN  => i_W_ADDR,
             DC_EN  => i_W_EN,
             DC_OUT => MID_DEC_OUT);

  mux_2t1_00: mux2t1_N generic MAP(N => N) port MAP(i_S  => MID_DEC_OUT(0), i_D0 => MID_REG_00_OUT, i_D1 => i_W_VAL, o_O  => MID_MUX_OUT);
  mux_2t1_01: mux2t1_N generic MAP(N => N) port MAP(i_S  => MID_DEC_OUT(1), i_D0 => MID_REG_00_OUT, i_D1 => i_W_VAL, o_O  => MID_MUX_OUT);
  mux_2t1_02: mux2t1_N generic MAP(N => N) port MAP(i_S  => MID_DEC_OUT(2), i_D0 => MID_REG_00_OUT, i_D1 => i_W_VAL, o_O  => MID_MUX_OUT);
  mux_2t1_03: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_04: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_05: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_06: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_07: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_08: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_09: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_10: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_11: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_12: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_13: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_14: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_15: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_16: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_17: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_18: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_19: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_20: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_21: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_22: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_23: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_24: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_25: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_26: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_27: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_28: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_29: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_30: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);
  mux_2t1_31: mux2t1_N generic MAP(N => N) port MAP(i_S  => i_C, i_D0 => i_B, i_D1 => MID_INV_OUT, o_O  => MID_MUX_OUT);


  register_00: reg generic MAP(N => N) port MAP(i_CLK => i_CLK, i_RST => i_RST, i_WE  => i_W_EN, i_D   => MID_MUX_2T1_00_OUT, o_Q   => MID_REG_00_OUT);
  register_01: reg generic MAP(N => N) port MAP(i_CLK => i_CLK, i_RST => i_RST, i_WE  => i_W_EN, i_D   => MID_MUX_2T1_00_OUT, o_Q   => MID_REG_00_OUT);
  register_02: reg generic MAP(N => N) port MAP(i_CLK => i_CLK, i_RST => i_RST, i_WE  => i_W_EN, i_D   => MID_MUX_2T1_00_OUT, o_Q   => MID_REG_00_OUT);





  end structure;
