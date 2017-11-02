LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY solve_control IS
	PORT (
	clk: IN std_logic;
	reset: IN std_logic;
	update_candidates_done: IN std_logic;
	--singles_done: IN std_logic;
	--singles_failed: IN std_logic;
	--hidden_singles_done: IN std_logic;
	--hidden_singles_failed: IN std_logic;
	solve_control_data: OUT std_logic_vector(2 downto 0);
	control: IN std_logic_vector(2 downto 0);
	led_state_solve: OUT std_logic_vector(2 downto 0)
	);

END ENTITY solve_control;

ARCHITECTURE bhv OF solve_control IS

	TYPE states IS (idle, update_candidates, singles, hidden_singles);
	SIGNAL state: states := idle;

BEGIN
	
PROCESS(clk,reset)
BEGIN
	IF reset = '0' THEN
	
	state <= idle;
	
	ELSIF rising_edge(clk) THEN
	
		IF control = "011" THEN
		
			CASE state IS
				WHEN idle =>
					IF control = "011" THEN
					state <= update_candidates;	
					END IF;
					
				WHEN update_candidates =>
					IF update_candidates_done = '1' THEN 
						state <= singles;
					END IF;
				
				--WHEN singles =>
				--	IF singles_done = '1' THEN
				--		state <= update_candidates;
				--	END IF;
				
				--WHEN update_candidates =>
				--	IF singles_failed = '1' THEN
				--		state <= hidden_singles;
				--	END IF;
				
				--WHEN hidden_singles =>
				--	IF hidden_singles_done = '1' THEN
				--		state <= update_candidates;
				--	END IF;
				WHEN OTHERS =>
					state <= idle;
			END CASE;
		
			CASE state IS
				WHEN idle => solve_control_data <= "000"; led_state_solve <= "000";
				WHEN update_candidates => solve_control_data <= "001"; led_state_solve <= "001";
				WHEN singles => solve_control_data <= "010"; led_state_solve <= "010";
				WHEN hidden_singles => solve_control_data <= "011"; led_state_solve <= "011";
				WHEN OTHERS => solve_control_data <= "000"; led_state_solve <= "000";
			END CASE;

		
		
		END IF;
	
	END IF;

END PROCESS;

END bhv;