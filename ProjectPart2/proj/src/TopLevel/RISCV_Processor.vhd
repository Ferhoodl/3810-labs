-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemBE       : std_logic_vector(3 downto 0); -- TODO: enable the addressed byte for SB, halfword for SH, or all bytes for SW
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_PC instead
  signal s_PC : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011 func3: 000 and func12: 000100000101 -- func12 is imm field from I-format)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- this signal indicates an overflow exception would have been initiated

    -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  component add_sub is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_A         : in std_logic_vector(N-1 downto 0);
         i_B         : in std_logic_vector(N-1 downto 0);
         i_C         : in std_logic;
         o_S         : out std_logic_vector(N-1 downto 0);
         o_C         : out std_logic);
  end component;

    component pc is
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
  end component;

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
         o_AndLinkReg    : out std_logic; -- added
         o_ImmediateType : out std_logic_vector(2 downto 0);
         o_MemSize       : out std_logic_vector(1 downto 0);
         o_LoadUnsigned  : out std_logic;
         o_ALUControl    : out std_logic_vector(3 downto 0));
  end component;

  component store_align is
    port(i_Data       : in  std_logic_vector(31 downto 0);
         i_Address    : in  std_logic_vector(1 downto 0);
         i_Size       : in  std_logic_vector(1 downto 0);
         o_Data       : out std_logic_vector(31 downto 0);
         o_ByteEnable : out std_logic_vector(3 downto 0));
  end component;

  component load_extend is
    port(i_Data     : in  std_logic_vector(31 downto 0);
         i_Address  : in  std_logic_vector(1 downto 0);
         i_Size     : in  std_logic_vector(1 downto 0);
         i_Unsigned : in  std_logic;
         o_Data     : out std_logic_vector(31 downto 0));
  end component;

  component alu is
    generic(N : integer := 32);
    port(i_A          : in  std_logic_vector(N-1 downto 0);
         i_B          : in  std_logic_vector(N-1 downto 0);
         i_ALUControl : in  std_logic_vector(3 downto 0);
         o_Result     : out std_logic_vector(N-1 downto 0);
         o_Zero       : out std_logic;
         o_CarryOut   : out std_logic;
         o_LT         : out std_logic;
         o_LTU        : out std_logic);
  end component;

  component reg_file
    generic(N : integer := 32);
    port(i_CLK       : in std_logic;                            -- Clock input
         i_RST       : in std_logic;
         i_W_VAL     : in std_logic_vector(31 downto 0);        -- 32-bit write value
         i_W_ADDR    : in std_logic_vector(4 downto 0);         -- 5-bit write address
         i_W_EN      : in std_logic;                            -- line for write enable
         i_R_ADDR_A  : in std_logic_vector(4 downto 0);         -- 5-bit read address A
         i_R_ADDR_B  : in std_logic_vector(4 downto 0);         -- 5-bit read address B
         o_R_VAL_A   : out std_logic_vector(31 downto 0);       -- 32-bit read value A
         o_R_VAL_B   : out std_logic_vector(31 downto 0));      -- 32-bit read value B
  end component;

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          be           : in std_logic_vector(3 downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;
    
component barrelShifter is
  port(i_Data         : in std_logic_vector(31 downto 0);
       i_Shift         : in std_logic_vector(4 downto 0);
       i_arith         : in std_logic; -- 0 for SRL, 1 for SRA
       i_Dir         : in std_logic; -- 0 for right, 1 for left
       o_Shifted        : out std_logic_vector(31 downto 0)
       );
end component;
    
  component mux2t1_N
    generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component zero_appender
      port(Z_APP_IN     : in std_logic_vector(19 downto 0);
           Z_APP_OUT    : out std_logic_vector(31 downto 0));
  end component;

  component sign_extender
      port(S_EXT_IN     : in std_logic_vector(11 downto 0);
           S_EXT_OUT    : out std_logic_vector(31 downto 0));
  end component;

  component adder_N
      port(i_A         : in std_logic_vector(N-1 downto 0);
       i_B             : in std_logic_vector(N-1 downto 0);
       i_C             : in std_logic;
       o_S             : out std_logic_vector(N-1 downto 0);
       o_C             : out std_logic);
  end component;

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

  component F_D_REG is
    port(i_CLK         : in  std_logic;
         i_RST         : in  std_logic;
         i_WE          : in  std_logic;
         i_PC          : in  std_logic_vector(31 downto 0);
         i_PC4         : in  std_logic_vector(31 downto 0);
         i_Instruction : in  std_logic_vector(31 downto 0);
         o_PC          : out std_logic_vector(31 downto 0);
         o_PC4         : out std_logic_vector(31 downto 0);
         o_Instruction : out std_logic_vector(31 downto 0));
  end component;

  component D_E_REG is
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
  end component;

  component E_M_REG is
    port(i_CLK          : in  std_logic;
         i_RST          : in  std_logic;
         i_WE           : in  std_logic;
         i_PC4          : in  std_logic_vector(31 downto 0);
         i_RdAddress    : in  std_logic_vector(4 downto 0);
         i_ALUResult    : in  std_logic_vector(31 downto 0);
         i_StoreData    : in  std_logic_vector(31 downto 0);
         i_MemWrite     : in  std_logic;
         i_MemSize      : in  std_logic_vector(1 downto 0);
         i_LoadUnsigned : in  std_logic;
         i_RegWrite     : in  std_logic;
         i_MemToReg     : in  std_logic;
         i_AndLink      : in  std_logic;
         i_Halt         : in  std_logic;
         o_PC4          : out std_logic_vector(31 downto 0);
         o_RdAddress    : out std_logic_vector(4 downto 0);
         o_ALUResult    : out std_logic_vector(31 downto 0);
         o_StoreData    : out std_logic_vector(31 downto 0);
         o_MemWrite     : out std_logic;
         o_MemSize      : out std_logic_vector(1 downto 0);
         o_LoadUnsigned : out std_logic;
         o_RegWrite     : out std_logic;
         o_MemToReg     : out std_logic;
         o_AndLink      : out std_logic;
         o_Halt         : out std_logic);
  end component;

  component M_W_REG is
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
  end component;

  signal d_PC : std_logic_vector(31 downto 0);
  signal d_PC4 : std_logic_vector(31 downto 0);
  signal d_Inst : std_logic_vector(31 downto 0);
  signal d_RegWrite : std_logic;
  signal d_MemWrite : std_logic;
  signal d_Halt : std_logic;
  -- Phase A exception status and protected control signals.
  signal d_Ebreak           : std_logic; -- High when Decode contains EBREAK.
  signal d_Illegal : std_logic; -- High for an unsupported instruction encoding.
  signal d_ExceptionValid : std_logic; -- Only report faults from valid instructions.
  signal d_InstructionValid : std_logic := '0'; -- Ignore the empty Decode stage during reset.
  signal s_ExceptionBlock   : std_logic; -- Stop new work when an exception is detected.
  signal s_ExceptionPending : std_logic := '0'; -- Remember a fault while older work finishes.
  signal s_ExceptionDone    : std_logic := '0'; -- Mark that the exception has reached completion.
  signal s_ExceptionPC    : std_logic_vector(31 downto 0); -- Save the address of the faulting instruction.
  signal s_ExceptionCause : std_logic_vector(3 downto 0); -- Save the breakpoint or illegal-instruction code.
  signal e_ExceptionValid : std_logic; -- Track the exception through EX.
  signal m_ExceptionValid : std_logic; -- Track the exception through MEM.
  signal w_ExceptionValid : std_logic; -- Track the exception through WB.
  signal s_InstToDecode : std_logic_vector(31 downto 0); -- Send a NOP to IF/ID after a fault.
  signal d_RegWriteSafe : std_logic; -- Block register writes from the faulting instruction.
  signal d_MemWriteSafe : std_logic; -- Block memory writes from the faulting instruction.
  signal d_BranchSafe   : std_logic; -- Block branch changes after a fault.
  signal d_JumpSafe     : std_logic; -- Block jumps after a fault.
  signal d_HaltSafe     : std_logic; -- Keep a fault separate from the WFI halt.
  signal e_PC : std_logic_vector(31 downto 0);
  signal e_PC4 : std_logic_vector(31 downto 0);
  signal e_Rs1 : std_logic_vector(31 downto 0);
  signal e_Rs2 : std_logic_vector(31 downto 0);
  signal e_Immediate : std_logic_vector(31 downto 0);
  signal e_Rd : std_logic_vector(4 downto 0);
  signal e_ALUSrcA : std_logic_vector(1 downto 0);
  signal e_MemSize : std_logic_vector(1 downto 0);
  signal e_ALUControl : std_logic_vector(3 downto 0);
  signal e_Funct3 : std_logic_vector(2 downto 0);
  signal e_Branch : std_logic;
  signal e_Jump : std_logic;
  signal e_AndLinkReg : std_logic;
  signal e_ALUSrcB : std_logic;
  signal e_MemWrite : std_logic;
  signal e_LoadUnsigned : std_logic;
  signal e_RegWrite : std_logic;
  signal e_MemToReg : std_logic;
  signal e_AndLink : std_logic;
  signal e_Halt : std_logic;
  signal m_PC4 : std_logic_vector(31 downto 0);
  signal m_ALUResult : std_logic_vector(31 downto 0);
  signal m_StoreData : std_logic_vector(31 downto 0);
  signal m_Rd : std_logic_vector(4 downto 0);
  signal m_MemSize : std_logic_vector(1 downto 0);
  signal m_MemWrite : std_logic;
  signal m_LoadUnsigned : std_logic;
  signal m_RegWrite : std_logic;
  signal m_MemToReg : std_logic;
  signal m_AndLink : std_logic;
  signal m_Halt : std_logic;
  signal w_PC4 : std_logic_vector(31 downto 0);
  signal w_ALUResult : std_logic_vector(31 downto 0);
  signal w_LoadData : std_logic_vector(31 downto 0);
  signal w_MemToReg : std_logic;
  signal w_AndLink : std_logic;

  signal MID_ALUMUX_OUT           : std_logic_vector(31 downto 0);
  signal MID_ADDSUB_OUT           : std_logic_vector(31 downto 0);
  signal MID_BOTMUX_OUT           : std_logic_vector(31 downto 0);
  signal MID_REG_A_OUT            : std_logic_vector(31 downto 0);
  signal MID_REG_B_OUT            : std_logic_vector(31 downto 0);
  signal MID_REGMUX_OUT           : std_logic_vector(31 downto 0);
  signal MID_MEM_OUT              : std_logic_vector(31 downto 0);
  signal MID_PC_NEXT              : std_logic_vector(31 downto 0);
  signal MID_PC_NEXT_4            : std_logic_vector(31 downto 0);
  signal MID_PC_JUMP_REG          : std_logic_vector(31 downto 0);
  signal MID_PC_AND               : std_logic;
  signal MID_IMMEDIATE_FULL       : std_logic_vector(31 downto 0);
  signal MID_PC_MUX_SEL           : std_logic;
  signal MID_ALUSRCA              : std_logic_vector(1 downto 0);
  signal MID_ALUSRCB              : std_logic;
  signal MID_MEMTOREG             : std_logic;
  signal MID_MEMWRITE             : std_logic;
  signal MID_CONTROL_BRANCH       : std_logic;
  signal MID_CONTROL_JUMP         : std_logic;
  signal MID_CONTROL_ANDLINK      : std_logic;
  signal MID_CONTROL_ANDLINKREG   : std_logic;
  signal MID_CONTROL_IMMTYPE      : std_logic_vector(2 downto 0);
  signal MID_CONTROL_ALUCONTROL   : std_logic_vector(3 downto 0);
  signal MID_ALU_ZERO             : std_logic;
  signal MID_ALU_LT               : std_logic;
  signal MID_ALU_LTU              : std_logic;
  signal MID_BRANCH_COND          : std_logic;
  signal MID_BRANCH_TAKEN         : std_logic;
  signal MID_ALU_A_IN             : std_logic_vector(31 downto 0);
  signal MID_PC_BASE              : std_logic_vector(31 downto 0);
  signal MID_JALR_SEL             : std_logic;
  signal MID_CONTROL_MEMSIZE      : std_logic_vector(1 downto 0);
  signal MID_CONTROL_LOADUNSIGNED : std_logic;
  signal MID_STORE_DATA           : std_logic_vector(31 downto 0);
  -- signal MID_STORE_BYTEENABLE     : std_logic_vector(3 downto 0);
  signal MID_LOAD_DATA            : std_logic_vector(31 downto 0);


begin
  s_Ovfl <= '0'; -- RISC-V does not have hardware overflow detection.
  -- Detect EBREAK in Decode so the processor can stop on a breakpoint.
  d_Ebreak <= '1' when d_Inst = x"00100073" else '0';

  -- Check supported instruction encodings before executing them.
  -- This is our supported subset, not a complete RV32I legality check.
  process(d_Inst)
  begin
      d_Illegal <= '0';

      -- Decode the opcode, then check the function bits when needed.
      case d_Inst(6 downto 0) is
          when "0110111" | "0010111" | "1101111" =>
              null; -- LUI, AUIPC, JAL

          when "1100111" => -- JALR needs funct3 = 000.
              if d_Inst(14 downto 12) /= "000" then
                  d_Illegal <= '1';
              end if;

          when "1100011" => -- Reject unused branch funct3 values.
              case d_Inst(14 downto 12) is
                  when "000" | "001" | "100" | "101" | "110" | "111" => null;
                  when others => d_Illegal <= '1';
              end case;

          when "0000011" => -- Accept supported load sizes and signs.
              case d_Inst(14 downto 12) is
                  when "000" | "001" | "010" | "100" | "101" => null;
                  when others => d_Illegal <= '1';
              end case;

          when "0100011" => -- Accept byte, halfword, or word stores.
              case d_Inst(14 downto 12) is
                  when "000" | "001" | "010" => null;
                  when others => d_Illegal <= '1';
              end case;

          when "0010011" => -- Reject invalid shift-immediate formats.
              case d_Inst(14 downto 12) is
                  when "001" => -- SLLI
                      if d_Inst(31 downto 25) /= "0000000" then
                          d_Illegal <= '1';
                      end if;
                  when "101" => -- SRLI / SRAI
                      if d_Inst(31 downto 25) /= "0000000" and
                         d_Inst(31 downto 25) /= "0100000" then
                          d_Illegal <= '1';
                      end if;
                  when others => null;
              end case;

          when "0110011" => -- Check the funct7 bits for ALU operations.
              if d_Inst(14 downto 12) = "000" or
                 d_Inst(14 downto 12) = "101" then
                  if d_Inst(31 downto 25) /= "0000000" and
                     d_Inst(31 downto 25) /= "0100000" then
                      d_Illegal <= '1';
                  end if;
              elsif d_Inst(31 downto 25) /= "0000000" then
                  d_Illegal <= '1';
              end if;

          when "1110011" => -- Keep existing ECALL, EBREAK, and WFI behavior.
              if d_Inst /= x"00000073" and -- ECALL
                 d_Inst /= x"00100073" and -- EBREAK
                 d_Inst /= x"10500073" then -- WFI
                  d_Illegal <= '1';
              end if;

          when others =>
              d_Illegal <= '1'; -- Unsupported opcode: report cause 2.
      end case;
  end process;

  -- Ignore invalid startup contents until IF/ID holds a real instruction.
  d_ExceptionValid <= (d_Ebreak or d_Illegal) and d_InstructionValid;



  -- Stop fetching new work once a fault is seen.
  s_ExceptionBlock <= d_ExceptionValid or s_ExceptionPending;

  -- Send NOPs to IF/ID so younger instructions cannot run.
  s_InstToDecode <= x"00000013" when s_ExceptionBlock = '1' else s_Inst;

  -- Disable the faulting instruction's side effects in ID/EX.
  d_RegWriteSafe <= d_RegWrite and not s_ExceptionBlock; -- Prevent a register write after a fault.
  d_MemWriteSafe <= d_MemWrite and not s_ExceptionBlock; -- Prevent a store after a fault.
  d_BranchSafe   <= MID_CONTROL_BRANCH and not s_ExceptionBlock; -- Prevent a branch after a fault.
  d_JumpSafe     <= MID_CONTROL_JUMP and not s_ExceptionBlock; -- Prevent a jump after a fault.
  d_HaltSafe     <= d_Halt and not s_ExceptionBlock; -- Keep WFI halt disabled on a fault.


  -- Save the fault and let older instructions finish in the pipeline.
  process(iCLK, iRST)
  begin
      if iRST = '1' then
          -- Clear exception state so reset never looks like a fault.
          d_InstructionValid <= '0';
          s_ExceptionPending <= '0';
          s_ExceptionDone <= '0';
          s_ExceptionPC <= (others => '0');
          s_ExceptionCause <= (others => '0');

          e_ExceptionValid <= '0';
          m_ExceptionValid <= '0';
          w_ExceptionValid <= '0';

      elsif rising_edge(iCLK) then
          -- IF/ID holds a fetched instruction after the first clock.
          d_InstructionValid <= '1';
          -- Follow the exception across EX, MEM, and WB cycles.
          e_ExceptionValid <= d_ExceptionValid and not s_ExceptionPending;
          m_ExceptionValid <= e_ExceptionValid;
          w_ExceptionValid <= m_ExceptionValid;

          -- Capture only the first exception until reset.
          if d_ExceptionValid = '1' and s_ExceptionPending = '0' then
              s_ExceptionPending <= '1';
              s_ExceptionPC <= d_PC; -- Record the address of the fault.

              if d_Ebreak = '1' then
                  s_ExceptionCause <= "0011"; -- EBREAK uses cause 3.
              else
                  s_ExceptionCause <= "0010"; -- Unsupported/illegal uses cause 2.
              end if;
          end if;

          -- Mark completion once the exception reaches the WB timing slot.
          if w_ExceptionValid = '1' then
              s_ExceptionDone <= '1';
          end if;
      end if;
  end process;


  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_PC when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             be   => "1111",
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             be   => s_DMemBE,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- Feed NOPs into IF/ID while an exception blocks new instructions.
  FETCH_DECODE: F_D_REG
    port map(i_CLK => iCLK, i_RST => iRST, i_WE => '1',
             i_PC => s_PC, i_PC4 => MID_PC_NEXT_4, i_Instruction => s_InstToDecode,
             o_PC => d_PC, o_PC4 => d_PC4, o_Instruction => d_Inst);

  -- Use protected controls so the faulting/younger instructions cannot commit.
  DECODE_EXECUTE: D_E_REG
    port map(i_CLK => iCLK, i_RST => iRST, i_WE => '1',
             i_PC => d_PC, i_PC4 => d_PC4, i_RdAddress => d_Inst(11 downto 7),
             i_Rs1Value => MID_REG_A_OUT, i_Rs2Value => MID_REG_B_OUT,
             i_Immediate => MID_IMMEDIATE_FULL, i_ALUSrcA => MID_ALUSRCA,
             i_ALUSrcB => MID_ALUSRCB, i_ALUControl => MID_CONTROL_ALUCONTROL,
             i_Funct3 => d_Inst(14 downto 12), i_Branch => d_BranchSafe,
             i_Jump => d_JumpSafe, i_AndLinkReg => MID_CONTROL_ANDLINKREG,
             i_MemWrite => d_MemWriteSafe, i_MemSize => MID_CONTROL_MEMSIZE,
             i_LoadUnsigned => MID_CONTROL_LOADUNSIGNED, i_RegWrite => d_RegWriteSafe,
             i_MemToReg => MID_MEMTOREG, i_AndLink => MID_CONTROL_ANDLINK,
             i_Halt => d_HaltSafe,
             o_PC => e_PC, o_PC4 => e_PC4, o_RdAddress => e_Rd,
             o_Rs1Value => e_Rs1, o_Rs2Value => e_Rs2, o_Immediate => e_Immediate,
             o_ALUSrcA => e_ALUSrcA, o_ALUSrcB => e_ALUSrcB,
             o_ALUControl => e_ALUControl, o_Funct3 => e_Funct3,
             o_Branch => e_Branch, o_Jump => e_Jump, o_AndLinkReg => e_AndLinkReg,
             o_MemWrite => e_MemWrite,
             o_MemSize => e_MemSize, o_LoadUnsigned => e_LoadUnsigned,
             o_RegWrite => e_RegWrite, o_MemToReg => e_MemToReg,
             o_AndLink => e_AndLink, o_Halt => e_Halt);

  EXECUTE_MEMORY: E_M_REG
    port map(i_CLK => iCLK, i_RST => iRST, i_WE => '1',
             i_PC4 => e_PC4, i_RdAddress => e_Rd,
             i_ALUResult => MID_ADDSUB_OUT, i_StoreData => e_Rs2,
             i_MemWrite => e_MemWrite, i_MemSize => e_MemSize,
             i_LoadUnsigned => e_LoadUnsigned, i_RegWrite => e_RegWrite,
             i_MemToReg => e_MemToReg, i_AndLink => e_AndLink, i_Halt => e_Halt,
             o_PC4 => m_PC4, o_RdAddress => m_Rd,
             o_ALUResult => m_ALUResult, o_StoreData => m_StoreData,
             o_MemWrite => m_MemWrite, o_MemSize => m_MemSize,
             o_LoadUnsigned => m_LoadUnsigned, o_RegWrite => m_RegWrite,
             o_MemToReg => m_MemToReg, o_AndLink => m_AndLink, o_Halt => m_Halt);

  MEMORY_WRITEBACK: M_W_REG
    port map(i_CLK => iCLK, i_RST => iRST, i_WE => '1',
             i_PC4 => m_PC4, i_RdAddress => m_Rd,
             i_ALUResult => m_ALUResult, i_LoadData => MID_LOAD_DATA,
             i_RegWrite => m_RegWrite, i_MemToReg => m_MemToReg,
             i_AndLink => m_AndLink, i_Halt => m_Halt,
             o_PC4 => w_PC4, o_RdAddress => s_RegWrAddr,
             o_ALUResult => w_ALUResult, o_LoadData => w_LoadData,
             o_RegWrite => s_RegWr, o_MemToReg => w_MemToReg,
             o_AndLink => w_AndLink, o_Halt => s_Halt);

  d_Halt <= '1' when d_Inst = x"10500073" else '0';

  with MID_CONTROL_IMMTYPE select
    MID_IMMEDIATE_FULL <= 
      (31 downto 12 => d_Inst(31)) & d_Inst(31 downto 25) & d_Inst(11 downto 7) when "001",                      -- S-type
      (31 downto 12 => d_Inst(31)) & d_Inst(7) & d_Inst(30 downto 25) & d_Inst(11 downto 8) & '0' when "010",    -- B-type
      d_Inst(31 downto 12) & x"000" when "011",                                                                  -- U-type
      (31 downto 20 => d_Inst(31)) & d_Inst(19 downto 12) & d_Inst(20) & d_Inst(30 downto 21) & '0' when "100",  -- J-type
      (31 downto 11 => d_Inst(31)) & d_Inst(30 downto 20) when others;                                           -- I-type
             
              
CONTROL_UNIT: control
port MAP(i_opcode        => d_Inst(6 downto 0),
         i_func3         => d_Inst(14 downto 12),
         i_func7         => d_Inst(31 downto 25),
         o_RegWrite      => d_RegWrite,
         o_MemWrite      => d_MemWrite,
         o_ALUSrcA       => MID_ALUSRCA,
         o_ALUSrcB       => MID_ALUSRCB,
         o_MemToReg      => MID_MEMTOREG,
         o_Branch        => MID_CONTROL_BRANCH,
         o_Jump          => MID_CONTROL_JUMP,
         o_AndLink       => MID_CONTROL_ANDLINK,
         o_AndLinkReg    => MID_CONTROL_ANDLINKREG,
         o_ImmediateType => MID_CONTROL_IMMTYPE,
         o_MemSize       => MID_CONTROL_MEMSIZE,
         o_LoadUnsigned  => MID_CONTROL_LOADUNSIGNED,
         o_ALUControl    => MID_CONTROL_ALUCONTROL);

  STORE_ALIGNER: store_align
    port MAP(i_Data       => m_StoreData,
             i_Address    => m_ALUResult(1 downto 0),
             i_Size       => m_MemSize,
             o_Data       => MID_STORE_DATA,
             o_ByteEnable => s_DMemBE);

  LOAD_EXTENDER: load_extend
    port MAP(i_Data     => s_DMemOut,
             i_Address  => m_ALUResult(1 downto 0),
             i_Size     => m_MemSize,
             i_Unsigned => m_LoadUnsigned,
             o_Data     => MID_LOAD_DATA);

  REGISTER_FILE: reg_file
  generic MAP(N => N)
    port MAP(i_CLK       => iCLK,
             i_RST       => iRST,
             i_W_VAL     => s_RegWrData,
             i_W_ADDR    => s_RegWrAddr,
             i_W_EN      => s_RegWr,
             i_R_ADDR_A  => d_Inst(19 downto 15),
             i_R_ADDR_B  => d_Inst(24 downto 20),
             o_R_VAL_A   => MID_REG_A_OUT,
             o_R_VAL_B   => MID_REG_B_OUT);


pc_add_four: add_sub
    generic MAP(N => N)
    port MAP(i_A  => s_PC,
             i_B  => x"00000004",
             i_C  => '0',
             o_S  => MID_PC_NEXT_4,
             o_C  => open);
             
  -- func3(2:1) picks the condition (beq/bne: zero, blt/bge: signed lt, bltu/bgeu: unsigned lt)
  -- and func3(0) inverts it (bne, bge, bgeu)
  with e_Funct3(2 downto 1) select
    MID_BRANCH_COND <= MID_ALU_ZERO when "00",
                       MID_ALU_LT   when "10",
                       MID_ALU_LTU  when "11",
                       '0'          when others;

  MID_BRANCH_TAKEN <= MID_BRANCH_COND xor e_Funct3(0);

  pc_and: andg2
    port MAP(i_A  => e_Branch,
             i_B  => MID_BRANCH_TAKEN,
             o_F  => MID_PC_AND);
             
  pc_or: org2
    port MAP(i_A  => e_Jump,
             i_B  => MID_PC_AND,
             o_F  => MID_PC_MUX_SEL);

  PC_BASE_MUX: mux2t1_N
    generic MAP(N => N)
    port MAP(i_S  => e_AndLinkReg,
             i_D0 => e_PC,
             i_D1 => e_Rs1,
             o_O  => MID_PC_BASE);
             
  pc_add_jump_reg: add_sub
    generic MAP(N => N)
    port MAP(i_A  => MID_PC_BASE,
             i_B  => e_Immediate,
             i_C  => '0',
             o_S  => MID_PC_JUMP_REG,
             o_C  => open);

  pc_mux: mux2t1_N
    generic MAP(N  => N)
    port MAP(i_S   => MID_PC_MUX_SEL,
         i_D0      => MID_PC_NEXT_4,
         i_D1      => MID_PC_JUMP_REG(31 downto 1) & '0',
         o_O       => MID_PC_NEXT);
             
  -- Hold the PC after a fault; older pipeline stages keep advancing.
  PC_REG: pc
  generic MAP(N => N)
    port MAP(i_CLK => iCLK,
             i_RST => iRST,
             i_WE => not s_ExceptionBlock,
             i_D   => MID_PC_NEXT,
             o_Q   => s_PC);

  MY_ALU: alu
    generic MAP(N => N)
    port MAP(i_A          => MID_ALU_A_IN,
             i_B          => MID_ALUMUX_OUT,
             i_ALUControl => e_ALUControl,
             o_Result     => MID_ADDSUB_OUT,
             o_Zero       => MID_ALU_ZERO,
             o_CarryOut   => open,
             o_LT         => MID_ALU_LT,
             o_LTU        => MID_ALU_LTU);

with e_ALUSrcA select
    MID_ALU_A_IN <= e_PC          when "01",
                    x"00000000"   when "10",
                    e_Rs1         when others;

  ALU_SRC_B_MUX: mux2t1_N
    generic MAP(N => N) 
    port MAP(i_S  => e_ALUSrcB,
             i_D0 => e_Rs2,
             i_D1 => e_Immediate,
             o_O  => MID_ALUMUX_OUT);

  AND_LINK_MUX: mux2t1_N
    generic MAP(N  => N)
    port MAP(i_S   => w_AndLink,
         i_D0      => w_PC4,
         i_D1      => w_ALUResult,
         o_O       => MID_BOTMUX_OUT);

  MEM_TO_REG_MUX: mux2t1_N
  generic MAP(N => N) 
    port MAP(i_S  => w_MemToReg,
             i_D0 => MID_BOTMUX_OUT,
             i_D1 => w_LoadData,
             o_O  => MID_REGMUX_OUT);


  s_RegWrData <= MID_REGMUX_OUT;
  s_DMemWr <= m_MemWrite;
  s_DMemAddr <= m_ALUResult;
  s_DMemData <= MID_STORE_DATA;
  oALUOut <= MID_ADDSUB_OUT;

end structure;
