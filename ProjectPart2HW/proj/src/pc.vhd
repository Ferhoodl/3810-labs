-------------------------------------------------------------------------
-- Troy Tomson
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- pc.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file is the program counter register.
--
-- 10/13/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity pc is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
end pc;

architecture structure of pc is

  component dffg
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_D          : in std_logic;
         o_Q          : out std_logic);
  end component;

  component dffg_set
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_D          : in std_logic;
         o_Q          : out std_logic);
  end component;

begin

  -- This is an annoying part where we have to treat bit 22 differently so every bit resets to 0 except bit 22 so that the PC resets to 0x00400000
  -- seems weird to me, but I guess I'm the one who's learning
  GEN_NBit_DFFG: for i in 0 to N-1 generate
    GEN_RESET_ZERO: if i /= 22 generate
      DFFGI: dffg port map(
                i_CLK     => i_CLK,
                i_RST     => i_RST,
                i_WE      => i_WE,
                i_D       => i_D(i),
                o_Q       => o_Q(i));
    end generate GEN_RESET_ZERO;

    GEN_RESET_ONE: if i = 22 generate
      DFFGI: dffg_set port map(
                i_CLK     => i_CLK,
                i_RST     => i_RST,
                i_WE      => i_WE,
                i_D       => i_D(i),
                o_Q       => o_Q(i));
    end generate GEN_RESET_ONE;
  end generate GEN_NBit_DFFG;

end structure;
