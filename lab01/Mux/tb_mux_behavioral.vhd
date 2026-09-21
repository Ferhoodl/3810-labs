-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------
-- tb_mux_behavioral.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for a 2-1 mux.
--              
-- 09/06/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_mux_behavioral is
  generic(gCLK_HPER   : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_mux_behavioral;



architecture mixed of tb_mux_behavioral is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify its
-- component interface.
-- TODO: change component declaration as needed.
component mux_behavioral is
  port(i_S 		            : in std_logic;
       i_D0 		            : in std_logic;
       i_D1 		            : in std_logic;
       o_O 		            : out std_logic);
end component;

signal s_i_S    : std_logic := '0';
signal s_i_D0   : std_logic := '0';
signal s_i_D1   : std_logic := '0';
signal s_o_O    : std_logic := '0';


begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: mux_behavioral
  port map( i_S        => s_i_S,
            i_D0       => s_i_D0,
            i_D1       => s_i_D1,
            o_O        => s_o_O);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  -- Assign inputs for each test case.
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER*2;

    -- Test case 0:
    s_i_S <= '0';
    s_i_D0 <= '0';
    s_i_D1 <= '0';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 1:
    s_i_S <= '0';
    s_i_D0 <= '0';
    s_i_D1 <= '1';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 2:
    s_i_S <= '0';
    s_i_D0 <= '1';
    s_i_D1 <= '0';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 3:
    s_i_S <= '0';
    s_i_D0 <= '1';
    s_i_D1 <= '1';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 4:
    s_i_S <= '1';
    s_i_D0 <= '0';
    s_i_D1 <= '0';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 5:
    s_i_S <= '1';
    s_i_D0 <= '0';
    s_i_D1 <= '1';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 6:
    s_i_S <= '1';
    s_i_D0 <= '1';
    s_i_D1 <= '0';
    wait for cCLK_PER;
    wait for cCLK_PER;

    -- Test case 7:
    s_i_S <= '1';
    s_i_D0 <= '1';
    s_i_D1 <= '1';
    wait for cCLK_PER;
    wait for cCLK_PER;

    wait;
  end process;

end mixed;
