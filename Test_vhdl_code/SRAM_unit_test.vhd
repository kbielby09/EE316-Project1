library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity SRAM_unit_test is
port
(
  -- Clocks & Resets
  I_CLK_50MHZ     : in std_logic;                    -- Input clock signal

  I_SYSTEM_RST_N  : in std_logic;                    -- Input signal to reset SRAM data form ROM

  -- seven segment display digit selection port
  OUT_DATA    : out std_logic_vector(15 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
                                                            -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4

 -- hex display for data address
 OUT_DATA_ADR : out std_logic_vector(17 downto 0);      -- segments that are to be illuminated for the seven segment hex
                                                            -- digits that are being used to display the address

  DIO : inout std_logic_vector(15 downto 0);

  CE_N : out std_logic;

  -- Read/Write enable signals
  WE_N    : out std_logic;     -- signal for writing to SRAM
  OE    : out std_logic;     -- Input signal for enabling output

  UB    : out std_logic;
  LB    : out std_logic

  );
end SRAM_unit_test;

architecture rtl of SRAM_unit_test is

  signal trigger_signal : std_logic;
  signal in_data_signal  : std_logic_vector(15 downto 0);
  signal out_data_signal  : std_logic_vector(15 downto 0);
  signal address_signal : std_logic_vector(7 downto 0);
  signal count_enable : std_logic;
  signal one_hz_counter_signal : unsigned(25 downto 0) := "00000000000000000000000000";
  signal input_data_addr : unsigned(7 downto 0) := (others => '0');
  signal input_data      : unsigned(15 downto 0);
  signal RW : std_logic;
  signal dio_data : std_logic_vector(15 downto 0);
  signal tri_state : std_logic;
  signal ce_signal : std_logic;
  signal we_signal : std_logic;
  signal oe_signal : std_logic;
  signal ub_signal : std_logic;
  signal lb_signal : std_logic;


  component SRAM_controller is
  port
  (
    -- Clocks & Resets
    I_CLK_50MHZ     : in std_logic;                    -- Input clock signal

    I_SYSTEM_RST_N  : in std_logic;                    -- Input signal to reset SRAM data form ROM

    COUNT_EN : in std_logic;

    RW         : in std_logic := '0';

    -- digit selection input
    IN_DATA      : in std_logic_vector(15 downto 0);    -- gives the values of the digits to be illuminated
                                                              -- bits 0-3: digit 1; bits 4-7: digit 2, bits 8-11: digit 3
                                                              -- bits 12-15: digit 4

    -- IN_DATA_ADDR : in std_logic_vector(7 downto 0);     -- gives the values of the SRAM address that is to be displayed

    DIO : inout std_logic_vector(15 downto 0);

    CE_N : out std_logic;

    -- Read/Write enable signals
    WE_N    : out std_logic;     -- signal for writing to SRAM
    OE    : out std_logic;     -- Input signal for enabling output

    UB    : out std_logic;
    LB    : out std_logic;

    -- TRI : out std_logic;

    -- seven segment display digit selection port
    OUT_DATA    : out std_logic_vector(15 downto 0)       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
                                                          -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4


    );
  end component SRAM_controller;

begin

  -- SRAM_COUNTER : process (I_CLK_50MHZ)
  --     begin
  --         if(rising_edge(I_CLK_50MHZ)) then
  --             if(count_enable = '1') then
  --               if(input_data_addr = "00001111") then --and count_enable = '0') then
  --                   input_data_addr <= (others => '0');  -- reset address count
  --                   RW <= not(RW);
  --               else
  --                  input_data_addr <= input_data_addr + 1;  -- increase count
  --               end if;
  --             end if;
  --         end if;
  -- end process SRAM_COUNTER;

 --  SRAM_DATA_COUNTER : process (I_CLK_50MHZ)
 --      begin
 --      if (rising_edge(I_CLK_50MHZ)) then
 --          if (RW = '1') then
 --              input_data <= (others => '0');
 --          elsif (RW = '0' and count_enable = '1') then
 --              input_data <= input_data + 1;
 --          end if;
 --      end if;
 -- end process SRAM_DATA_COUNTER;

 ONE_HZ_CLOCK : process (I_CLK_50MHZ, I_SYSTEM_RST_N)
     begin
      -- if(I_SYSTEM_RST_N = '0') then
         -- one_hz_counter_signal <= (others => '0');
     if (rising_edge(I_CLK_50MHZ)) then
         one_hz_counter_signal <= one_hz_counter_signal + 1;
         if (one_hz_counter_signal = "10111110101111000001111111") then  -- check for 1 Hz clock (count to 50 million)
             count_enable <= '1';
             RW <= not(RW);
             one_hz_counter_signal <= (others => '0');
         else
             count_enable <= '0';
         end if;
     end if;

 end process ONE_HZ_CLOCK;

  SRAM : SRAM_controller
      port map(
          I_CLK_50MHZ => I_CLK_50MHZ,
          I_SYSTEM_RST_N => I_SYSTEM_RST_N,
          COUNT_EN => count_enable,
          RW => RW,
          DIO => DIO,
          CE_N => CE_N,
          WE_N => WE_N,
          OE => OE,
          UB => UB,
          LB => LB,
          -- TRI => tri_state,
          IN_DATA => std_logic_vector(input_data),
          -- IN_DATA_ADDR => std_logic_vector(input_data_addr),
          OUT_DATA => OUT_DATA
      );

      -- OUT_DATA <= out_data_signal;
      OUT_DATA_ADR <= "000000000000001111";

      -- DIO <= dio_data when tri_state = '1'  else (others => 'Z');

      -- CE_N <= '0';
      --
      -- WE_N <= we_signal;
      -- OE <= oe_signal;
      --
      -- UB <= '0';
      -- LB <= '0';

end rtl;
