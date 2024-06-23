----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2024 11:50:12 AM
-- Design Name: 
-- Module Name: MEM - Behavioral
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

entity MEM is
    Port ( clk          : in STD_LOGIC;
           memWrite     : in STD_LOGIC;
           ALUResIn     : in STD_LOGIC_VECTOR (31 downto 0);
           RD2          : in STD_LOGIC_VECTOR (31 downto 0);
           ALUResOut    : out STD_LOGIC_VECTOR (31 downto 0);
           MemData      : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is

type ram_mem is array(0 to 63) of std_logic_vector(31 downto 0);
signal ram : ram_mem := (
    X"00000049",
    X"0000001A",
    X"00000008",
    X"00000034",
    X"00000050",
    X"0000001f",
    X"00000019",
    X"00000005",
    X"0000002B",
    X"00000020",
    X"0000000D",
    X"00000009",
    X"00000016",
    X"00000042",
    X"000000F2",
    X"000000CC",
    others => X"00000000"
);

begin

process(clk, memWrite, RD2, ALUResIn)
begin
    if(rising_edge(clk)) then
        if(memWrite = '1') then
            ram(conv_integer(ALUResIn)) <= RD2;
        end if;
    end if;
end process;

ALUResOut <= ALUResIn;
MemData <= ram(conv_integer(ALUResIn));

end Behavioral;
