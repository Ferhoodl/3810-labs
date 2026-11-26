library IEEE;
use IEEE.std_logic_1164.all;

entity F_D_REG is
  port(i_CLK         : in  std_logic;
       i_RST         : in  std_logic;
       i_WE          : in  std_logic;
       i_Flush       : in  std_logic;
       i_PC          : in  std_logic_vector(31 downto 0);
       i_PC4         : in  std_logic_vector(31 downto 0);
       i_Instruction : in  std_logic_vector(31 downto 0);
       o_PC          : out std_logic_vector(31 downto 0);
       o_PC4         : out std_logic_vector(31 downto 0);
       o_Instruction : out std_logic_vector(31 downto 0));
end F_D_REG;

architecture structure of F_D_REG is
  component dffg is
    port(i_CLK, i_RST, i_WE, i_D : in std_logic;
         o_Q : out std_logic);
  end component;

  signal s_D, s_Q : std_logic_vector(95 downto 0);
  signal s_D_flush : std_logic_vector(95 downto 0);
begin
  s_D <= i_PC & i_PC4 & i_Instruction;

  -- Mux to handle flush: on flush, replace instruction with NOP (x"00000013")
  s_D_flush <= i_PC & i_PC4 & i_Instruction when i_Flush = '0' else
               (others => '0') & (others => '0') & x"00000013";

  GEN_FF: for i in s_D'range generate
    FF: dffg port map(i_CLK => i_CLK, i_RST => i_RST, i_WE => i_WE or i_Flush,
                      i_D => s_D_flush(i), o_Q => s_Q(i));
  end generate;

  o_PC          <= s_Q(95 downto 64) when i_Flush = '0' else (others => '0');
  o_PC4         <= s_Q(63 downto 32) when i_Flush = '0' else (others => '0');
  o_Instruction <= s_Q(31 downto 0);
end structure;
