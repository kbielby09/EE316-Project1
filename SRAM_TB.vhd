--------------------------------------------------------------------------------
-- Filename     : SRAM_controller.vhd
-- Author       : Joseph Drahos
-- Date Created : 2021-1-24
-- Last Revised : 2021-1-25
-- Project      : EE316 Project 1
-- Description  : SRAM controller testbench 
--------------------------------------------------------------------------------
-- Todos:
-- SImulation isn't outputing correct values
--
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
			  INITIALIZE		: in std_logic;
			  MEM_RESET			: in std_logic;
			  R_W					: in std_logic;
			  IN_DATA			: in std_logic_vector(15 downto 0);
			  IN_DATA_ADDR		: in std_logic_vector(7 downto 0);
			  OUT_DATA 			: out std_logic_vector(15 downto 0);
			  SRAM_bidir_bus  : inout std_logic_vector(7 downto 0);
			  OE					: out std_logic;
			  CE 					: out std_logic;
			  WE 					: out std_logic;
			  LB					: out std_logic;
			  UB 					: out std_logic;
			  BUSY				: out std_logic;
			  OUT_DATA_ADR		: out std_logic_vector(7 downto 0));
	end component;
	
	signal I_CLK_50MHZ 		: std_logic;
	signal INITIALIZE  		: std_logic;
	signal MEM_RESET   		: std_logic;
	signal R_W			 		: std_logic;
	signal IN_DATA		 		: std_logic_vector(15 downto 0);
	signal IN_DATA_ADDR		: std_logic_vector(7 downto 0);
	signal OUT_DATA			: std_logic_vector(15 downto 0);
	signal SRAM_bidir_bus 	: std_logic_vector(7 downto 0);
	signal OE					: std_logic;
	signal CE					: std_logic;
	signal WE					: std_logic;
	signal LB 					: std_logic;
	signal UB					: std_logic;
	signal BUSY 				: std_logic;
	signal OUT_DATA_ADR		: std_logic_vector(7 downto 0);
	
	constant clock_period : time := 20 ns;
	
begin 
	dut : SRAM_Controller
		port map(
			I_CLK_50MHZ => I_CLK_50MHZ,
			INITIALIZE => INITIALIZE,
			MEM_RESET => MEM_RESET,
			R_W => R_W,
			IN_DATA => IN_DATA,
			IN_DATA_ADDR => IN_DATA_ADDR,
			OUT_DATA => OUT_DATA,
			SRAM_bidir_bus => SRAM_bidir_bus,
			OE => OE,
			CE => CE,
			WE => WE,
			LB => LB,
			UB => UB,
			BUSY => BUSY,
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
				INITIALIZE <= '1';
				MEM_RESET <= '1';
				wait for 40 ns;
				INITIALIZE <= '0';
				MEM_RESET <= '0';
				R_W <= '1';
				IN_DATA_ADDR <= "00000000";
				IN_DATA <= "0011001110101010";
				SRAM_bidir_bus <= "01101100";
				wait for 40 ms;
				SRAM_bidir_bus <= "00001100";
				wait for 40 ms;
				SRAM_bidir_bus <= "00000011";
				wait for 40 ms;
				SRAM_bidir_bus <= "00000000";
				wait for 40 ms;
				R_W <= '0';
				IN_DATA_ADDR <= "00001111";
				IN_DATA <= "0000000011111111";
				wait for 40 ns;
				IN_DATA_ADDR <= "00010000";
				IN_DATA <= "0000111111110000";
				wait for 40 ns;
				IN_DATA_ADDR <= "00010001";
				IN_DATA <= "1010101010101010";
				wait for 40 ns;
				R_W <= 'Z';
				wait;
		end process;
end tb;
