-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- tb_datapath1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for a datapath.
--              
-- 09/21/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_datapath1 is
  generic(
  gCLK_HPER   : time := 10 ns;   -- Generic for half of the clock cycle period
  N           : integer := 32);
end tb_datapath1;



architecture structure of tb_datapath1 is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

component datapath1 is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK         : in std_logic;                            -- Clock input
       i_RST         : in std_logic;
       i_rd          : in std_logic_vector(4 downto 0);         -- 5-bit write address
       i_regWrite    : in std_logic;                            -- line for write enable
       i_rs1         : in std_logic_vector(4 downto 0);         -- 5-bit read address A
       i_rs2         : in std_logic_vector(4 downto 0);         -- 5-bit read address B
       i_imm         : in std_logic_vector(31 downto 0);
       i_AddSub      : in std_logic;
       i_ALUSrc      : in std_logic);
end component;

signal tb_i_CLK       : std_logic;                            -- Clock input
signal tb_i_RST       : std_logic;                            -- line for reset
signal tb_i_rd        : std_logic_vector(4 downto 0);         -- 5-bit write address
signal tb_i_regWrite  : std_logic;                            -- line for write enable
signal tb_i_rs1       : std_logic_vector(4 downto 0);         -- 5-bit read address A
signal tb_i_rs2       : std_logic_vector(4 downto 0);         -- 5-bit read address B
signal tb_i_imm       : std_logic_vector(31 downto 0);        -- 32-bit write value
signal tb_i_AddSub    : std_logic;                            -- 32-bit read value A
signal tb_i_ALUSrc    : std_logic;                            -- 32-bit read value B


begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: datapath1
  generic map(
    N => N)
  port map( 
       i_CLK        => tb_i_CLK,
       i_RST        => tb_i_RST,
       i_rd         => tb_i_rd,
       i_regWrite   => tb_i_regWrite,
       i_rs1        => tb_i_rs1,
       i_rs2        => tb_i_rs2,
       i_imm        => tb_i_imm,
       i_AddSub     => tb_i_AddSub,
       i_ALUSrc     => tb_i_ALUSrc);

--This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    tb_i_CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    tb_i_CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;


  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- helps to remove ambiguous edges

    -- setup
    tb_i_RST      <= '1';
    tb_i_regWrite <= '0';
    wait for cCLK_PER*2;
    
    tb_i_RST      <= '0';
    wait for cCLK_PER;

-- addi x1 , zero , 1      # Place "1" in x1
    tb_i_rd       <= "00001";
    tb_i_rs1      <= "00000";
    tb_i_imm      <= x"00000001";
    tb_i_AddSub   <= '0';
    tb_i_ALUSrc   <= '1';
    tb_i_regWrite <= '1';
    wait for cCLK_PER;

-- addi x2 , zero , 2      # Place "2" in x2
    tb_i_rd       <= "00010";
    tb_i_imm      <= x"00000002";
    wait for cCLK_PER;

-- addi x3 , zero , 3      # Place "3" in x3
    tb_i_rd       <= "00011";
    tb_i_imm      <= x"00000003";
    wait for cCLK_PER;

-- addi x4 , zero , 4      # Place "4" in x4
    tb_i_rd       <= "00100";
    tb_i_imm      <= x"00000004";
    wait for cCLK_PER;

-- addi x5 , zero , 5      # Place "5" in x5
    tb_i_rd       <= "00101";
    tb_i_imm      <= x"00000005";
    wait for cCLK_PER;

-- addi x6 , zero , 6      # Place "6" in x6
    tb_i_rd       <= "00110";
    tb_i_imm      <= x"00000006";
    wait for cCLK_PER;

-- addi x7 , zero , 7      # Place "7" in x7
    tb_i_rd       <= "00111";
    tb_i_imm      <= x"00000007";
    wait for cCLK_PER;

-- addi x8 , zero , 8      # Place "8" in x8
    tb_i_rd       <= "01000";
    tb_i_imm      <= x"00000008";
    wait for cCLK_PER;

-- addi x9 , zero , 9      # Place "9" in x9
    tb_i_rd       <= "01001";
    tb_i_imm      <= x"00000009";
    wait for cCLK_PER;

