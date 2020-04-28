----------------------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     8 digits 8 segments 
-- Module Name:     Eight_Bits_Display - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Driver for 8 digits 8 segments
--                  split input data (8 * 4 = 32 bits) to singel bit,
--                  then display it. when clock is quickly
--                  it looks like a code sequence 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Eight_Digits_Display is
PORT(
    CLK800Hz:      in      STD_LOGIC;
    codeSequence:   in      STD_LOGIC_VECTOR (31 downto 0);        
    SEGMENTS:       out     STD_LOGIC_VECTOR (7 downto 0);
    DIGITS:         out     STD_LOGIC_VECTOR (7 downto 0);    
    RESET_N:        in      STD_LOGIC
);
end Eight_Digits_Display;

architecture Behavioral of Eight_Digits_Display is
begin
    SEGMENTS(7) <= '1'; -- Close decimal point
    process(CLK800Hz, RESET_N)
        variable  digitIndex: STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
        variable  digitData:  STD_LOGIC_VECTOR(3 downto 0) := (others => '1');
    begin
        if RESET_N = '0' then
            digitIndex := B"0000";
            DIGITS <= "11111111";
            digitData := "1111"; 
        elsif rising_edge(CLK800Hz) then            
            digitIndex := digitIndex + '1';
            if digitIndex =B"1000" then
                digitIndex := (others => '0');
            end if;                        
                        
            case digitIndex is -- switch DIGITS and select bit
                when B"0000"  =>  -- Bit 0
                    DIGITS <= "11111110";
                    digitData := codeSequence(3 downto 0);                                        
                when B"0001"  =>  -- Bit 1
                    DIGITS <= "11111101";
                    digitData := codeSequence(7 downto 4);                                            
                when B"0010"  =>  -- Bit 2
                    DIGITS <= "11111011";
                    digitData := codeSequence(11 downto 8);
                when B"0011"  =>  -- Bit 3
                    DIGITS <= "11110111";
                    digitData := codeSequence(15 downto 12); 
                when B"0100"  =>  -- Bit 4
                    DIGITS <= "11101111";
                    digitData := codeSequence(19 downto 16);
                when B"0101"  =>  -- Bit 5
                    DIGITS <= "11011111"; 
                    digitData := codeSequence(23 downto 20);
                when B"0110"  =>  -- Bit 6
                    DIGITS <= "10111111"; 
                    digitData := codeSequence(27 downto 24);
                when B"0111"  =>  -- Bit 7
                    DIGITS <= "01111111";
                    digitData := codeSequence(31 downto 28);                          
                when others  => 
                    DIGITS <= "11111111";
                    digitData := "1111";                                             
            end case;
            
            case digitData is
                when B"0000" => SEGMENTS(6 downto 0) <= "1000000"; -- 0, ok
                when B"0001" => SEGMENTS(6 downto 0) <= "1111001"; -- 1
                when B"0010" => SEGMENTS(6 downto 0) <= "0100100"; -- 2
                when B"0011" => SEGMENTS(6 downto 0) <= "0110000"; -- 3
                when B"0100" => SEGMENTS(6 downto 0) <= "0011001"; -- 4
                when B"0101" => SEGMENTS(6 downto 0) <= "0010010"; -- 5
                when B"0110" => SEGMENTS(6 downto 0) <= "0000010"; -- 6
                when B"0111" => SEGMENTS(6 downto 0) <= "1111000"; -- 7
                when B"1000" => SEGMENTS(6 downto 0) <= "0000000"; -- 8
                when B"1001" => SEGMENTS(6 downto 0) <= "0010000"; -- 9
                
                when B"1010" => SEGMENTS(6 downto 0) <= "0001001"; -- K, ok
                when B"1011" => SEGMENTS(6 downto 0) <= "0000110"; -- E
                when B"1100" => SEGMENTS(6 downto 0) <= "0101111"; -- r
                when B"1101" => SEGMENTS(6 downto 0) <= "1110111"; -- _
                when B"1111" => SEGMENTS(6 downto 0) <= "1111111"; -- close all segs
                when others => SEGMENTS(6 downto 0) <= "1111111";
            end case;
        end if;
    end process;

end Behavioral;
