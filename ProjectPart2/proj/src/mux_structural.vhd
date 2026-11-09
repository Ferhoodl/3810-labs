-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- mux_structural.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation for a
-- 2-1 mux.
--
-- 09/06/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux_structural is

  port(i_S 		            : in std_logic;
       i_D0 		            : in std_logic;
       i_D1 		            : in std_logic;
       o_O 		            : out std_logic);

end mux_structural;

architecture structure of mux_structural is
  
  -- Describe the component entities as defined in their
  -- respective .vhd files.
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

  component invg
    port(i_A          : in std_logic;
         o_F          : out std_logic);
  end component;



  -- line to carry not i_S
  signal not_i_S       : std_logic;

  -- line to carry signal between and0 and or.
  signal mid_0         : std_logic;

  -- line to carry signal between and1 and or.
  signal mid_1         : std_logic;

begin


-- NOT the i_S signal so we have normal and notted
  notter: invg
    port MAP(i_A  => i_S,
             o_F  => not_i_S);


  and_0: andg2
    port MAP(i_A  => i_D0,
             i_B  => not_i_S,
             o_F  => mid_0);

  and_1: andg2
    port MAP(i_A  => i_D1,
             i_B  => i_S,
             o_F  => mid_1);

  or_0: org2
    port MAP(i_A  => mid_0,
             i_B  => mid_1,
             o_F  => o_O

);

  end structure;
