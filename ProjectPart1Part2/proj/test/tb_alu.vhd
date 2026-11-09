-------------------------------------------------------------------------
-- Troy Tomson
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------
-- tb_alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the ALU
--              
-- 10/27/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_alu is
  generic(
  gCLK_HPER   : time := 10 ns;
  N           : integer := 32);
end tb_alu;



architecture mixed of tb_alu is


constant cCLK_PER  : time := gCLK_HPER * 2;

component alu is
  generic(N : integer := 32);
  port(i_A          : in  std_logic_vector(N-1 downto 0);
       i_B          : in  std_logic_vector(N-1 downto 0);
       i_ALUControl : in  std_logic_vector(3 downto 0);
       o_Result     : out std_logic_vector(N-1 downto 0);
       o_Zero       : out std_logic;
       o_CarryOut   : out std_logic;
       o_LT         : out std_logic;
       o_LTU        : out std_logic);
end component;

signal s_i_A          : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_i_B          : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_i_ALUControl : std_logic_vector(3 downto 0) := "0000";
signal s_o_Result     : std_logic_vector(N-1 downto 0);
signal s_o_Zero       : std_logic;
signal s_o_CarryOut   : std_logic;
signal s_o_LT         : std_logic;
signal s_o_LTU        : std_logic;


begin

  DUT0: alu
  generic map(
    N => N)
  port map( i_A          => s_i_A,
            i_B          => s_i_B,
            i_ALUControl => s_i_ALUControl,
            o_Result     => s_o_Result,
            o_Zero       => s_o_Zero,
            o_CarryOut   => s_o_CarryOut,
            o_LT         => s_o_LT,
            o_LTU        => s_o_LTU);

  -- alucontrol add 0000 sll 0001 and 0010 or 0011 xor 0100 srl 0101 sub 1000 slt 1010 sltu 1011 sra 1101
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER*2;

    -- 1 add -- r type basic addition
    s_i_A <= x"00000001"; s_i_B <= x"00000002"; s_i_ALUControl <= "0000";
    wait for cCLK_PER;
    -- expected: result=0x00000003 zero=0
    assert (s_o_Result = x"00000003" and s_o_Zero = '0')
      report "error: problem on add basic" severity error;

    -- 2 add -- r type rollover and zero flag
    s_i_A <= x"FFFFFFFF"; s_i_B <= x"00000001"; s_i_ALUControl <= "0000";
    wait for cCLK_PER;
    -- expected: result=0x00000000 zero=1
    assert (s_o_Result = x"00000000" and s_o_Zero = '1')
      report "error: problem on add zero flag" severity error;

    -- 3 sub -- r type basic subtraction
    s_i_A <= x"00000005"; s_i_B <= x"00000003"; s_i_ALUControl <= "1000";
    wait for cCLK_PER;
    -- expected: result=0x00000002 zero=0
    assert (s_o_Result = x"00000002" and s_o_Zero = '0')
      report "error: problem on sub basic" severity error;

    -- 4 sub -- r type equal values and zero flag
    s_i_A <= x"00000003"; s_i_B <= x"00000003"; s_i_ALUControl <= "1000";
    wait for cCLK_PER;
    -- expected: result=0x00000000 zero=1
    assert (s_o_Result = x"00000000" and s_o_Zero = '1')
      report "error: problem on sub zero flag" severity error;

    -- 5 sub -- r type negative result and lt flags
    s_i_A <= x"00000003"; s_i_B <= x"00000005"; s_i_ALUControl <= "1000";
    wait for cCLK_PER;
    -- expected: result=0xFFFFFFFE zero=0 lt=1 ltu=1
    assert (s_o_Result = x"FFFFFFFE" and s_o_Zero = '0' and s_o_LT = '1' and s_o_LTU = '1')
      report "error: problem on sub negative result" severity error;

    -- 6 and -- r type bitwise and
    s_i_A <= x"F0F0F0F0"; s_i_B <= x"FFFF0000"; s_i_ALUControl <= "0010";
    wait for cCLK_PER;
    -- expected: result=0xF0F00000 zero=0
    assert (s_o_Result = x"F0F00000" and s_o_Zero = '0')
      report "error: problem on bitwise and" severity error;

    -- 7 or -- r type bitwise or
    s_i_A <= x"F0F0F0F0"; s_i_B <= x"0F0F0F0F"; s_i_ALUControl <= "0011";
    wait for cCLK_PER;
    -- expected: result=0xFFFFFFFF zero=0
    assert (s_o_Result = x"FFFFFFFF" and s_o_Zero = '0')
      report "error: problem on bitwise or" severity error;

    -- 8 xor -- r type bitwise xor
    s_i_A <= x"FFFF0000"; s_i_B <= x"FF00FF00"; s_i_ALUControl <= "0100";
    wait for cCLK_PER;
    -- expected: result=0x00FFFF00 zero=0
    assert (s_o_Result = x"00FFFF00" and s_o_Zero = '0')
      report "error: problem on bitwise xor" severity error;

    -- 9 sll -- r type shift left logical
    s_i_A <= x"00000001"; s_i_B <= x"00000004"; s_i_ALUControl <= "0001";
    wait for cCLK_PER;
    -- expected: result=0x00000010 zero=0
    assert (s_o_Result = x"00000010" and s_o_Zero = '0')
      report "error: problem on sll" severity error;

    -- 10 srl -- r type shift right logical
    s_i_A <= x"80000000"; s_i_B <= x"00000004"; s_i_ALUControl <= "0101";
    wait for cCLK_PER;
    -- expected: result=0x08000000 zero=0
    assert (s_o_Result = x"08000000" and s_o_Zero = '0')
      report "error: problem on srl" severity error;

    -- 11 sra -- r type shift right arithmetic
    s_i_A <= x"80000000"; s_i_B <= x"00000004"; s_i_ALUControl <= "1101";
    wait for cCLK_PER;
    -- expected: result=0xF8000000 zero=0
    assert (s_o_Result = x"F8000000" and s_o_Zero = '0')
      report "error: problem on sra" severity error;

    -- 12 slt -- r type set less than true signed
    s_i_A <= x"FFFFFFFF"; s_i_B <= x"00000001"; s_i_ALUControl <= "1010";
    wait for cCLK_PER;
    -- expected: result=0x00000001 zero=0 lt=1
    assert (s_o_Result = x"00000001" and s_o_Zero = '0' and s_o_LT = '1')
      report "error: problem on slt true" severity error;

    -- 13 sltu -- r type set less than unsigned false
    s_i_A <= x"FFFFFFFF"; s_i_B <= x"00000001"; s_i_ALUControl <= "1011";
    wait for cCLK_PER;
    -- expected: result=0x00000000 zero=1 ltu=0
    assert (s_o_Result = x"00000000" and s_o_Zero = '1' and s_o_LTU = '0')
      report "error: problem on sltu false" severity error;

    -- 14 slt -- r type set less than false signed
    s_i_A <= x"00000001"; s_i_B <= x"FFFFFFFF"; s_i_ALUControl <= "1010";
    wait for cCLK_PER;
    -- expected: result=0x00000000 zero=1 lt=0
    assert (s_o_Result = x"00000000" and s_o_Zero = '1' and s_o_LT = '0')
      report "error: problem on slt false" severity error;

    -- 15 sltu -- r type set less than unsigned true
    s_i_A <= x"00000001"; s_i_B <= x"FFFFFFFF"; s_i_ALUControl <= "1011";
    wait for cCLK_PER;
    -- expected: result=0x00000001 zero=0 ltu=1
    assert (s_o_Result = x"00000001" and s_o_Zero = '0' and s_o_LTU = '1')
      report "error: problem on sltu true" severity error;

    wait;
  end process;

end mixed;
