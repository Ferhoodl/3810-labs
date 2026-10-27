
-------------------------------------------------------------------------
-- Troy Tomson
-- tb_pc.vhd
-- DESCRIPTION: Testbench for the program counter register
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use std.env.all;

entity tb_pc is
end tb_pc;

architecture test of tb_pc is

    constant N : integer := 32;
    constant gCLK_HPER : time := 5 ns;

    signal s_CLK : std_logic := '0';
    signal s_RST : std_logic := '0';
    signal s_WE  : std_logic := '1';
    signal s_D   : std_logic_vector(N-1 downto 0)
                   := x"00400000";
    signal s_Q   : std_logic_vector(N-1 downto 0);

begin

    -- Clock generation
    s_CLK <= not s_CLK after gCLK_HPER;

    -- PC under test
    DUT: entity work.pc
        generic map(N => N)
        port map(
            i_CLK => s_CLK,
            i_RST => s_RST,
            i_WE  => s_WE,
            i_D   => s_D,
            o_Q   => s_Q
        );

    -- Test process
    test_proc: process
    begin

        -- Reset the PC
        s_RST <= '1';
        wait until rising_edge(s_CLK);
        wait for 1 ns;

        assert s_Q = x"00400000"
            report "FAIL: PC reset value is incorrect"
            severity error;

        s_RST <= '0';

        -- Load the initial PC
        s_D <= x"00400000";
        s_WE <= '1';
        wait until rising_edge(s_CLK);
        wait for 1 ns;

        assert s_Q = x"00400000"
            report "FAIL: PC did not load initial address"
            severity error;

        -- PC + 4
        s_D <= x"00400004";
        wait until rising_edge(s_CLK);
        wait for 1 ns;

        assert s_Q = x"00400004"
            report "FAIL: PC did not increment to 0x00400004"
            severity error;

        -- PC + 4 again
        s_D <= x"00400008";
        wait until rising_edge(s_CLK);
        wait for 1 ns;

        assert s_Q = x"00400008"
            report "FAIL: PC did not increment to 0x00400008"
            severity error;

        -- Branch/Jump
        s_D <= x"00400100";
        wait until rising_edge(s_CLK);
        wait for 1 ns;

        assert s_Q = x"00400100"
            report "FAIL: PC did not load branch/jump target"
            severity error;

        stop;
        wait;
    end process;

end test;
