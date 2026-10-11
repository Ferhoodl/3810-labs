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
end component;

signal s_opcode     : std_logic_vector(6 downto 0);
signal s_func7      : std_logic_vector(6 downto 0);
signal s_func3      : std_logic_vector(2 downto 0);

signal s_ALUControl : std_logic_vector(3 downto 0);
signal s_ImmType    : std_logic_vector(2 downto 0);

signal s_Branch     : std_logic;
signal s_Jump       : std_logic;
signal s_MemToReg   : std_logic;
signal s_MemWrite   : std_logic;
signal s_AndLink    : std_logic;
signal s_ALUSrc     : std_logic;
signal s_RegWrite   : std_logic;


begin

  DUT0: control
  port map( 
       i_opcode => s_opcode,
       i_func7 => s_func7,
       i_func3 => s_func3,
       o_ALUControl => s_ALUControl,
       o_ImmType => s_ImmType,

       o_Branch => s_Branch,
       o_Jump => s_Jump,
       o_MemToReg => s_MemToReg,
       o_MemWrite => s_MemWrite,
       o_AndLink => s_AndLink,
       o_ALUSrc => s_ALUSrc,
       o_RegWrite => s_RegWrite);

  P_TEST_CASES: process
  begin

    s_opcode <= "0110011"; -- R-Type, output should be 0,0,0,0,0,0,1
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;
    
    s_opcode <= "0010011"; -- I-Type, output should be 0,0,0,0,0,1,1
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;
    
    s_opcode <= "0000011"; -- lw, output should be 0,0,1,0,0,1,1
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;
    
    s_opcode <= "0100011"; -- sw, output should be 0,0,0,1,0,1,1
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;
    
    s_opcode <= "1100011"; -- branch, output should be 1,0,0,0,0,1,0
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;
    
    s_opcode <= "1101111"; -- jal, output should be 0,1,?,?,?,?,?
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;
    
    s_opcode <= "1100111"; -- jalr, output should be ?,?,?,?,?,?,?
    s_func7 <= "1111111";
    s_func3 <= "111";
    wait for 10 ns;

    wait;
  end process;

end structure;
