LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
LIBRARY sudokuvhdl;
USE sudokuvhdl.sudoku_package.ALL;

ENTITY singles IS
	PORT (
		clk: IN std_logic;
		reset:  IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		singles_done: OUT std_logic;
		singles_failed: OUT std_logic;
		
		mem_read_address: OUT unsigned(11 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_write_address: OUT unsigned(11 downto 0);
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY singles;

ARCHITECTURE bhv OF singles IS
	
	SIGNAL tmp_read_address : unsigned(11 downto 0);
	SIGNAL tmp_write_address : unsigned(11 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);

	SIGNAL x,y : integer RANGE 1 to 10 := 1;
	SIGNAL i : integer RANGE 0 to 12 := 0;
	SIGNAL count : integer RANGE 0 to 4 := 0;
	SIGNAL cont : std_logic := '0';

	FUNCTION address(x: integer; y: integer; i: integer) return unsigned IS
	BEGIN
		return (to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4));
	END address;

	FUNCTION data(val: integer) return std_logic_vector IS
	BEGIN
		return std_logic_vector(to_unsigned(val,4));
	END data;

BEGIN

	PROCESS(clk,reset)
	BEGIN
		IF reset = '0' THEN
			x <= 1; y <= 1;
			i <= 0;
			count <= 0;
			cont <= '0';
		ELSIF rising_edge(clk) THEN
			IF solve_control_data = "001" THEN
				singles_done <= '0';
			ELSIF solve_control_data = "010" THEN
				IF x < 10 THEN
					IF y < 10 THEN
						tmp_read_address <= address(x,y,0);
						IF mem_data_out = "0000" THEN
							cont <= '1';
							IF cont = '1' THEN
								cont <= '0';
								tmp_read_address <= address(x,y,10);
								IF mem_data_out = "0001" THEN
									cont <= '1';
									IF cont = '1' THEN
										cont <= '0';
										IF i < 10 THEN
											tmp_read_address <= address(x,y,i);
											IF mem_data_out /= "0000" THEN
												CASE count IS
													WHEN 0 => null;
													WHEN 1 =>--wcandboard(x,y,0,candboard(x,y,I,mem_data_out));
															tmp_write_address <= address(x,y,0);
															tmp_read_address <= address(x,y,I);
															tmp_data_in <= mem_data_out;
													WHEN 2 =>--wcandboard(x,y,I,0);
															tmp_write_address <= address(x,y,0);
															tmp_data_in <= "0000";
													WHEN 3 =>--wcandboard(x,y,10,0);
															tmp_write_address <= address(x,y,10);
															tmp_data_in <= "0000";
													WHEN OTHERS => null;
													count <= count + 1;
												END CASE;
											END IF;
											singles_failed <= '0';
										END IF;
										IF count = 4 THEN
											i <= i + 1;
											count <= 0;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
						IF i = 12 THEN
							y <= y + 1;
							i <= 0;
						END IF;
					END IF;
					IF y=10 THEN
						x <= x + 1;
						y <= 1;
					END IF;
				END IF;
				singles_done <= '1';
			END IF;
		END IF;
	END PROCESS;

	mem_read_address <= (OTHERS => 'Z') WHEN solve_control_data /= "010" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN solve_control_data /= "010" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN solve_control_data /= "010" 
		ELSE tmp_data_in;

END bhv;

	--PROCESS(clk,reset)
	--BEGIN
	--	IF rising_edge(clk) THEN
	--		IF solve_control_data = "001" THEN

	--			singles_done <= '0';
	--		ELSIF solve_control_data = "010" THEN
	--			FOR x IN 1 to 9 LOOP -- find singles
	--				FOR y IN 1 to 9 LOOP
	--					IF (candboard(x,y,0,mem_data_out) = 0 and candboard(x,y,10,mem_data_out) = 1) THEN -- unique solution found
	--						FOR I IN 1 to 9 LOOP
	--							IF candboard(x,y,I,mem_data_out) /= 0 THEN
	--								wcandboard(x,y,0,candboard(x,y,I,mem_data_out));
	--								wcandboard(x,y,I,0);
	--								wcandboard(x,y,10,0);
	--							END IF;
	--						END LOOP;
	--						singles_failed <= '0';
	--					END IF;
	--				END LOOP;
	--			END LOOP;
	--			singles_done <= '1';
	--		END IF;
	--	END IF;
	--END PROCESS;