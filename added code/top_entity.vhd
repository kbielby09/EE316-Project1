-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

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
        SRAM_DATA_ADR : out std_logic_vector(17 downto 0);      -- segments that are to be illuminated for the seven segment hex
        DIO : inout std_logic_vector(15 downto 0);
        CE_N : out std_logic;
        WE_N    : out std_logic;     -- signal for writing to SRAM
        OE    : out std_logic;     -- Input signal for enabling output
        UB    : out std_logic;
        LB    : out std_logic;

        LEDG0 : out std_logic

    );
  end top_entity;

architecture rtl of top_entity is

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

  component ROM is
  	port
  	(
  		address		: in std_logic_vector (7 downto 0);
  		clock		: in std_logic  := '1';
  		q		: out std_logic_vector (15 downto 0)
  	);
  end component ROM;

  -- ROM initialization signal
  signal rom_initialize  : std_logic := '0';
  signal rom_data        : std_logic_vector(15 downto 0);
  signal init_data_addr  : unsigned(7 downto 0);
  signal rom_write       : unsigned(1 downto 0) := "00";

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
  signal in_data_signal        : std_logic_vector(15 downto 0);
  signal out_data_signal       : std_logic_vector(15 downto 0);
  signal address_signal        : std_logic_vector(7 downto 0);
  signal count_enable          : std_logic;
  signal one_hz_counter_signal : unsigned(25 downto 0) := (others => '0');
  signal input_data_addr       : unsigned(7 downto 0) := (others => '0');
  signal input_data            : unsigned(15 downto 0);
  signal RW                    : std_logic;

  -- signal dio_data : std_logic_vector(15 downto 0);
  signal tri_state : std_logic;
  signal ce_signal : std_logic;
  signal we_signal : std_logic;
  signal oe_signal : std_logic;
  signal ub_signal : std_logic;
  signal lb_signal : std_logic;

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

  type PROGRAM_ST is (
      SRAM_ADDR_MD,
      SRAM_DATA_MD
  );

  type COUNT_MODE is(
      COUNT_UP,
      COUNT_DOWN
  );

  signal count_direction : COUNT_MODE;

  signal program_mode : PROGRAM_ST := SRAM_ADDR_MD;

  begin

    ROM_UNIT : ROM
    port map(
        address	=> std_logic_vector(init_data_addr),
        clock	=> I_CLK_50MHZ,
        q	=> rom_data
    );

    SRAM : SRAM_controller
    port map(
        I_CLK_50MHZ => I_CLK_50MHZ,
        I_SYSTEM_RST_N => I_RESET_N,
        COUNT_EN => count_enable,
        RW => RW,
        DIO => DIO,
        CE_N => CE_N,
        WE_N => WE_N,
        OE => OE,
        UB => UB,
        LB => LB,
        IN_DATA => sram_data,
        IN_DATA_ADDR => std_logic_vector(sram_data_address),
        OUT_DATA => out_data_signal,
        OUT_DATA_ADR => SRAM_DATA_ADR
    );

    HEX_DISP : quad_hex_driver
    port map(
        I_CLK_50MHZ   => I_CLK_50MHZ,
        I_RESET_N     => I_RESET_N,
        I_COUNT       => hex_data_in,
        I_DATA_ADDR   => std_logic_vector(hex_data_addr),
        O_DATA_ADDR	  => O_DATA_ADDR,
        O_HEX_N       => O_HEX_N
    );

    KEYPAD : key_counter
    port map(
        I_CLK_50MHZ => I_CLK_50MHZ,
        I_SYSTEM_RST => I_RESET_N,
        ADDR => address_active,
        I_KEYPAD_ROW_1 => I_KEYPAD_ROW_1,
        I_KEYPAD_ROW_2 => I_KEYPAD_ROW_2,
        I_KEYPAD_ROW_3 => I_KEYPAD_ROW_3,
        I_KEYPAD_ROW_4 => I_KEYPAD_ROW_4,
        I_KEYPAD_ROW_5 => I_KEYPAD_ROW_5,
        O_KEYPAD_COL_1 => O_KEYPAD_COL_1,
        O_KEYPAD_COL_2 => O_KEYPAD_COL_2,
        O_KEYPAD_COL_3 => O_KEYPAD_COL_3,
        O_KEYPAD_COL_4 => O_KEYPAD_COL_4,
        OP_MODE => shift_key_pressed,
        H_KEY_OUT => h_key_pressed,
        L_KEY_OUT => l_key_pressed,
        O_KEY_ADDR => i_keypd_addr,
        KEY_DATA_OUT => i_keypd_data
    );

    ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_RESET_N)
     begin

     if (rising_edge(I_CLK_50MHZ)) then
         if(I_RESET_N = '1') then
            one_hz_counter_signal <= (others => '0');
         end if;

         one_hz_counter_signal <= one_hz_counter_signal + 1;
         if (one_hz_counter_signal = "10111110101111000001111111") then  -- check for 1 Hz clock (count to 50 million)
             count_enable <= '1';
             one_hz_counter_signal <= (others => '0');
         else
             count_enable <= '0';
         end if;
     end if;

 end process ONE_HZ_CLOCK;

    CONTROL_STATE : process(I_CLK_50MHZ, I_RESET_N)
        begin
            if (rising_edge(I_CLK_50MHZ)) then
              if (rom_initialize = '0') then
                  controller_state <= INIT;
              end if;
              case( controller_state ) is
                when INIT =>
                    LEDG0 <= '1'; -- TODO change to 0
                    if (rom_initialize = '1') then
                        controller_state <= OPERATION;
                    end if;

                when OPERATION =>
                    LEDG0 <= '0';
                    if (I_RESET_N = '1') then
                        controller_state <= INIT;
                    elsif (shift_key_pressed = '1') then
                        controller_state <= PROGRAMMING;
                    elsif (shift_key_pressed = '0') then
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
                    LEDG0 <= '0'; -- TODO change to 1

                    if (I_RESET_N = '1') then
                       controller_state <= INIT;
                       address_active <= '0';
                    elsif (shift_key_pressed = '1') then
                        controller_state <= OPERATION;
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

    STATE_FUNCTION : process(I_CLK_50MHZ, I_RESET_N)
        begin
            if (rising_edge(I_CLK_50MHZ)) then
                case controller_state is
                    when INIT =>
                        RW <= '0';

                        sram_data_address(7 downto 0) <= init_data_addr;
                        sram_data     <= rom_data;
                        hex_data_in   <= rom_data;
                        hex_data_addr <= init_data_addr;

                        rom_write <= rom_write + 1;

                        if (rom_write = "11") then
                            rom_write <= (others => '0');
                            init_data_addr <= init_data_addr + 1;
                            if (init_data_addr = "11111111") then
                                init_data_addr <= (others => '0');
                                rom_initialize <= '1';
                            end if;
                        end if;

                    when OPERATION =>
                      RW <= '1';

                      if (I_RESET_N = '1') then
                          sram_data_address <= (others  => '0');
                          hex_data_addr     <= (others  => '0');
                      end if;

                      hex_data_in       <= out_data_signal;

                      if (count_enable = '1') then
                        if (sram_data_address = "11111111") then
                            sram_data_address <= (others  => '0');
                            hex_data_addr     <= (others  => '0');
                        end if;

                        case( count_direction ) is

                          when COUNT_UP =>
                              sram_data_address <= sram_data_address + 1;
                              hex_data_addr     <= hex_data_addr     + 1;

                          when COUNT_DOWN =>
                              sram_data_address <= sram_data_address - 1;
                              hex_data_addr     <= hex_data_addr     - 1;
                        end case;
                      end if;

                    when PROGRAMMING =>
                        RW <= '0';

                        sram_data_address <= unsigned(i_keypd_addr);
                        hex_data_addr     <= unsigned(i_keypd_addr(7 downto 0));
                        sram_data         <= std_logic_vector(i_keypd_data);
                        hex_data_in       <= std_logic_vector(i_keypd_data);

                end case;
            end if;
    end process STATE_FUNCTION;


  end rtl;
