----------------------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     Create 100Hz clock 
-- Module Name:     CLK100Hz - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Use counter to create 100Hz clock 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CLK100Hz is
PORT(
    CLK100MHZ:      in      STD_LOGIC;
    CLK100Hz:       out     STD_LOGIC;
    RESET_N:        in      STD_LOGIC
);
end CLK100Hz;

architecture Behavioral of CLK100Hz is
    signal counter:         STD_LOGIC_VECTOR (19 downto 0);    
    signal CLK100Hz_Local:  STD_LOGIC;
begin
    -- Create 100Hz  for swiths and buttons  100Hz = 1 / F, F = 100 
    -- One Cycle  : 100 000 000 / 100 = 1 000 000
    -- Half Cycle : 1 000 000 / 2 = 500 000
    -- 500 000 in hex is A120, in binary have 20 bit
    process (CLK100MHZ, RESET_N)
    begin  -- process gen_clk
        if RESET_N = '0' then
            CLK100Hz_Local   <= '0';
            counter   <= (others => '0');
        elsif rising_edge(CLK100MHZ) then
            if counter = X"7A120"then      
                counter   <= (others => '0');
                CLK100Hz_Local   <= not CLK100Hz_Local;
            else
                counter <= counter + "1";
            end if;
        end if;
    end process;  
    CLK100Hz <= CLK100Hz_Local;

end Behavioral;