-- addi x10 , zero , 10    # Place "10" in x10
    tb_i_rd       <= "01010";
    tb_i_imm      <= x"0000000A";
    wait for cCLK_PER;

-- add x11 , x1 , x2       # x11 = x1 + x2
    tb_i_rd       <= "01011";
    tb_i_rs1      <= "00001";
    tb_i_rs2      <= "00010";
    tb_i_AddSub   <= '0';
    tb_i_ALUSrc   <= '0';
    wait for cCLK_PER;

-- sub x12 , x11 , x3      # x12 = x11 - x3
    tb_i_rd       <= "01100";
    tb_i_rs1      <= "01011";
    tb_i_rs2      <= "00011";
    tb_i_AddSub   <= '1';
    tb_i_ALUSrc   <= '0';
    wait for cCLK_PER;

-- add x13 , x12 , x4      # x13 = x12 + x4
    tb_i_rd       <= "01101";
    tb_i_rs1      <= "01100";
    tb_i_rs2      <= "00100";
    tb_i_AddSub   <= '0';
    wait for cCLK_PER;

-- sub x14 , x13 , x5      # x14 = x13 - x5
    tb_i_rd       <= "01110";
    tb_i_rs1      <= "01101";
    tb_i_rs2      <= "00101";
    tb_i_AddSub   <= '1';
    wait for cCLK_PER;

-- add x15 , x14 , x6      # x15 = x14 + x6
    tb_i_rd       <= "01111";
    tb_i_rs1      <= "01110";
    tb_i_rs2      <= "00110";
    tb_i_AddSub   <= '0';
    wait for cCLK_PER;

-- sub x16 , x15 , x7      # x16 = x15 - x7
    tb_i_rd       <= "10000";
    tb_i_rs1      <= "01111";
    tb_i_rs2      <= "00111";
    tb_i_AddSub   <= '1';
    wait for cCLK_PER;

-- add x17 , x16 , x8      # x17 = x16 + x8
    tb_i_rd       <= "10001";
    tb_i_rs1      <= "10000";
    tb_i_rs2      <= "01000";
    tb_i_AddSub   <= '0';
    wait for cCLK_PER;

-- sub x18 , x17 , x9      # x18 = x17 - x9
    tb_i_rd       <= "10010";
    tb_i_rs1      <= "10001";
    tb_i_rs2      <= "01001";
    tb_i_AddSub   <= '1';
    wait for cCLK_PER;

-- add x19 , x18 , x10     # x19 = x18 + x10
    tb_i_rd       <= "10011";
    tb_i_rs1      <= "10010";
    tb_i_rs2      <= "01010";
    tb_i_AddSub   <= '0';
    wait for cCLK_PER;

-- addi x20 , zero , -35   # Place " -35" in x20
    tb_i_rd       <= "10100";
    tb_i_rs1      <= "00000";
    tb_i_imm      <= x"FFFFFFDD"; -- Two's complement for -35
    tb_i_AddSub   <= '0';
    tb_i_ALUSrc   <= '1';
    wait for cCLK_PER;

-- add x21 , x19 , x20     # x21 = x19 + x20
    tb_i_rd       <= "10101";
    tb_i_rs1      <= "10011";
    tb_i_rs2      <= "10100";
    tb_i_AddSub   <= '0';
    tb_i_ALUSrc   <= '0';
    wait for cCLK_PER;

-- lui x22 , 0 XFEED2      # Place "0 xFEED2000 " in x22
    tb_i_rd       <= "10110";
    tb_i_imm      <= x"FEED2000";
    tb_i_AddSub   <= '1';
    tb_i_ALUSrc   <= '1';
    wait for cCLK_PER;

-- addi x22 , x22 , 0x050  # Complete loading x22 with a large immediate
    tb_i_rd       <= "10110";
    tb_i_rs1      <= "10110";
    tb_i_imm      <= x"00000050";
    tb_i_AddSub   <= '0';
    tb_i_ALUSrc   <= '1';
    wait for cCLK_PER;

    tb_i_regWrite <= '0';
    wait for cCLK_PER;


    wait;
  end process;

end structure;