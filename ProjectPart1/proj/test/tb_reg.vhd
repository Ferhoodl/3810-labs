-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------
-- tb_adder_n.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for an n-bit register.
--              
-- 09/16/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_reg is
  generic(
  gCLK_HPER   : time := 10 ns;   -- Generic for half of the clock cycle period
  N           : integer := 32);
end tb_reg;



architecture mixed of tb_reg is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component reg is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
end component;


signal s_i_CLK    : std_logic := '0';
signal s_i_RST    : std_logic := '0';
signal s_i_WE     : std_logic := '0';
signal s_i_D      : std_logic_vector(N-1 downto 0);
signal s_o_Q      : std_logic_vector(N-1 downto 0);


begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: reg
  generic map(N => N)
  port map( i_CLK        => s_i_CLK, -- clock
            i_RST        => s_i_RST, -- reset
            i_WE         => s_i_WE,  -- write enable
            i_D          => s_i_D,   -- data value input
            o_Q          => s_o_Q);  -- data value output
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

--This first process is to setup the clock for the test bench
P_CLK: process
begin
  s_i_CLK <= '1';         -- clock starts at 1
  wait for gCLK_HPER; -- after half a cycle
  s_i_CLK <= '0';         -- clock becomes a 0 (negative edge)
  wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
end process;


  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Test case 0:
    s_i_RST <= '0';         -- reset
    s_i_WE  <= '1';         -- write enable
    s_i_D   <= x"FFFFFFFF"; -- data value input
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test case 1:
    s_i_RST <= '0';         -- reset
    s_i_WE  <= '0';         -- write enable
    s_i_D   <= x"AAAAAAAA"; -- data value input
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test case 2:
    s_i_RST <= '1';         -- reset
    s_i_WE  <= '0';         -- write enable
    s_i_D   <= x"00000000"; -- data value input
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test case 3:
    s_i_RST <= '0';         -- reset
    s_i_WE  <= '1';         -- write enable
    s_i_D   <= x"11111111"; -- data value input
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;


    wait;
  end process;

end mixed;
