----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2024 10:37:00 AM
-- Design Name: 
-- Module Name: ID - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
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
end ID;

architecture Behavioral of ID is

component REGISTER_FILE is
    Port ( clk   : in STD_LOGIC;
           wa    : in STD_LOGIC_VECTOR (4   downto 0);
           wd    : in STD_LOGIC_VECTOR (31  downto 0);
           ra1   : in STD_LOGIC_VECTOR (4   downto 0);
           ra2   : in STD_LOGIC_VECTOR (4   downto 0);
           regwr : in STD_LOGIC;
           rd1   : out STD_LOGIC_VECTOR (31 downto 0);
           rd2   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal temp : std_logic_vector(4 downto 0) :=  "00000";

begin

process(instr(25 downto 21), instr(20 downto 16), regdst)
begin
    case (regdst) is
        when '1'  => temp <= instr(15 downto 11);
        when '0'  => temp <= instr(20 downto 16);
     end case;
end process;

RF: REGISTER_FILE port map(clk => clk, wd => wd, wa => temp, ra2 => instr(20 downto 16), ra1 => instr(25 downto 21), rd1 => rd1, rd2=>rd2, regwr => regwrite); 

func <= instr(5  downto 0);
sa   <= instr(10 downto 6);
ext_imm(15 downto 0)  <= Instr(15 downto 0);
ext_imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else (others => '0');
end Behavioral;
