-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- sign_extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation for a sign
-- extender.
--
-- 09/23/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity sign_extender is
    port(S_EXT_IN   : in std_logic_vector(11 downto 0);
         S_EXT_OUT    : out std_logic_vector(31 downto 0));
end sign_extender;

architecture flow of sign_extender is

begin
  S_EXT_OUT <= (31 downto 12 => S_EXT_IN(11)) & S_EXT_IN;  -- sign-extend 20 bits to left
end flow;
