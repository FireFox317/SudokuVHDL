LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY update_candidates IS
	PORT (
		clk: IN std_logic;
		reset:  IN std_logic;
		solve_control_data: IN std_logic_vector(2 downto 0);
		update_candidates_done: OUT std_logic;
		
		mem_read_address: OUT unsigned(11 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_write_address: OUT unsigned(11 downto 0);
		mem_data_in : OUT std_logic_vector(3 downto 0)	
		);
END ENTITY update_candidates;

ARCHITECTURE bhv OF update_candidates IS
	
	SIGNAL tmp_read_address : unsigned(11 downto 0);
	SIGNAL tmp_write_address : unsigned(11 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);
	SIGNAL first_candidate_initialise : std_logic := '0';

	SIGNAL x: integer range 1 to 10 := 1;
	SIGNAL y: integer range 1 to 10 := 1;
	SIGNAL i: integer range 0 to 11 := 1;

	SIGNAL stage: integer range 0 to 2 := 0;


	
	FUNCTION seg_assign(x,y : IN integer) RETURN integer IS
	BEGIN
		CASE x IS 
			WHEN 1 to 3 =>	return 1;
			WHEN 4 to 6 =>	return 2;
			WHEN 7 to 9 =>	return 3;
			WHEN OTHERS => return 0;
		END CASE;
	END seg_assign;


	FUNCTION address(x: integer; y: integer; i: integer) return unsigned IS
	BEGIN
		return (to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4));
	END address;

BEGIN

	PROCESS(clk,reset)
		VARIABLE b: integer range 0 to 9 := 0;

		
	BEGIN

		IF reset = '0' THEN

		ELSIF rising_edge(clk) THEN
			IF solve_control_data = "010" THEN
				update_candidates_done <= '0';
			ELSIF solve_control_data = "001" THEN
			
				IF first_candidate_initialise = '0' THEN
					IF stage = 0 THEN
						-- segment assigment
	                	IF x < 10 THEN
							if y < 10 THEN
								tmp_write_address <= address(x,y,11);
								tmp_data_in <= std_logic_vector(to_unsigned(seg_assign(x,y),4));

								y <= y + 1;
							END IF;
							IF y = 10 THEN
								x <= x + 1;
								y <= 1;
							END IF;
						ELSE
							stage <= 1;
							x <= 1;
							y <= 1;
						END IF;
					ELSIF stage = 1 THEN
						-- other thing
						IF x < 10 THEN
							IF y < 10 THEN
								tmp_read_address <= address(x,y,0);
								IF mem_data_out = "0000" THEN
									IF i < 10 THEN
										tmp_write_address <= address(x,y,i);
										tmp_data_in <= std_logic_vector(to_unsigned(i,4));

										i <= i + 1;
									ELSE
										y <= y + 1;
									END IF;
								END IF;
								IF y = 10 THEN
									x <= x + 1;
									y <= 1;
								END IF;
							END IF;
						ELSE
							x <= 1;
							y <= 1;
							i <= 0;
							stage <= 3;
						END IF;

					ELSIF stage = 3 THEN

					END IF;


				
				END IF;

				--FOR x IN 1 to 9 LOOP -- update cadidates: elimination
				--	FOR y IN 1 to 9 LOOP
				--		IF candboard(x,y,0) /= 0 THEN
				--			FOR xc IN 1 to 9 LOOP -- eliminate in row
				--				IF 	candboard(xc,y,0) = 0 THEN
				--					wcandboard(xc,y,(candboard(x,y,0)),0);
				--					wcandboard(xc,y,10,candboard(xc,y,10) - 1);
				--				END IF;
				--			END LOOP;
				--			FOR yc IN 1 to 9 LOOP -- eliminate in column
				--				IF 	candboard(x,yc,0) = 0 THEN
				--					wcandboard(x,yc,(candboard(x,y,0)),0);
				--					wcandboard(x,yc,10,candboard(x,yc,10) - 1);
				--				END IF;
				--			END LOOP;
							

							
				--			WHILE (i <= 9) LOOP -- eliminate in segment
				--				FOR xc IN 1 to 9 LOOP
				--					FOR yc IN 1 to 9 LOOP
				--						IF	candboard(xc,yc,11) = candboard(x,y,11) THEN
				--							wcandboard(x,yc,(candboard(x,y,0)),0);
				--							wcandboard(x,yc,10,candboard(x,yc,10) - 1 );
				--							i := i + 1;
				--						END IF;
				--					END LOOP;
				--				END LOOP;
				--			END LOOP;
				--			i := 0;
				--		END IF;
				--	END LOOP;
				--END LOOP;
				update_candidates_done <= '0';
			END IF;

		END IF;
	END PROCESS;

	mem_read_address <= (OTHERS => 'Z') WHEN solve_control_data /= "001" 
		ELSE tmp_read_address;

	mem_write_address <= (OTHERS => 'Z') WHEN solve_control_data /= "001" 
		ELSE tmp_write_address;
		
	mem_data_in <= (OTHERS => 'Z') WHEN solve_control_data /= "001" 
		ELSE tmp_data_in;

END bhv;