----------------------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     Create 800Hz clock 
-- Module Name:     CLK800Hz - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Use counter to create 800Hz clock 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CLK800Hz is
PORT(
    CLK100MHZ:      in      STD_LOGIC;
    RESET_N:        in      STD_LOGIC;
    CLK800Hz:      out     STD_LOGIC
);
end CLK800Hz;

architecture Behavioral of CLK800Hz is
    signal counter:             STD_LOGIC_VECTOR (15 downto 0); 
    signal CLK800Hz_Local:     STD_LOGIC;
begin
    -- Create 800Hz clock for scan 8 digits display     
    -- One Cycle  : 100 000 000 / 800 = 125 000
    -- Half Cycle : 125 000 / 2 = 62500 = F424 in hex
    -- 62 500 in hex is F424, in binary have 20 bit
    process (CLK100MHZ, RESET_N)
    begin  -- process gen_clk
        if RESET_N = '0' then
            CLK800Hz_Local   <= '0';
            counter   <= (others => '0');
        elsif rising_edge(CLK100MHZ) then
            if counter = X"F424" then      
                counter   <= (others => '0');
                CLK800Hz_Local   <= not CLK800Hz_Local;
            else
                counter <= counter + "1";
            end if;
        end if;
    end process;
    CLK800Hz <= CLK800Hz_Local;
end Behavioral;
