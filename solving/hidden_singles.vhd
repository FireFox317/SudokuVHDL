LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY hidden_singles IS
	PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		hidden_singles_done: OUT std_logic;
		hidden_singles_failed : OUT std_logic;
		
		mem_read_address: OUT integer range 0 to 255;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT integer range 0 to 255;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY hidden_singles;

ARCHITECTURE bhv OF hidden_singles IS
	
	SIGNAL tmp_read_address : unsigned(7 downto 0);
	SIGNAL tmp_write_address : unsigned(7 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);

	TYPE hidden_single_store IS ARRAY (1 TO 9, 1 TO 3) OF natural range 0 to 9;
	SIGNAL hsa : hidden_single_store;
-- hsa(i,1) is the number of times a certain candidate (i) appears
-- hsa(i,2) is the x value of the latest candidate of value (i)
-- hsa(i,3) is the y value of the latest candidate	of value (i)
	VARIABLE seg : natural range 1 to 9;
	
	
	TYPE candidatesudoku IS ARRAY (1 TO 9, 1 TO 9, 0 TO 11) OF natural range 0 to 9; -- array type for possible candidates.
	SIGNAL candboard : candidatesudoku;


BEGIN

	PROCESS(clk,reset,solve_control_data)
	BEGIN
		IF reset = '0' THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
		ELSIF solve_control_data = "001" THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
		ELSIF solve_control_data = "011" THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
			FOR a IN 1 to 9 LOOP
				FOR b IN 1 to 3 LOOP
					hsa(a,b) <= 0;
				END LOOP;
			END LOOP;
			FOR x IN 1 to 9 LOOP -- find hidden singles in rows
				FOR y IN 1 to 9 LOOP
					IF (candboard(x,y,0) = 0 and candboard(x,y,10) > 1) THEN -- several candidates found
						FOR I IN 1 to 9 LOOP
							IF candboard(x,y,I) /= 0 THEN
								hsa(I,1) <= hsa(I,1) + 1;
								hsa(I,2) <= x;
								hsa(I,3) <= y;
							END IF;
						END LOOP;
					END IF;
				END LOOP;
			END LOOP;
			FOR I IN 1 to 9 LOOP
				IF hsa(I,1) = 1 THEN
					candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
					candboard(hsa(I,2),hsa(I,3),I) <= 0;
					candboard(hsa(I,2),hsa(I,3),10) <= 0;
					hidden_singles_failed <= '0';
				END IF;
			END LOOP;

			FOR a IN 1 to 9 LOOP
				FOR b IN 1 to 3 LOOP
					hsa(a,b) <= 0;
				END LOOP;
			END LOOP;

			FOR y IN 1 to 9 LOOP -- find hidden singles in columns
				FOR x IN 1 to 9 LOOP
					IF (candboard(x,y,0) = 0 and candboard(x,y,10) > 1) THEN -- several candidates found
						FOR I IN 1 to 9 LOOP
							IF candboard(x,y,I) /= 0 THEN
								hsa(I,1) <= hsa(I,1) + 1;
								hsa(I,2) <= x;
								hsa(I,3) <= y;
							END IF;
						END LOOP;
					END IF;
				END LOOP;
			END LOOP;
			FOR I IN 1 to 9 LOOP
				IF hsa(I,1) = 1 THEN
					candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
					candboard(hsa(I,2),hsa(I,3),I) <= 0;
					candboard(hsa(I,2),hsa(I,3),10) <= 0;
					hidden_singles_failed <= '0';
				END IF;
			END LOOP;

			FOR a IN 1 to 9 LOOP
				FOR b IN 1 to 3 LOOP
					hsa(a,b) <= 0;
				END LOOP;
			END LOOP;

			seg := 1;
			WHILE (seg <= 9) LOOP -- find hidden singles in segment 
				FOR x IN 1 to 9 LOOP
					FOR y IN 1 to 9 LOOP
						IF candboard(x,y,11) = seg THEN
							IF (candboard(x,y,0) = 0 and candboard(x,y,10) > 1) THEN -- several candidates found
								FOR I IN 1 to 9 LOOP
									IF candboard(x,y,I) /= 0 THEN
										hsa(I,1) <= hsa(I,1) + 1;
										hsa(I,2) <= x;
										hsa(I,3) <= y;
									END IF;
								END LOOP;
							END IF;
						END IF;
					END LOOP;
				END LOOP;
				FOR I IN 1 to 9 LOOP
					IF hsa(I,1) = 1 THEN
						candboard(hsa(I,2),hsa(I,3),0) <= hsa(I,1);
						candboard(hsa(I,2),hsa(I,3),I) <= 0;
						candboard(hsa(I,2),hsa(I,3),10) <= 0;
						hidden_singles_failed <= '0';
					END IF;
				END LOOP;
				seg := seg + 1;
			END LOOP;
			hidden_singles_done <= '1';
		END IF;
	END PROCESS;

	mem_read_address <= (OTHERS => 'Z') WHEN control /= "011" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN control /= "011" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN control /= "011" 
		ELSE tmp_data_in;

END bhv;