-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- mux_behavioral.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a behavioral implementation for a
-- 2-1 mux.
--
-- 09/06/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux_behavioral is

  port(i_S, i_D0, i_D1 : in std_logic;
        o_O            : out std_logic);
	

end mux_behavioral;

architecture behavioral of mux_behavioral is
begin

o_O <= i_D0 when (i_S = '0') else
       i_D1 when (i_S = '1');

end behavioral;
