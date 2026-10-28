-------------------------------------------------------------------------
-- Troy Tomson
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- tb_control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the control unit
--              
-- 10/11/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

entity tb_control is
end tb_control;

architecture structure of tb_control is

component control is
  port(i_opcode        : in  std_logic_vector(6 downto 0);
       i_func3         : in  std_logic_vector(2 downto 0);
       i_func7         : in  std_logic_vector(6 downto 0);
       o_RegWrite      : out std_logic;
       o_MemWrite      : out std_logic;
       o_ALUSrcA       : out std_logic_vector(1 downto 0);
       o_ALUSrcB       : out std_logic;
       o_MemToReg      : out std_logic;
       o_Branch        : out std_logic;
       o_Jump          : out std_logic;
       o_AndLink       : out std_logic;
       o_AndLinkReg    : out std_logic;
       o_ImmediateType : out std_logic_vector(2 downto 0);
       o_MemSize       : out std_logic_vector(1 downto 0);
       o_LoadUnsigned  : out std_logic;
       o_ALUControl    : out std_logic_vector(3 downto 0));
end component;

signal s_opcode        : std_logic_vector(6 downto 0);
signal s_func7         : std_logic_vector(6 downto 0);
signal s_func3         : std_logic_vector(2 downto 0);

signal s_RegWrite      : std_logic;
signal s_MemWrite      : std_logic;
signal s_ALUSrcA       : std_logic_vector(1 downto 0);
signal s_ALUSrcB       : std_logic;
signal s_MemToReg      : std_logic;
signal s_Branch        : std_logic;
signal s_Jump          : std_logic;
signal s_AndLink       : std_logic;
signal s_AndLinkReg    : std_logic;
signal s_ImmediateType : std_logic_vector(2 downto 0);
signal s_MemSize       : std_logic_vector(1 downto 0);
signal s_LoadUnsigned  : std_logic;
signal s_ALUControl    : std_logic_vector(3 downto 0);


begin

  DUT0: control
  port map( 
       i_opcode        => s_opcode,
       i_func3         => s_func3,
       i_func7         => s_func7,
       o_RegWrite      => s_RegWrite,
       o_MemWrite      => s_MemWrite,
       o_ALUSrcA       => s_ALUSrcA,
       o_ALUSrcB       => s_ALUSrcB,
       o_MemToReg      => s_MemToReg,
       o_Branch        => s_Branch,
       o_Jump          => s_Jump,
       o_AndLink       => s_AndLink,
       o_AndLinkReg    => s_AndLinkReg,
       o_ImmediateType => s_ImmediateType,
       o_MemSize       => s_MemSize,
       o_LoadUnsigned  => s_LoadUnsigned,
       o_ALUControl    => s_ALUControl);

  -- expected outputs are listed as RegWrite, MemWrite, ALUSrcA, ALUSrcB, MemToReg, Branch, Jump, AndLink, AndLinkReg, ImmediateType, MemSize, LoadUnsigned, ALUControl
  P_TEST_CASES: process
  begin

    s_opcode <= "0110011"; -- add, output should be 1,0,00,0,0,0,0,1,0,000,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0110011"; -- sub, output should be 1,0,00,0,0,0,0,1,0,000,00,0,1000
    s_func7 <= "0100000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0110011"; -- sra, output should be 1,0,00,0,0,0,0,1,0,000,01,1,1101
    s_func7 <= "0100000";
    s_func3 <= "101";
    wait for 10 ns;

    s_opcode <= "0010011"; -- addi, output should be 1,0,00,1,0,0,0,1,0,000,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0010011"; -- sltiu, output should be 1,0,00,1,0,0,0,1,0,000,11,0,1011
    s_func7 <= "0000000";
    s_func3 <= "011";
    wait for 10 ns;

    s_opcode <= "0010011"; -- srai, output should be 1,0,00,1,0,0,0,1,0,000,01,1,1101
    s_func7 <= "0100000";
    s_func3 <= "101";
    wait for 10 ns;

    s_opcode <= "0000011"; -- lw, output should be 1,0,00,1,1,0,0,1,0,000,10,0,0000
    s_func7 <= "0000000";
    s_func3 <= "010";
    wait for 10 ns;

    s_opcode <= "0000011"; -- lb, output should be 1,0,00,1,1,0,0,1,0,000,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0000011"; -- lhu, output should be 1,0,00,1,1,0,0,1,0,000,01,1,0000
    s_func7 <= "0000000";
    s_func3 <= "101";
    wait for 10 ns;

    s_opcode <= "0100011"; -- sw, output should be 0,1,00,1,0,0,0,1,0,001,10,0,0000
    s_func7 <= "0000000";
    s_func3 <= "010";
    wait for 10 ns;

    s_opcode <= "0100011"; -- sb, output should be 0,1,00,1,0,0,0,1,0,001,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0100011"; -- sh, output should be 0,1,00,1,0,0,0,1,0,001,01,0,0000
    s_func7 <= "0000000";
    s_func3 <= "001";
    wait for 10 ns;

    s_opcode <= "1100011"; -- beq, output should be 0,0,00,0,0,1,0,1,0,010,00,0,1000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0110111"; -- lui, output should be 1,0,10,1,0,0,0,1,0,011,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "0010111"; -- auipc, output should be 1,0,01,1,0,0,0,1,0,011,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "1101111"; -- jal, output should be 1,0,00,0,0,0,1,0,0,100,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    s_opcode <= "1100111"; -- jalr, output should be 1,0,00,1,0,0,1,0,1,000,00,0,0000
    s_func7 <= "0000000";
    s_func3 <= "000";
    wait for 10 ns;

    wait;
  end process;

end structure;
