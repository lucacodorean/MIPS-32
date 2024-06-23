----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/07/2024 10:57:49 PM
-- Design Name: 
-- Module Name: test_new - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_new is
    Port ( clk : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_new;

architecture Behavioral of test_new is

component MPG 
    port ( clk: in STD_LOGIC; btn: in STD_LOGIC; ENABLE: out STD_LOGIC); 
end component;

signal CNT: std_logic_vector(31 downto 0);
signal  EN: std_logic;

begin
   
    an(7 downto 4) <= "1111";
    an(3 downto 0) <= btn(3 downto 0);
    cat <= (others => '0');
    
    MPG1: MPG port map(clk => clk, btn => btn(0), ENABLE => EN);
    
    process(clk)
    begin
        if rising_edge(clk) then
            CNT <= CNT + 1;
        end if;
    
    end process;
   
    process(CNT)
    begin
         case CNT is
             when "000"  => led <= "00000001";
             when "001"  => led <= "00000010";
             when "010"  => led <= "00000100";
             when "011"  => led <= "00001000";
             when "100"  => led <= "00010000";
             when "101"  => led <= "00100000";
             when "110"  => led <= "01000000";
             when others => led <= "10000000";
        end case;
end process;
end Behavioral;
