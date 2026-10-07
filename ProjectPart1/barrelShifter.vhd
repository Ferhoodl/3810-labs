-------------------------------------------------------------------------
-- Troy Tomson
-- Student in CprE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an L/R selectable
-- 32 bit barrel shifter
--
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity barrelShifter is
  port(i_Data         : in std_logic_vector(31 downto 0);
       i_Shift         : in std_logic_vector(4 downto 0);
       i_arith         : in std_logic; -- 0 for SRL, 1 for SRA
       i_Dir         : in std_logic; -- 0 for right, 1 for left
       o_Shifted        : out std_logic_vector(31 downto 0)
       );
end barrelShifter;


architecture structural of barrelShifter is

  signal stage1 : std_logic_vector(31 downto 0);
  signal stage2 : std_logic_vector(31 downto 0);
  signal stage3 : std_logic_vector(31 downto 0);
  signal stage4 : std_logic_vector(31 downto 0);
  
  signal fill_bit : std_logic;

begin

  fill_bit <= i_Data(31) when i_arith = '1' else '0';
  
  -- SHIFT 1

  shift1 : for i in 0 to 31 generate
    begin
    
      -- Don't shift if it's a 0
      stage1(i) <= i_Data(i) when i_Shift(0) = '0' else
      
        -- Right shift
        i_Data(i+1) when i_dir = '0' and i <= 30 else
        
        fill_bit when i_dir = '0' else
        
        -- Left shift
        i_Data(i-1) when i_dir = '1' and i >= 1 else
        
        '0';
      
    end generate shift1;
    
  -- SHIFT 2
  
  shift2 : for i in 0 to 31 generate
    begin
    
      -- Don't shift if it's a 0
      stage2(i) <= stage1(i) when i_Shift(1) = '0' else
      
        -- Right shift
        stage1(i+2) when i_dir = '0' and i <= 29 else
        
        fill_bit when i_dir = '0' else
        
        -- Left shift
        stage1(i-2) when i_dir = '1' and i >= 2 else
        
        '0';
      
    end generate shift2;
    
      -- SHIFT 4
  
  shift4 : for i in 0 to 31 generate
    begin
    
      -- Don't shift if it's a 0
      stage3(i) <= stage2(i) when i_Shift(2) = '0' else
      
        -- Right shift
        stage2(i+4) when i_dir = '0' and i <= 27 else
        
        fill_bit when i_dir = '0' else
        
        -- Left shift
        stage2(i-4) when i_dir = '1' and i >= 4 else
        
        '0';
      
    end generate shift4;
    
      -- SHIFT 8
  
  shift8 : for i in 0 to 31 generate
    begin
    
      -- Don't shift if it's a 0
      stage4(i) <= stage3(i) when i_Shift(3) = '0' else
      
        -- Right shift
        stage3(i+8) when i_dir = '0' and i <= 23 else
        
        fill_bit when i_dir = '0' else
        
        -- Left shift
        stage3(i-8) when i_dir = '1' and i >= 8 else
        
        '0';
      
    end generate shift8;
    
      -- SHIFT 16
  
  shift16 : for i in 0 to 31 generate
    begin
    
      -- Don't shift if it's a 0
      o_Shifted(i) <= stage4(i) when i_Shift(4) = '0' else
      
        -- Right shift
        stage4(i+16) when i_dir = '0' and i <= 15 else
        
        fill_bit when i_dir = '0' else
        
        -- Left shift
        stage4(i-16) when i_dir = '1' and i >= 16 else
        
        '0';
      
    end generate shift16;

  
end structural;
