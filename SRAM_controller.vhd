--------------------------------------------------------------------------------
-- Filename     : seven_seg_driver.vhd
-- Author       : Kyle Bielby
-- Date Created : 2020-11-05
-- Last Revised : 2020-11-05
-- Project      : seven_seg_driver
-- Description  : driver code that displays digit on the seven segment display
--------------------------------------------------------------------------------
-- Todos:
--
--
--------------------------------------------------------------------------------

-----------------
--  Libraries  --
-----------------

library IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.Numeric_std.all;
USE ieee.std_logic_unsigned.ALL;

--------------
--  Entity  --
--------------
entity SRAM_Controller is
port
(
  -- Clocks & Resets
  I_CLK_50MHZ    : in std_logic;                    -- Input clock signal

  INITIALIZE 	  : in std_logic;							 -- Input signal used to initialize sram controller
  
  MEM_RESET      : in std_logic;                    -- Input signal to reset SRAM data form ROM

  -- Read/Write enable signals
  R_W    : in std_logic;     -- signal for writing to SRAM
  

  -- digit selection input
  IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
                                                            -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
                                                            -- bits 12-15: digit 4

  IN_DATA_ADDR : in std_logic_vector(7 downto 0);     -- gives the values of the SRAM address that is to be displayed


  -- seven segment display digit selection port
  OUT_DATA    : out std_logic_vector(15 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
																			-- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4

	-- 8 bit bidirection data bus to SRAM
	SRAM_bidir_bus : inout std_logic_vector(7 downto 0);
																		  
  --SRAM control signals
  OE    : out std_logic;     -- Output signal for enabling output
  CE 	  : out std_logic;	  -- Output for chip enable 
  WE    : out std_logic;	  --output for write enable 
  LB    : out std_logic;     --output for lower data bits from SRAM 
  UB    : out std_logic;     --output for upper data bits from SRAM 
  BUSY  : out std_logic;	  --output for controller busy signal 
  
 -- hex display for data address
 OUT_DATA_ADR : out std_logic_vector(7 downto 0)      -- segments that are to be illuminated for the seven segment hex
                                                            -- digits that are being used to display the address

  );
end SRAM_Controller;


--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of SRAM_Controller is

  -------------
  -- SIGNALS --
  -------------
  
  -- counter signal for 1 Hz clock
  signal one_hz_counter : unsigned(25 downto 0) := "00000000000000000000000000";
  signal count_enable : std_logic;

  -- contains address that data is written to
  signal input_data_addr : std_logic_vector(7 downto 0);

  signal input_data      : unsigned(15 downto 0);
  signal output_data 	 : unsigned(15 downto 0);
  
  -- counter for digit refresh
  signal digit_refresh_counter : unsigned(16 downto 0) := "00000000000000000";

  -- digit selection signal
  signal digit_select          : std_logic_vector(3 downto 0);

  -- value of the digit being displayed
  signal digit_value           : std_logic_vector(3 downto 0);

  -- segment selection signal
  signal segment_select    : std_logic_vector(6 downto 0);
  
  --FSM
  type statetype is (state_init, state_ready, state_write1, state_write2, state_read1, state_read2);
  signal state : statetype;
  
  --output signals 
  signal OE_signal    : std_logic;       
  signal CE_signal 	 : std_logic;	   
  signal WE_signal    : std_logic;	   
  signal LB_signal    : std_logic;     
  signal UB_signal    : std_logic;     
  signal BUSY_signal  : std_logic;	  
  
  signal data_tofrom_SRAM : std_logic_vector(7 downto 0);
  
begin

	ONE_HZ_CLOCK : process (I_CLK_50MHZ, MEM_RESET)
      begin
		   if(MEM_RESET = '1') then
			    -- TODO add reset code here
			elsif (rising_edge(I_CLK_50MHZ)) then
				  one_hz_counter <= one_hz_counter + 1;
		      if (one_hz_counter = "10111110101111000001111111") then  -- check for 1 Hz clock (count to 50 million)
				      count_enable <= '1';
              one_hz_counter <= (others => '0');
				  else
				      count_enable <= '0';
		      end if;
			end if;

  end process ONE_HZ_CLOCK;


  SRAM_COUNTER : process (I_CLK_50MHZ)
      begin
			if(rising_edge(I_CLK_50MHZ)) then
               if(one_hz_counter = "10111110101111000001111111") then
                 if(input_data_addr = "11111111" and count_enable = '0') then
                     input_data_addr <= "00000000";  -- reset address count
                else
                    input_data_addr <= input_data_addr + 1;  -- increase count
                 end if;
               end if;
           end if;
  end process SRAM_COUNTER;

  
  SRAM_Controller_FSM : process(I_CLK_50MHZ, INITIALIZE, MEM_RESET, R_W, IN_DATA)
		begin
			if rising_edge(I_CLK_50MHZ) then
				if(INITIALIZE = '1' or MEM_RESET = '1') then
					WE <= '1';
					CE <= '0';
					OE <= '1';
					
					state <= state_init;
				else
					case state is
						when state_init =>
							state <= state_ready;
						when state_ready =>
							WE <= '1';
							CE <= '0';
							OE <= '1';
							BUSY <= '0';
							
							if(R_W = '1') then 
								state <= state_read1;
							elsif(R_W = '0') then 
								state <= state_write1;
							else
								state <= state_ready;
							end if;
						when state_read1 =>
							--read1 state outputs read upper bits first
							WE <= '1';
							OE <= '0';
							UB <= '1';
							LB <= '0';
							BUSY <= '1';
							
							--timing wait for one clock cycle
							while not one_hz_counter'event loop 
							end loop;
							
							output_data(15 downto 8) <= unsigned(data_tofrom_SRAM);
							
							state <= state_read2;
						when state_read2 =>
						
							--read2 state outputs send lower bits second
							WE <= '1';
							OE <= '0';
							UB <= '0';
							LB <= '1';
							BUSY <= '1';
							
							--timing wait for one clock cycle
							while not one_hz_counter'event loop 
							end loop;
							
							output_data(7 downto 0) <= unsigned(data_tofrom_SRAM);
							
							out_DATA <= std_logic_vector(output_data);
							
							state <= state_ready;
						when state_write1 =>
							input_data <= unsigned(IN_DATA);
							
							--write1 state outputs write lower bits first
							WE <= '0';
							OE <= '1';
							UB <= '0';
							LB <= '1';
							BUSY <= '1';
							
							--timing wait for one clock cycle
							while not one_hz_counter'event loop 
							end loop;
							
							data_tofrom_SRAM <= input_data(7 downto 0);
							
							state <= state_write2;
						when state_write2 =>
							--write2 state outputs write upper bits second
							WE <= '0';
							OE <= '1';
							UB <= '1';
							LB <= '0';
							BUSY <= '1';
							
							--timing wait for one clock cycle 
							while not one_hz_counter'event loop 
							end loop;
						
							data_tofrom_SRAM <= input_data(15 downto 8);
						
						   state <= state_ready;
					end case;	
				end if;
			end if;
		end process SRAM_Controller_FSM;

  OUT_DATA_ADR <= input_data_addr;

------------------------------------------------------------------------------
  -- Process Name     : REFRESH_DIGITS
  -- Sensitivity List : I_CLK_100MHZ    : 100 MHz global clock
  --
  -- Useful Outputs   : segment_select : Gives the segment section that is to be illuminated
  --                  : digit_select : selects the digit to illuminate
  --                    (active high enable logic)
  -- Description      : illuminates the desired segment and digit that is to be displayed
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------



  -- send signals to output ports

end architecture rtl;
