--------------------------------------------------------------------------------
-- Filename     : top_entity.vhd
-- Author       : Kyle Bielby
-- Date Created : 2021-02-04
-- Last Revised : 2021-02-04
-- Project      : EE 316 Project 1
-- Description  : Top entity of SRAM  controller used to implement all modular
--                entities
--
--------------------------------------------------------------------------------

-----------------
--  Libraries  --
-----------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--------------
--  Entity  --
--------------
entity top_entity is
    port(
        -- Clock and reset Signals
        I_RESET_N   : in std_logic;
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

        -- Seven segment display outputs
        O_DATA_ADDR	      : out Std_logic_Vector(13 downto 0);
        O_HEX_N           : out Std_logic_Vector(27 downto 0);

        -- SRAM outputs
        SRAM_DATA_ADR : out std_logic_vector(17 downto 0);
        DIO : inout std_logic_vector(15 downto 0);
        CE_N : out std_logic;
        WE_N    : out std_logic;     -- signal for writing to SRAM
        OE    : out std_logic;     -- Input signal for enabling output
        UB    : out std_logic;
        LB    : out std_logic;

        -- LED output
        LEDG0 : out std_logic

    );
  end top_entity;

--------------------------------
--  Architecture Declaration  --
--------------------------------
architecture rtl of top_entity is

  ----------------
  -- COMPONENTS --
  ----------------

  -- SRAM controlller
  component SRAM_controller is
  port
  (
    I_CLK_50MHZ     : in std_logic;
    I_SYSTEM_RST_N  : in std_logic;
    COUNT_EN : in std_logic;
    RW         : in std_logic;
    DIO : inout std_logic_vector(15 downto 0);
    CE_N : out std_logic;
    WE_N    : out std_logic;
    OE    : out std_logic;
    UB    : out std_logic;
    LB    : out std_logic;
    IN_DATA      : in std_logic_vector(15 downto 0);
    IN_DATA_ADDR : in std_logic_vector(17 downto 0);
    OUT_DATA    : out std_logic_vector(15 downto 0);
    OUT_DATA_ADR : out std_logic_vector(17 downto 0)
  );
  end component SRAM_controller;

  -- seven segment display driver
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

  -- Key counter/keypad driver
  component key_counter is
      port(
          I_CLK_50MHZ     : in  std_logic;
          I_SYSTEM_RST    : in  std_logic;
          ADDR            : in std_logic;
          I_KEYPAD_ROW_1  : in  std_logic;
          I_KEYPAD_ROW_2  : in  std_logic;
          I_KEYPAD_ROW_3  : in  std_logic;
          I_KEYPAD_ROW_4  : in  std_logic;
          I_KEYPAD_ROW_5  : in  std_logic;
          O_KEYPAD_COL_1  : out std_logic;
          O_KEYPAD_COL_2  : out std_logic;
          O_KEYPAD_COL_3  : out std_logic;
          O_KEYPAD_COL_4  : out std_logic;
          OP_MODE         : out std_logic;
          H_KEY_OUT       : out std_logic;
          L_KEY_OUT       : out std_logic;
          O_KEY_ADDR      : out std_logic_vector(17 downto 0);
          KEY_DATA_OUT    : out std_logic_vector(15 downto 0)
      );
  end component key_counter;

  -- ROM driver (auto generated signature)
  component ROM is
  	port
  	(
  		address		: in std_logic_vector (7 downto 0);
  		clock		  : in std_logic  := '1';
  		q		      : out std_logic_vector (15 downto 0)
  	);
  end component ROM;

  -------------
  -- SIGNALS --
  -------------

  -- ROM initialization signal
  signal rom_initialize     : std_logic := '0';
  signal rom_data           : std_logic_vector(15 downto 0);
  signal init_data_addr     : unsigned(17 downto 0) := (others => '1');
  signal rom_address_change : std_logic;
  signal rom_write          : unsigned(17 downto 0) := (others => '0');

  -- keypad signals
  signal i_keypd_data : std_logic_vector(15 downto 0);
  signal i_keypd_addr : std_logic_vector(17 downto 0) := (others => '1');
  signal h_key_pressed : std_logic;
  signal l_key_pressed : std_logic;
  signal shift_key_pressed : std_logic;
  signal address_active : std_logic;

  -- data signals
  signal sram_data_address : unsigned(17 downto 0);
  signal sram_data         : std_logic_vector(15 downto 0);

  -- sram Signals
  signal out_data_signal       : std_logic_vector(15 downto 0);
  signal count_enable          : std_logic;
  signal count_enable_1        : std_logic;
  signal counter_paused        : std_logic := '1';
  signal one_hz_counter_signal : unsigned(25 downto 0) := (others => '0');
  signal RW                    : std_logic;

  -- seven segment data signals
  signal hex_data_in : std_logic_vector(15 downto 0);
  signal hex_data_addr : unsigned(7 downto 0);

  -- controller state signals
  type CONTROL_ST is (
      INIT,
      OPERATION,
      PROGRAMMING
  );

  signal controller_state : CONTROL_ST := INIT;

  -- Programming mode states
  type PROGRAM_ST is (
      SRAM_ADDR_MD,
      SRAM_DATA_MD
  );

  signal program_mode : PROGRAM_ST := SRAM_ADDR_MD;

  -- Counting mode states
  type COUNT_MODE is(
      COUNT_UP,
      COUNT_DOWN
  );

  signal count_direction : COUNT_MODE;

  begin

    -- ROM driver port map
    ROM_UNIT : ROM
    port map(
        address	=> std_logic_vector(init_data_addr(7 downto 0)),
        clock	  => I_CLK_50MHZ,
        q	      => rom_data
    );

    -- SRAM  controller port map
    SRAM : SRAM_controller
    port map(
        I_CLK_50MHZ    => I_CLK_50MHZ,
        I_SYSTEM_RST_N => I_RESET_N,
        COUNT_EN       => count_enable_1,
        RW             => RW,
        DIO            => DIO,
        CE_N           => CE_N,
        WE_N           => WE_N,
        OE             => OE,
        UB             => UB,
        LB             => LB,
        IN_DATA        => sram_data,
        IN_DATA_ADDR   => std_logic_vector(sram_data_address),
        OUT_DATA       => out_data_signal,
        OUT_DATA_ADR   => SRAM_DATA_ADR
    );

    -- Seven sement driver port map
    HEX_DISP : quad_hex_driver
    port map(
        I_CLK_50MHZ   => I_CLK_50MHZ,
        I_RESET_N     => I_RESET_N,
        I_COUNT       => hex_data_in,
        I_DATA_ADDR   => std_logic_vector(hex_data_addr),
        O_DATA_ADDR	  => O_DATA_ADDR,
        O_HEX_N       => O_HEX_N
    );

    -- Key counter/keypad driver port map
    KEYPAD : key_counter
    port map(
        I_CLK_50MHZ    => I_CLK_50MHZ,
        I_SYSTEM_RST   => I_RESET_N,
        ADDR           => address_active,
        I_KEYPAD_ROW_1 => I_KEYPAD_ROW_1,
        I_KEYPAD_ROW_2 => I_KEYPAD_ROW_2,
        I_KEYPAD_ROW_3 => I_KEYPAD_ROW_3,
        I_KEYPAD_ROW_4 => I_KEYPAD_ROW_4,
        I_KEYPAD_ROW_5 => I_KEYPAD_ROW_5,
        O_KEYPAD_COL_1 => O_KEYPAD_COL_1,
        O_KEYPAD_COL_2 => O_KEYPAD_COL_2,
        O_KEYPAD_COL_3 => O_KEYPAD_COL_3,
        O_KEYPAD_COL_4 => O_KEYPAD_COL_4,
        OP_MODE        => shift_key_pressed,
        H_KEY_OUT      => h_key_pressed,
        L_KEY_OUT      => l_key_pressed,
        O_KEY_ADDR     => i_keypd_addr,
        KEY_DATA_OUT   => i_keypd_data
    );

    ------------------------------------------------------------------------------
    -- Process Name     : ONE_HZ_CLOCK
    --
    -- Sensitivity List : I_CLK_50MHZ    : 50 MHz global clock
    --                    I_RESET_N      : Global Reset line
    --
    -- Useful Outputs   : count_enable   : Enable to allow state change in SRAM
    --                                     controller
    --
    --                  : one_hz_counter_signal : signal used for counter value
    --
    -- Description      : One Hz clock counter enable generator used to control
    --                    SRAM read write operations.
    ------------------------------------------------------------------------------
    ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_RESET_N)
     begin
       if(I_RESET_N = '0') then
           one_hz_counter_signal <= (others => '0');
           count_enable          <= '0';
       elsif (rising_edge(I_CLK_50MHZ)) then
         if (controller_state = INIT ) then
             if (rom_write = "110000110101000000") then  --101
                 count_enable <= '1';
             else
                 count_enable <= '0';
             end if;
         end if;

        if (controller_state = OPERATION) then
            one_hz_counter_signal <= one_hz_counter_signal + 1;
            if (one_hz_counter_signal = "10111110101111000001111111") then
                count_enable <= '1';
                one_hz_counter_signal <= (others => '0');
            else
                count_enable <= '0';
            end if;
        elsif (controller_state = PROGRAMMING) then
            count_enable <= l_key_pressed;
        end if;
        count_enable_1 <= count_enable;
     end if;
    end process ONE_HZ_CLOCK;
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Process Name     : KEYPAD_EN_CNTR
    -- Sensitivity List : I_CLK_50MHZ     : 50 MHz global clock
    --                    I_RESET_N       : Global Reset line
    --
    -- Useful Outputs   : controller_state : The state holder signal for the
    --                    current state of the sate machine
    --
    --                  : address_active : signal to state if address input is
    --                    to be collected from the keypad driver and written to
    --                    the seven segment display
    --
    --                  : counter_paused : signal used to control the state of
    --                    the ONE_HZ_CLOCK process
    --
    -- Description      : State machine process that is responsible for changing
    --                    the current state of the controller
    ----------------------------------------------------------------------------
    CONTROL_STATE : process(I_CLK_50MHZ, I_RESET_N)
        begin
            if (I_RESET_N = '0') then
                controller_state <= INIT;
                address_active <= '0';
                counter_paused <= '0';
            elsif (rising_edge(I_CLK_50MHZ)) then

              case( controller_state ) is
                when INIT =>
                    LEDG0 <= '0';

                    if ( rom_initialize = '1') then
                        controller_state <= OPERATION;
                    end if;

                when OPERATION =>
                    LEDG0 <= '1';

                    if (shift_key_pressed = '1') then
                        controller_state <= PROGRAMMING;
                        counter_paused <= '1';
                    elsif (shift_key_pressed = '0') then
                        if (h_key_pressed = '1') then
                           counter_paused <= not(counter_paused);
                        end if;

                        if (l_key_pressed = '1') then
                            case( count_direction ) is
                              when COUNT_UP =>
                                  count_direction <= COUNT_DOWN;
                              when COUNT_DOWN =>
                                  count_direction <= COUNT_UP;
                            end case;
                        end if;
                    end if;

                when PROGRAMMING =>
                    LEDG0 <= '0';

                    if (shift_key_pressed = '1') then
                        controller_state <= OPERATION;
                        counter_paused   <= '1';
                    elsif (shift_key_pressed = '0') then
                        if (h_key_pressed = '1') then
                           case( program_mode ) is
                             when SRAM_ADDR_MD =>
                                 address_active <= '0';
                                 program_mode <= SRAM_DATA_MD;
                             when SRAM_DATA_MD =>
                                 address_active <= '1';
                                 program_mode <= SRAM_ADDR_MD;
                           end case;
                        end if;
                    end if;
              end case;
            end if;
    end process CONTROL_STATE;
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Process Name     : STATE_FUNCTION
    -- Sensitivity List : I_CLK_50MHZ    : 50 MHz global clock
    --                    I_RESET_N      : Global Reset line
    --
    -- Useful Outputs   : hex_data_addr : the SRAM address signal used to
    --                    display the address on the seven segment display
    --
    --                  : sram_data : the data written to the sram controller
    --
    --                  : rom_write : the intermediate signal used to transmit
    --                    data form the ROM to the SRAM
    --
    --                  : rom_initialize : the signal used to indicate the SRAM
    --                    has been initialized with the ROM contents
    --
    --                  : init_data_addr : the intermediate signal used to
    --                    initialize the SRAM
    --
    -- Description      : this process uses the current state of the controller
    --                    state machine to set the signals needed for read and
    --                    write operations to the SRAM
    --
    ----------------------------------------------------------------------------
    STATE_FUNCTION : process(I_CLK_50MHZ, I_RESET_N)
        begin
            if (I_RESET_N = '0') then
                hex_data_addr     <= (others  => '0');
                sram_data         <= (others  => '0');
                rom_write         <= (others  => '0');
                rom_initialize    <= '0';
                init_data_addr    <= (others  => '1');
            elsif (rising_edge(I_CLK_50MHZ)) then
                case controller_state is
                    when INIT =>
                        RW <= '0';

                        if (init_data_addr /= "000000000100000000") then
                            sram_data_address <= init_data_addr;
                            sram_data         <= rom_data;
                            hex_data_in       <= rom_data;
                            hex_data_addr     <= init_data_addr(7 downto 0);
                        end if;

                        rom_write <= rom_write + 1;
                        if (rom_write = "110000110101000000") then
                            rom_write <= (others => '0');
                            init_data_addr <= init_data_addr + 1;

                            if (init_data_addr = "000000000011111111") then
                                hex_data_in   <= (others => '0');
                                hex_data_addr <= (others => '0');
                                sram_data <= (others => '0');
                                sram_data_address <= (others => '0');
                                rom_initialize <= '1';
                            end if;
                         end if;

                    when OPERATION =>
                        RW <= '1';
                        hex_data_in       <= out_data_signal;
                        if (count_enable = '1') then
                          case( count_direction ) is
                              when COUNT_UP =>
                                  if (sram_data_address(7 downto 0) = "11111111" and counter_paused = '0') then
                                      sram_data_address <= (others  => '0');
                                      hex_data_addr     <= (others  => '0');
                                  elsif (counter_paused = '0') then
                                      sram_data_address <= sram_data_address + 1;
                                      hex_data_addr     <= hex_data_addr     + 1;
                                  end if;

                              when COUNT_DOWN =>
                                  if (sram_data_address(7 downto 0) = "00000000" and counter_paused = '0') then
                                      sram_data_address(7 downto 0) <= (others  => '1');
                                      hex_data_addr     <= (others  => '1');
                                  elsif (counter_paused = '0') then
                                      sram_data_address <= sram_data_address - 1;
                                      hex_data_addr     <= hex_data_addr     - 1;
                                  end if;
                          end case;
                      end if;

                    when PROGRAMMING =>
                        RW <= '0';
                        if (shift_key_pressed = '1') then
                            hex_data_addr     <= (others => '0');
                            sram_data_address <= (others => '0');
                            hex_data_in       <= (others => '0');
                        elsif (shift_key_pressed = '0') then
                            hex_data_addr     <= unsigned(i_keypd_addr(7 downto 0));
                            hex_data_in       <= std_logic_vector(i_keypd_data);
                            if (l_key_pressed = '1') then
                                sram_data_address(7 downto 0) <= unsigned(i_keypd_addr(7 downto 0));
                                sram_data         <= std_logic_vector(i_keypd_data);
                            end if;
                        end if;

                end case;
            end if;
    end process STATE_FUNCTION;
    ----------------------------------------------------------------------------

  end rtl;
