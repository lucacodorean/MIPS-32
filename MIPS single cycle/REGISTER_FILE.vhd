----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2024 06:49:31 PM
-- Design Name: 
-- Module Name: REGISTER_FILE - Behavioral
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

entity REGISTER_FILE is
    Port ( clk   : in STD_LOGIC;
           wa    : in STD_LOGIC_VECTOR (4   downto 0);
           wd    : in STD_LOGIC_VECTOR (31  downto 0);
           ra1   : in STD_LOGIC_VECTOR (4   downto 0);
           ra2   : in STD_LOGIC_VECTOR (4   downto 0);
           regwr : in STD_LOGIC;
           rd1   : out STD_LOGIC_VECTOR (31 downto 0);
           rd2   : out STD_LOGIC_VECTOR (31 downto 0));
end REGISTER_FILE;

architecture Behavioral of REGISTER_FILE is

type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal reg_file : reg_array := ( 
    others => X"00000000"
);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if regwr = '1' then
                reg_file(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
        
    rd1 <= reg_file(conv_integer(ra1));
    rd2 <= reg_file(conv_integer(ra2));

end Behavioral;
