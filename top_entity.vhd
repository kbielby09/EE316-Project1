-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity top_entity is
    port(
        -- Clocks and base signals
        SYSTEM_RESET : in std_logic;
        BASE_CLK : in std_logic;

        -- Keypad inputs
        I_KEYPAD_ROW_1  : in  std_logic;
        I_KEYPAD_ROW_2  : in  std_logic;
        I_KEYPAD_ROW_3  : in  std_logic;
        I_KEYPAD_ROW_4  : in  std_logic;
        I_KEYPAD_ROW_5  : in  std_logic;

        -- Keypad outputs
        O_KEYPAD_COL_1  : out std_logic;
        O_KEYPAD_COL_2  : out std_logic;
        O_KEYPAD_COL_3  : out std_logic;
        O_KEYPAD_COL_4  : out std_logic

        -- SRAM outputs

        -- Seven-seg display outputs
        -- HEX_ADDR : out std_logic_vector(7 downto 0);  -- Used for sending the address to the hexadecimal driver
        -- HEX_DATA : out std_logic_vector(15 downto 0)    -- Used for displaying the data in the SRAM

    );

architecture Behavior of top_entity is

  component key_counter is
      port(
      -- Clocks & Resets
      I_CLK_50MHZ    : in  std_logic;
      I_SYSTEM_RST    : in  std_logic;

      -- Keypad Inputs (rows)
      I_KEYPAD_ROW_1  : in  std_logic;
      I_KEYPAD_ROW_2  : in  std_logic;
      I_KEYPAD_ROW_3  : in  std_logic;
      I_KEYPAD_ROW_4  : in  std_logic;
      I_KEYPAD_ROW_5  : in  std_logic;

      -- Keypad Outputs (cols)
      O_KEYPAD_COL_1  : out std_logic;
      O_KEYPAD_COL_2  : out std_logic;
      O_KEYPAD_COL_3  : out std_logic;
      O_KEYPAD_COL_4  : out std_logic;

      OP_MODE         : out std_logic;

      -- Function key output
      H_KEY_OUT  : out std_logic;
      L_KEY_OUT  : out std_logic;

      O_KEY_ADDR : out std_logic_vector(17 downto 0);

      KEY_DATA_OUT : out std_logic_vector(15 downto 0)
      );

  end component key_counter;

  -- keypad signals
  signal i_keypd_data : std_logic_vector(15 downto 0);
  signal i_keypd_addr : std_logic_vector(17 downto 0);



  -- Seven Segment display component
  -- component seven_seg_driver is
  --     port( DATA_IN : in std_logic_vector(15 downto 0);
  --         DATA_ADDR_IN : in std_logic_vector(7 downto 0);
  --
  --      : out std_logic_vector();
  --      : out std_logic_vector()
  --     );
  -- end component

  -- component SRAM_controller is
  --     port();
  --   end SRAM_controller;

  begin

    -- KEYPAD : key_counter
    -- port map(
    --     I_CLK_50MHZ => I_CLK_50MHZ,
    --     I_SYSTEM_RST => I_SYSTEM_RST,
    --
    --     -- Keypad Inputs (rows)
    --     I_KEYPAD_ROW_1 => I_KEYPAD_ROW_1,
    --     I_KEYPAD_ROW_2 => I_KEYPAD_ROW_2,
    --     I_KEYPAD_ROW_3 => I_KEYPAD_ROW_3,
    --     I_KEYPAD_ROW_4 => I_KEYPAD_ROW_4,
    --     I_KEYPAD_ROW_5 => I_KEYPAD_ROW_5,
    --
    --     -- Keypad Outputs (cols)
    --     O_KEYPAD_COL_1 => O_KEYPAD_COL_1,
    --     O_KEYPAD_COL_2 => O_KEYPAD_COL_2,
    --     O_KEYPAD_COL_3 => O_KEYPAD_COL_3,
    --     O_KEYPAD_COL_4 => O_KEYPAD_COL_4,
    --
    --     OP_MODE => ,
    --
    --     -- Function key output
    --     H_KEY_OUT => ,
    --     L_KEY_OUT => ,
    --
    --     O_KEY_ADDR => ,
    --
    --     KEY_DATA_OUT => ,);

  end Behavior;
