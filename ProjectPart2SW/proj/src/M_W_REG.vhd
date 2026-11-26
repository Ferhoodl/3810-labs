library IEEE;
use IEEE.std_logic_1164.all;

entity M_W_REG is
  port(i_CLK       : in  std_logic;
       i_RST       : in  std_logic;
       i_WE        : in  std_logic;
       i_PC4       : in  std_logic_vector(31 downto 0);
       i_RdAddress : in  std_logic_vector(4 downto 0);
       i_ALUResult : in  std_logic_vector(31 downto 0);
       i_LoadData  : in  std_logic_vector(31 downto 0);
       i_RegWrite  : in  std_logic;
       i_MemToReg  : in  std_logic;
       i_AndLink   : in  std_logic;
       i_Halt      : in  std_logic;
       o_PC4       : out std_logic_vector(31 downto 0);
       o_RdAddress : out std_logic_vector(4 downto 0);
       o_ALUResult : out std_logic_vector(31 downto 0);
       o_LoadData  : out std_logic_vector(31 downto 0);
       o_RegWrite  : out std_logic;
       o_MemToReg  : out std_logic;
       o_AndLink   : out std_logic;
       o_Halt      : out std_logic);
end M_W_REG;

architecture structure of M_W_REG is
  component dffg is
    port(i_CLK, i_RST, i_WE, i_D : in std_logic;
         o_Q : out std_logic);
  end component;
  signal s_D, s_Q : std_logic_vector(104 downto 0);
begin
  s_D <= i_PC4 & i_RdAddress & i_ALUResult & i_LoadData &
         i_RegWrite & i_MemToReg & i_AndLink & i_Halt;

  GEN_FF: for i in s_D'range generate
    FF: dffg port map(i_CLK => i_CLK, i_RST => i_RST, i_WE => i_WE,
                      i_D => s_D(i), o_Q => s_Q(i));
  end generate;

  o_PC4       <= s_Q(104 downto 73);
  o_RdAddress <= s_Q(72 downto 68);
  o_ALUResult <= s_Q(67 downto 36);
  o_LoadData  <= s_Q(35 downto 4);
  o_RegWrite  <= s_Q(3);
  o_MemToReg  <= s_Q(2);
  o_AndLink   <= s_Q(1);
  o_Halt      <= s_Q(0);
end structure;
