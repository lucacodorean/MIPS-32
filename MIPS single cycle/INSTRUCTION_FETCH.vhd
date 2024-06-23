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
                                                -- instr        pc + 4 
    B"000000_00101_00101_00101_00000_000001",   -- A5  2801    |   4                se initializeaza valoarea neutra pentru suma partiala folosind     xor
    B"000001_00110_00000_0000000000000000",     -- 4C0 0000  |   8                se initializeaza valoarea neutra pentru suma   totala folosind     addi 0
    B"000000_00001_00001_00001_00000_000001",   -- 21  0801  |   C                se initializeaza contorul pentru bucla
    B"000001_00100_00000_0000000000001111",     -- 48  0000F |  10                se incarca limita pentru array
    B"000000_00010_00010_00010_00000_000001",   -- 42   1001 |  14                se initializeaza indexul locatiei de memorie pentru elementul current din array
    B"000000_00111_00111_00111_00000_000001",   -- E7  3801  |  18                se intializeaza  un registru auxiliar, folosit pentru a stoca valori temporare
    B"001000_00001_00100_0000000000001000",     -- 2081 0008 |  1C                s-au facut 15 iteratii? daca da, iesi din loop
    B"100000_00010_00011_0000000000000000",     -- 8043 0000 |  20  1c            incarca in $3 elementul de la indexul $2
    B"000010_00111_00011_0000000000000011",     -- 8E3  0003 |  24  20            incarca in registrul auxiliar valoarea array[$2] % 3
    B"001100_00000_00111_0000000000000001",     -- 3007 0001 |  28  24            daca in registrul $7 nu se afla valoarea 0, atunci du-te la continue_loop
    B"000000_00101_00011_00101_00000_100000",   -- A3   2820 |  2C  28            daca sunt egale, adauga-mi la $5 valoarea din $3.
    B"000000_00110_00011_00110_00000_100000",   -- C3   3020 |  30  2c            adauga la suma totala elementul curent.
    B"000001_00010_00010_0000000000000100",     -- 442  0004 |  34  30            urmatorul index din sir
    B"000001_00001_00001_0000000000000001",     -- 421  0001 |  38  34            i++
    B"111111_00000000000000000000000110",       -- FC00 0006 |  3C  38            du-te la inceputul lui begin_loop
    B"000000_00111_00111_00111_00000_000001",   -- E7   3801 |  40  3c            reseteaza valoarea temporara
    B"000000_00101_00110_00111_00000_111100",   -- A6   383C |  44  40            pune-mi in registrul 7 temporar suma totala OR suma partiala
    B"110000_00111_00000_0000000000111100",     -- C0E0 003C |  48  44            la adresa 86, salveaza-mi valoarea din $5
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
