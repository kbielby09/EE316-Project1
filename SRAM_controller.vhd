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

  -- Write enable signals
  WE    : in std_logic;

  OE    : in std_logic;

  -- digit selection input
  IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
                                                            -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
                                                            -- bits 12-15: digit 4

  IN_DATA_ADDR : in std_logic_vector(7 downto 0);     -- gives the values of the SRAM address that is to be displayed


  -- seven segment display digit selection port
  OUT_DATA    : out std_logic_vector(3 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
                                                            -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4

 -- hex display for data address
 OUT_DATA_ADR : out std_logic_vector(15 downto 0)      -- segments that are to be illuminated for the seven segment hex
                                                            -- digits that are being used to display the address

  );
end SRAM_controller;


--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of seven_seg_driver is

  -------------
  -- SIGNALS --
  -------------

  -- stores digit this is currently illuminated
  signal current_digit     : REFRESHED_DIGIT;

  -- counter for digit refresh
  signal digit_refresh_counter : unsigned(16 downto 0) := "00000000000000000";

  -- digit selection signal
  signal digit_select          : std_logic_vector(3 downto 0);

  -- value of the digit being displayed
  signal digit_value           : std_logic_vector(3 downto 0);

  -- segment selection signal
  signal segment_select    : std_logic_vector(6 downto 0);


begin

  SRAM_COUNTER : process (I_CLK_50MHZ)
      begin

  end process SRAM_COUNTER;

  INITIALIZE_SRAM : process (I_CLK_50MHZ, INITIALIZE, RESET)
      begin
        if(INITIALIZE = '1' or RESET = '1') then

        end if;

  end process INITIALIZE_SRAM;



------------------------------------------------------------------------------
  -- Process Name     : REFRESH_DIGITS
  -- Sensitivity List : I_CLK_100MHZ    : 100 MHz global clock
  --
  -- Useful Outputs   : segment_select : Gives the segment section that is to be illuminated
  --                  : digit_select : selects the digit to illuminate
  --                    (active high enable logic)
  -- Description      : illuminates the desired segment and digit that is to be displayed
  ------------------------------------------------------------------------------
  REFRESH_DIGITS : process (I_CLK_100MHZ, DIGIT_VALUES_IN)
  begin


  end process REFRESH_DIGITS;
  ------------------------------------------------------------------------------



  -- send signals to output ports
  GND_CTRL_VEC <= digit_select;
  SEG_SELECT   <= segment_select;

end architecture rtl;
