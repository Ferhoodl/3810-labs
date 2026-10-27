-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- tb_mux32t1_32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the a
-- 32-bit 32-to-1 mux.
--
--
-- 9/20/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux32t1_32 is
         generic(gCLK_HPER   : time := 50 ns);
end tb_mux32t1_32;

architecture behavior of tb_mux32t1_32 is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component mux32t1_32
    port(i_S           : in std_logic_vector(4 downto 0);
         i_D00         : in std_logic_vector(31 downto 0);
         i_D01         : in std_logic_vector(31 downto 0);
         i_D02         : in std_logic_vector(31 downto 0);
         i_D03         : in std_logic_vector(31 downto 0);
         i_D04         : in std_logic_vector(31 downto 0);
         i_D05         : in std_logic_vector(31 downto 0);
         i_D06         : in std_logic_vector(31 downto 0);
         i_D07         : in std_logic_vector(31 downto 0);
         i_D08         : in std_logic_vector(31 downto 0);
         i_D09         : in std_logic_vector(31 downto 0);
         i_D10         : in std_logic_vector(31 downto 0);
         i_D11         : in std_logic_vector(31 downto 0);
         i_D12         : in std_logic_vector(31 downto 0);
         i_D13         : in std_logic_vector(31 downto 0);
         i_D14         : in std_logic_vector(31 downto 0);
         i_D15         : in std_logic_vector(31 downto 0);
         i_D16         : in std_logic_vector(31 downto 0);
         i_D17         : in std_logic_vector(31 downto 0);
         i_D18         : in std_logic_vector(31 downto 0);
         i_D19         : in std_logic_vector(31 downto 0);
         i_D20         : in std_logic_vector(31 downto 0);
         i_D21         : in std_logic_vector(31 downto 0);
         i_D22         : in std_logic_vector(31 downto 0);
         i_D23         : in std_logic_vector(31 downto 0);
         i_D24         : in std_logic_vector(31 downto 0);
         i_D25         : in std_logic_vector(31 downto 0);
         i_D26         : in std_logic_vector(31 downto 0);
         i_D27         : in std_logic_vector(31 downto 0);
         i_D28         : in std_logic_vector(31 downto 0);
         i_D29         : in std_logic_vector(31 downto 0);
         i_D30         : in std_logic_vector(31 downto 0);
         i_D31         : in std_logic_vector(31 downto 0);
         o_O           : out std_logic_vector(31 downto 0));
  end component;

  signal tb_i_S   : std_logic_vector(4 downto 0);
  signal tb_o_O   : std_logic_vector(31 downto 0);

  signal tb_i_D00   : std_logic_vector(31 downto 0);
  signal tb_i_D01   : std_logic_vector(31 downto 0);
  signal tb_i_D02   : std_logic_vector(31 downto 0);
  signal tb_i_D03   : std_logic_vector(31 downto 0);
  signal tb_i_D04   : std_logic_vector(31 downto 0);
  signal tb_i_D05   : std_logic_vector(31 downto 0);
  signal tb_i_D06   : std_logic_vector(31 downto 0);
  signal tb_i_D07   : std_logic_vector(31 downto 0);
  signal tb_i_D08   : std_logic_vector(31 downto 0);
  signal tb_i_D09   : std_logic_vector(31 downto 0);
  signal tb_i_D10   : std_logic_vector(31 downto 0);
  signal tb_i_D11   : std_logic_vector(31 downto 0);
  signal tb_i_D12   : std_logic_vector(31 downto 0);
  signal tb_i_D13   : std_logic_vector(31 downto 0);
  signal tb_i_D14   : std_logic_vector(31 downto 0);
  signal tb_i_D15   : std_logic_vector(31 downto 0);
  signal tb_i_D16   : std_logic_vector(31 downto 0);
  signal tb_i_D17   : std_logic_vector(31 downto 0);
  signal tb_i_D18   : std_logic_vector(31 downto 0);
  signal tb_i_D19   : std_logic_vector(31 downto 0);
  signal tb_i_D20   : std_logic_vector(31 downto 0);
  signal tb_i_D21   : std_logic_vector(31 downto 0);
  signal tb_i_D22   : std_logic_vector(31 downto 0);
  signal tb_i_D23   : std_logic_vector(31 downto 0);
  signal tb_i_D24   : std_logic_vector(31 downto 0);
  signal tb_i_D25   : std_logic_vector(31 downto 0);
  signal tb_i_D26   : std_logic_vector(31 downto 0);
  signal tb_i_D27   : std_logic_vector(31 downto 0);
  signal tb_i_D28   : std_logic_vector(31 downto 0);
  signal tb_i_D29   : std_logic_vector(31 downto 0);
  signal tb_i_D30   : std_logic_vector(31 downto 0);
  signal tb_i_D31   : std_logic_vector(31 downto 0);

