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
           regdst       : in STD_LOGIC;
           rt           : in STD_LOGIC_VECTOR(4 downto 0);
           rd           : in STD_LOGIC_VECTOR(4 downto 0);
           rd2          : in STD_LOGIC_VECTOR (31 downto 0);
           ext_imm      : in STD_LOGIC_VECTOR (31 downto 0);
           sa           : in STD_LOGIC_VECTOR (4 downto 0);
           func         : in STD_LOGIC_VECTOR (5 downto 0);
           aluop        : in STD_LOGIC_VECTOR (2 downto 0);
           PCp4         : in STD_LOGIC_VECTOR (31 downto 0);
           zero         : out STD_LOGIC;
           ALUres       : out STD_LOGIC_VECTOR (31 downto 0);
           Branch_addr  : out STD_LOGIC_VECTOR (31 downto 0);
           rWA          : out STD_LOGIC_VECTOR(4 downto 0));
end component;

component UC is 
    Port(instr: in  STD_LOGIC_VECTOR(5 downto 0);
         flags: out STD_LOGIC_VECTOR(11 downto 0));
end component;

component ID is
    Port ( clk :        in STD_LOGIC;
           regwrite :   in STD_LOGIC;
           extop :      in STD_LOGIC;
           wd :         in STD_LOGIC_VECTOR  (31 downto 0);
           instr :      in STD_LOGIC_VECTOR  (25 downto 0);
           wa:          in STD_LOGIC_VECTOR   (4 downto 0);
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
signal EX_WRITE_ADDRESS : std_logic_vector(4 downto 0)   :="00000";
signal EX_ZERO          : std_logic := '0';

signal MEM_DATA_OUT     : std_logic_vector(31 downto 0)  := X"00000000";
signal MEM_READ_DATA    : std_logic_vector(31 downto 0)  := X"00000000";

signal SSD_OUT          : std_logic_vector(31 downto 0)  := X"00000000";
signal PC_SRC           : std_logic := '0';
signal JUMP_ADDRESS     : std_logic_vector(31 downto 0)  := X"00000000";

signal JUMP_ADDRESS_FIRST:     std_logic_vector(3 downto 0)  := "0000";
signal JUMP_ADDRESS_SECOND:    std_logic_vector(27 downto 0);

signal REG_IF_ID:   std_logic_vector(63  downto 0);
signal REG_ID_EX:   std_logic_vector(158 downto 0);
signal REG_EX_MEM:  std_logic_vector(106 downto 0);
signal REG_MEM_WB:  std_logic_vector(70  downto 0);
begin 
    
    led(11 downto 0) <= ID_FLAGS;
    JUMP_ADDRESS_FIRST <= REG_IF_ID(31 downto 28);
    JUMP_ADDRESS_SECOND <= REG_IF_ID(57 downto 32) & "00";
    JUMP_ADDRESS <= JUMP_ADDRESS_FIRST & JUMP_ADDRESS_SECOND;
    
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
    SSD1: SSD port map(clk => clk, digits => SSD_OUT, an => an, cat => cat);                 
    
    IF1: IFetch port map(clk => clk, jump => ID_FLAGS(6), pcsrc => PC_SRC, jump_addr => JUMP_ADDRESS,
                         branch_addr => REG_EX_MEM(101 downto 70), en => mpg_en, rst => btn(1), 
                         instruction => INSTRUCTION_OUT, next_pc => NEXT_PC_OUT
    ); 
    

    REG_IF_ID_SYNC: process(clk, mpg_en, NEXT_PC_OUT, INSTRUCTION_OUT)
    begin
           if rising_edge(clk) then
                if mpg_en = '1' then
                    REG_IF_ID(31 downto 0)  <= NEXT_PC_OUT;
                    REG_IF_ID(63 downto 32) <= INSTRUCTION_OUT;
                end if;
           end if;
    end process;
    
    UC1: UC port map(instr => REG_IF_ID(63 downto 58), flags => ID_FLAGS);
    
    ID1: ID port map(
        clk    => clk,          regwrite => REG_MEM_WB(69),       wa => REG_MEM_WB(4  downto  0),
        extop  => ID_FLAGS(10), wd       => ID_WRITE_DATA,    instr  =>  REG_IF_ID(57 downto 32), --- ID_WRITE_DATA nu mai intra in pipeline?   
        rd1    => ID_1_OUT,     rd2      => ID_2_OUT,        ext_imm => ID_EXT_OUT,    func   => ID_FUNC,  sa  => ID_SA
    );      
    
    REG_ID_EX_SYNC: process(clk, mpg_en, ID_FLAGS, ID_1_OUT, ID_2_OUT, REG_IF_ID, ID_EXT_OUT)
    begin
           if rising_edge(clk) then 
                if mpg_en = '1' then
                    REG_ID_EX(158) <= ID_FLAGS(1);                          -- WB
                    REG_ID_EX(157) <= ID_FLAGS(0);                          -- WB
                    REG_ID_EX(156) <= ID_FLAGS(2);                          -- M
                    REG_ID_EX(155 downto 154) <= ID_FLAGS(8 downto 7);      -- M
                    REG_ID_EX(153 downto 151) <= ID_FLAGS(5 downto 3);      -- EX
                    REG_ID_EX(150) <= ID_FLAGS(9);                          -- EX
                    REG_ID_EX(149) <= ID_FLAGS(11);                         -- EX
                    REG_ID_EX(148 downto 117) <= REG_IF_ID(31 downto 0);    -- PCp4
                    REG_ID_EX(116 downto  85) <= ID_1_OUT;                  -- READ_DATA_1
                    REG_ID_EX(84  downto  53) <= ID_2_OUT;                  -- READ_DATA_2
                    REG_ID_EX(52  downto  21) <= ID_EXT_OUT;                -- EXTENDED IMMEDIATE
                    REG_ID_EX(20  downto   0) <= REG_IF_ID(52 downto 32);   -- INSTR[20:0], de unde 20->16 e RT si 15->11 e RD, 10->6 e SA, 5->0 e func
                end if;
           end if;
    end process;
    
    EX1:   EX port map( 
        rd1  => REG_ID_EX(116 downto  85),     alusrc => REG_ID_EX(150),           rd2     => REG_ID_EX(84  downto  53),   ext_imm => REG_ID_EX(52  downto  21),      
        sa   => REG_ID_EX(10 downto 6),        func   => REG_ID_EX(5 downto 0),    aluop   => REG_ID_EX(153 downto 151),      PCp4 => REG_ID_EX(148 downto 117),
        rt   => REG_ID_EX(20 downto 16),       rd     => REG_ID_EX(15 downto 11),  regdst  => REG_ID_EX(149),       
        
        zero => EX_ZERO,                       ALUres => EX_ALU_RES,           Branch_addr => EX_BRANCH_ADDR,                 rWA  => EX_WRITE_ADDRESS
    );
    
    REG_EX_MEM_SYNC: process(clk, mpg_en, EX_ZERO, EX_ALU_RES, EX_BRANCH_ADDR, REG_ID_EX)       --- oare trebuie pus si REG_ID_EX?
    begin
           if rising_edge(clk) then
                if mpg_en = '1' then
                    REG_EX_MEM(4  downto  0)  <= EX_WRITE_ADDRESS;           --- READ ADDRESS   DIN EX
                    REG_EX_MEM(36 downto  5)  <= REG_ID_EX(84 downto 53);    --- RD2,   OARE E OK ASA?
                    REG_EX_MEM(68 downto 37)  <= EX_ALU_RES;                 --- ALU RES        DIN EX
                    REG_EX_MEM(69)            <= EX_ZERO;                    --- ZERO FLAG      DIN EX
                    REG_EX_MEM(101 downto 70) <= EX_BRANCH_ADDR;             --- BRANCH ADDR    DIN EX
                    REG_EX_MEM(103 downto 102)<= REG_ID_EX(155 downto 154);  --- EQ & NEQ       FLAGS 
                    REG_EX_MEM(104)           <= REG_ID_EX(156);             --- MEM WRITE      FLAG
                    REG_EX_MEM(105)           <= REG_ID_EX(157);             --- REG_WRITE      FLAG 
                    REG_EX_MEM(106)           <= REG_ID_EX(158);             --- MEM_TO_REG     FLAG  
                end if;
           end if;
    end process;
    
    PC_SRC <= (REG_EX_MEM(102) and REG_EX_MEM(69)) or (REG_EX_MEM(103) and not(REG_EX_MEM(69)));
    
    MEM1: MEM port map(
        clk  => clk, memWrite => REG_EX_MEM(104), ALUResIn  => REG_EX_MEM(68 downto 37), RD2  => REG_EX_MEM(36 downto  5),   
        ALUResOut => MEM_DATA_OUT,   MemData   => MEM_READ_DATA
    );
    
    REG_MEM_WB_SYNC: process(clk, mpg_en, REG_EX_MEM(109), MEM_DATA_OUT, MEM_READ_DATA, REG_EX_MEM(108))
    begin
        if(rising_edge(clk)) then 
            if(mpg_en = '1') then 
                REG_MEM_WB(4  downto  0) <= REG_EX_MEM(4 downto 0); --- WA
                REG_MEM_WB(36 downto  5) <= MEM_DATA_OUT;           --- ALU RES OUT
                REG_MEM_WB(68 downto 37) <= MEM_READ_DATA;          --- MEM DATA OUT
                REG_MEM_WB(69)           <= REG_EX_MEM(105);        --- REG WRITE
                REG_MEM_WB(70)           <= REG_EX_MEM(106);        --- MEM TO REG
            end if;
        end if;
    end process;

    process(REG_MEM_WB(70), MEM_READ_DATA, EX_ALU_RES) 
    begin
        case(REG_MEM_WB(70)) is
             when '0' => ID_WRITE_DATA <= REG_MEM_WB(36 downto  5);
             when '1' => ID_WRITE_DATA <= REG_MEM_WB(68 downto 37);
        end case;
    end process;
end Behavioral;