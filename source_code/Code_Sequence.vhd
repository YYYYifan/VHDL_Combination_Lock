----------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     Get code sequence 
-- Module Name:     Code_Sequence - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Get code sequence
----------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Code_Sequence is
PORT(
    CLK100MHZ:      in      STD_LOGIC;                             
    codeSequence:   out     STD_LOGIC_VECTOR (31 downto 0);        
    PasswordState:  in      boolean;
    digitCounter:   in      STD_LOGIC_VECTOR (3 downto 0);
    inputValue:     in      STD_LOGIC_VECTOR (3 downto 0);
    clearData:      in      boolean;   
    displayCode:    in      boolean;    -- Display something from main    
    displayNumber:  in      boolean;    -- TRUE -> Code Sequence, FALSE -> OK / Err
    displayData:    in      STD_LOGIC_VECTOR (31 downto 0);    
    RESET_N:        in      STD_LOGIC         
);
end Code_Sequence;

architecture Behavioral of Code_Sequence is
    signal codeSequence_Local: STD_LOGIC_VECTOR (31 downto 0);
begin
    process(CLK100MHZ, RESET_N)
    begin
        if RESET_N = '0' then         
            codeSequence_Local <=  B"1101_1101_1101_1101_1101_1101_1101_1101";                      
        elsif rising_edge(CLK100MHZ) then                                                                                  
            if displayCode = TRUE then -- confirm 
                if displayNumber = FALSE then
                    if PasswordState = TRUE then -- is right code sequcnce ?
                        -- OK
                        codeSequence_Local <= B"1111_1111_1111_1111_1111_1111_0000_1010"; 
                    else
                        -- Error
                        codeSequence_Local <= B"1111_1111_1111_1111_1111_1011_1100_1100"; 
                    end if;
                else
                    codeSequence_Local <= displayData;
                end if;    
            elsif clearData = TRUE then    
                codeSequence_Local <= B"1101_1101_1101_1101_1101_1101_1101_1101";
            else    
                case digitCounter is           
                    when "0000" => codeSequence_Local <= B"1101_1101_1101_1101_1101_1101_1101_1101";                                                             
                    when "0001" => codeSequence_Local (31 downto 28)   <= inputValue;    
                    when "0010" => codeSequence_Local (27 downto 24)   <= inputValue;
                    when "0011" => codeSequence_Local (23 downto 20)   <= inputValue;
                    when "0100" => codeSequence_Local (19 downto 16)   <= inputValue;
                    when "0101" => codeSequence_Local (15 downto 12)   <= inputValue;
                    when "0110" => codeSequence_Local (11 downto 8)    <= inputValue;
                    when "0111" => codeSequence_Local (7  downto 4)    <= inputValue;
                    when "1000" => codeSequence_Local (3  downto 0)    <= inputValue;                                                
                    when "1111" =>  null;         
                    when others => codeSequence_Local <= B"1101_1101_1101_1101_1101_1101_1101_1101";
                end case;
            end  if;                
        end if;                                                                                                                      
    end process;
    codeSequence <= codeSequence_Local;
end Behavioral;