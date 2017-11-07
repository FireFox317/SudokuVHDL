LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY solving IS
	PORT (
		reset			: IN std_logic;
		clk 			: IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_read_address: OUT integer range 0 to 4095;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_write_address: OUT integer range 0 to 4095;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0);

		solving_done: OUT std_logic

		);
END ENTITY solving;

ARCHITECTURE bhv of solving IS


	FUNCTION seg_assign(x,y : integer) return integer IS
	BEGIN
		CASE x IS 
			WHEN 0 to 2 =>	
							CASE y IS 
								WHEN 0 to 2 =>	return 0;
								WHEN 3 to 5 =>	return 3;
								WHEN 6 to 8 =>	return 6;
								WHEN OTHERS => return 0;
							END CASE;
			WHEN 3 to 5 =>	
							CASE y IS 
								WHEN 0 to 2 =>	return 1;
								WHEN 3 to 5 =>	return 4;
								WHEN 6 to 8 =>	return 7;
								WHEN OTHERS => return 0;
								
							END CASE;
			WHEN 6 to 8 =>		
							CASE y IS 
								WHEN 0 to 2 =>	return 2;
								WHEN 3 to 5 =>	return 5;
								WHEN 6 to 8 =>	return 8;
								WHEN OTHERS => return 0;
					
							END CASE;
			WHEN OTHERS => return 0;
		END CASE;
	END seg_assign;

	FUNCTION address(x: integer; y: integer; i: integer) return integer IS
	BEGIN
		return to_integer((to_unsigned(i,4) & to_unsigned(y,4) & to_unsigned(x,4)));
	END address;


	SIGNAL count: integer range 0 to 3;
	SIGNAL upd_can_state: integer range 0 to 3;
	--SIGNAL hid_sig_state: integer range 0 to 3;
	
	--SIGNAL hid_sig_count: integer range 0 to 3;
	--SIGNAL hid_sig_state1: std_logic;
	

	TYPE candidatesudoku IS ARRAY (0 TO 8, 0 TO 8, 0 TO 11) OF integer range 0 to 9; -- array type for possible candidates.
	SIGNAL candboard : candidatesudoku;

	TYPE hidden_single_store IS ARRAY (1 TO 9, 1 TO 3) OF integer range 0 to 9;
	SIGNAL hsa : hidden_single_store; 

	TYPE states is (mem_receive, init, update_candidates, singles, hidden_singles, mem_send, done);
	SIGNAL state : states;
	

BEGIN
PROCESS(clk,reset)
		VARIABLE x : integer range 0 to 9;
		VARIABLE y : integer range 0 to 9;
		VARIABLE i : integer range 0 to 12;
		VARIABLE seg : integer range 0 to 9;
		VARIABLE single_found: std_logic;
		VARIABLE hidden_single_found: std_logic;
	
