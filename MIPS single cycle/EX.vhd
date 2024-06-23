----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2024 09:03:47 AM
-- Design Name: 
-- Module Name: EX - Behavioral
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
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EX is
    Port ( rd1          : in STD_LOGIC_VECTOR (31 downto 0);
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
end EX;

architecture Behavioral of EX is
signal mux_rd2_ext: std_logic_vector(31 downto 0) := X"00000000";
signal tempAluRes:  std_logic_vector(31 downto 0) := X"00000000";
signal aluCtrl:     std_logic_vector(0 to 2)      := "000";   

begin

MUX1: process(rd2, ext_imm, alusrc) 
begin
    case (alusrc) is
        when '0' => mux_rd2_ext <= rd2;
        when '1' => mux_rd2_ext <= ext_imm;
    end case;
end process;

ALU_CONTROL: process(ALUop, func)
begin
    case(ALUop) is
        when "000000" =>
            case(func) is
                when "100000" => aluCtrl <= "000"; -- add
                when "110000" => aluCtrl <= "001"; -- sub
                when "111000" => aluCtrl <= "010"; -- and
                when "111100" => aluCtrl <= "100"; -- or
                when "111110" => aluCtrl <= "101"; -- mod
                when "000001" => aluCtrl <= "011"; -- xor
                when "000011" => aluCtrl <= "110"; -- sll
                when "000111" => aluCtrl <= "111"; -- srl
                when others   => aluCtrl <= "000";
            end case;
        
        when "100000" => aluCtrl <= "000"; -- LW
        when "110000" => aluCtrl <= "000"; -- SW
        when "111111" => aluCtrl <= "111"; -- J
        when "001000" => aluCtrl <= "011"; -- BEQ
        when "001100" => aluCtrl <= "001"; -- BNEQ
        when "000010" => aluCtrl <= "110"; -- MODI
        when "000001" => aluCtrl <= "101"; -- ADDI
        when others   => aluCtrl <= "000";
    end case;
end process;

ALU: process(aluCtrl, aluOp, rd1, mux_rd2_ext, sa, tempAluRes) 
begin
     case(ALUop) is
        when "000000" =>
            case(aluCtrl) is
                when "000" => tempAluRes <= rd1   +   mux_rd2_ext;
                when "001" => tempAluRes <= rd1   -   mux_rd2_ext;
                when "010" => tempAluRes <= rd1  and  mux_rd2_ext;
                when "011" => tempAluRes <= rd1  xor  mux_rd2_ext;
                when "100" => tempAluRes <= rd1  or   mux_rd2_ext;
                when "101" => tempAluRes <= std_logic_vector(unsigned(rd1) mod unsigned(mux_rd2_ext));  -- mod
                when "110" => 
                    if sa = "00001" then
                        tempAluRes <= rd1(30 downto 0) & "0";
                    else tempAluRes <= rd1;
                    end if;
                 
                when "111" => 
                    if sa = "00001" then
                        tempAluRes <= "0" & rd1(31 downto 1);
                    else tempAluRes <= rd1;
                    end if;
                when others => tempAluRes <= X"00000000";
            end case; 
        
        when "100000" => tempAluRes <=  rd1 + mux_rd2_ext; -- LW
        when "110000" => tempAluRes <=  rd1 + mux_rd2_ext; -- SW
        when "001000" => tempAluRes <=  rd1 - mux_rd2_ext; -- BEQ
        when "001100" => tempAluRes <=  rd1 - mux_rd2_ext; -- BNEQ
        when "000010" => tempAluRes <=  std_logic_vector(unsigned(rd1) mod unsigned(mux_rd2_ext)); -- MODI
        when "000001" => tempAluRes <=  rd1 + mux_rd2_ext;                                         -- ADDI
        when "111111" => tempAluRes <=  X"00000000"; -- J, nu conteaza
        when others   => tempAluRes <=  X"00000000";
    end case;
end process;

aluRes <= tempAluRes;
zero <= '1' when tempAluRes = X"00000000" else '0';
branch_addr <= (ext_imm(29 downto 0) & "00") + PCp4;
end Behavioral;
