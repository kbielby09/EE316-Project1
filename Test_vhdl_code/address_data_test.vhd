library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


  --------------
  --  Entity  --
  --------------
  entity address_data_test is
  port
  (
    -- Clocks & Resets
    I_CLK_50MHZ    : in std_logic;                    -- Input clock signal

    I_SYSTEM_RST_N      : in std_logic;               -- Input signal to reset SRAM data form ROM

    COUNT_EN : in std_logic;

    TRIGGER     : out std_logic;

    -- seven segment display digit selection port
    OUT_DATA    : out std_logic_vector(15 downto 0);       -- if bit is 1 then digit is activated and if bit is 0 digit is inactive
                                                              -- bits 0-3: digit 1; bits 3-7: digit 2, bit 7: digit 4

    -- hex display for data address
    OUT_DATA_ADR : out std_logic_vector(7 downto 0)      -- segments that are to be illuminated for the seven segment hex
                                                              -- digits that are being used to display the address

    );
  end address_data_test;

architecture rtl of address_data_test is

    signal input_data_addr : unsigned(7 downto 0) := (others => '0');
    signal input_data      : unsigned(15 downto 0);
    signal first_pass : std_logic;

    begin

      SRAM_COUNTER : process (I_CLK_50MHZ, COUNT_EN)
          begin
              if(rising_edge(I_CLK_50MHZ)) then
                  if(COUNT_EN = '1') then
                    if(input_data_addr = "000000000001111") then --and count_enable = '0') then
                        input_data_addr <= (others => '0');  -- reset address count
                        first_pass <= not(first_pass);
                    else
                       input_data_addr <= input_data_addr + 1;  -- increase count
                    end if;
                  end if;
              end if;
      end process SRAM_COUNTER;

      SRAM_DATA_COUNTER : process (I_CLK_50MHZ, COUNT_EN)
          begin
          if (rising_edge(I_CLK_50MHZ)) then
              if (first_pass = '1') then
                  input_data <= (others => '0');
              elsif (first_pass = '0' and COUNT_EN = '1') then
                  input_data <= input_data + 1;
              end if;
          end if;
     end process SRAM_DATA_COUNTER;

     OUT_DATA <= std_logic_vector(input_data);

     OUT_DATA_ADR <= std_logic_vector(input_data_addr);

     TRIGGER <= first_pass;

end rtl;
