-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- store_align.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation for the
-- store aligner. It replicates the store data across the word and picks
-- the byte enables for sb, sh, and sw.
--
-- 10/27/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity store_align is
  port(
    i_Data       : in  std_logic_vector(31 downto 0);
    i_Address    : in  std_logic_vector(1 downto 0);
    i_Size       : in  std_logic_vector(1 downto 0);
    o_Data       : out std_logic_vector(31 downto 0);
    o_ByteEnable : out std_logic_vector(3 downto 0)
  );
end store_align;

architecture dataflow of store_align is
begin

  with i_Size select
    o_Data <= i_Data(7 downto 0) & i_Data(7 downto 0) & i_Data(7 downto 0) & i_Data(7 downto 0) when "00", -- sb
              i_Data(15 downto 0) & i_Data(15 downto 0)                                         when "01", -- sh
              i_Data                                                                            when others; -- sw

  o_ByteEnable <= "0001" when (i_Size = "00" and i_Address = "00") else
                  "0010" when (i_Size = "00" and i_Address = "01") else
                  "0100" when (i_Size = "00" and i_Address = "10") else
                  "1000" when (i_Size = "00" and i_Address = "11") else
                  "0011" when (i_Size = "01" and i_Address(1) = '0') else
                  "1100" when (i_Size = "01" and i_Address(1) = '1') else
                  "1111";

end dataflow;
