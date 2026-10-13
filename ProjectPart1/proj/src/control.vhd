-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation for an
-- control unit. 
--
-- 10/07/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity control is
  port(i_opcode     : in std_logic_vector(6 downto 0);
       i_func7      : in std_logic_vector(6 downto 0);

       o_RegWrite   : out std_logic;
       o_MemWrite   : out std_logic;
       o_AddSub     : out std_logic;
       o_ALUSrc     : out std_logic;
       o_IMMSel     : out std_logic;
       o_MemToReg   : out std_logic);

  
--       i_func3      : in std_logic_vector(2 downto 0);
--
--        o_ALUControl : out std_logic_vector(3 downto 0);
--        o_ImmType    : out std_logic_vector(2 downto 0);
--
--
--
--       o_Branch     : out std_logic;
--       o_Jump       : out std_logic;
--       o_MemToReg   : out std_logic;
--       o_MemWrite   : out std_logic;
--       o_AndLink    : out std_logic;
--       o_ALUSrc     : out std_logic;
--       o_RegWrite   : out std_logic);
       

end control;

architecture dataflow of control is
	-- RegWrite, MemWrite, AddSub, ALUSrc, IMMSel, MemToReg
	signal signal_bus : std_logic_vector(4 downto 0);

	--signal aluop_bus : std_logic_vector(1 downto 0);
begin
with i_opcode select
  signal_bus <= "10000" when "0110011", -- R-type (like ADD)
                "10110" when "0010011", -- I-type (like ADDI)
                "10111" when "0000011", -- I-type (like LW)
                "01110" when "0100011", -- S-type (like SW)
                "10100" when "0110111", -- U-type (like LUI)
                "00000" when others;

  o_RegWrite   <= signal_bus(4);
  o_MemWrite   <= signal_bus(3);
  o_ALUSrc     <= signal_bus(2);
  o_IMMSel     <= signal_bus(1);
  o_MemToReg   <= signal_bus(0);
 

  o_AddSub <= '1' when (i_opcode = "0110011" and i_func7(5) =  '1') else -- this is an R-type SUB instruction case
	    '1' when i_opcode = "0110111" else                       -- this is a U-type LUI instruction case
	    '0';

-- this stuff will be used in the future, full datapath:
--  ALUControl <=
-- 	-- R-type:
--	"????" when (opcode = "0110011" and )
--
--	-- I-type:
--	"????" when (opcode = "0010011")

--	-- lw things:
--	"0000" when (opcode = "")

--	-- sw things:
--	"0000" when (opcode = "");
--
--	-- branch things:
--	"????" when (opcode = "")
--
--	-- jal:
--	"????" when (opcode = "")
--
--	-- jalr:
--	"????" when (opcode = "")


end dataflow;
