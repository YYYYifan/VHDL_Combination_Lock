
# University of Birmingham, 2020 Digit Design Assigment: An Combination Lock
Using VHDL language and implement on Nexys4 DDR ,design by Yifan Du, Check it on [Github](https://github.com/YYYYifan/Combination_Lock)

----
* [Hardware Specification](#hardware-specification)
* [Button Function Specification](#button-function-specification)
* [Theory](#Theory)
   * [Clock Divider](#Clock-Divider)

## **Hardware Specification**
![avatar](./Figures/board.png)
- **RESET**: Reset all value, code sequence and password

- **Buttons**: Use button to entry differnet function (mode).
   - **UP**: Normal input mode
   - **Left**: Modify password mode, only working afer input right code sequence
   - **Center**: Confirm button, when user finfish input, push this button to confirm input code sequence.  
   - **Right**: Forget password mode / Admain mode
   - **Down**: Cancel / exit button.

- **8 Dight 7 Segments**: Initial state will display "_"

- **Switches**: Push up then push down same switch, its means input one number   
   - *e.g*: push up switch [4] then push down, its means input deciaml number 4

----
## **Button Function Specification**
![avatar](./Figures/Button_Specification.png)

> Input whole code sequence then push confirm (center) button 
>> *e.g* Input code sequence 0123, switch[0]-up-down -> switch[1]-up-down -> switch[2]-up-down -> switch[3]-up-down

----
## **Theory**
* ### **Clock Divider**
<img src="http://chart.googleapis.com/chart?cht=tx&chl= Time = 1 / Frequency" style="border:none;">

firstly, XC7A000T main frequency = 100Mhz = 100,000,000Hz

if we want create 100Hz clock by using 100MHz clock, so the counter limit we need is 1,000,000

<img src="http://chart.googleapis.com/chart?cht=tx&chl= CounterLimit = MainFrequency / 100 = 1000000" style="border:none;">

 we need to use counter limit divided by 2, because there has high-level and low-level in one cycle.

<img src="http://chart.googleapis.com/chart?cht=tx&chl= CounterLimit = CounterLimit / 2 = 1000000/2 = 500000" style="border:none;">

So, its mean when counter is equal to 500000, we change the "CLK100Hz" e.g: high-level -> low-level
5000000 in hex is 7A120, and has 18 bit in binary

## IMPLEMENT

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
    PORT(
        CLK100MHZ : in  std_logic;        
        RESET_N   : in  std_logic
    );
end main;

architecture Behavioral of main is
    signal counter  : std_logic_vector (17 downto 0); -- 500000 in binary has 18 bit
    signal CLK100Hz : std_logic; -- Create clock
begin
    process(CLK100MHZ, RESET_N)
    begin
        if RESET_N = '1' then
            CLK100Hz <= '0';
            counter <= (others => '0');     -- clear counter
        elsif rising_edge(CLK100MHZ) then   
            if counter = X"7A120" then      -- 500000 in hex
                counter <= (others => '0');
                CLK100Hz <= not CLK100Hz;
            else
                counter <= counter + "1";
            end if;
        end if;
    end process;
end Behavioral;
```