----------------------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     Determain input bits 
-- Module Name:     Bit_Counter - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Use clock by switches to determain inputs bits 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Digits_Counter is
PORT(
    CLK_Switches:   in      STD_LOGIC;
    digitCounter:   out     STD_LOGIC_VECTOR (3 downto 0);    
    clearData:      in      boolean;   
    allowInput:     in      boolean;
    RESET_N:        in      STD_LOGIC
);
end Digits_Counter;

architecture Behavioral of Digits_Counter is
    signal digitCounter_Local:   STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
begin
    process(CLK_Switches, RESET_N)
    begin
        if RESET_N = '0' then                      
            digitCounter_Local <= (others => '0');
        elsif rising_edge(CLK_Switches) then -- Counter     
            if clearData = TRUE then
                digitCounter_Local <= (others => '0');       
            elsif allowInput = TRUE then -- initial and cancel                                                                                                                                                                                                  
                digitCounter_Local <= digitCounter_Local + '1';
                if digitCounter_Local = B"1000"then
                    digitCounter_Local <= (others => '0');                    
                end if;                            
            end if;                                                        
        end if;                
    end process;
    digitCounter <= digitCounter_Local;
end Behavioral;