BEGIN
	IF reset = '0' THEN
		single_found := '0';
		state <= mem_receive;
		upd_can_state <= 0;
		solving_done <= '0';
		--hid_sig_state <= 0;
		--hid_sig_count <= 0;
		--hid_sig_state1 <= '0';
		hidden_single_found := '0';
		x := 0;
		y := 0;
		i := 0;
		seg := 0;

		
		count <= 0;

	ELSIF rising_edge(clk) THEN

		IF control = "011" THEN

		IF state = mem_receive THEN
			solving_done <= '0';
			IF count = 0 THEN
				mem_read_address <= address(x,y,0);
				count <= 1;
			ELSIF count = 1 THEN
				
				count <= 2;
			ELSIF count = 2 THEN
				count <= 0;
				candboard(x,y,0) <= to_integer(unsigned(mem_data_out));
			END IF;

			IF count = 2 THEN
				IF x = 8 THEN
					x := 0;
					y := y + 1;
				ELSE
					x := x + 1;
				END IF;

				IF y = 9 THEN
					x := 0;
					y := 0;
					state <= init;

				END IF;
	   END IF;

		ELSIF state = init THEN

			FOR x in 0 to 8 LOOP
				FOR y in 0 to 8 LOOP
					candboard(x,y,11) <= seg_assign(x,y);

					IF candboard(x,y,0) = 0 THEN
						FOR i in 1 to 9 LOOP
							candboard(x,y,i) <= i;	
						END LOOP;
						candboard(x,y,10) <= 9;
					END IF;
		 
				END LOOP;
			END LOOP;

			state <= update_candidates;

		ELSIF state = update_candidates THEN

		IF upd_can_state = 0 THEN
			single_found := '0';
			hidden_single_found := '0';
			IF x = 8 THEN
				x := 0;
				y := y + 1;
			ELSE
				x := x + 1;
			END IF;

			IF y = 9 THEN
				x := 0;
				y := 0;
				upd_can_state <= 1;
			END IF;
					IF candboard(x,y,0) /= 0 THEN
						FOR xc in 0 to 8 LOOP
							IF candboard(xc,y,0) = 0 THEN
					
								IF candboard(xc,y,candboard(x,y,0)) /= 0 THEN
									candboard(xc,y,10) <= candboard(xc,y,10) - 1;
									candboard(xc,y,candboard(x,y,0)) <= 0;
								END IF;

							END IF;
						END LOOP;
						
					END IF;
  
			

		ELSIF upd_can_state = 1 THEN

		IF x = 8 THEN
				x := 0;
				y := y + 1;
			ELSE
				x := x + 1;
			END IF;

			IF y = 9 THEN
				x := 0;
				y := 0;
				upd_can_state <= 2;
			END IF;
   --    
					IF candboard(x,y,0) /= 0 THEN
						FOR yc IN 0 to 8 LOOP -- eliminate in column
							IF candboard(x,yc,0) = 0 THEN

								IF candboard(x,yc,candboard(x,y,0)) /= 0 THEN
									candboard(x,yc,10) <= candboard(x,yc,10) - 1;
									candboard(x,yc,candboard(x,y,0)) <= 0;
								END IF;
							END IF;
						END LOOP;
					END IF;

		ELSIF upd_can_state = 2 THEN

		IF x = 8 THEN
				x := 0;
				y := y + 1;
			ELSE
				x := x + 1;
			END IF;

			IF y = 9 THEN
				x := 0;
				y := 0;
				upd_can_state <= 0;
				state <= singles;
			END IF;

			IF candboard(x,y,0) /= 0 THEN
				FOR xc IN 0 to 8 LOOP
					FOR yc IN 0 to 8 LOOP
						IF candboard(xc,yc,11) = candboard(x,y,11) THEN
							IF candboard(xc,yc,candboard(x,y,0)) /= 0 THEN
								candboard(xc,yc,candboard(x,y,0)) <= 0;
								candboard(xc,yc,10) <= candboard(xc,yc,10) - 1;
							END IF;
							
						END IF;
					END LOOP;
				END LOOP;
			END IF;
								
			
		END IF;

			

		ELSIF state = singles THEN

        	FOR x IN 0 to 8 LOOP -- find singles
					FOR y IN 0 to 8 LOOP
						IF candboard(x,y,0) = 0 and candboard(x,y,10) = 1 THEN -- unique solution found
							FOR I IN 1 to 9 LOOP
								IF candboard(x,y,I) /= 0 THEN
									candboard(x,y,0) <= candboard(x,y,I);
									candboard(x,y,I) <= 0;
									candboard(x,y,10) <= 0;
								END IF;
							END LOOP;
							single_found := '1';
						END IF;
					END LOOP;
				END LOOP;

			IF single_found = '1' THEN
	        	state <= update_candidates;
        	ELSE
        		state <= hidden_singles;
        	END IF;
		


		ELSIF state = hidden_singles THEN

		--If hid_sig_state = 0 THEN
		--	CASE hid_sig_count IS
		--		WHEN 0 =>
		--			IF x = 8 THEN
		--				x := 0;
		--				y := y + 1;
		--			ELSE
		--				x := x + 1;
		--			END IF;

		--			IF y = 9 THEN
		--				x := 0;
		--				y := 0;
		--				hid_sig_state <= 1;
		--			END IF;

		--			IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1 THEN -- several candidates found
		--					FOR I IN 1 to 9 LOOP
		--						IF candboard(x,y,I) /= 0 THEN
		--							hsa(I,1) <= hsa(I,1) + 1;
		--							hsa(I,2) <= x;
		--							hsa(I,3) <= y;
		--						END IF;
		--					END LOOP;
		--			END IF;
					
		--		WHEN 1 =>
		--			IF x = 8 THEN
		--				x := 0;
		--				y := y + 1;
		--			ELSE
		--				x := x + 1;
		--			END IF;

		--			IF y = 9 THEN
		--				x := 0;
		--				y := 0;
		--				hid_sig_state <= 1;
		--			END IF;

					
		--					IF candboard(x,y,0) = 0 and candboard(x,y,10) > 1 THEN -- several candidates found
		--						FOR I IN 1 to 9 LOOP
		--							IF candboard(x,y,I) /= 0 THEN
		--								hsa(I,1) <= hsa(I,1) + 1;
		--								hsa(I,2) <= x;
		--								hsa(I,3) <= y;
		--							END IF;
		--						END LOOP;
		--					END IF;
						
		--		WHEN 2 =>-- find hidden singles in segment 
		--			IF x = 8 THEN
		--				x := 0;
		--				y := y + 1;
		--			ELSE
		--				x := x + 1;
		--			END IF;

		--			IF y = 9 THEN
		--				x := 0;
		--				y := 0;
		--				hid_sig_state <= 1;
		--			END IF;
	
		--					IF candboard(x,y,11) = seg THEN
		--						IF (candboard(x,y,0) = 0 and candboard(x,y,10) > 1) THEN -- several candidates found
		--							FOR I IN 1 to 9 LOOP
		--								IF candboard(x,y,I) /= 0 THEN
		--									hsa(I,1) <= hsa(I,1) + 1;
		--									hsa(I,2) <= x;
		--									hsa(I,3) <= y;
		--								END IF;
		--							END LOOP;
		--						END IF;
		--					END IF;
			
					
		--		WHEN 3 =>

		--	END CASE;
		--ELSIF hid_sig_state = 1 THEN
		--	IF hid_sig_state1 = '0' THEN
		--		FOR I IN 1 to 9 LOOP
		--			IF hsa(I,1) = 1 THEN
		--				candboard(hsa(I,2),hsa(I,3),0) <= I;
		--				candboard(hsa(I,2),hsa(I,3),I) <= 0;
		--				candboard(hsa(I,2),hsa(I,3),10) <= 0;
		--				hidden_single_found := '1';
		--			END IF;
		--		END LOOP;
		--		hid_sig_state1 <= '1';
		--	ELSE

		--	FOR a in 1 to 9 LOOP
		--		FOR b in 1 to 3 LOOP
		--			hsa(a,b) <= 0;
		--		END LOOP;
		--	END LOOP;
		--	hid_sig_state1 <= '0';	

		--	IF hid_sig_count = 2 THEN
		--		seg := seg + 1;
		--		hid_sig_state <= 0;
		--	ELSIF hid_sig_count < 2 THEN
		--		hid_sig_state <= 0;
		--		hid_sig_count <= hid_sig_count + 1;
		--	ELSE
		--		IF hidden_single_found = '0' THEN
		--			state <= mem_send;
		--		ELSE
		--			state <= update_candidates;
		--		END IF;
		--	END IF;
		--	END IF;
					
		--IF seg = 9 THEN
		--	hid_sig_count <= hid_sig_count + 1;
		--END IF;
	


		
		--END IF;
		state <= mem_send;

			

		ELSIF state = mem_send THEN
			mem_write_enable <= '1';

			IF count = 0 THEN
				mem_data_in <= std_logic_vector(to_unsigned(candboard(x,y,i),4));
				mem_write_address <= address(x,y,i);
				count <= 1;
			ELSIF count = 1 THEN
				count <= 2;
			ELSE
				count <= 0;
			END IF;

			IF count = 2 THEN
				IF i = 12 THEN
					i := 0;
					x := x + 1;
				ELSE
					i := i + 1;
				END IF;

				IF x = 9 THEN
					x := 0;
					y := y + 1;
				END IF;

				IF y = 9 THEN
					x := 0;
					y := 0;
					i := 0;
					state <= done;
					mem_write_enable <= '0';
				END IF;
			END IF;


		ELSIF state = done THEN
			solving_done <= '1';
		END IF;

		END IF;
	   

		--IF control = "011" THEN

		--	IF data_stored = '0' THEN
				
		--	ELSE

				

		   -- 	send_data <= '1';
		--	END IF;

		--	IF send_data = '1' THEN
				

		   -- ELSE
		   -- 	mem_write_enable <= '0';

		--	END IF;


			
			
			--	IF stage = 0 THEN
			--		mem_write_enable <= '1';

			--		mem_write_address <= address(x,y,11);
			   -- 	mem_data_in <= data(seg_assign(x,y));	

			--		IF x = 9 THEN
		 --               x <= 0;
		 --               y <= y + 1;
		 --           ELSE
		 --               x <= x + 1;
		 --           END IF;

		 --           IF y = 9 THEN
		 --               y <= 0;
		 --               x <= 0;
		 --               i <= 1;
		 --               value <= "1111";
		 --               stage <= 1;
		 --               mem_write_enable <= '0';
		 --           END IF;

			   -- ELSE
			   -- 	mem_write_enable <= '1';

			   -- 	IF count /= 2 THEN
			   -- 		count <= count + 1;
			   -- 	END IF;

			   -- 	IF count = 0 THEN
			   -- 		mem_read_address <= address(x,y,0);
						
			   -- 	ELSIF count = 1 THEN
			   -- 		IF mem_data_out = "0000" THEN
			   -- 			set_candidates <= '1';
							
			   -- 		ELSE
			   -- 			set_candidates <= '0';
						
			   -- 		END IF;
			   -- 	ELSIF count = 3 THEN
			   -- 		x <= x + 1;
			   -- 	END IF;

			   -- 	IF y < 9 THEN
			   -- 		IF x < 9 THEN
			   -- 			IF set_candidates = '1' AND count = 2 THEN
				  --  			IF i < 11 THEN
				  --  					IF x = 0 THEN
				  --  						mem_write_address <= address(8,y,i);
				  --  					ELSE
				  --  						mem_write_address <= address(x-1,y,i);
				  --  					END IF;
										
					 --   				IF i = 10 THEN
						--    				mem_data_in <= data(9);
						--    			ELSE
						--    				mem_data_in <= data(i);
					 --   				END IF;
					 --   				i <= i + 1;
				  --  			ELSE
				  --  				i <= 1;
				  --  				count <= 3;
				  --  				set_candidates <= '0';
				  --  			END IF;
				  --  		ELSIF set_candidates = '0' AND count = 2 THEN
				  --  				i <= 1;
									
				  --  				count <= 3;
				  --  				set_candidates <= '0';
			   -- 			END IF;
			   -- 		END IF;
			   -- 		IF x = 8 AND count = 2 THEN
			   -- 			x <= 0;
			   -- 			y <= y + 1;
							
			   -- 			i <= 1;
			--				count <= 0;
			--				set_candidates <= '0';
			   -- 		END IF;
			   -- 	ELSE
			   -- 		x <= 0;
			   -- 		y <= 0;
			   -- 		first_candidate_initialise <= '1';
			   -- 		mem_write_enable <= '0';
			   -- 	END IF;
			   -- END IF;

			--ELSE

			--	mem_write_enable <= '0';
		   
		--END IF;
	
	END IF;
END PROCESS;

END bhv;