begin

  DUT: mux32t1_32
    port map(i_S   => tb_i_S,
             i_D00 => tb_i_D00,
             i_D01 => tb_i_D01,
             i_D02 => tb_i_D02,
             i_D03 => tb_i_D03,
             i_D04 => tb_i_D04,
             i_D05 => tb_i_D05,
             i_D06 => tb_i_D06,
             i_D07 => tb_i_D07,
             i_D08 => tb_i_D08,
             i_D09 => tb_i_D09,
             i_D10 => tb_i_D10,
             i_D11 => tb_i_D11,
             i_D12 => tb_i_D12,
             i_D13 => tb_i_D13,
             i_D14 => tb_i_D14,
             i_D15 => tb_i_D15,
             i_D16 => tb_i_D16,
             i_D17 => tb_i_D17,
             i_D18 => tb_i_D18,
             i_D19 => tb_i_D19,
             i_D20 => tb_i_D20,
             i_D21 => tb_i_D21,
             i_D22 => tb_i_D22,
             i_D23 => tb_i_D23,
             i_D24 => tb_i_D24,
             i_D25 => tb_i_D25,
             i_D26 => tb_i_D26,
             i_D27 => tb_i_D27,
             i_D28 => tb_i_D28,
             i_D29 => tb_i_D29,
             i_D30 => tb_i_D30,
             i_D31 => tb_i_D31,
             o_O   => tb_o_O);

  
  -- Testbench process  
  P_TB: process
  begin

    -- Setup:
    tb_i_D00 <= x"00000000";
    tb_i_D01 <= x"00000001";
    tb_i_D02 <= x"00000002";
    tb_i_D03 <= x"00000003";
    tb_i_D04 <= x"00000004";
    tb_i_D05 <= x"00000005";
    tb_i_D06 <= x"00000006";
    tb_i_D07 <= x"00000007";
    tb_i_D08 <= x"00000008";
    tb_i_D09 <= x"00000009";
    tb_i_D10 <= x"0000000A";
    tb_i_D11 <= x"0000000B";
    tb_i_D12 <= x"0000000C";
    tb_i_D13 <= x"0000000D";
    tb_i_D14 <= x"0000000E";
    tb_i_D15 <= x"0000000F";
    tb_i_D16 <= x"00000010";
    tb_i_D17 <= x"00000011";
    tb_i_D18 <= x"00000012";
    tb_i_D19 <= x"00000013";
    tb_i_D20 <= x"00000014";
    tb_i_D21 <= x"00000015";
    tb_i_D22 <= x"00000016";
    tb_i_D23 <= x"00000017";
    tb_i_D24 <= x"00000018";
    tb_i_D25 <= x"00000019";
    tb_i_D26 <= x"0000001A";
    tb_i_D27 <= x"0000001B";
    tb_i_D28 <= x"0000001C";
    tb_i_D29 <= x"0000001D";
    tb_i_D30 <= x"0000001E";
    tb_i_D31 <= x"0000001F";

    -- Test case 0:
    tb_i_S <= "00000";
    wait for cCLK_PER;

    -- Test case 1:
    tb_i_S <= "00001";
    wait for cCLK_PER;

    -- Test case 2:
    tb_i_S <= "00010";
    wait for cCLK_PER;

    -- Test case 3:
    tb_i_S <= "00011";
    wait for cCLK_PER;

    -- Test case 4:
    tb_i_S <= "00100";
    wait for cCLK_PER;

    -- Test case 5:
    tb_i_S <= "00101";
    wait for cCLK_PER;

    -- Test case 6:
    tb_i_S <= "00110";
    wait for cCLK_PER;

    -- Test case 7:
    tb_i_S <= "00111";
    wait for cCLK_PER;

    -- Test case 8:
    tb_i_S <= "01000";
    wait for cCLK_PER;

    -- Test case 9:
    tb_i_S <= "01001";
    wait for cCLK_PER;

    -- Test case 10:
    tb_i_S <= "01010";
    wait for cCLK_PER;

    -- Test case 11:
    tb_i_S <= "01011";
    wait for cCLK_PER;

    -- Test case 12:
    tb_i_S <= "01100";
    wait for cCLK_PER;

    -- Test case 13:
    tb_i_S <= "01101";
    wait for cCLK_PER;

    -- Test case 14:
    tb_i_S <= "01110";
    wait for cCLK_PER;

    -- Test case 15:
    tb_i_S <= "01111";
    wait for cCLK_PER;

    -- Test case 16:
    tb_i_S <= "10000";
    wait for cCLK_PER;

    -- Test case 17:
    tb_i_S <= "10001";
    wait for cCLK_PER;

    -- Test case 18:
    tb_i_S <= "10010";
    wait for cCLK_PER;

    -- Test case 19:
    tb_i_S <= "10011";
    wait for cCLK_PER;

    -- Test case 20:
    tb_i_S <= "10100";
    wait for cCLK_PER;

    -- Test case 21:
    tb_i_S <= "10101";
    wait for cCLK_PER;

    -- Test case 22:
    tb_i_S <= "10110";
    wait for cCLK_PER;

    -- Test case 23:
    tb_i_S <= "10111";
    wait for cCLK_PER;

    -- Test case 24:
    tb_i_S <= "11000";
    wait for cCLK_PER;

    -- Test case 25:
    tb_i_S <= "11001";
    wait for cCLK_PER;

    -- Test case 26:
    tb_i_S <= "11010";
    wait for cCLK_PER;

    -- Test case 27:
    tb_i_S <= "11011";
    wait for cCLK_PER;

    -- Test case 28:
    tb_i_S <= "11100";
    wait for cCLK_PER;

    -- Test case 29:
    tb_i_S <= "11101";
    wait for cCLK_PER;

    -- Test case 30:
    tb_i_S <= "11110";
    wait for cCLK_PER;

    -- Test case 31:
    tb_i_S <= "11111";
    wait for cCLK_PER;

    wait;
  end process;
  
end behavior;