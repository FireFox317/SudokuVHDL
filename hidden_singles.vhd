LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY hidden_singles IS
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
END ENTITY hidden_singles;

ARCHITECTURE bhv OF hidden_singles IS

BEGIN

PROCESS(clk,reset)
BEGIN


IF solve_control_data = "011" THEN
	singles_failed = '0';
ELSIF solve_control_data = "011"


FOR x IN 1 to 9 LOOP -- find hidden singles in rows
					FOR y IN 1 to 9 LOOP
						IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1; -- several candidates found
								FOR I IN 1 to 9;
									IF candboard(x,y,I) /= 0 THEN
										hsa(I,1) <= hsa(I,1) + 1;
										hsa(I,2) <= x;
										hsa(I,3) <= y;
									END IF;
								END LOOP;
							END LOOP;
						END IF;
					END LOOP;
					FOR I IN 1 to 9;
						IF hsa(I,1) = 1 THEN
							candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
							candboard(hsa(I,2),hsa(I,3),I) <= 0;
							candboard(hsa(I,2),hsa(I,3),10) <= 0;
							hidden_single_found <= '1';
						END IF;
					END LOOP;
				END LOOP;
				FOR y IN 1 to 9 LOOP -- find hidden singles in columns
					FOR x IN 1 to 9 LOOP
						IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1; -- several candidates found
								FOR I IN 1 to 9;
									IF candboard(x,y,I) /= 0 THEN
										hsa(I,1) <= hsa(I,1) + 1;
										hsa(I,2) <= x;
										hsa(I,3) <= y;
									END IF;
								END LOOP;
							END LOOP;
						END IF;
					END LOOP;
					FOR I IN 1 to 9;
						IF hsa(I,1) = 1 THEN
							candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
							candboard(hsa(I,2),hsa(I,3),I) <= 0;
							candboard(hsa(I,2),hsa(I,3),10) <= 0;
							hidden_single_found <= '1';
						END IF;
					END LOOP;
				END LOOP;
				seg := 1;
				WHILE (seg <= 9) LOOP -- find hidden singles in segment -- UNFINISHED!! (Need a way to legantly loop through segments. maybe lut? This will be a big lut, but probably easier in the long run.
--					FOR x IN 1 to 9 LOOP
--						FOR y IN 1 to 9 LOOP
--							IF candboard(x,y,11) = seg THEN
--								IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1; -- several candidates found
--								FOR I IN 1 to 9;
--									IF candboard(x,y,I) /= 0 THEN
--										hsa(I,1) <= hsa(I,1) + 1;
--										hsa(I,2) <= x;
--										hsa(I,3) <= y;
--									END IF;
--								END LOOP;
--							END LOOP;
--						END IF;
--							END IF;
--						END LOOP;
--					END LOOP;
				END LOOP;
			END IF;
		END PROCESS;
		
		
		
		hidden_single_found <= '1';