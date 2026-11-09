-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- load_extend.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation for the
-- load extender. It picks the addressed byte or halfword out of the
-- memory word and sign or zero extends it for lb, lh, lbu, lhu, and lw.
--
-- 10/27/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity load_extend is
  port(
    i_Data     : in  std_logic_vector(31 downto 0);
    i_Address  : in  std_logic_vector(1 downto 0);
    i_Size     : in  std_logic_vector(1 downto 0);
    i_Unsigned : in  std_logic;
    o_Data     : out std_logic_vector(31 downto 0)
  );
end load_extend;

architecture dataflow of load_extend is
  signal s_Byte     : std_logic_vector(7 downto 0);
  signal s_Half     : std_logic_vector(15 downto 0);
  signal s_ByteSign : std_logic;
  signal s_HalfSign : std_logic;
begin

  with i_Address select
    s_Byte <= i_Data(7 downto 0)   when "00",
              i_Data(15 downto 8)  when "01",
              i_Data(23 downto 16) when "10",
              i_Data(31 downto 24) when others;

  with i_Address(1) select
    s_Half <= i_Data(15 downto 0)  when '0',
              i_Data(31 downto 16) when others;

  s_ByteSign <= s_Byte(7)  and not i_Unsigned;
  s_HalfSign <= s_Half(15) and not i_Unsigned;

  with i_Size select
    o_Data <= (31 downto 8 => s_ByteSign) & s_Byte when "00", -- lb, lbu
              (31 downto 16 => s_HalfSign) & s_Half when "01", -- lh, lhu
              i_Data                                when others; -- lw

end dataflow;
