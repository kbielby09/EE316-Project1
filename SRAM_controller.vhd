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
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity SRAM_controller is
port
(
  -- Clocks & Resets
  I_CLK_50MHZ    : in std_logic;                    -- Input clock signal

  INITIALIZE     : in std_logic;                    -- Input signal used to iniialize SRAM

  MEM_RESET      : in std_logic;                    -- Input signal to reset SRAM data form ROM

  -- Read/Write enable signals
  WE    : in std_logic;     -- signal for writing to SRAM
  OE    : in std_logic;     -- Input signal for enabling output

  -- digit selection input
  IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
                                                            -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
                                                            -- bits 12-15: digit 4

  IN_DATA_ADDR : in std_logic_vector(7 downto 0);     -- gives the values of the SRAM address that is to be displayed


  -- seven segment display digit selection port
  OUT_DATA    : out std_logic_vector(3 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
                                                            -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4

 -- hex display for data address
 OUT_DATA_ADR : out std_logic_vector(7 downto 0)      -- segments that are to be illuminated for the seven segment hex
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
  signal input_data_addr : unsigned(7 downto 0);

  signal input_data      : std_logic_vector(15 downto 0);

  signal write_enable    : std_logic;
  signal output_enable   : std_logic;
  signal                 : std_logic;

  -- counter for digit refresh
  signal digit_refresh_counter : unsigned(16 downto 0) := "00000000000000000";

  -- digit selection signal
  signal digit_select          : std_logic_vector(3 downto 0);

  -- value of the digit being displayed
  signal digit_value           : std_logic_vector(3 downto 0);

  -- segment selection signal
  signal segment_select    : std_logic_vector(6 downto 0);


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

   SRAM_COUNTER : process (I_CLK_50MHZ, MEM_RESET)
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

 -- INITIALIZE_SRAM : process (I_CLK_50MHZ, INITIALIZE, RESET)
 --     begin
 --       if(INITIALIZE = '1' or RESET = '1') then
 --
 --       end if;
 --
 -- end process INITIALIZE_SRAM;

 WRITE_SRAM_DATA : process (I_CLK_50MHZ, WE, OE, IN_DATA)
     begin
         if(WE = '0' and CE = '1') then
             input_data <= IN_DATA;
         end if;
 end process WRITE_SRAM_DATA;

 READ_SRAM_DATA : process ()
     begin
         if(rising_edge(I_CLK_50MHZ)) then

         end if;
 end process READ_SRAM_DATA;

  OUT_DATA_ADR <= std_logic_vector(input_data_addr);
  OUT_DATA     <= input_data;



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
