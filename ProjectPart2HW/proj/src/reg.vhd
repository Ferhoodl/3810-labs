-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- reg.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation for an
-- n-bit register.
--
-- 09/16/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity reg is
  generic(N : integer := 32; -- Generic of type integer for input/output data width. Default value is 32.
          RESET_VALUE : integer := 0); -- Value the register takes on reset
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
end reg;

architecture structure of reg is

  constant c_RESET_VALUE : std_logic_vector(N-1 downto 0) := std_logic_vector(to_unsigned(RESET_VALUE, N));
  
  -- Describe the component entities as defined in their
  -- respective .vhd files.
  component dffg
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic;     -- Data value input
         o_Q          : out std_logic);   -- Data value output
  end component;

  component dffg_set
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic;     -- Data value input
         o_Q          : out std_logic);   -- Data value output
  end component;

begin

  -- Instantiate N mux instances.
  G_NBit_DFFG: for i in 0 to N-1 generate
    GEN_RESET_ZERO: if c_RESET_VALUE(i) = '0' generate
      DFFGI: dffg port map(
                i_CLK     => i_CLK,  
                i_RST     => i_RST,
                i_WE      => i_WE,  
                i_D       => i_D(i),
                o_Q       => o_Q(i));
    end generate GEN_RESET_ZERO;

    GEN_RESET_ONE: if c_RESET_VALUE(i) = '1' generate
      DFFGI: dffg_set port map(
                i_CLK     => i_CLK,
                i_RST     => i_RST,
                i_WE      => i_WE,
                i_D       => i_D(i),
                o_Q       => o_Q(i));
    end generate GEN_RESET_ONE;
  end generate G_NBit_DFFG;

  end structure;
