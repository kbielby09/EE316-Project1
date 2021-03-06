--------------------------------------------------------------------------------
-- Filename     : SRAM_controller.vhd
-- Author       : Joseph Drahos
-- Date Created : 2021-1-14
-- Last Revised : 2021-1-25
-- Project      : EE316 Project 1
-- Description  : SRAM controller code to read and write data 
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
entity SRAM_controller is
port
(
  -- Clocks & Resets
  I_CLK_50MHZ    : in std_logic;                    -- Input clock signal
  
  MEM_RESET      : in std_logic;                    -- Input signal to reset SRAM data form ROM

  -- Read/Write enable signals
  R_W    : in std_logic;     -- signal for writing to SRAM
  

  -- digit selection input
  IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
                                                            -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
                                                            -- bits 12-15: digit 4

  IN_DATA_ADDR : in std_logic_vector(17 downto 0);     -- gives the values of the SRAM address that is to be displayed


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
 OUT_DATA_ADR : out std_logic_vector(17 downto 0)      -- segments that are to be illuminated for the seven segment hex
                                                            -- digits that are being used to display the address

  );
end SRAM_controller;


--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of SRAM_controller is

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
  ------------------------------------------------------------------------------
  -- Process Name     : SRAM_Controller_FSM
  -- Sensitivity List : I_CLK_50MHZ    	: 100 MHz global clock (1 bit)
  --                    MEM_RESET    	: Global Reset line (1 bit)
  --			R_W		: Read/Write State input (1 bit)
  --			IN_DATA		: Input data (16 bits)
  --			IN_DATA_ADDRESS	: SRAM data address 
  -- Useful Outputs   : WE 		: Write Enable SRAM Input (1 bit)
  --			CE		: Chip Enable SRAM Input (1 bit)
  --			OE		: Output Enable SRAM Input (1 bit)
  --			LB		: Lower-byte Control SRAM Input (1 bit)
  --			UB 		: Upper-byte Control SRAM Input (1 bit)
  --   			BUSY		: SRAM Busy signal output (1 bit)
  --			
  -- Description      : Finite State Machine Logic for SRAM Controller
  --			Changes between 6 states: Init, Ready, Read1, Read2, Write1, Write2
  ------------------------------------------------------------------------------
  SRAM_Controller_FSM : process(I_CLK_50MHZ, MEM_RESET, R_W, IN_DATA, IN_DATA_ADDR)
		begin
			if rising_edge(I_CLK_50MHZ) then
				if(MEM_RESET = '1') then
					state <= state_init;
				else
					case state is
						when state_init =>
							WE <= '1';
							CE <= '0';
							OE <= '1';
							BUSY <= '0';
							UB <= '1';
							LB <= '1';	
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
							while not rising_edge(I_CLK_50MHZ) loop 
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
							while not rising_edge(I_CLK_50MHZ) loop 
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
							while not rising_edge(I_CLK_50MHZ) loop 
							end loop;
							
							data_tofrom_SRAM <= std_logic_vector(input_data(7 downto 0));
							
							state <= state_write2;
						when state_write2 =>
							--write2 state outputs write upper bits second
							WE <= '0';
							OE <= '1';
							UB <= '1';
							LB <= '0';
							BUSY <= '1';
							
							--timing wait for one clock cycle 
							while not rising_edge(I_CLK_50MHZ) loop 
							end loop;
						
							data_tofrom_SRAM <= std_logic_vector(input_data(15 downto 8));
						
						   state <= state_ready;
					end case;	
				end if;
			end if;
		end process SRAM_Controller_FSM;

  OUT_DATA_ADR <= IN_DATA_ADDR; --redirects SRAM address

end architecture rtl;
