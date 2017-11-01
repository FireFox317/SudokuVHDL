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
	reset:  IN std_logic;
	clk: IN std_logic;
	solve_control_data: IN std_logic_vector(2 downto 0);
	update_candidates_done: OUT std_logic;	
	mem_read_address: OUT integer range 0 to 255;
	mem_data_out: IN std_logic_vector(3 downto 0);

	mem_store_address: OUT integer range 0 to 255;
	mem_write_enable: OUT std_logic;
	mem_data_in : OUT std_logic_vector(3 downto 0)	
	);
END COMPONENT solve_control;
	
COMPONENT singles IS
	PORT (
	reset:  IN std_logic;
	clk: IN std_logic;
	solve_control_data: IN std_logic_vector(2 downto 0);
	singles_done: OUT std_logic;
	mem_read_address: OUT integer range 0 to 255;
	mem_data_out: IN std_logic_vector(3 downto 0);

	mem_store_address: OUT integer range 0 to 255;
	mem_write_enable: OUT std_logic;
	mem_data_in : OUT std_logic_vector(3 downto 0)	

	);
END COMPONENT solve_control;
	
COMPONENT hidden_singles IS
	PORT (
	reset:  IN std_logic;
	clk: IN std_logic;
	solve_control_data: IN std_logic_vector(2 downto 0);
	singles_done: OUT std_logic;
	mem_read_address: OUT integer range 0 to 255;
	mem_data_out: IN std_logic_vector(3 downto 0);

	mem_store_address: OUT integer range 0 to 255;
	mem_write_enable: OUT std_logic;
	mem_data_in : OUT std_logic_vector(3 downto 0)	
	);	
END COMPONENT solve_control;

COMPONENT solve_control IS
	PORT (
	clk: IN std_logic;
	reset: IN std_logic;
	update_candidates_done: IN std_logic;
	singles_done: IN std_logic;
	singles_failed: IN std_logic;
	hidden_singles_done: IN std_logic;
	solve_control_data: OUT std_logic_vector(2 downto 0);
	control: IN std_logic_vector(2 downto 0)
	);
END COMPONENT solve_control;


SIGNAL solve_control_data_wire: std_logic_vector(2 downto 0);


BEGIN

	upc: update_candidates PORT MAP(
        clk => clk,
        reset => reset,	
		solve_control_data => 
	);
	
	singl: singles PORT MAP (
        clk => clk,
        reset => reset,	
	);
	
	h_singl: hidden_singles PORT MAP (
        clk => clk,
        reset => reset,	
	);
	
	sol_con: solve_control PORT MAP (
		clk => clk,
		reset => reset,	
	);


END bhv;