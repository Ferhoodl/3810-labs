-------------------------------------------------------------------------
-- CprE 3810 Project Part 2: Phase A exception verification
-- Independent testbench; does not modify the course-provided tb.vhd.
-- TEST_ID: 0 = ebreak, 1 = drain, 2 = store, 3 = unsupported
-------------------------------------------------------------------------

-- Use the normal VHDL types and simulation finish command.
library IEEE;
use IEEE.std_logic_1164.all;
library std;
use std.env.all;

-- Choose which exception program to check when starting the simulator.
entity tb_exception is
  generic(TEST_ID : integer := 0);
end entity;

-- These signals drive the processor clock, reset, and output.
architecture test of tb_exception is
  constant CLK_HPER : time := 10 ns;  -- Half of one clock period
  signal CLK        : std_logic := '0';  -- Processor clock
  signal RST        : std_logic := '0';  -- Processor reset
  signal reset_done : std_logic := '0';  -- Start checking only after reset
  signal alu_out    : std_logic_vector(31 downto 0);  -- Unused top-level ALU output

begin
  -- Run the same processor used by the normal project tests.
  MyRiscv: entity work.RISCV_Processor
    generic map(N => 32)
    port map(iCLK => CLK, iRST => RST, iInstLd => '0',
             iInstAddr => (others => '0'),
             iInstExt => (others => '0'), oALUOut => alu_out);

  -- Generate a clock with a 20 ns period.
  P_CLK: process
  begin
    CLK <= '1';
    wait for CLK_HPER;
    CLK <= '0';
    wait for CLK_HPER;
  end process;

  -- Match the course testbench's reset timing.
  -- Reset the processor before the test program executes.
  P_RST: process
  begin
    RST <= '0';
    wait for CLK_HPER / 2;
    RST <= '1';
    wait for CLK_HPER * 2;
    RST <= '0';
    reset_done <= '1';
    wait;
  end process;

  -- Read internal processor signals without changing the processor.
  P_CHECK: process
    alias regWr is <<signal MyRiscv.s_RegWr : std_logic>>;  -- Register write enable
    alias regAddr is <<signal MyRiscv.s_RegWrAddr : std_logic_vector(4 downto 0)>>;  -- Destination register number
    alias regData is <<signal MyRiscv.s_RegWrData : std_logic_vector(31 downto 0)>>;  -- Value written to a register
    alias memWr is <<signal MyRiscv.s_DMemWr : std_logic>>;  -- Data memory write enable
    alias memAddr is <<signal MyRiscv.s_DMemAddr : std_logic_vector(31 downto 0)>>;  -- Data memory address
    alias memData is <<signal MyRiscv.s_DMemData : std_logic_vector(31 downto 0)>>;  -- Data written to memory
    alias memBE is <<signal MyRiscv.DMem.be : std_logic_vector(3 downto 0)>>;  -- Enabled memory bytes
    alias excPending is <<signal MyRiscv.s_ExceptionPending : std_logic>>;  -- Exception has been detected
    alias excDone is <<signal MyRiscv.s_ExceptionDone : std_logic>>;  -- Older instructions have drained
    alias excCause is <<signal MyRiscv.s_ExceptionCause : std_logic_vector(3 downto 0)>>;  -- Exception type
    alias excPC is <<signal MyRiscv.s_ExceptionPC : std_logic_vector(31 downto 0)>>;  -- Address of faulting instruction
    alias halt is <<signal MyRiscv.s_Halt : std_logic>>;  -- Normal WFI halt must stay low

    variable saw_x5      : boolean := false;  -- Saw x5 = 42
    variable saw_x7      : boolean := false;  -- Saw x7 = 7 in drain test
    variable saw_x8      : boolean := false;  -- Saw x8 = 8 in drain test
    variable saw_x10     : integer := 0;  -- Count writes to the store address register
    variable saw_x11     : boolean := false;  -- Saw the store data value
    variable saw_store   : boolean := false;  -- Saw the one allowed memory store
    variable after_done  : integer := 0;  -- Cycles observed after exception completes

  begin
    -- Reject an unknown test number.
    assert TEST_ID >= 0 and TEST_ID <= 3
      report "Invalid TEST_ID; use 0, 1, 2, or 3" severity failure;

    -- Watch each rising clock edge and time out if the exception never finishes.
    for cycle in 0 to 120 loop
      wait until rising_edge(CLK);

      -- Ignore register and memory activity during reset.
      if reset_done = '1' then
        -- Check meaningful register writes; writes to x0 do not change state.
        if regWr = '1' and regAddr /= "00000" then
          -- The store test needs x10 for the address and x11 for the value.
          if TEST_ID = 2 then
            if regAddr = "01010" then -- x10: array/data address
              assert regData = x"10010000"
                report "Wrong x10 address value" severity failure;
              saw_x10 := saw_x10 + 1;
            elsif regAddr = "01011" then -- x11: store data
              assert regData = x"0000007B"
                report "Wrong x11 store value" severity failure;
              saw_x11 := true;
            else
              assert false report "Unexpected nonzero register write in store test"
                severity failure;
            end if;
          -- Other tests expect x5 to finish before the fault.
          elsif regAddr = "00101" then -- x5: 42
            assert regData = x"0000002A"
              report "Expected x5 = 42" severity failure;
            saw_x5 := true;
          elsif TEST_ID = 1 and regAddr = "00111" then -- x7: 7
            assert regData = x"00000007"
              report "Expected x7 = 7" severity failure;
            saw_x7 := true;
          elsif TEST_ID = 1 and regAddr = "01000" then -- x8: 8
            assert regData = x"00000008"
              report "Expected x8 = 8" severity failure;
            saw_x8 := true;
          else
            assert false report "Unexpected nonzero register write after exception setup"
              severity failure;
          end if;
        end if;

        -- Only the store test may write memory, and only once.
        if memWr = '1' then
          assert TEST_ID = 2
            report "Unexpected memory write in a register-only exception test"
            severity failure;
          assert memAddr = x"10010000" and memData = x"0000007B"
                 and memBE = "1111"
            report "Incorrect memory write (or younger store committed)"
            severity failure;
          assert not saw_store
            report "Unexpected duplicate memory write" severity failure;
          saw_store := true;
        end if;

        -- Once the fault reaches completion, verify its saved information.
        if excDone = '1' then
          assert excPending = '1'
            report "Exception completed without pending state" severity failure;
          assert halt = '0'
            report "WFI halt asserted during an exception test" severity failure;

          -- Test 3 expects unsupported/illegal-instruction cause 2.
          if TEST_ID = 3 then
            assert excCause = "0010"
              report "Expected cause 2 for unsupported instruction"
              severity failure;
          else
            assert excCause = "0011"
              report "Expected cause 3 for EBREAK" severity failure;
          end if;

          -- Each test has its own faulting instruction address.
          if TEST_ID = 1 then
            assert excPC = x"00400018"
              report "Wrong exception PC for drain test" severity failure;
          elsif TEST_ID = 2 then
            assert excPC = x"00400028"
              report "Wrong exception PC for store test" severity failure;
          else
            assert excPC = x"00400010"
              report "Wrong exception PC for EBREAK/unsupported test"
              severity failure;
          end if;

          -- Keep watching for five cycles after completion.
          after_done := after_done + 1;
          -- Confirm every older instruction really completed.
          if after_done = 5 then
            if TEST_ID = 2 then
              assert saw_x10 >= 1 and saw_x11 and saw_store
                report "Older address/data/store instruction did not complete"
                severity failure;
            else
              assert saw_x5
                report "Older x5 = 42 instruction did not complete"
                severity failure;
            end if;
            if TEST_ID = 1 then
              assert saw_x7 and saw_x8
                report "Older x7/x8 instructions did not complete"
                severity failure;
            end if;
            -- Print PASS only after every check succeeds.
            report "PASS: exception test " & integer'image(TEST_ID)
              severity note;
            finish(0);  -- End the simulation successfully
          end if;
        end if;
      end if;
    end loop;

    -- Fail clearly if we run out of cycles.
    assert false report "FAIL: exception did not complete within 120 cycles"
      severity failure;
    finish(1);  -- End the simulation with failure
    wait;
  end process;
end architecture;
