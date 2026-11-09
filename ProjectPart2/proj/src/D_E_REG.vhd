library IEEE;
use IEEE.std_logic_1164.all;

entity D_E_REG is
  port(i_CLK          : in  std_logic;
       i_RST          : in  std_logic;
       i_WE           : in  std_logic;
       i_PC           : in  std_logic_vector(31 downto 0);
       i_PC4          : in  std_logic_vector(31 downto 0);
       i_RdAddress    : in  std_logic_vector(4 downto 0);
       i_Rs1Value     : in  std_logic_vector(31 downto 0);
       i_Rs2Value     : in  std_logic_vector(31 downto 0);
       i_Immediate    : in  std_logic_vector(31 downto 0);
       i_ALUSrcA      : in  std_logic_vector(1 downto 0);
       i_ALUSrcB      : in  std_logic;
       i_ALUControl   : in  std_logic_vector(3 downto 0);
       i_Funct3       : in  std_logic_vector(2 downto 0);
       i_Branch       : in  std_logic;
       i_Jump         : in  std_logic;
       i_AndLinkReg   : in  std_logic;
       i_MemWrite     : in  std_logic;
       i_MemSize      : in  std_logic_vector(1 downto 0);
       i_LoadUnsigned : in  std_logic;
       i_RegWrite     : in  std_logic;
       i_MemToReg     : in  std_logic;
       i_AndLink      : in  std_logic;
       i_Halt         : in  std_logic;
       o_PC           : out std_logic_vector(31 downto 0);
       o_PC4          : out std_logic_vector(31 downto 0);
       o_RdAddress    : out std_logic_vector(4 downto 0);
       o_Rs1Value     : out std_logic_vector(31 downto 0);
       o_Rs2Value     : out std_logic_vector(31 downto 0);
       o_Immediate    : out std_logic_vector(31 downto 0);
       o_ALUSrcA      : out std_logic_vector(1 downto 0);
       o_ALUSrcB      : out std_logic;
       o_ALUControl   : out std_logic_vector(3 downto 0);
       o_Funct3       : out std_logic_vector(2 downto 0);
       o_Branch       : out std_logic;
       o_Jump         : out std_logic;
       o_AndLinkReg   : out std_logic;
       o_MemWrite     : out std_logic;
       o_MemSize      : out std_logic_vector(1 downto 0);
       o_LoadUnsigned : out std_logic;
       o_RegWrite     : out std_logic;
       o_MemToReg     : out std_logic;
       o_AndLink      : out std_logic;
       o_Halt         : out std_logic);
end D_E_REG;

architecture structure of D_E_REG is
  component dffg is
    port(i_CLK, i_RST, i_WE, i_D : in std_logic;
         o_Q : out std_logic);
  end component;
  signal s_D, s_Q : std_logic_vector(185 downto 0);
begin
  s_D <= i_Funct3 & i_Branch & i_Jump & i_AndLinkReg &
         i_PC & i_PC4 & i_RdAddress & i_Rs1Value & i_Rs2Value & i_Immediate &
         i_ALUSrcA & i_ALUSrcB & i_ALUControl & i_MemWrite & i_MemSize &
         i_LoadUnsigned & i_RegWrite & i_MemToReg & i_AndLink & i_Halt;

  GEN_FF: for i in s_D'range generate
    FF: dffg port map(i_CLK => i_CLK, i_RST => i_RST, i_WE => i_WE,
                      i_D => s_D(i), o_Q => s_Q(i));
  end generate;

  o_Funct3       <= s_Q(185 downto 183);
  o_Branch       <= s_Q(182);
  o_Jump         <= s_Q(181);
  o_AndLinkReg   <= s_Q(180);
  o_PC           <= s_Q(179 downto 148);
  o_PC4          <= s_Q(147 downto 116);
  o_RdAddress    <= s_Q(115 downto 111);
  o_Rs1Value     <= s_Q(110 downto 79);
  o_Rs2Value     <= s_Q(78 downto 47);
  o_Immediate    <= s_Q(46 downto 15);
  o_ALUSrcA      <= s_Q(14 downto 13);
  o_ALUSrcB      <= s_Q(12);
  o_ALUControl   <= s_Q(11 downto 8);
  o_MemWrite     <= s_Q(7);
  o_MemSize      <= s_Q(6 downto 5);
  o_LoadUnsigned <= s_Q(4);
  o_RegWrite     <= s_Q(3);
  o_MemToReg     <= s_Q(2);
  o_AndLink      <= s_Q(1);
  o_Halt         <= s_Q(0);
end structure;
