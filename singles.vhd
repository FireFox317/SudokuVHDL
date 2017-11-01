LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY singles IS
	PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		singles_done: OUT std_logic;

		);
END ENTITY singles;

ARCHITECTURE bhv OF singles IS

BEGIN

PROCESS(clk,reset)
BEGIN

	IF solve_control_data = "001" THEN

		singles_done <= '0';
	ELSIF solve_control_data = "010" THEN

		FOR x IN 1 to 9 LOOP -- find singles
			FOR y IN 1 to 9 LOOP
				IF candboard(x,y,0) = 0 and candboard(x,y,10) = 1; -- unique solution found
					FOR I IN 1 to 9 LOOP
						IF candboard(x,y,I) /= 0 THEN
							candboard(x,y,0) <= candboard(x,y,I);
							candboard(x,y,I) <= 0;
							candboard(x,y,10) <= 0;
						END IF;
					END LOOP;
					single_found <= '1';
				END IF;
			END LOOP;
		END LOOP;
		singles_done <= '1';
	
	END IF;