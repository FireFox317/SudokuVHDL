LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY solving IS
	PORT (
		reset			: IN std_logic;
		clk 			: IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_read_address: OUT integer range 0 to 255;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT integer range 0 to 255;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)

		);
END ENTITY solving;

ARCHITECTURE bhv OF solving IS

COMPONENT update_candidates IS
    PORT (
		
	);
	
COMPONENT singles IS
	PORT (
	
	);
	
COMPONENT hidden_singles IS
	PORT (
	
	);

COMPONENT solve_control IS
	PORT (
	
	);



BEGIN


END bhv;