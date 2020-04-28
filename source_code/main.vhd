----------------------------------------------------------------------------------
-- Company:         University of Birmingham
-- Engineer:        Yifan Du
-- Create Date:     2020/04/25 06:28:39
-- Design Name:     main function (buttons)
-- Module Name:     main - Behavioral
-- Project Name:    8 bits combination lock
-- Target Devices:  NEXYS 4 DDR
-- Tool Versions:   Vivado 2019.2
-- Description:     Specify output, input.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
port (
        CLK100MHZ:      in      STD_LOGIC;                           -- Main Frequency        
        SWITCHES:       in      STD_LOGIC_VECTOR (9 downto 0);      -- Use to input password
        DIGITS:         out     STD_LOGIC_VECTOR (7 downto 0);      -- Digits of 8 digit 8 segments digital display
        SEGMENTS:       out     STD_LOGIC_VECTOR (7 downto 0);      -- Segments of 8 digit 8 segments digital display
        BTN_Confirm:    in      STD_LOGIC;                           -- Button of comfirm function (central)
        BTN_Modify:     in      STD_LOGIC;                           -- Button of modify function (left)
        BTN_Forget:     in      STD_LOGIC;                           -- Button of forget function (right)
        BTN_Cancel:     in      STD_LOGIC;                           -- Button of cancel function (down)
        BTN_Input:      in      STD_LOGIC;                           -- Button of input function (up)        
        RESET_N:        in      STD_LOGIC                            -- Button of reset, negetive (cpu reset) 
    );
end main;

architecture Behavioral of main is   
    signal CLK800Hz:       STD_LOGIC;
    signal CLK100Hz:        STD_LOGIC;    
    signal CLK_Switches:    STD_LOGIC;
    signal inputValue:      STD_LOGIC_VECTOR(3 downto 0);
    signal codeSequence:    STD_LOGIC_VECTOR (31 downto 0)  :=  (others => '1');    
    signal digitCounter:    STD_LOGIC_VECTOR (3 downto 0)   :=  (others => '0');              
    signal sequenceBuffer:  STD_LOGIC_VECTOR (31 downto 0)  :=  (others => '0');    
    signal PasswordState:   boolean;    
    signal allowInput:      boolean;
    signal clearData:       boolean;            
    signal displayCode:     boolean;
    
    signal displayNumber:   boolean; 
    signal displayData:     STD_LOGIC_VECTOR (31 downto 0);
