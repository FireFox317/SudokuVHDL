LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY solve_control IS
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

END ENTITY solve_control;

ARCHITECTURE bhv OF solve_control IS

	TYPE states IS (idle, update_candidates, singles, hidden_singles);
	SIGNAL state: states := idle;

BEGIN
	
PROCESS(clk,reset)
BEGIN
	IF reset = '0' THEN
	
	state <= idle
	
	ELSIF rising_edge(clk) THEN
	
		IF control = "011" THEN
		
			CASE state IS
				WHEN idle and control = "011" =>
					state <= update_candidates;				
				WHEN update_candidates and update_candidates_done = '1' =>
					state <= singles;
				WHEN singles and singles_done = '1' =>
					state <= update_candidates;
				WHEN update_candidates and singles_failed = '1' =>
					state <= hidden_singles;
				WHEN hidden_singles and hidden_singles_done '1' =>
					state <= update_candidates;
			END CASE;
		
			CASE state IS
				WHEN update_candidates => solve_control_data <= "001";
				WHEN singles => solve_control_data <= "010";
				WHEN hidden_singles => solve_control_data <= "011";
			END CASE;
		
		END IF;
	
	END IF;

END PROCESS;

END bhv;