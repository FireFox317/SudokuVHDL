LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY solving IS
	PORT (
		reset			: IN std_logic;
		clk 			: IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_read_address: INOUT unsigned(7 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);
		mem_write_address: INOUT unsigned(7 downto 0);
		mem_data_in : INOUT std_logic_vector(3 downto 0)
		
		);
END ENTITY solving;

ARCHITECTURE bhv OF solving IS

	COMPONENT update_candidates IS
	    PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		update_candidates_done: OUT std_logic;	
		
		mem_read_address: OUT unsigned(7 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT unsigned(7 downto 0);
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
	END COMPONENT update_candidates;
		
	COMPONENT singles IS
		PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		singles_done: OUT std_logic;
		singles_failed: OUT std_logic;
		
		mem_read_address: OUT unsigned(7 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT unsigned(7 downto 0);
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	

		);
	END COMPONENT singles;
		
	COMPONENT hidden_singles IS
		PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		hidden_singles_done: OUT std_logic;
		hidden_singles_failed: OUT std_logic;
		
		mem_read_address: OUT unsigned(7 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT unsigned(7 downto 0);
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);	
	END COMPONENT hidden_singles;

	COMPONENT solve_control IS
		PORT (
		clk: IN std_logic;
		reset: IN std_logic;
		update_candidates_done: IN std_logic;
		singles_done: IN std_logic;
		singles_failed: IN std_logic;
		hidden_singles_done: IN std_logic;
		hidden_singles_failed: IN std_logic;
		solve_control_data: OUT std_logic_vector(2 downto 0);
		control: IN std_logic_vector(2 downto 0)
		);
	END COMPONENT solve_control;


	SIGNAL solve_control_data_wire: std_logic_vector(2 downto 0);
	SIGNAL singles_done_wire: std_logic;
	SIGNAL hidden_singles_done_wire: std_logic;
	SIGNAL update_candidates_done_wire: std_logic;
	SIGNAL singles_failed_wire: std_logic;
	SIGNAL hidden_singles_failed_wire: std_logic;

	SIGNAL tmp_read_address : unsigned(7 downto 0);
	SIGNAL tmp_write_address : unsigned(7 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);


BEGIN

	upc: update_candidates PORT MAP(
        clk => clk,
        reset => reset,	
		solve_control_data => solve_control_data_wire,
		update_candidates_done => update_candidates_done_wire,
		mem_read_address => mem_read_address,
		mem_data_out => mem_data_out,
		mem_store_address => mem_store_address,
		mem_write_enable => mem_write_enable,
		mem_data_in => mem_data_in
	);
	
	singl: singles PORT MAP (
        clk => clk,
        reset => reset,	
		solve_control_data => solve_control_data_wire,
		singles_done => singles_done_wire,
		singles_failed => singles_failed_wire,
		mem_read_address => mem_read_address,
		mem_data_out => mem_data_out,
		mem_store_address => mem_store_address,
		mem_write_enable => mem_write_enable,
		mem_data_in => mem_data_in
		
		
	);
	
	h_singl: hidden_singles PORT MAP (
        clk => clk,
        reset => reset,	
		solve_control_data => solve_control_data_wire,
		hidden_singles_done => hidden_singles_done_wire,
		hidden_singles_failed => hidden_singles_failed_wire,
		mem_read_address => mem_read_address,
		mem_data_out => mem_data_out,
		mem_store_address => mem_store_address,
		mem_write_enable => mem_write_enable,
		mem_data_in => mem_data_in
		
	);
	
	sol_con: solve_control PORT MAP (
		clk => clk,
		reset => reset,
		update_candidates_done => update_candidates_done_wire,
		singles_done => singles_done_wire,
		singles_failed => singles_failed_wire,
		hidden_singles_done => hidden_singles_done_wire,
		hidden_singles_failed => hidden_singles_failed_wire,
		solve_control_data => solve_control_data_wire,
		control => control
		
	);
	
	mem_read_address <= (OTHERS => 'Z') WHEN control /= "011" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN control /= "011" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN control /= "011" 
		ELSE tmp_data_in;

END bhv;