begin        
    ButtonsFunction: process(CLK100Hz, RESET_N)        
        variable rightPassword:     STD_LOGIC_VECTOR (31 downto 0)  
                                    :=  B"0010_0000_0011_0100_1000_1000_0100_1101"; -- Right password
        variable securityPassword:  STD_LOGIC_VECTOR (31 downto 0)  
                                    :=  B"1001_1000_0000_0011_0010_0110_1101_1101"; -- Security pwd
        variable counter:           STD_LOGIC_VECTOR (7 DOWNTO 0)   :=  (others => '0');        
        variable switchCounter:     STD_LOGIC_VECTOR (7 DOWNTO 0)   :=  (others => '0');
        
        variable deBounced:         boolean; -- Whether to debounce
        variable modifyMode:        boolean;         
        variable changeDisplay:     boolean; -- Code / State
        variable switchDisplay:     boolean; -- Code sequence or OK / Err        
    begin
        if RESET_N = '0' then                          
            PasswordState <= FALSE;
            deBounced := FALSE;
            clearData <= FALSE;
            modifyMode := FALSE;
            allowInput <= FALSE;
            displayCode <= FALSE;   -- display state in code_sequence.vhd            
            changeDisplay := FALSE;
            switchDisplay := FALSE;
            rightPassword := B"0010_0000_0011_0100_1000_1000_0100_1101";
        elsif rising_edge(CLK100Hz) then          
            -- De-Bounce                                        
            SingleButtonFunction: if (deBounced = TRUE)  or (clearData = TRUE) then                
                counter := counter + '1';
                if counter = B"0001_0100" then --  wait for  20 ms
                    counter := (others => '0');
                    deBounced := FALSE;
                    clearData <= FALSE;
                end if;            
                                                                                                                                            
            elsif ( (BTN_Confirm = '1') or -- if any button has been pushed 
                    (BTN_Modify = '1') or 
                    (BTN_Forget = '1') or 
                    (BTN_Cancel = '1') or 
                    (BTN_Confirm = '1') or 
                    (BTN_Input = '1')) then           
                deBounced := TRUE;       
                switchDisplay := FALSE;         
                ConfirmButtonFunction: if BTN_Confirm = '1' then
                    displayCode <= TRUE;
                    displayNumber <= FALSE;
                    allowInput <= FALSE;
                    if modifyMode = TRUE then -- change password
                        rightPassword := codeSequence;
                        PasswordState <= TRUE;
                        modifyMode := FALSE;                     
                    else
                        displayData <= codeSequence; -- display state
                        switchDisplay := TRUE;
                        is_right_sequence: if sequenceBuffer = codeSequence then
                            PasswordState <= TRUE;
                        else
                            PasswordState <= FALSE;    
                        end if is_right_sequence;
                    end if;    
                end if ConfirmButtonFunction;
                
                InputButtonFunction: if BTN_Input = '1' then  --
                    clearData <= TRUE;                  
                    allowInput <= TRUE;
                    sequenceBuffer <= rightPassword; 
                end if InputButtonFunction;
                
                ModifyButtonFunction: if BTN_Modify = '1' then                                                   
                    if PasswordState = TRUE then
                        allowInput <= TRUE;
                        clearData <= TRUE; 
                        ModifyMode := TRUE;
                        displayCode <= FALSE;
                    else                     
                        displayCode <= TRUE;   
                        PasswordState <= FALSE;                               
                    end if;                        
                end if ModifyButtonFunction;
                
                ForgetButtonFunction: if BTN_Forget = '1' then
                    sequenceBuffer <= securityPassword;
                    clearData <= TRUE;                         
                    allowInput <= TRUE;                                                  
                end if ForgetButtonFunction;                    
                
                CancelButtonFunction: if BTN_Cancel = '1' then                    
                    PasswordState <= FALSE;
                    clearData <= TRUE;
                    allowInput <= FALSE;
                    displayCode <= FALSE;
                end if CancelButtonFunction;
                
            elsif switchDisplay = TRUE then -- switch display when input correct code sequence
                displayCode <=  TRUE;
                switchCounter := switchCounter + '1';
                if switchCounter = B"0110_0100" then --  wait for  1s
                    switchCounter := (others => '0');
                    changeDisplay := not changeDisplay;
                end if;
                if changeDisplay = TRUE then -- number                    
                    displayNumber <= TRUE;
                else -- OK / ERR
                    displayCode <= TRUE;
                    displayNumber <= FALSE;
                    if sequenceBuffer = displayData then
                        PasswordState <= TRUE;
                    else
                        PasswordState <= FALSE;    
                    end if;
                end if;
                                                                                                                                            
            end if SingleButtonFunction;                        
        end if;
    end process ButtonsFunction;
                  
    Create_CLK800Hz: entity work.CLK800Hz(Behavioral) 
    PORT MAP(
        CLK100MHZ => CLK100MHZ,
        RESET_N => RESET_N,
        CLK800Hz => CLK_800Hz
    );
    
    Create_CLK100Hz: entity work.CLK100Hz(Behavioral) 
    PORT MAP(
        CLK100MHZ => CLK100MHZ,
        RESET_N => RESET_N,
        CLK100Hz => CLK100Hz        
    );    
    
    Create_CLK_Switchs: entity work.CLK_Switches(Behavioral) 
    PORT MAP(
        CLK100Hz => CLK100Hz,
        SWITCHES => SWITCHES,
        CLK_Switches => CLK_Switches,
        clearData => clearData,
        RESET_N => RESET_N
    );        
    
    Get_Bit_Counter: entity work.Digits_Counter(Behavioral) 
    PORT MAP(
        CLK_Switches => CLK_Switches,
        digitCounter => digitCounter,        
        clearData => clearData,
        allowInput => allowInput,
        RESET_N => RESET_N            
    );
    
    Get_Code_Sequence: entity work.Code_Sequence(Behavioral) 
    PORT MAP(
        CLK100MHZ => CLK100MHZ,
        codeSequence => codeSequence,                
        PasswordState => PasswordState,
        digitCounter => digitCounter,
        inputValue => inputValue,
        clearData => clearData,
        displayCode => displayCode,
        displayNumber => displayNumber,
        displayData => displayData,
        RESET_N => RESET_N    
    );
    
    Get_Input_Keys: entity work.Get_Keys(Behavioral) 
    PORT MAP(
        SWITCHES => SWITCHES,
        inputValue => inputValue,
        CLK100Hz => CLK100Hz,
        RESET_N => RESET_N   
    );
    
    Go_To_Display: entity work.Eight_Digits_Display(Behavioral) 
    PORT MAP(
        CLK800Hz => CLK800Hz,
        codeSequence => codeSequence,        
        SEGMENTS => SEGMENTS,
        DIGITS => DIGITS,
        RESET_N => RESET_N
    );
end Behavioral;