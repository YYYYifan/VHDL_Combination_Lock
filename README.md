# University of Birmingham, 2020 Digit Design Assigment: An Combination Lock
Using VHDL language and implement on Nexys4 DDR ,design by Yifan Du
* [Hardware Specification](#hardware-specification)
* [Button Function Specification](#button-function-specification)
* [Theory](#Theory)
   * [Clock Divider](#Clock-Divider)
   * [8-Digit 7 Segment Display Driver](#8-Digit-7-Segment-Display-Driver)
---
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
### **Clock Divider**
<img src="http://chart.googleapis.com/chart?cht=tx&chl= Time = 1 / Frequency" style="border:none;">

firstly, XC7A000T main frequency = 100Mhz = 100,000,000Hz

if we want create 100Hz clock by using 100MHz clock, so the counter limit we need is 1,000,000

<img src="http://chart.googleapis.com/chart?cht=tx&chl= CounterLimit = MainFrequency / 100 = 1000000" style="border:none;">

 we need to use counter limit divided by 2, because there has high-level and low-level in one cycle.

<img src="http://chart.googleapis.com/chart?cht=tx&chl= CounterLimit = CounterLimit / 2 = 1000000/2 = 500000" style="border:none;">

So, its mean when counter is equal to 500000, we change the "CLK100Hz" e.g: high-level -> low-level
5000000 in hex is 7A120, and has 18 bit in binary

#### Code Implement
In './source_code/VLK100Hz.Vhd'
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
---
### **8-Digit 7 Segment Display Driver**
![8_Digits_7_Segments_Display](./Figures/8_Digits_7_Segments_Display.png)

It can not display a different number in the same time, basically, we use a scan signal to display a single number in a single bit and turn off others bit in the same time, when scan signal has high frequency, its looks like a string of numbers, but the frequency can not be too high, otherwise, it looks like there have nothing on the digital tube. i tried a lot of frequence, finally, 800Hz is working great for this.

Because it is common anode digital tube, so high-level is turn off, low-level is turn on

|Number|A|B|C|D|E|F|G|
|-|-|-|-|-|-|-|-|
|None|1|1|1|1|1|1|1|
|0/O|1|0|0|0|0|0|0|
|1|1|1|1|1|0|0|1|
|2|0|1|0|0|1|0|0|
|3|0|1|1|0|0|0|0|
|4|0|0|1|1|0|0|1|
|5|0|0|1|0|0|1|0|
|6|0|0|0|0|0|1|0|
|7|1|1|1|1|0|0|0|
|8|0|0|0|0|0|0|0|
|9|0|0|1|0|0|0|0|
|K|0|0|0|1|0|0|1|
|E|0|0|0|0|1|1|0|
|r|0|1|0|1|1|1|1|
|_|1|1|1|0|1|1|1|

#### Code Implement
In './source_code/Eight_Digit_Seven_Segment_Display.Vhd'
```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Eight_Digit_Seven_Segment_Display is
PORT(
    CLK800Hz:       in      STD_LOGIC;  -- Scan frequency
    codeSequence:   in      STD_LOGIC_VECTOR (31 downto 0); -- Data
    SEGMENTS:       out     STD_LOGIC_VECTOR (7 downto 0);
    DIGITS:         out     STD_LOGIC_VECTOR (7 downto 0);    
    RESET_N:        in      STD_LOGIC
);
end Eight_Digit_Seven_Segment_Display;

architecture Behavioral of Eight_Digit_Seven_Segment_Display is
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
```
---