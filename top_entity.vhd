-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.Numeric_std.all;
USE ieee.std_logic_unsigned.ALL;

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
        O_HEX_N             : out Std_logic_Vector(27 downto 0);

        -- SRAM outputs
		    OE    : out std_logic;     -- Output signal for enabling output
		    CE 	  : out std_logic;	  -- Output for chip enable
		    WE    : out std_logic;	  --output for write enable
		    LB    : out std_logic;     --output for lower data bits from SRAM
		    UB    : out std_logic;     --output for upper data bits from SRAM
		    BUSY  : out std_logic;	  --output for controller busy signal
		    OUT_DATA_ADR : out std_logic_vector(17 downto 0);	--address signal for sram input
		    SRAM_bidir_bus :inout std_logic_vector(7 downto 0)	--bidirection datatbus to sram

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
        I_DATA_ADDR         : in Std_logic_Vector(17 downto 0);
        O_DATA_ADDR	        : out Std_logic_Vector(13 downto 0);
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

	component SRAM_controller is
		port(
		-- Clocks and Resets
		I_CLK_50MHZ 	: in std_logic;
		MEM_RESET		: in std_logic;

		-- Read/write enable signals
		R_W 				: in std_logic;

		IN_DATA			: in std_logic_vector(15 downto 0);

		IN_DATA_ADDR 	: in std_logic_vector(17 downto 0);

		OUT_DATA			: out std_logic_vector(15 downto 0);
		OUT_DATA_ADR 	: out std_logic_vector(17 downto 0);

		SRAM_bidir_bus :inout std_logic_vector(7 downto 0);

		-- SRAM Control Signals
		OE 				: out std_logic;
		CE					: out std_logic;
		WE					: out std_logic;
		LB					: out std_logic;
		UB 				: out std_logic;
		BUSY				: out std_logic
		);
  end component SRAM_controller;

	component ROM is
		port(
			address	: IN STD_LOGIC_VECTOR (7 downto 0);
			clock		: IN STD_LOGIC  := '1';
			q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	end component;

  -- keypad signals
  signal i_keypd_data : std_logic_vector(15 downto 0) := "0000000000001111";
  signal i_keypd_addr : std_logic_vector(17 downto 0) := (others => '1');
  signal h_key_pressed : std_logic;
  signal l_key_pressed : std_logic;
  signal shift_key_pressed : std_logic;

  -- data signals
  signal sram_data_address : std_logic_vector(17 downto 0);
  signal sram_output_data         : std_logic_vector(15 downto 0);
  signal sram_input_data	: std_logic_vector(15 downto 0);

  -- seven segment display signals


  --SRAM controller signals
  -- counter signal for 1 Hz clock
  signal one_hz_counter : unsigned(25 downto 0) := "00000000000000000000000000";
  signal count_enable : std_logic;

  -- contains address that data is written to
  signal input_data_addr : std_logic_vector(17 downto 0);
  signal read_write		:std_logic := '0';

  --ROM signals
  signal rom_address 	: std_logic_vector (7 downto 0);
  signal rom_data_out 	: std_logic_vector (15 downto 0);
  signal isstartup : std_logic := '1';

begin

    HEX_DISP : quad_hex_driver
    port map(
        I_CLK_50MHZ   => I_CLK_50MHZ,
        I_RESET_N     => I_RESET_N,
        I_COUNT       => i_keypd_data,
        I_DATA_ADDR   => i_keypd_addr(17 downto 0),
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

	 SRAM : SRAM_controller
	 port map(
		I_CLK_50MHZ => I_CLK_50MHZ,
		MEM_RESET => I_RESET_N,
		R_W => read_write,
		IN_DATA => sram_input_data,
		IN_DATA_ADDR => input_data_addr,
		OUT_DATA => sram_output_data,
		SRAM_bidir_bus => SRAM_bidir_bus,
		OE => OE,
		CE => CE,
		WE => WE,
		LB => LB,
		UB => UB,
		BUSY => BUSY,
		OUT_DATA_ADR => OUT_DATA_ADR
	 );

	 ROM_MAPPING : ROM
	 port map(
		address => rom_address,
		clock => I_CLK_50MHZ,
		q => rom_data_out
	 );

	 --SRAM processes
	ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_RESET_N)
      begin
		   if(I_RESET_N = '1') then
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

  ------------------------------------------------------------------------------
  -- Process Name     : SRAM_COUNTER
  -- Sensitivity List : I_CLK_50MHZ    : 100 MHz global clock
  --                    I_RESET_N    : Global Reset line
  -- Useful Outputs   : input_data_addr
  --
  -- Description      : Initializes SRAM to ROM values when reset
  --							Increments SRAM address every second in read mode
  --							Changes SRAM address in write mode
  ------------------------------------------------------------------------------
  SRAM_COUNTER : process (I_CLK_50MHZ, I_RESET_N)
      begin
			if(rising_edge(I_CLK_50MHZ)) then
				if(I_RESET_N = '1' or isstartup = '1') then
					isstartup <= '0';
					input_data_addr <= "000000000000000000";
					rom_address <= "00000000";

					for I in 0 to 255 loop
						sram_input_data <= rom_data_out;
						input_data_addr <= input_data_addr + 1;
						rom_address <= rom_address + 1;

						--delay for write time;
						for J in 0 to 3 loop
						end loop;
					end loop;
				elsif(one_hz_counter = "10111110101111000001111111" and read_write = '1') then
				  if(input_data_addr = "000000000011111111" and count_enable = '0') then
						input_data_addr <= "000000000000000000";  -- reset address count
				  else
					  input_data_addr <= input_data_addr + 1;  -- increase count
				  end if;

				elsif(not read_write = '1') then
					input_data_addr <= sram_data_address;
				end if;
		  end if;
  end process SRAM_COUNTER;

  READ_WRITE_TOGGLE : process (I_CLK_50MHZ, I_RESET_N)
	begin
		if(rising_edge(I_CLK_50MHZ)) then
			if (shift_key_pressed = '1' and I_RESET_N = '0') then
				if(read_write = '1') then
					read_write <= '0';
				else
					read_write <= '1';
				end if;
			else
				read_write <= '0'; --reset
			end if;
		end if;
  end process READ_WRITE_TOGGLE;

  end rtl;
