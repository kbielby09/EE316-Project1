--------------------------------------------------------------------------------
-- Filename     : SRAM_controller.vhd
-- Author       : Joseph Drahos
-- Date Created : 2021-1-24
-- Last Revised : 2021-1-25
-- Project      : EE316 Project 1
-- Description  : SRAM controller testbench 
--------------------------------------------------------------------------------

library IEEE;
USE IEEE.Std_logic_1164.all;
USE IEEE.Numeric_std.all;
USE ieee.std_logic_unsigned.ALL;

entity tb_SRAM_controller is
end tb_SRAM_controller;


architecture tb of tb_SRAM_controller is 
	component SRAM_Controller 
		port(I_CLK_50MHZ 		: in std_logic;
			  I_SYSTEM_RST_N	: in std_logic;
			  RW			: in std_logic;
		     	  COUNT_EN		: in std_logic;
			  DIO		        : inout std_logic_vector(15 downto 0);
			  OE			: out std_logic;
			  CE_N 			: out std_logic;
			  WE_N			: out std_logic;
			  LB			: out std_logic;
			  UB 			: out std_logic;
			  IN_DATA		: in std_logic_vector(15 downto 0);
			  IN_DATA_ADDR		: in std_logic_vector(7 downto 0);
			  OUT_DATA 		: out std_logic_vector(15 downto 0);
			  OUT_DATA_ADR		: out std_logic_vector(7 downto 0));
	end component;
	
	signal I_CLK_50MHZ 		: std_logic;
	signal I_SYSTEM_RST_N   	: std_logic;
	signal RW	 		: std_logic;
	signal COUNT_EN			: std_logic;
	signal IN_DATA		 	: std_logic_vector(15 downto 0);
	signal IN_DATA_ADDR		: std_logic_vector(7 downto 0);
	signal OUT_DATA			: std_logic_vector(15 downto 0);
	signal DIO	 		: std_logic_vector(15 downto 0);
	signal OE			: std_logic;
	signal CE_N			: std_logic;
	signal WE_N			: std_logic;
	signal LB 			: std_logic;
	signal UB			: std_logic;
	signal OUT_DATA_ADR		: std_logic_vector(7 downto 0);
	
	constant clock_period : time := 20 ns;
	
begin 
	dut : SRAM_Controller
		port map(
			I_CLK_50MHZ => I_CLK_50MHZ,
			I_SYSTEM_RST_N => I_SYSTEM_RST_N,
			COUNT_EN => COUNT_EN,
			RW => RW,
			IN_DATA => IN_DATA,
			IN_DATA_ADDR => IN_DATA_ADDR,
			OUT_DATA => OUT_DATA,
			DIO => DIO,
			OE => OE,
			CE_N => CE_N,
			WE_N => WE_N,
			LB => LB,
			UB => UB,
			OUT_DATA_ADR => OUT_DATA_ADR);
			
		clock_process: process
		begin 
			I_CLK_50MHZ <= '0';
			wait for clock_period/2;
			I_CLK_50MHZ <= '1';
			wait for clock_period/2;
		end process;
		
		test : process
			begin 
				I_SYSTEM_RST_N <= '1';
				wait for 40 ns;
				I_SYSTEM_RST_N <= '0';
				COUNT_EN <= '0';
				RW <= '1';
				IN_DATA_ADDR <= "00000000";
				IN_DATA <= "0011001110101010";
				DIO <= "0110110001101100";
				wait for 40 ms;
				COUNT_EN <= '1';
				DIO <= "0000110000001100";
				wait for 40 ms;
				DIO <= "1111000000000011";
				wait for 40 ms;
				DIO <= "0000000000000000";
				wait for 40 ms;
				RW <= '0';
				IN_DATA_ADDR <= "00001111";
				IN_DATA <= "0000000011111111";
				wait for 40 ns;
				IN_DATA_ADDR <= "00010000";
				IN_DATA <= "0000111111110000";
				wait for 40 ns;
				IN_DATA_ADDR <= "00010001";
				IN_DATA <= "1010101010101010";
				wait for 40 ns;
				RW <= 'Z';
				wait;
		end process;
end tb;
