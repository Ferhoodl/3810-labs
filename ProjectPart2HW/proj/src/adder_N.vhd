-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide
-- adder
--
--
-- NOTES:
-- 1/6/20 by H3::Created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B         : in std_logic_vector(N-1 downto 0);
       i_C         : in std_logic;
       o_S        : out std_logic_vector(N-1 downto 0);
       o_C        : out std_logic);
end adder_N;


architecture structural of adder_N is

  component my_adder is
    port(i_A 		            : in std_logic;
         i_B 		            : in std_logic;
         i_C 		            : in std_logic;
         o_S 		            : out std_logic;
         o_C 		            : out std_logic);
  end component;

signal carry : std_logic_vector(N downto 0);


begin

  carry(0) <= i_C;

  -- Instantiate N mux instances.
  G_NBit_ADD: for i in 0 to N-1 generate
    ADDI: my_adder port map(
              i_A     => i_A(i),
              i_B     => i_B(i),
              i_C     => carry(i),
              o_S     => o_S(i),
              o_C     => carry(i+1));
  end generate G_NBit_ADD;

  o_C <= carry(N);
  
end structural;
