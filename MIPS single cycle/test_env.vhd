----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2024 09:48:33 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR  (4 downto  0);
           sw  : in STD_LOGIC_VECTOR  (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an  : out STD_LOGIC_VECTOR (7 downto  0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
 
component IFetch is
    Port ( clk :         in STD_LOGIC;
           jump :        in STD_LOGIC;
           pcsrc :       in STD_LOGIC;
           jump_addr :   in STD_LOGIC_VECTOR (31 downto 0);
           branch_addr : in STD_LOGIC_VECTOR (31 downto 0);
           en :          in STD_LOGIC;
           rst :         in STD_LOGIC;
           instruction : out STD_LOGIC_VECTOR (31 downto 0);
           next_pc :     out STD_LOGIC_VECTOR (31 downto 0));
end component;

component MPG is
    Port ( enable:     out STD_LOGIC;
           btn:        in STD_LOGIC;
           clk:        in STD_LOGIC);
end component; 

component SSD is
    Port ( clk:        in STD_LOGIC;
           digits:     in STD_LOGIC_VECTOR(31 downto 0);
           an:         out STD_LOGIC_VECTOR(7 downto 0);
           cat:        out STD_LOGIC_VECTOR(6 downto 0));
end component;

component MEM is
    Port ( clk:         in STD_LOGIC;
           memWrite:    in STD_LOGIC;
           RD2:         in STD_LOGIC_VECTOR(31 downto 0);
           AluResIn:    in STD_LOGIC_VECTOR(31 downto 0);
           MemData:     out STD_LOGIC_VECTOR(31 downto 0);
           AluResOut:   out STD_LOGIC_VECTOR(31 downto 0));
end component;

component EX is
      Port(rd1          : in STD_LOGIC_VECTOR (31 downto 0);
           alusrc       : in STD_LOGIC;
           rd2          : in STD_LOGIC_VECTOR (31 downto 0);
           ext_imm      : in STD_LOGIC_VECTOR (31 downto 0);
           sa           : in STD_LOGIC_VECTOR (4 downto 0);
           func         : in STD_LOGIC_VECTOR (5 downto 0);
           aluop        : in STD_LOGIC_VECTOR (5 downto 0);
           PCp4         : in STD_LOGIC_VECTOR (31 downto 0);
           zero         : out STD_LOGIC;
           ALUres       : out STD_LOGIC_VECTOR (31 downto 0);
           Branch_addr  : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component ID is
    Port ( clk :        in STD_LOGIC;
           regwrite :   in STD_LOGIC;
           regdst :     in STD_LOGIC;
           extop :      in STD_LOGIC;
           wd :         in STD_LOGIC_VECTOR  (31 downto 0);
           instr :      in STD_LOGIC_VECTOR  (31 downto 0);
           rd1 :        out STD_LOGIC_VECTOR (31 downto 0);
           rd2 :        out STD_LOGIC_VECTOR (31 downto 0);
           ext_imm :    out STD_LOGIC_VECTOR (31 downto 0);
           func :       out STD_LOGIC_VECTOR (5 downto 0);
           sa :         out STD_LOGIC_VECTOR (4 downto 0));
end component;

signal mpg_en           : std_logic := '0';
signal instruction_out  : std_logic_vector(31 downto 0)  := X"00000000";
signal next_pc_out      : std_logic_vector(31 downto 0)  := X"00000000";    
signal IF_out           : std_logic_vector(31 downto 0)  := X"00000000";

signal ID_1_OUT         : std_logic_vector(31 downto 0)  := X"00000000";
signal ID_2_OUT         : std_logic_vector(31 downto 0)  := X"00000000";
signal ID_EXT_OUT       : std_logic_vector(31 downto 0)  := X"00000000";
signal ID_FUNC          : std_logic_vector(5  downto 0)  :=    "000000";
signal ID_SA            : std_logic_vector(4  downto 0)  :=     "00000";
signal ID_FLAGS         : std_logic_vector(11  downto 0) :="000000000000";
signal ID_WRITE_DATA    : std_logic_vector(31 downto 0)  := X"00000000";

signal EX_BRANCH_ADDR   : std_logic_vector(31 downto 0)  := X"00000000";
signal EX_ALU_RES       : std_logic_vector(31 downto 0)  := X"00000000";
signal EX_ZERO          : std_logic := '0';

signal MEM_DATA_OUT     : std_logic_vector(31 downto 0)  := X"00000000";
signal MEM_READ_DATA    : std_logic_vector(31 downto 0)  := X"00000000";

signal SSD_OUT          : std_logic_vector(31 downto 0)  := X"00000000";
signal PC_SRC           : std_logic := '0';
signal JUMP_ADDRESS     : std_logic_vector(31 downto 0)  := X"00000000";

signal JUMP_ADDRESS_FIRST:     std_logic_vector(3 downto 0)  := "0000";
signal JUMP_ADDRESS_SECOND:    std_logic_vector(27 downto 0);
begin 

    JUMP_ADDRESS_FIRST <= next_pc_out(31 downto 28);
    JUMP_ADDRESS_SECOND <= instruction_out(25 downto 0) & "00";
    JUMP_ADDRESS <= JUMP_ADDRESS_FIRST & JUMP_ADDRESS_SECOND;
    
    PC_SRC <= (ID_FLAGS(8) and EX_ZERO) or (ID_FLAGS(7) and not(EX_ZERO));
    
    SSD_DECIDER: process(sw(7 downto 5), IF_OUT, NEXT_PC_OUT, ID_1_OUT, ID_2_OUT, ID_EXT_OUT, EX_ALU_RES, MEM_READ_DATA, MEM_DATA_OUT)
    begin
        case(sw(7 downto 5)) is
            when "000" => SSD_OUT <= INSTRUCTION_OUT;
            when "001" => SSD_OUT <= NEXT_PC_OUT;
            when "010" => SSD_OUT <= ID_1_OUT;
            when "011" => SSD_OUT <= ID_2_OUT;
            when "100" => SSD_OUT <= ID_EXT_OUT;
            when "101" => SSD_OUT <= EX_ALU_RES;
            when "110" => SSD_OUT <= MEM_READ_DATA;
            when "111" => SSD_OUT <= MEM_DATA_OUT;
        end case;
    end process;
    
    MPG1: MPG port map(enable => mpg_en, btn => btn(0), clk => clk);
    SSD1: SSD port map(clk => clk, digits => SSD_OUT, an => an, cat => cat);                     --- ce apare pe placuta?
    
    IF1: IFetch port map(clk => clk, jump => ID_FLAGS(6), pcsrc => PC_SRC, jump_addr => JUMP_ADDRESS,
                         branch_addr => EX_BRANCH_ADDR, en => mpg_en, rst => btn(1), 
                         instruction => instruction_out, next_pc => next_pc_out
    ); 
    
    UC: process(instruction_out(31 downto 26))
        begin
        case(instruction_out(31 downto 26)) is
        --                                109876543210
            when "000000" => ID_FLAGS <= "100000000001"           ; -- R-Type
            when "100000" => ID_FLAGS <= "011000000011"           ; -- LW
            when "110000" => ID_FLAGS <= "011000000101"           ; -- SW 
            when "111111" => ID_FLAGS <= "111001001000"           ; -- J 
            when "001000" => ID_FLAGS <= "010100011000"           ; -- BEQ
            when "001100" => ID_FLAGS <= "010110011000"           ; -- BNEQ
            when "000001" => ID_FLAGS <= "011000001001"           ; -- ADDI
            when "000010" => ID_FLAGS <= "011000011001"           ; -- MODI
            when others   => ID_FLAGS <= "000000000000";
        end case;
    end process;

    ID1: ID port map(
        clk    => clk,          regwrite => ID_FLAGS(0),      regdst => ID_FLAGS(11),   
        extop  => ID_FLAGS(10),       wd => ID_WRITE_DATA,    instr  => instruction_out,   rd1 => ID_1_OUT,    
        rd2    => ID_2_OUT,      ext_imm => ID_EXT_OUT,       func   => ID_FUNC,           sa  => ID_SA
    );
    
    EX1:   EX port map( 
        rd1  => ID_1_OUT,     alusrc => ID_FLAGS(9),                    rd2         => ID_2_OUT,                        ext_imm => ID_EXT_OUT,      
        sa   => ID_SA,        func   => instruction_out(5 downto 0),    aluop       => instruction_out(31 downto 26),      PCp4 => next_pc_out,         
        zero => EX_ZERO,      ALUres => EX_ALU_RES,                     Branch_addr => EX_BRANCH_ADDR
    );  
    
    MEM1: MEM port map(
        clk  => clk,        memWrite     => ID_FLAGS(2),    ALUResIn  => EX_ALU_RES,
        RD2  => ID_2_OUT,   ALUResOut    => MEM_DATA_OUT,   MemData   => MEM_READ_DATA
    );
    
    process(ID_FLAGS(1), MEM_READ_DATA, EX_ALU_RES) 
    begin
        case(ID_FLAGS(1)) is
             when '0' => ID_WRITE_DATA <= EX_ALU_RES;
             when '1' => ID_WRITE_DATA <= MEM_READ_DATA;
        end case;
    end process;
end Behavioral;