LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY solving IS
	PORT (
		reset: IN std_logic;
		clk : IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_read_address: INOUT unsigned(7 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);
		mem_write_address: INOUT unsigned(7 downto 0);
		mem_data_in : INOUT std_logic_vector(3 downto 0)
		
		);
END ENTITY solving;

ARCHITECTURE bhv of solving IS

	SIGNAL tmp_read_address : unsigned(7 downto 0);
	SIGNAL tmp_write_address : unsigned(7 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);

BEGIN

	mem_read_address <= "ZZZZZZZZ" WHEN control /= "010" 
		ELSE tmp_read_address;

	mem_write_address <= "ZZZZZZZZ" WHEN control /= "001" 
		ELSE tmp_write_address;
		
	mem_data_in <= "ZZZZ" WHEN control /= "001" 
		ELSE tmp_data_in;

END bhv;