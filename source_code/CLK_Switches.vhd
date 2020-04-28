----------------------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     Create Switch clock 
-- Module Name:     CLK_Switches - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR (XC7A110T_0)
-- Tool Versions:   Vivado 2019.2
-- Description:     Create a clock based on swithces 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CLK_Switches is
PORT(
    CLK100Hz:       in      STD_LOGIC;
    SWITCHES:       in      STD_LOGIC_VECTOR (9 downto 0);
    CLK_Switches:   out     STD_LOGIC;
    clearData:      in      boolean;   
    RESET_N:        in      STD_LOGIC
);
end CLK_Switches;

architecture Behavioral of CLK_Switches is
    signal CLK_Switches_Local:           STD_LOGIC;        
begin
    process(CLK100Hz, RESET_N)
    begin
        if RESET_N = '0' then
            CLK_Switches_Local <= '0';
        elsif rising_edge(CLK100Hz) then    
            if clearData then
                CLK_Switches_Local <= not CLK_Switches_Local;
            else             
                if SWITCHES /= "0" then         -- When anyone switches has been pushed up
                    CLK_Switches_Local <= '1';   -- HIGH-level 
                elsif SWITCHES = "0" then       -- Push down
                    CLK_Switches_Local <= '0';   -- Low-level
                end if;
             end if;   
        end if;
    end process;
    CLK_Switches <= CLK_Switches_Local;          -- Output clock signal
end Behavioral;