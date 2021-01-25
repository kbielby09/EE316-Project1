library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.all;

entity quad_hex_driver is
port
(
  I_CLK_50MHZ         : in Std_logic;
  I_RESET_N           : in Std_logic;
  I_COUNT             : in Std_logic_Vector(15 downto 0);
  I_DATA_ADDR         : in Std_logic_Vector(7 downto 0);
  O_DATA_ADDR	      : out Std_logic_Vector(13 downto 0);
  O_HEX_N             : out Std_logic_Vector(27 downto 0)
);
end;

architecture behavioral of quad_hex_driver is

  signal O_HEX_N_BUF: std_logic_vector(27 downto 0);
  signal O_DATA_ADDR_BUF: std_logic_vector(13 downto 0);

  begin
quad_hex_driver: process(I_CLK_50MHZ, I_RESET_N) begin 

    -- Reset state to Idle
    if I_RESET_N = '0' then
      O_HEX_N <= "1111111111111111111111111111";

    elsif rising_edge(I_CLK_50MHZ) then
      case(I_COUNT(3 downto 0)) is
        when "0000"             => -- '0'
          O_HEX_N_BUF <= "0000000000000000000001000000";
        when "0001"             => -- '1'
          O_HEX_N_BUF <= "0000000000000000000001111001";
        when "0010"             => -- '2'
          O_HEX_N_BUF <= "0000000000000000000000100100";
        when "0011"             => -- '3'
          O_HEX_N_BUF <= "0000000000000000000000110000";
        when "0100"             => -- '4'
          O_HEX_N_BUF <= "0000000000000000000000011001";
        when "0101"             => -- '5'
          O_HEX_N_BUF <= "0000000000000000000000010010";
        when "0110"             => -- '6'
          O_HEX_N_BUF <= "0000000000000000000000000010";
        when "0111"             => -- '7'
          O_HEX_N_BUF <= "0000000000000000000001111000";
        when "1000"             => -- '8'
          O_HEX_N_BUF <= "0000000000000000000000000000";
        when "1001"             => -- '9'
          O_HEX_N_BUF <= "0000000000000000000000010000";
        when "1010"             => -- 'A'
          O_HEX_N_BUF <= "0000000000000000000000001000";
        when "1011"             => -- 'B'
          O_HEX_N_BUF <= "0000000000000000000000000011";
        when "1100"             => -- 'C'
          O_HEX_N_BUF <= "0000000000000000000001000110";
        when "1101"             => -- 'D'
          O_HEX_N_BUF <= "0000000000000000000000100001";
        when "1110"             => -- 'E'
          O_HEX_N_BUF <= "0000000000000000000000000110";
        when "1111"             => -- 'F'
          O_HEX_N_BUF <= "0000000000000000000000001110";
        when others             => -- ' '
          O_HEX_N_BUF <= "0000000000000000000001111111";
      end case; 
		
		case(I_COUNT(7 downto 4)) is
        when "0000"             => -- '0'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000010000000000000";
        when "0001"             => -- '1'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000011110010000000";
        when "0010"             => -- '2'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000001001000000000";
        when "0011"             => -- '3'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000001100000000000";
        when "0100"             => -- '4'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000110010000000";
        when "0101"             => -- '5'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000100100000000";
        when "0110"             => -- '6'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000000100000000";
        when "0111"             => -- '7'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000011110000000000";
        when "1000"             => -- '8'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000000000000000";
        when "1001"             => -- '9'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000100000000000";
        when "1010"             => -- 'A'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000010000000000";
        when "1011"             => -- 'B'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000000110000000";
        when "1100"             => -- 'C'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000010001100000000";
        when "1101"             => -- 'D'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000001000010000000";
        when "1110"             => -- 'E'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000001100000000";
        when "1111"             => -- 'F'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000011100000000";
        when others             => -- ' '
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000011111110000000";
      end case; 
		
		case(I_COUNT(11 downto 8)) is
        when "0000"             => -- '0'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000100000000000000000000";
        when "0001"             => -- '1'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000111100100000000000000";
        when "0010"             => -- '2'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000010010000000000000000";
        when "0011"             => -- '3'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000011000000000000000000";
        when "0100"             => -- '4'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000001100100000000000000";
        when "0101"             => -- '5'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000001001000000000000000";
        when "0110"             => -- '6'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000001000000000000000";
        when "0111"             => -- '7'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000111100000000000000000";
        when "1000"             => -- '8'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000000000000000";
        when "1001"             => -- '9'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000001000000000000000000";
        when "1010"             => -- 'A'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000100000000000000000";
        when "1011"             => -- 'B'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000001100000000000000";
        when "1100"             => -- 'C'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000100011000000000000000";
        when "1101"             => -- 'D'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000010000100000000000000";
        when "1110"             => -- 'E'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000011000000000000000";
        when "1111"             => -- 'F'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000111000000000000000";
        when others             => -- ' '
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000111111100000000000000";
      end case; 
		
		case(I_COUNT(15 downto 12)) is
        when "0000"             => -- '0'
          O_HEX_N_BUF <= O_HEX_N_BUF and "1000000000000000000000000000";
        when "0001"             => -- '1'
          O_HEX_N_BUF <= O_HEX_N_BUF and "1111001000000000000000000000";
        when "0010"             => -- '2'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0100100000000000000000000000";
        when "0011"             => -- '3'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0110000000000000000000000000";
        when "0100"             => -- '4'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0011001000000000000000000000";
        when "0101"             => -- '5'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0010010000000000000000000000";
        when "0110"             => -- '6'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000010000000000000000000000";
        when "0111"             => -- '7'
          O_HEX_N_BUF <= O_HEX_N_BUF and "1111000000000000000000000000";
        when "1000"             => -- '8'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000000000000000000000000000";
        when "1001"             => -- '9'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0010000000000000000000000000";
        when "1010"             => -- 'A'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0001000000000000000000000000";
        when "1011"             => -- 'B'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000011000000000000000000000";
        when "1100"             => -- 'C'
          O_HEX_N_BUF <= O_HEX_N_BUF and "1000110000000000000000000000";
        when "1101"             => -- 'D'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0100001000000000000000000000";
        when "1110"             => -- 'E'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0000110000000000000000000000";
        when "1111"             => -- 'F'
          O_HEX_N_BUF <= O_HEX_N_BUF and "0001110000000000000000000000";
        when others             => -- ' '
          O_HEX_N_BUF <= O_HEX_N_BUF and "1111111000000000000000000000";
      end case;	
      
		case(I_DATA_ADDR(3 downto 0)) is
        when "0000"             => -- '0'
          O_DATA_ADDR_BUF <= "00000001000000";
        when "0001"             => -- '1'
          O_DATA_ADDR_BUF <= "00000001111001";
        when "0010"             => -- '2'
          O_DATA_ADDR_BUF <= "00000000100100";
        when "0011"             => -- '3'
          O_DATA_ADDR_BUF <= "00000000110000";
        when "0100"             => -- '4'
          O_DATA_ADDR_BUF <= "00000000011001";
        when "0101"             => -- '5'
          O_DATA_ADDR_BUF <= "00000000010010";
        when "0110"             => -- '6'
          O_DATA_ADDR_BUF <= "00000000000010";
        when "0111"             => -- '7'
          O_DATA_ADDR_BUF <= "00000001111000";
        when "1000"             => -- '8'
          O_DATA_ADDR_BUF <= "00000000000000";
        when "1001"             => -- '9'
          O_DATA_ADDR_BUF <= "00000000010000";
        when "1010"             => -- 'A'
          O_DATA_ADDR_BUF <= "00000000001000";
        when "1011"             => -- 'B'
          O_DATA_ADDR_BUF <= "00000000000011";
        when "1100"             => -- 'C'
          O_DATA_ADDR_BUF <= "00000001000110";
        when "1101"             => -- 'D'
          O_DATA_ADDR_BUF <= "00000000100001";
        when "1110"             => -- 'E'
          O_DATA_ADDR_BUF <= "00000000000110";
        when "1111"             => -- 'F'
          O_DATA_ADDR_BUF <= "00000000001110";
        when others             => -- ' '
          O_DATA_ADDR_BUF <= "00000001111111";
      end case; 
		
		case(I_DATA_ADDR(7 downto 4)) is
        when "0000"             => -- '0'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "10000000000000";
        when "0001"             => -- '1'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "11110010000000";
        when "0010"             => -- '2'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "01001000000000";
        when "0011"             => -- '3'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "01100000000000";
        when "0100"             => -- '4'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00110010000000";
        when "0101"             => -- '5'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00100100000000";
        when "0110"             => -- '6'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00000100000000";
        when "0111"             => -- '7'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "11110000000000";
        when "1000"             => -- '8'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00000000000000";
        when "1001"             => -- '9'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00100000000000";
        when "1010"             => -- 'A'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00010000000000";
        when "1011"             => -- 'B'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00000110000000";
        when "1100"             => -- 'C'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "10001100000000";
        when "1101"             => -- 'D'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "01000010000000";
        when "1110"             => -- 'E'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00001100000000";
        when "1111"             => -- 'F'
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "00011100000000";
        when others             => -- ' '
          O_DATA_ADDR_BUF <= O_DATA_ADDR_BUF and "11111110000000";
      end case; 
      O_HEX_N <= O_HEX_N_BUF;
		O_DATA_ADDR <= O_DATA_ADDR_BUF;
      
    end if;
  end process quad_hex_driver;

 end architecture behavioral;
