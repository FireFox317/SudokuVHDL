LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY update_candidates IS
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
END ENTITY update_candidates;

ARCHITECTURE bhv OF update_candidates IS

BEGIN

PROCESS(clk,reset)
BEGIN

	IF solve_control_data = "010" THEN
		update_candidates_done <= '0';
	ELSIF solve_control_data = "001" THEN
		FOR x IN 1 to 9 LOOP -- update cadidates: elimination
			FOR y IN 1 to 9 LOOP
				IF candboard(x,y,0) /= "0" THEN
					FOR xc IN 1 to 9 LOOP -- eliminate in row
						IF 	candboard(xc,y,0) = 0 THEN
							candboard(xc,y,(candboard(x,y,0))) <= 0;
							candboard(xc,y,10) <= candboard(xc,y,10) - 1;
						END IF;
					END LOOP;
					FOR yc IN 1 to 9 LOOP -- eliminate in column
						IF 	candboard(x,yc,0) = 0 THEN
							candboard(x,yc,(candboard(x,y,0))) <= 0;
							candboard(x,yc,10) <= candboard(x,yc,10) - 1;
						END IF;
					END LOOP;
					I := 1;
					WHILE (i <= 9) LOOP -- eliminate in segment
						FOR xc IN 1 to 9 LOOP
							FOR yc IN 1 to 9 LOOP
								IF	candboard(xc,yc,11) = candboard(x,y,11) THEN
									candboard(x,yc,(candboard(x,y,0))) <= 0;
									candboard(x,yc,10) <= candboard(x,yc,10) - 1;
									i := i + 1;
								END IF;
							END LOOP;
						END LOOP;
					END LOOP;
				END IF;
			END LOOP;
		END LOOP;
		update_candidates_done <= '1';
	END IF;
	
END PROCESS;

END bhv;