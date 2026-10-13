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
       i_func3      : in std_logic_vector(2 downto 0);

       o_ALUControl : out std_logic_vector(3 downto 0);
       o_ImmType    : out std_logic_vector(2 downto 0);

       o_Branch     : out std_logic;
       o_Jump       : out std_logic;
       o_MemToReg   : out std_logic;
       o_MemWrite   : out std_logic;
       o_AndLink    : out std_logic;
       o_ALUSrc     : out std_logic;
       o_RegWrite   : out std_logic);
end control;

architecture dataflow of control is
	-- Branch, Jump, MemToReg, MemWrite, AndLink, ALUSrc, RegWrite
	signal signal_bus : std_logic_vector(6 downto 0);
	signal aluop_bus : std_logic_vector(1 downto 0);
begin
with i_opcode select
  signal_bus <= "0000001" when "0110011", -- R-type
                "0000011" when "0010011", -- I-type
                "0010011" when "0000011", -- lw things
                "0001011" when "0100011", -- sw things
                "1000010" when "1100011", -- branch things
                "01?????" when "1101111", -- jal
                "???????" when "1100111", -- jalr
                "0000000" when others;

  o_Branch     => signal_bus(6);
  o_Jump       => signal_bus(5);
  o_MemToReg   => signal_bus(4);
  o_MemWrite   => signal_bus(3);
  o_AndLink    => signal_bus(2);
  o_ALUSrc     => signal_bus(1);
  o_RegWrite   => signal_bus(0);
  

  ALUControl <=
 	-- R-type:
	"????" when (opcode = "0110011" and )

	-- I-type:
	"????" when (opcode = "0010011")

	-- lw things:
	"0000" when (opcode = "")

	-- sw things:
	"0000" when (opcode = "")

	-- branch things:
	"????" when (opcode = "")

	-- jal:
	"????" when (opcode = "")

	-- jalr:
	"????" when (opcode = "");


end dataflow;
