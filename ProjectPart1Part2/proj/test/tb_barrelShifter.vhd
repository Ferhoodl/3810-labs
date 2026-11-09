-------------------------------------------------------------------------
-- isaiah steele
-- student in cpre 3810
-- iowa state university
-------------------------------------------------------------------------
-- tb_barrelShifter.vhd
-------------------------------------------------------------------------
-- description: testbench for 32-bit barrel shifter.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_barrelShifter is
  generic(gCLK_HPER : time := 10 ns);
end tb_barrelShifter;

architecture behavior of tb_barrelShifter is

  constant cCLK_PER : time := gCLK_HPER * 2;

  component barrelShifter is
    port(
      i_Data    : in  std_logic_vector(31 downto 0);
      i_Shift   : in  std_logic_vector(4 downto 0);
      i_arith   : in  std_logic; -- 0 for srl, 1 for sra
      i_Dir     : in  std_logic; -- 0 for right, 1 for left
      o_Shifted : out std_logic_vector(31 downto 0)
    );
  end component;

  -- test signals
  signal s_Data    : std_logic_vector(31 downto 0) := (others => '0');
  signal s_Shift   : std_logic_vector(4 downto 0)  := (others => '0');
  signal s_arith   : std_logic                     := '0';
  signal s_Dir     : std_logic                     := '0';
  signal s_Shifted : std_logic_vector(31 downto 0);

begin

  DUT: barrelShifter
    port map (
      i_Data    => s_Data,
      i_Shift   => s_Shift,
      i_arith   => s_arith,
      i_Dir     => s_Dir,
      o_Shifted => s_Shifted
    );

  THING_TEST: process
  begin

    -- 1 -- no shift -- pass through
    s_Data <= x"87654321"; s_Shift <= "00000"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x87654321
    assert (s_Shifted = x"87654321")
      report "error: problem on no shift pass through" severity error;

    -- 2 -- sll -- shift left logical by 1
    s_Data <= x"00000001"; s_Shift <= "00001"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x00000002
    assert (s_Shifted = x"00000002")
      report "error: problem on sll by 1" severity error;

    -- 3 -- sll -- shift left logical by 2
    s_Data <= x"00000001"; s_Shift <= "00010"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x00000004
    assert (s_Shifted = x"00000004")
      report "error: problem on sll by 2" severity error;

    -- 4 -- sll -- shift left logical by 4
    s_Data <= x"00000001"; s_Shift <= "00100"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x00000010
    assert (s_Shifted = x"00000010")
      report "error: problem on sll by 4" severity error;


    -- 5 -- sll -- shift left logical by 8
    s_Data <= x"00000001"; s_Shift <= "01000"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x00000100
    assert (s_Shifted = x"00000100")
      report "error: problem on sll by 8" severity error;

    -- 6 -- sll -- shift left logical by 16
    s_Data <= x"00000001"; s_Shift <= "10000"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x00010000
    assert (s_Shifted = x"00010000")
      report "error: problem on sll by 16" severity error;

    -- 7 -- sll -- shift left logical by 31
    s_Data <= x"00000001"; s_Shift <= "11111"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x80000000
    assert (s_Shifted = x"80000000")
      report "error: problem on sll by 31" severity error;

    -- 8 -- sll -- shift left logical overflow zero fill
    s_Data <= x"F000000F"; s_Shift <= "00100"; s_arith <= '0'; s_Dir <= '1';
    wait for cCLK_PER;
    -- expected: shifted=0x000000F0
    assert (s_Shifted = x"000000F0")
      report "error: problem on sll overflow zero fill" severity error;

    -- 9 -- srl -- shift right logical by 1
    s_Data <= x"80000000"; s_Shift <= "00001"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x40000000
    assert (s_Shifted = x"40000000")
      report "error: problem on srl by 1" severity error;

    -- 10 -- srl -- shift right logical by 2
    s_Data <= x"80000000"; s_Shift <= "00010"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x20000000
    assert (s_Shifted = x"20000000")
      report "error: problem on srl by 2" severity error;

    -- 11 -- srl -- shift right logical by 4
    s_Data <= x"F0000000"; s_Shift <= "00100"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x0F000000
    assert (s_Shifted = x"0F000000")
      report "error: problem on srl by 4" severity error;

    -- 12 -- srl -- shift right logical by 8
    s_Data <= x"FF000000"; s_Shift <= "01000"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x00FF0000
    assert (s_Shifted = x"00FF0000")
      report "error: problem on srl by 8" severity error;

    -- 13 -- srl -- shift right logical by 16
    s_Data <= x"FFFF0000"; s_Shift <= "10000"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x0000FFFF
    assert (s_Shifted = x"0000FFFF")
      report "error: problem on srl by 16" severity error;

    -- 14 -- srl -- shift right logical by 31
    s_Data <= x"80000000"; s_Shift <= "11111"; s_arith <= '0'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x00000001
    assert (s_Shifted = x"00000001")
      report "error: problem on srl by 31" severity error;

    -- 15 -- sra -- shift right arithmetic by 1 positive msb
    s_Data <= x"70000000"; s_Shift <= "00001"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0x38000000
    assert (s_Shifted = x"38000000")
      report "error: problem on sra positive msb by 1" severity error;

    -- 16 -- sra -- shift right arithmetic by 1 negative sign extend
    s_Data <= x"80000000"; s_Shift <= "00001"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0xC0000000
    assert (s_Shifted = x"C0000000")
      report "error: problem on sra negative sign extend by 1" severity error;

    -- 17 -- sra -- shift right arithmetic by 2 negative sign extend
    s_Data <= x"80000000"; s_Shift <= "00010"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0xE0000000
    assert (s_Shifted = x"E0000000")
      report "error: problem on sra negative sign extend by 2" severity error;

    -- 18 -- sra -- shift right arithmetic by 4 negative sign extend
    s_Data <= x"F0000000"; s_Shift <= "00100"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0xFF000000
    assert (s_Shifted = x"FF000000")
      report "error: problem on sra negative sign extend by 4" severity error;

    -- 19 -- sra -- shift right arithmetic by 8 negative sign extend
    s_Data <= x"80000000"; s_Shift <= "01000"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0xFF800000
    assert (s_Shifted = x"FF800000")
      report "error: problem on sra negative sign extend by 8" severity error;

    -- 20 -- sra -- shift right arithmetic by 16 negative sign extend
    s_Data <= x"80000000"; s_Shift <= "10000"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0xFFFF8000
    assert (s_Shifted = x"FFFF8000")
      report "error: problem on sra negative sign extend by 16" severity error;

    -- 21 -- sra -- shift right arithmetic by 31 negative sign extend
    s_Data <= x"80000000"; s_Shift <= "11111"; s_arith <= '1'; s_Dir <= '0';
    wait for cCLK_PER;
    -- expected: shifted=0xFFFFFFFF
    assert (s_Shifted = x"FFFFFFFF")
      report "error: problem on sra negative sign extend by 31" severity error;

    wait;
  end process THING_TEST;

end architecture behavior;