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
  generic (
    gCLK_HPER   : time := 10 ns   -- Generic for half of the clock cycle period
  );
end tb_control;

architecture structure of tb_control is

constant cCLK_PER : time := gCLK_HPER * 2;

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

    -- 1 add -- r type
    s_opcode <= "0110011"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0000")
      report "problem on add" severity error;

    -- 2 addi -- i type
    s_opcode <= "0010011"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0000")
      report "problem on addi" severity error;

    -- 3 and -- r type
    s_opcode <= "0110011"; s_func3 <= "111"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0010
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0010")
      report "problem on and" severity error;

    -- 4 andi -- i type
    s_opcode <= "0010011"; s_func3 <= "111"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0010
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0010")
      report "problem on andi" severity error;

    -- 5 lui -- u type
    s_opcode <= "0110111"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=10 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=011 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "10" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "011" and s_ALUControl = "0000")
      report "problem on lui" severity error;

    -- 6 lw -- i type
    s_opcode <= "0000011"; s_func3 <= "010"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=1 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 memsize=10 loadunsigned=0 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '1' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_MemSize = "10" and s_LoadUnsigned = '0' and s_ALUControl = "0000")
      report "problem on lw" severity error;

    -- 7 xor -- r type
    s_opcode <= "0110011"; s_func3 <= "100"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0100
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0100")
      report "problem on xor" severity error;

    -- 8 xori -- i type
    s_opcode <= "0010011"; s_func3 <= "100"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0100
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0100")
      report "problem on xori" severity error;

    -- 9 or -- r type
    s_opcode <= "0110011"; s_func3 <= "110"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0011
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0011")
      report "problem on or" severity error;

    -- 10 ori -- i type
    s_opcode <= "0010011"; s_func3 <= "110"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0011
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0011")
      report "problem on ori" severity error;

    -- 11 slt -- r type
    s_opcode <= "0110011"; s_func3 <= "010"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=1010
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "1010")
      report "problem on slt" severity error;

    -- 12 slti -- i type
    s_opcode <= "0010011"; s_func3 <= "010"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=1010
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "1010")
      report "problem on slti" severity error;

    -- 13 sltiu -- i type
    s_opcode <= "0010011"; s_func3 <= "011"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=1011
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "1011")
      report "problem on sltiu" severity error;

    -- 14 sll -- r type
    s_opcode <= "0110011"; s_func3 <= "001"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0001
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0001")
      report "problem on sll" severity error;

    -- 15 srl -- r type
    s_opcode <= "0110011"; s_func3 <= "101"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0101
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0101")
      report "problem on srl" severity error;

    -- 16 sra -- r type
    s_opcode <= "0110011"; s_func3 <= "101"; s_func7 <= "0100000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=1101
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "1101")
      report "problem on sra" severity error;

    -- 17 sb -- s type
    s_opcode <= "0100011"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=1 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=001 memsize=00 loadunsigned=0 alucontrol=0000
    assert (s_RegWrite = '0' and s_MemWrite = '1' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "001" and s_MemSize = "00" and s_LoadUnsigned = '0' and s_ALUControl = "0000")
      report "problem on sb" severity error;

    -- 18 sh -- s type
    s_opcode <= "0100011"; s_func3 <= "001"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=1 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=001 memsize=01 loadunsigned=0 alucontrol=0000
    assert (s_RegWrite = '0' and s_MemWrite = '1' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "001" and s_MemSize = "01" and s_LoadUnsigned = '0' and s_ALUControl = "0000")
      report "problem on sh" severity error;

    -- 19 sw -- s type
    s_opcode <= "0100011"; s_func3 <= "010"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=1 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=001 memsize=10 loadunsigned=0 alucontrol=0000
    assert (s_RegWrite = '0' and s_MemWrite = '1' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "001" and s_MemSize = "10" and s_LoadUnsigned = '0' and s_ALUControl = "0000")
      report "problem on sw" severity error;

    -- 20 sub -- r type
    s_opcode <= "0110011"; s_func3 <= "000"; s_func7 <= "0100000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=1000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "1000")
      report "problem on sub" severity error;

    -- 21 beq -- sb type
    s_opcode <= "1100011"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=1 jump=0 andlink=1 andlinkreg=0 immtype=010 alucontrol=1000
    assert (s_RegWrite = '0' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '1' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "010" and s_ALUControl = "1000")
      report "problem on beq" severity error;

    -- 22 bne -- sb type
    s_opcode <= "1100011"; s_func3 <= "001"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=1 jump=0 andlink=1 andlinkreg=0 immtype=010 alucontrol=1000
    assert (s_RegWrite = '0' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '1' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "010" and s_ALUControl = "1000")
      report "problem on bne" severity error;

    -- 23 blt -- sb type
    s_opcode <= "1100011"; s_func3 <= "100"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=1 jump=0 andlink=1 andlinkreg=0 immtype=010 alucontrol=1000
    assert (s_RegWrite = '0' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '1' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "010" and s_ALUControl = "1000")
      report "problem on blt" severity error;

    -- 24 bge -- sb type
    s_opcode <= "1100011"; s_func3 <= "101"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=1 jump=0 andlink=1 andlinkreg=0 immtype=010 alucontrol=1000
    assert (s_RegWrite = '0' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '1' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "010" and s_ALUControl = "1000")
      report "problem on bge" severity error;

    -- 25 bltu -- sb type
    s_opcode <= "1100011"; s_func3 <= "110"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=1 jump=0 andlink=1 andlinkreg=0 immtype=010 alucontrol=1000
    assert (s_RegWrite = '0' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '1' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "010" and s_ALUControl = "1000")
      report "problem on bltu" severity error;

    -- 26 bgeu -- sb type
    s_opcode <= "1100011"; s_func3 <= "111"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=0 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=1 jump=0 andlink=1 andlinkreg=0 immtype=010 alucontrol=1000
    assert (s_RegWrite = '0' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '1' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "010" and s_ALUControl = "1000")
      report "problem on bgeu" severity error;

    -- 27 jal -- uj type
    s_opcode <= "1101111"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=0 memtoreg=0 branch=0 jump=1 andlink=0 andlinkreg=0 immtype=100 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '0' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '1' and s_AndLink = '0' and s_AndLinkReg = '0' and s_ImmediateType = "100" and s_ALUControl = "0000")
      report "problem on jal" severity error;

    -- 28 jalr -- i type
    s_opcode <= "1100111"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=1 andlink=0 andlinkreg=1 immtype=000 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '1' and s_AndLink = '0' and s_AndLinkReg = '1' and s_ImmediateType = "000" and s_ALUControl = "0000")
      report "problem on jalr" severity error;

    -- 29 lb -- i type
    s_opcode <= "0000011"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=1 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 memsize=00 loadunsigned=0 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '1' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_MemSize = "00" and s_LoadUnsigned = '0' and s_ALUControl = "0000")
      report "problem on lb" severity error;

    -- 30 lh -- i type
    s_opcode <= "0000011"; s_func3 <= "001"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=1 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 memsize=01 loadunsigned=0 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '1' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_MemSize = "01" and s_LoadUnsigned = '0' and s_ALUControl = "0000")
      report "problem on lh" severity error;

    -- 31 lbu -- i type
    s_opcode <= "0000011"; s_func3 <= "100"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=1 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 memsize=00 loadunsigned=1 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '1' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_MemSize = "00" and s_LoadUnsigned = '1' and s_ALUControl = "0000")
      report "problem on lbu" severity error;

    -- 32 lhu -- i type
    s_opcode <= "0000011"; s_func3 <= "101"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=1 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 memsize=01 loadunsigned=1 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '1' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_MemSize = "01" and s_LoadUnsigned = '1' and s_ALUControl = "0000")
      report "problem on lhu" severity error;

    -- 33 slli -- i type
    s_opcode <= "0010011"; s_func3 <= "001"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0001
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0001")
      report "problem on slli" severity error;

    -- 34 srli -- i type
    s_opcode <= "0010011"; s_func3 <= "101"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=0101
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "0101")
      report "problem on srli" severity error;

    -- 35 srai -- i type
    s_opcode <= "0010011"; s_func3 <= "101"; s_func7 <= "0100000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=00 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=000 alucontrol=1101
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "00" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "000" and s_ALUControl = "1101")
      report "problem on srai" severity error;

    -- 36 auipc -- u type
    s_opcode <= "0010111"; s_func3 <= "000"; s_func7 <= "0000000";
    wait for cCLK_PER;
    -- expected: regwrite=1 memwrite=0 alusrca=01 alusrcb=1 memtoreg=0 branch=0 jump=0 andlink=1 andlinkreg=0 immtype=011 alucontrol=0000
    assert (s_RegWrite = '1' and s_MemWrite = '0' and s_ALUSrcA = "01" and s_ALUSrcB = '1' and s_MemToReg = '0' and s_Branch = '0' and s_Jump = '0' and s_AndLink = '1' and s_AndLinkReg = '0' and s_ImmediateType = "011" and s_ALUControl = "0000")
      report "problem on auipc" severity error;

    wait;
  end process;

end structure;
