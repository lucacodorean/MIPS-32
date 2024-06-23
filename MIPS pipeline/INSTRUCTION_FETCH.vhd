----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2024 10:35:03 AM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFetch is
    Port ( clk : in STD_LOGIC;
           jump : in STD_LOGIC;
           pcsrc : in STD_LOGIC;
           jump_addr : in STD_LOGIC_VECTOR (31 downto 0);
           branch_addr : in STD_LOGIC_VECTOR (31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           instruction : out STD_LOGIC_VECTOR (31 downto 0);
           next_pc : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

signal pc_out        : std_logic_vector(31 downto 0) := X"00000000";
signal pc_branch_mux : std_logic_vector(31 downto 0) := X"00000000";
signal pc_in         : std_logic_vector(31 downto 0) := X"00000000";
signal pc_added_4    : std_logic_vector(31 downto 0) := X"00000000";

type    MEM is array(0 to 31) of std_logic_vector(31 downto 0);    
signal  MEM_ROM : MEM := (

--              COD MASINA                               --    VARIANTA ASM      - INDEX   PCp4  HEX(0xRD1 RD2)
-----------------------------------------------------------------------------------------------------------------
        B"000000_00101_00101_00101_00000_000001",        --   XOR  $5, $5, $5    - 0     - 4    - 0x00A5 2801
        B"000001_00000_00110_0000000000000000",          --   ADDI $6, $0,  0    - 1     - 8    - 0x0406 0000
        B"000000_00000_00000_00001_00000_100000",        --   ADD  $1, $0, $0    - 2     - C    - 0x0000 0820
        B"000001_00000_00100_0000000000001111",          --   ADDI $4, $0, 15    - 3     - 10   - 0x0404 000F
        B"000000_00010_00010_00010_00000_000001",        --   XOR  $2, $2, $2    - 4     - 14   - 0x0042 1001
        B"000000_00111_00111_00111_00000_000001",        --   XOR  $7, $7, $7    - 5     - 18   - 0x00E7 3801
        B"001000_00001_00100_0000000000010001",          --   BEQ  $4, $1, 17    - 6     - 1C   - 0x2024 0011
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 7     - 20   - 0x0000 0001
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 8     - 24   - 0x0000 0001
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 9     - 28   - 0x0000 0001
        B"100000_00010_00011_0000000000000000",          --   LW   $3,  0($2)    - 10    - 2C   - 0x8043 0000
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 11    - 30   - 0x0000 0001
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 12    - 34   - 0x0000 0001
        B"000010_00011_00111_0000000000000011",          --   MODI $7, $3,  3    - 13    - 38   - 0x0867 0003
        B"001100_00000_00111_0000000000000100",          --   BNEQ $7, $0,  4    - 14    - 3C   - 0x3007 0004
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 15    - 40   - 0x0000 0001
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 16    - 44   - 0x0000 0001
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 17    - 48   - 0x0000 0001
        B"000000_00011_00101_00101_00000_100000",        --   ADD  $5, $3, $5    - 18    - 4C   - 0x0065 2820
        B"000000_00011_00110_00110_00000_100000",        --   ADD  $6, $3, $6    - 19    - 50   - 0x0066 3020
        B"000001_00010_00010_0000000000000100",          --   ADDI $2, $2,  4    - 20    - 54   - 0x0442 0004
        B"000001_00001_00001_0000000000000001",          --   ADDI $1, $1,  1    - 21    - 58   - 0x0421 0001
        B"111111_00000000000000000000000110",            --   J 6                - 22    - 5C   - 0xFC00 0006
        B"000000_00000_00000_00000_00000_000001",        --   NoOp               - 23    - 60   - 0x0000 0001
        B"000000_00111_00111_00111_00000_000001",        --   XOR  $7, $7, $7    - 24    - 64   - 0x00E7 3801
        B"000000_00110_00101_00111_00000_111100",        --   OR   $7, $6, $5    - 25    - 68   - 0x00C5 383C
        B"110000_00000_00111_0000000000111100",          --   SW   $7, 60($0)    - 26    - 6C   - 0xC007 003C
    others => x"11111111");
begin
    
    pc_added_4 <= pc_out + 4;
    process(pcsrc, branch_addr, pc_added_4) 
    begin
        case(pcsrc) is
            when '0' => pc_branch_mux <= pc_added_4;
            when '1' => pc_branch_mux <= branch_addr;
        end case;
    end process;

    process(jump, pc_branch_mux, jump_addr)
    begin
        case(jump) is
            when '0' => pc_in <= pc_branch_mux;
            when '1' => pc_in <= jump_addr;
        end case;
    end process;
       
    process(clk, en, rst, pc_in)
    begin
        if rst = '1' then
            pc_out <= X"00000000";
        end if;
        if rising_edge(clk) then 
            if en = '1' 
                then pc_out <= pc_in;
            end if;
        end if;
    end process;
    
    next_pc     <= pc_added_4; --- aici modificat
    instruction <= MEM_ROM(conv_integer(pc_out(6 downto 2))); 
end Behavioral;
