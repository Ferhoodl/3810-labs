-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- add_sub.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation for an
-- adder/subtracter unit.
--
-- 09/08/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity add_sub is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       i_C         : in std_logic;
       o_S         : out std_logic_vector(N-1 downto 0);
       o_C         : out std_logic);

end add_sub;

architecture structure of add_sub is
  
  -- Describe the component entities as defined in their
  -- respective .vhd files.
  component complimentor
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_I          : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component adder_N
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
         i_C         : in std_logic;
         o_S        : out std_logic_vector(N-1 downto 0);
         o_C        : out std_logic);
  end component;



  -- line to carry output of inverter
  signal MID_INV_OUT         : std_logic_vector(N-1 downto 0);

  -- line to carry output of mux
  signal MID_MUX_OUT         : std_logic_vector(N-1 downto 0);


begin


-- NOT the i_S signal so we have normal and notted

  ones_complimenter: complimentor
    generic MAP(N => N)
    port MAP(i_I => i_B,
             o_O => MID_INV_OUT);


  mux: mux2t1_N
    generic MAP(N => N)
    port MAP(i_S  => i_C,
             i_D0 => i_B,
             i_D1 => MID_INV_OUT,
             o_O  => MID_MUX_OUT);


  adder: adder_N
    generic MAP(N => N)
    port MAP(i_A => i_A,
             i_B => MID_MUX_OUT,
             i_C => i_C,
             o_S => o_S,
             o_C => o_C);


  end structure;
