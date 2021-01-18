-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity top_entity is
    port(
        -- Clocks and base signals
        SYSTEM_RESET : in std_logic;
        BASE_CLK : in std_logic;

        -- Keypad input
        

        -- SRAM inputs

        -- SRAM outputs

        -- Seven-seg display outputs
        HEX_ADDR : out std_logic_vector(7 downto 0);  -- Used for sending the address to the hexadecimal driver
        HEX_DATA : out std_logic_vector(15 downto 0)    -- Used for displaying the data in the SRAM

    );

architecture Behavior of top_entity is

  -- TODO not sure what to do with this component
  -- component hex_keypad_driver is
  --     port(I_CLK : in std_logic;
  --         RESET : in std_logic;
  --         );

  -- Seven Segment display component
  component seven_seg_driver is
      port( DATA_IN : in std_logic_vector(15 downto 0);
          DATA_ADDR_IN : in std_logic_vector(7 downto 0);

       : out std_logic_vector();
       : out std_logic_vector()
      );
