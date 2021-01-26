-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity top_entity is
    port(
        -- Clocks and base signals
        I_RESET_N : in std_logic;
        I_CLK_50MHZ : in std_logic;

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
        O_KEYPAD_COL_4  : out std_logic;

        -- hex display outputs
        O_DATA_ADDR	      : out Std_logic_Vector(13 downto 0);
        O_HEX_N             : out Std_logic_Vector(27 downto 0)

        -- SRAM outputs

        -- Seven-seg display outputs
        -- HEX_ADDR : out std_logic_vector(7 downto 0);  -- Used for sending the address to the hexadecimal driver
        -- HEX_DATA : out std_logic_vector(15 downto 0)    -- Used for displaying the data in the SRAM

    );
  end top_entity;

architecture rtl of top_entity is

  component quad_hex_driver is
      port
      (
        I_CLK_50MHZ         : in Std_logic;
        I_RESET_N           : in Std_logic;
        I_COUNT             : in Std_logic_Vector(15 downto 0);
        I_DATA_ADDR         : in Std_logic_Vector(7 downto 0);
        O_DATA_ADDR	      : out Std_logic_Vector(13 downto 0);
        O_HEX_N             : out Std_logic_Vector(27 downto 0)
      );
  end component quad_hex_driver;

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
  signal i_keypd_data : std_logic_vector(15 downto 0) := "0000000000001111";
  signal i_keypd_addr : std_logic_vector(17 downto 0) := (others => '1');
  signal h_key_pressed : std_logic;
  signal l_key_pressed : std_logic;
  signal shift_key_pressed : std_logic;

  -- data signals
  signal sram_data_address : std_logic_vector(17 downto 0);
  signal sram_data         : std_logic_vector(15 downto 0);

  -- seven segment display signals


  begin

    HEX_DISP : quad_hex_driver
    port map(
        I_CLK_50MHZ   => I_CLK_50MHZ,
        I_RESET_N     => I_RESET_N,
        I_COUNT       => i_keypd_data,
        I_DATA_ADDR   => i_keypd_addr(7 downto 0),
        O_DATA_ADDR	  => O_DATA_ADDR,
        O_HEX_N       => O_HEX_N
    );

    KEYPAD : key_counter
    port map(
        I_CLK_50MHZ => I_CLK_50MHZ,
        I_SYSTEM_RST => I_RESET_N,

        -- Keypad Inputs (rows)
        I_KEYPAD_ROW_1 => I_KEYPAD_ROW_1,
        I_KEYPAD_ROW_2 => I_KEYPAD_ROW_2,
        I_KEYPAD_ROW_3 => I_KEYPAD_ROW_3,
        I_KEYPAD_ROW_4 => I_KEYPAD_ROW_4,
        I_KEYPAD_ROW_5 => I_KEYPAD_ROW_5,

        -- Keypad Outputs (cols)
        O_KEYPAD_COL_1 => O_KEYPAD_COL_1,
        O_KEYPAD_COL_2 => O_KEYPAD_COL_2,
        O_KEYPAD_COL_3 => O_KEYPAD_COL_3,
        O_KEYPAD_COL_4 => O_KEYPAD_COL_4,

        OP_MODE => shift_key_pressed,

        -- Function key output
        H_KEY_OUT => h_key_pressed,
        L_KEY_OUT => l_key_pressed,

        O_KEY_ADDR => i_keypd_addr,

        KEY_DATA_OUT => i_keypd_data
    );


  end rtl;
