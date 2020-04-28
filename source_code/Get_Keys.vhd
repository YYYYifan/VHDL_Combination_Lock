------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     Get input data form switches 
-- Module Name:     Get_Keys - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Get input data form switches (0 - 9)
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Get_Keys is
PORT(
    SWITCHES:       in      STD_LOGIC_VECTOR(9 downto 0);
    CLK100Hz:       in      STD_LOGIC;
    inputValue:     out     STD_LOGIC_VECTOR(3 downto 0);
    RESET_N:        in      STD_LOGIC
);
end Get_Keys;

architecture Behavioral of Get_Keys is    
begin
    process(CLK100Hz, RESET_N)
    begin
         if RESET_N = '0' then
            inputValue <= B"1111";
        elsif rising_edge(CLK100Hz) then    
            case SWITCHES is 
                when "0000000000" => null;
                when "0000000001" => inputValue <= B"0000"; -- SWITCHES[0], number 0
                when "0000000010" => inputValue <= B"0001"; -- SWITCHES[1], number 1
                when "0000000100" => inputValue <= B"0010"; -- SWITCHES[2], number 2
                when "0000001000" => inputValue <= B"0011"; -- SWITCHES[3], number 3
                when "0000010000" => inputValue <= B"0100"; -- SWITCHES[4], number 4
                when "0000100000" => inputValue <= B"0101"; -- SWITCHES[5], number 5
                when "0001000000" => inputValue <= B"0110"; -- SWITCHES[6]，number 6
                when "0010000000" => inputValue <= B"0111"; -- SWITCHES[7], number 7
                when "0100000000" => inputValue <= B"1000"; -- SWITCHES[8], number 8
                when "1000000000" => inputValue <= B"1001"; -- SWITCHES[9], number 9
                when others         => null;                                           
            end case; 
        end if;
    end process;
end Behavioral;