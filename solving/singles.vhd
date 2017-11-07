LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY singles IS
	PORT (
		clk: IN std_logic;
		reset:  IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		singles_done: OUT std_logic;
		singles_failed: OUT std_logic;
		
		mem_read_address: OUT integer range 0 to 255;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT integer range 0 to 255;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY singles;

ARCHITECTURE bhv OF singles IS
	
	SIGNAL tmp_read_address : unsigned(7 downto 0);
	SIGNAL tmp_write_address : unsigned(7 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);


	TYPE candidatesudoku IS ARRAY (1 TO 9, 1 TO 9, 0 TO 11) OF natural range 0 to 9; -- array type for possible candidates.
	SIGNAL candboard : candidatesudoku;


BEGIN

PROCESS(clk,reset)
BEGIN

	IF solve_control_data = "001" THEN

		singles_done <= '0';
	ELSIF solve_control_data = "010" THEN

		FOR x IN 1 to 9 LOOP -- find singles
			FOR y IN 1 to 9 LOOP
				IF (candboard(x,y,0) = 0 and candboard(x,y,10) = 1) THEN -- unique solution found
					FOR I IN 1 to 9 LOOP
						IF candboard(x,y,I) /= 0 THEN
							candboard(x,y,0) <= candboard(x,y,I);
							candboard(x,y,I) <= 0;
							candboard(x,y,10) <= 0;
						END IF;
					END LOOP;
					singles_failed <= '0';
				END IF;
			END LOOP;
		END LOOP;
		singles_done <= '1';
	END IF;

	mem_read_address <= (OTHERS => 'Z') WHEN control /= "010" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN control /= "010" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN control /= "010" 
		ELSE tmp_data_in;

END PROCESS;

END bhv;