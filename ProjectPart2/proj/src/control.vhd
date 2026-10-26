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
port (
    i_opcode        : in  std_logic_vector(6 downto 0);
    i_func3         : in  std_logic_vector(2 downto 0);
    i_func7         : in  std_logic_vector(6 downto 0);
    o_RegWrite      : out std_logic;
    o_MemWrite      : out std_logic;
    o_ALUSrc        : out std_logic;
    o_MemToReg      : out std_logic;
    o_Branch        : out std_logic;
    o_Jump          : out std_logic;
    o_AndLink       : out std_logic;
    o_ImmediateType : out std_logic_vector(2 downto 0);
    o_ALUControl    : out std_logic_vector(3 downto 0)
  );   
end control;

architecture dataflow of control is
	-- RegWrite, MemWrite, AddSub, ALUSrc, IMMSel, MemToReg
	signal controls : std_logic_vector(6 downto 0);
	signal alu_op : std_logic_vector(1 downto 0);
begin

with i_opcode select
  controls <= "1000001" when "0110011", -- r-type
                   "1010001" when "0010011", -- i-type
                   "1011001" when "0000011", -- lw stuff (lw, lb, lh, etc. . .)
                   "0110001" when "0100011", -- sw stuff (sw, sb, sh)
                   "0000101" when "1100011", -- branches
                   "1010001" when "0110111", -- lui
                   "1010001" when "0010111", -- auipc
                   "1000010" when "1101111", -- jal
                   "1010010" when "1100111", -- jalr
                   "0000001" when others;

  o_RegWrite <= controls(6);
  o_MemWrite <= controls(5);
  o_ALUSrc   <= controls(4);
  o_MemToReg <= controls(3);
  o_Branch   <= controls(2);
  o_Jump     <= controls(1);
  o_AndLink  <= controls(0);
 
-- immediate things
with i_opcode select
o_ImmediateType <= "001" when "0100011",                -- S-Type (Store)
                   "010" when "1100011",                -- B-Type (Branch)
                   "011" when "0110111" | "0010111",    -- U-Type (LUI, AUIPC)
                   "100" when "1101111",                -- J-Type (JAL)
                   "000" when others;                   -- I-Type (ALU, Load, JALR)

-- aluop determination
with i_opcode select
    alu_op <= "10" when "0110011", -- R-Type
              "11" when "0010011", -- I-Type ALU
              "01" when "1100011", -- Branch (Compare via Sub)
              "00" when others;    -- Address addition / Pass-through

-- doing aluop decode inside of control instead of making a separate module
o_ALUControl <=
    "1000" when (alu_op = "10" and i_func3 = "000" and i_func7(5) = '1')  else -- sub      <--- r type instructions
    "0000" when (alu_op = "10" and i_func3 = "000")                       else -- add
    "0001" when (alu_op = "10" and i_func3 = "001")                       else -- sll
    "0100" when (alu_op = "10" and i_func3 = "100")                       else -- xor
    "0101" when (alu_op = "10" and i_func3 = "101" and i_func7(5) = '0')  else -- srl
    "1101" when (alu_op = "10" and i_func3 = "101" and i_func7(5) = '1')  else -- sra
    "0011" when (alu_op = "10" and i_func3 = "110")                       else -- or
    "0010" when (alu_op = "10" and i_func3 = "111")                       else -- and
    "0000" when (alu_op = "11" and i_func3 = "000")                       else -- addi     <--- i type instructions
    "0001" when (alu_op = "11" and i_func3 = "001")                       else -- slli
    "0100" when (alu_op = "11" and i_func3 = "100")                       else -- xori
    "0101" when (alu_op = "11" and i_func3 = "101" and i_func7(5) = '0')  else -- srli
    "1101" when (alu_op = "11" and i_func3 = "101" and i_func7(5) = '1')  else -- srai
    "0011" when (alu_op = "11" and i_func3 = "110")                       else -- ori
    "0010" when (alu_op = "11" and i_func3 = "111")                       else -- andi
    "1000" when (alu_op = "01")                                           else -- <-- branch compare
    "0000";                                                                    -- <-- default (address additions like loads, stores, auic, jalr)

end dataflow;
