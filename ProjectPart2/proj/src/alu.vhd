-------------------------------------------------------------------------
-- Isaiah Steele
-- Student in CpRE 3810
-- Iowa State University
-------------------------------------------------------------------------


-- alu.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation for an alu.
--
-- 10/26/2026: created
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu is
generic(N : integer := 32);
  port(
    i_A          : in  std_logic_vector(N-1 downto 0);
    i_B          : in  std_logic_vector(N-1 downto 0);
    i_ALUControl : in  std_logic_vector(3 downto 0);
    o_Result     : out std_logic_vector(N-1 downto 0);
    o_Zero       : out std_logic;
    o_CarryOut   : out std_logic
  );
end alu;

architecture structure of alu is
  
  -- Describe the component entities as defined in their
  -- respective .vhd files.
  component andg2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  component org2
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
  end component;

  component xorg2 is
    port(
      i_A : in  std_logic;
      i_B : in  std_logic;
      o_F : out std_logic
    );
  end component;

  component mux2t1_N is
    generic(N : integer := 32);
    port(
      i_S  : in  std_logic;
      i_D0 : in  std_logic_vector(N-1 downto 0);
      i_D1 : in  std_logic_vector(N-1 downto 0);
      o_O  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component add_sub is
    generic(N : integer := 32);
    port(
      i_A : in  std_logic_vector(N-1 downto 0);
      i_B : in  std_logic_vector(N-1 downto 0);
      i_C : in  std_logic;
      o_S : out std_logic_vector(N-1 downto 0);
      o_C : out std_logic
    );
  end component;

  component barrelShifter is
    port(
      i_Data    : in  std_logic_vector(31 downto 0);
      i_Shift   : in  std_logic_vector(4 downto 0);
      i_arith   : in  std_logic; -- 0 for SRL, 1 for SRA
      i_Dir     : in  std_logic; -- 0 for right, 1 for left
      o_Shifted : out std_logic_vector(31 downto 0)
    );
  end component;

  signal MID_AND_OUT         : std_logic_vector(N-1 downto 0);
  signal MID_OR_OUT          : std_logic_vector(N-1 downto 0);
  signal MID_XOR_OUT         : std_logic_vector(N-1 downto 0);
  signal MID_ADDSUB_OUT      : std_logic_vector(N-1 downto 0);
  signal MID_SHIFTER_OUT     : std_logic_vector(N-1 downto 0);
  signal MID_SHIFT_DIRECTION : std_logic;
  signal MID_ARITHMETIC      : std_logic;
  signal MID_ADDSUB_CONTROL  : std_logic;
  signal MID_MUX1_OUT        : std_logic_vector(N-1 downto 0);
  signal MID_MUX2_OUT        : std_logic_vector(N-1 downto 0);
  signal MID_MUX3_OUT        : std_logic_vector(N-1 downto 0);
  signal MID_MUX4_OUT        : std_logic_vector(N-1 downto 0);
  signal MID_MUX5_OUT        : std_logic_vector(N-1 downto 0);

begin

  MID_ADDSUB_CONTROL  <= i_ALUControl(3); -- subtract mode when ALUControl(3) is 1
  MID_ARITHMETIC      <= i_ALUControl(3); -- arithmetic shift: 1 for sra/srai on a 1101, and 0 for srl/srli on a 0101
  MID_SHIFT_DIRECTION <= '1' when (i_ALUControl(2 downto 0) = "001" and i_ALUControl(3) = '0') else '0'; -- 1 for left with sll/slli and 0001, and 0 for right with a srl/srl of 0101/1101

  GENERATE_AND: for i in 0 to N-1 generate
    WIDE_AND: andg2
      port map(
        i_A => i_A(i),
        i_B => i_B(i),
        o_F => MID_AND_OUT(i)
      );

  end generate GENERATE_AND;

  GENERATE_OR: for i in 0 to N-1 generate
    WIDE_OR: org2
      port map(
        i_A => i_A(i),
        i_B => i_B(i),
        o_F => MID_OR_OUT(i)
      );
  end generate GENERATE_OR;

  GENERATE_XOR: for i in 0 to N-1 generate
    WIDE_XOR: xorg2
      port map(
        i_A => i_A(i),
        i_B => i_B(i),
        o_F => MID_XOR_OUT(i)
      );
  end generate GENERATE_XOR;

  ADDSUB: add_sub
    generic map(N => N)
    port map(
      i_A => i_A,
      i_B => i_B,
      i_C => MID_ADDSUB_CONTROL,
      o_S => MID_ADDSUB_OUT,
      o_C => o_CarryOut
    );

  SHIFTER: barrelShifter
    port map(
      i_Data    => i_A,
      i_Shift   => i_B(4 downto 0),
      i_arith   => MID_ARITHMETIC,
      i_Dir     => MID_SHIFT_DIRECTION,
      o_Shifted => MID_SHIFTER_OUT
    );


  MUX1: mux2t1_N
    generic map(N => N)
    port map(
      i_S  => i_ALUControl(0),
      i_D0 => MID_AND_OUT,
      i_D1 => MID_OR_OUT,
      o_O  => MID_MUX1_OUT
    );


  MUX2: mux2t1_N
    generic map(N => N)
    port map(
      i_S  => i_ALUControl(2),
      i_D0 => MID_MUX1_OUT,
      i_D1 => MID_XOR_OUT,
      o_O  => MID_MUX2_OUT
    );


  MUX3: mux2t1_N
    generic map(N => N)
    port map(
      i_S  => i_ALUControl(0),
      i_D0 => MID_ADDSUB_OUT,
      i_D1 => MID_SHIFTER_OUT,
      o_O  => MID_MUX3_OUT
    );


  MUX4: mux2t1_N
    generic map(N => N)
    port map(
      i_S  => i_ALUControl(1),
      i_D0 => MID_MUX3_OUT,
      i_D1 => MID_MUX2_OUT,
      o_O  => MID_MUX4_OUT
    );


  MUX5: mux2t1_N
    generic map(N => N)
    port map(
      i_S  => i_ALUControl(2),
      i_D0 => MID_MUX4_OUT,
      i_D1 => MID_MUX2_OUT,
      o_O  => MID_MUX5_OUT
    );

  o_Result <= MID_MUX5_OUT;
  o_Zero   <= '1' when MID_MUX5_OUT = (MID_MUX5_OUT'range => '0') else '0';

  end structure;
