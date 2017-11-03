LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
LIBRARY sudokuvhdl;
USE sudokuvhdl.sudoku_package.ALL;

ENTITY hidden_singles IS
	PORT (
		reset:  IN std_logic;
		clk: IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		hidden_singles_done: OUT std_logic;
		hidden_singles_failed : OUT std_logic;
		
		mem_read_address: OUT unsigned(11 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_write_address: OUT unsigned(11 downto 0);
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY hidden_singles;

ARCHITECTURE bhv OF hidden_singles IS
	
	SIGNAL tmp_read_address : unsigned(11 downto 0);
	SIGNAL tmp_write_address : unsigned(11 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);

	TYPE hidden_single_store IS ARRAY (1 TO 9, 1 TO 3) OF natural range 0 to 9;
	SIGNAL hsa : hidden_single_store;
-- hsa(i,1) is the number of times a certain candidate (i) appears
-- hsa(i,2) is the x value of the latest candidate of value (i)
-- hsa(i,3) is the y value of the latest candidate	of value (i)

	SIGNAL x,y : integer RANGE 1 to 10 := 1;
	SIGNAL i : integer RANGE 0 to 12 := 0;
	SIGNAL count : integer RANGE 0 to 3 := 0;
	SIGNAL ctrl : integer RANGE 0 to 7 := 0;
	SIGNAL cont,done : std_logic := '0';
	
	FUNCTION address(x: integer; y: integer; i: integer) return unsigned IS
	BEGIN
		return (to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4));
	END address;

	FUNCTION data(val: integer) return std_logic_vector IS
	BEGIN
		return std_logic_vector(to_unsigned(val,4));
	END data;

	PROCEDURE rsthsa IS
		VARIABLE a,b : integer RANGE 1 to 10 := 1;
	BEGIN
		IF a < 10 THEN
			IF b < 10 THEN
				hsa(a,b) <= 0;
				b := b + 1;
			END IF;
			IF b = 10 THEN
				a := a + 1;
				b := 0;
			END IF;
		END IF;
		IF a = 10 THEN
			a := 0;
		END IF;
	END rsthsa;

BEGIN

	PROCESS(clk,reset,solve_control_data)
		VARIABLE seg : natural range 1 to 10;
	BEGIN
		IF reset = '0' THEN
			hidden_singles_done <= '0';
			hidden_singles_failed <= '1';
			x <= 1; y <= 1;
			i <= 0;
			count <= 0;
			ctrl <= 0;
			cont <= '0'; done <= '0';
		ELSIF rising_edge(clk) THEN
			IF solve_control_data = "001" THEN
				hidden_singles_done <= '0';
				hidden_singles_failed <= '1';
			ELSIF solve_control_data = "011" THEN
				CASE ctrl IS
					WHEN 0 =>	hidden_singles_done <= '0';
								hidden_singles_failed <= '1';
								rsthsa;

					WHEN 1 =>	IF x < 10 THEN
									IF y < 10 THEN
										tmp_read_address <= address(x,y,0);
										IF mem_data_out = "0000" THEN
											cont <= '1';
											IF cont = '1' THEN
												cont <= '0';
												tmp_read_address <= address(x,y,10);
												IF mem_data_out > "0001" THEN
													cont <= '1';
													IF cont = '1' THEN
														cont <= '0';
														IF i < 10 THEN
															tmp_read_address <= address(x,y,i);
															IF mem_data_out /= "0000" THEN
																hsa(I,1) <= hsa(I,1) + 1;
																hsa(I,2) <= x;
																hsa(I,3) <= y;
															END IF;
															i <= i + 1;
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
								IF x = 10 THEN
									x <= 1;
									done <= '1';
								END IF;

					WHEN 2 =>	IF i < 10 THEN
									IF hsa(i,1) = 1 THEN
										CASE count IS
											WHEN 0 =>--wcandboard(hsa(i,2),hsa(i,3),0,hsa(i,1));
													tmp_write_address <= address(hsa(i,2),hsa(i,3),0);
													tmp_data_in <= data(hsa(i,1));
											WHEN 1 =>--wcandboard(hsa(i,2),hsa(i,3),i,0);
													tmp_write_address <= address(hsa(i,2),hsa(i,3),i);
													tmp_data_in <= "0000";
											WHEN 2 =>--wcandboard(hsa(i,2),hsa(i,3),10,0);
													tmp_write_address <= address(hsa(i,2),hsa(i,3),10);
													tmp_data_in <= "0000";
											WHEN OTHERS => null;
											hidden_singles_failed <= '0';
										END CASE;
									END IF;
								END IF;
								IF i = 10 THEN
									i <= 0;
									done <= '1';
									rsthsa;
								END IF;

					WHEN 3 =>	IF y < 10 THEN
									IF x < 10 THEN
										tmp_read_address <= address(x,y,0);
										IF mem_data_out = "0000" THEN
											cont <= '1';
											IF cont = '1' THEN
												cont <= '0';
												tmp_read_address <= address(x,y,10);
												IF mem_data_out > "0001" THEN
													cont <= '1';
													IF cont = '1' THEN
														cont <= '0';
														IF i < 10 THEN
															tmp_read_address <= address(x,y,i);
															IF mem_data_out /= "0000" THEN
																hsa(I,1) <= hsa(I,1) + 1;
																hsa(I,2) <= x;
																hsa(I,3) <= y;
															END IF;
															i <= i + 1;
														END IF;
													END IF;
												END IF;
											END IF;
										END IF;
										IF i = 12 THEN
											x <= x + 1;
											i <= 0;
										END IF;
									END IF;
									IF y=10 THEN
										y <= y + 1;
										x <= 1;
									END IF;
								END IF;
								IF y = 10 THEN
									y <= 1;
									done <= '1';
								END IF;

					WHEN 4 =>	IF i < 10 THEN
									IF hsa(i,1) = 1 THEN
										CASE count IS
											WHEN 0 =>--wcandboard(hsa(i,2),hsa(i,3),0,hsa(i,1));
													tmp_write_address <= address(hsa(i,2),hsa(i,3),0);
													tmp_data_in <= data(hsa(i,1));
											WHEN 1 =>--wcandboard(hsa(i,2),hsa(i,3),i,0);
													tmp_write_address <= address(hsa(i,2),hsa(i,3),i);
													tmp_data_in <= "0000";
											WHEN 2 =>--wcandboard(hsa(i,2),hsa(i,3),10,0);
													tmp_write_address <= address(hsa(i,2),hsa(i,3),10);
													tmp_data_in <= "0000";
											WHEN OTHERS => null;
											hidden_singles_failed <= '0';
										END CASE;
									END IF;
								END IF;
								IF i = 10 THEN
									i <= 0;
									done <= '1';
									rsthsa;
									seg := 1;
								END IF;

					WHEN 5 =>	IF x < 10 THEN
									IF y < 10 THEN
										tmp_read_address <= address(x,y,11);
										IF mem_data_out = data(seg) THEN
											cont <= '1';
											IF cont = '1' THEN
												cont <= '0';
												tmp_read_address <= address(x,y,0);
												IF mem_data_out = "0000" THEN
													cont <= '1';
													IF cont = '1' THEN
														cont <= '0';
														tmp_read_address <= address(x,y,10);
														IF mem_data_out > "0001" THEN
															cont <= '1';
															IF cont = '1' THEN
																cont <= '0';
																IF i < 10 THEN
																	tmp_read_address <= address(x,y,i);
																	IF mem_data_out /= "0000" THEN
																		hsa(I,1) <= hsa(I,1) + 1;
																		hsa(I,2) <= x;
																		hsa(I,3) <= y;
																	END IF;
																	i <= i + 1;
																END IF;
															END IF;
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
								IF x = 10 THEN
									x <= 1;
									done <= '1';
								END IF;

					WHEN 6 =>	IF i < 10 THEN
									IF hsa(i,1) = 1 THEN
										CASE count IS
											WHEN 0 =>--wcandboard(hsa(i,2),hsa(i,3),0,hsa(i,1));
													tmp_write_address <= address(hsa(i,2),hsa(i,3),0);
													tmp_data_in <= data(hsa(i,1));
											WHEN 1 =>--wcandboard(hsa(i,2),hsa(i,3),i,0);
													tmp_write_address <= address(hsa(i,2),hsa(i,3),i);
													tmp_data_in <= "0000";
											WHEN 2 =>--wcandboard(hsa(i,2),hsa(i,3),10,0);
													tmp_write_address <= address(hsa(i,2),hsa(i,3),10);
													tmp_data_in <= "0000";
											WHEN OTHERS => null;
											hidden_singles_failed <= '0';
										END CASE;
									END IF;
								END IF;
								IF i = 10 THEN
									i <= 0;
									done <= '1';
									seg := seg + 1;									
									rsthsa;
								END IF;
					WHEN OTHERS => done <= '1'; ctrl <= 0;
				END CASE;
				IF done = '1' THEN
					ctrl <= ctrl + 1;
					done <= '0';
				END IF;
				hidden_singles_done <= '1';
			END IF;
		END IF;
	END PROCESS;

	mem_read_address <= (OTHERS => 'Z') WHEN solve_control_data /= "011" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN solve_control_data /= "011" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN solve_control_data /= "011" 
		ELSE tmp_data_in;

END bhv;


				--FOR x IN 1 to 9 LOOP -- find hidden singles in rows
				--	FOR y IN 1 to 9 LOOP
				--		IF (candboard(x,y,0,mem_data_out) = 0 and candboard(x,y,10,mem_data_out) > 1) THEN -- several candidates found
				--			FOR I IN 1 to 9 LOOP
				--				IF candboard(x,y,I,mem_data_out) /= 0 THEN
				--					hsa(I,1) <= hsa(I,1) + 1;
				--					hsa(I,2) <= x;
				--					hsa(I,3) <= y;
				--				END IF;
				--			END LOOP;
				--		END IF;
				--	END LOOP;
				--END LOOP;

				--FOR I IN 1 to 9 LOOP
				--	IF hsa(I,1) = 1 THEN
				--		wcandboard(hsa(I,2),hsa(I,3),0,hsa(I,1));
				--		wcandboard(hsa(I,2),hsa(I,3),I,0);
				--		wcandboard(hsa(I,2),hsa(I,3),10,0);
				--		hidden_singles_failed <= '0';
				--	END IF;
				--END LOOP;

				--FOR y IN 1 to 9 LOOP -- find hidden singles in columns
				--	FOR x IN 1 to 9 LOOP
				--		IF (candboard(x,y,0,mem_data_out) = 0 and candboard(x,y,10,mem_data_out) > 1) THEN -- several candidates found
				--			FOR I IN 1 to 9 LOOP
				--				IF candboard(x,y,I,mem_data_out) /= 0 THEN
				--					hsa(I,1) <= hsa(I,1) + 1;
				--					hsa(I,2) <= x;
				--					hsa(I,3) <= y;
				--				END IF;
				--			END LOOP;
				--		END IF;
				--	END LOOP;
				--END LOOP;



				--FOR I IN 1 to 9 LOOP
				--	IF hsa(I,1) = 1 THEN
				--		wcandboard(hsa(I,2),hsa(I,3),0,hsa(I,1));
				--		wcandboard(hsa(I,2),hsa(I,3),I,0);
				--		wcandboard(hsa(I,2),hsa(I,3),10,0);
				--		hidden_singles_failed <= '0';
				--	END IF;
				--END LOOP;

				--FOR a IN 1 to 9 LOOP
				--	FOR b IN 1 to 3 LOOP
				--		hsa(a,b) <= 0;
				--	END LOOP;
				--END LOOP;

				--seg := 1;
				--WHILE (seg <= 9) LOOP -- find hidden singles in segment 
				--	FOR x IN 1 to 9 LOOP
				--		FOR y IN 1 to 9 LOOP
				--			IF candboard(x,y,11,mem_data_out) = seg THEN
				--				IF (candboard(x,y,0,mem_data_out) = 0 and candboard(x,y,10,mem_data_out) > 1) THEN -- several candidates found
				--					FOR I IN 1 to 9 LOOP
				--						IF candboard(x,y,I,mem_data_out) /= 0 THEN
				--							hsa(I,1) <= hsa(I,1) + 1;
				--							hsa(I,2) <= x;
				--							hsa(I,3) <= y;
				--						END IF;
				--					END LOOP;
				--				END IF;
				--			END IF;
				--		END LOOP;
				--	END LOOP;
				--	FOR I IN 1 to 9 LOOP
				--		IF hsa(I,1) = 1 THEN
				--			wcandboard(hsa(I,2),hsa(I,3),0,hsa(I,1));
				--			wcandboard(hsa(I,2),hsa(I,3),I,0);
				--			wcandboard(hsa(I,2),hsa(I,3),10,0);
				--			hidden_singles_failed <= '0';
				--		END IF;
				--	END LOOP;
				--	seg := seg + 1;
				--END LOOP;