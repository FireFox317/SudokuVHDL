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
		mem_data_in : OUT std_logic_vector(3 downto 0)

		);
END ENTITY solving;

ARCHITECTURE bhv of solving IS


	FUNCTION seg_assign(x,y : integer) return integer IS
	BEGIN
		CASE x IS 
			WHEN 0 to 2 =>	return 1;
			 			--	CASE y IS 
							--	WHEN 0 to 2 =>	return 0;
							--	WHEN 3 to 5 =>	return 3;
							--	WHEN 6 to 8 =>	return 6;
							--	WHEN OTHERS => return 0;
							--END CASE;
			WHEN 3 to 5 =>	return 2;
							--CASE y IS 
							--	WHEN 0 to 2 =>	return 1;
							--	WHEN 3 to 5 =>	return 4;
							--	WHEN 6 to 8 =>	return 7;
							--	WHEN OTHERS => return 0;
							--END CASE;
			WHEN 6 to 8 =>	return 3;	
							--CASE y IS 
							--	WHEN 0 to 2 =>	return 2;
							--	WHEN 3 to 5 =>	return 5;
							--	WHEN 6 to 8 =>	return 8;
							--	WHEN OTHERS => return 0;
							--END CASE;
			WHEN OTHERS => return 0;
		END CASE;
	END seg_assign;

	SIGNAL x : integer range 0 to 9;
	SIGNAL y : integer range 0 to 9;
	SIGNAL i : integer range 0 to 12;
	--SIGNAL first_candidate_initialise: std_logic;
	----SIGNAL stage: integer range 0 to 2;
	--SIGNAL data_stored: std_logic;
	--SIGNAL send_data: std_logic;
	--SIGNAL check_value: std_logic;
	--		SIGNAL count: integer range 0 to 3;
	--SIGNAL set_candidates: std_logic;
	--SIGNAL value: std_logic_vector(3 downto 0);

	TYPE candidatesudoku IS ARRAY (0 TO 8, 0 TO 8, 0 TO 11) OF integer range 0 to 9; -- array type for possible candidates.
	SIGNAL candboard : candidatesudoku;

	TYPE states is (mem_receive, init, update_candidates, singles, hidden_singles, mem_send, done);
	SIGNAL state : states;
	

BEGIN
PROCESS(clk,reset)

BEGIN
    IF reset = '0' THEN
    	--mem_write_enable <= '0';
    	--mem_write_address <= address(0,0,0);
    	--mem_read_address <= address(0,0,0);
    	----mem_data_in <= data(0);
    	--data_stored <= '0';
    	--send_data <= '0';
    	state <= mem_receive;
    	x <= 0;
    	y <= 0;
    	i <= 0;
    	--count <= 0;
    	--value <= "0000";
    	--set_candidates <= '0';
    	--first_candidate_initialise <= '0';
    	--stage <= 0;
	ELSIF rising_edge(clk) THEN

		IF control = "011" THEN

		IF state = mem_receive THEN

			mem_read_address <= address(x,y,i);

       		IF x /= 0 AND y /= 0 AND i /= 0 THEN
	        	candboard(x-1,y-1,i-1) <= to_integer(unsigned(mem_data_out));
        	END IF;

        	IF i = 12 THEN
        		i <= 0;
        		x <= x + 1;
        	ELSE
        		i <= i + 1;
        	END IF;

        	IF x = 9 THEN
        		x <= 0;
        		y <= y + 1;
        	END IF;

        	IF y = 9 THEN
        		x <= 0;
        		y <= 0;
        		i <= 0;
        		state <= init;
        	END IF;

        ELSIF state = init THEN

        	FOR y in 0 to 8 LOOP
        		FOR x in 0 to 8 LOOP
        			candboard(x,y,11) <= seg_assign(x,y);
        			IF candboard(x,y,0) = 0 THEN
	        			FOR i in 1 to 9 LOOP
	        				candboard(x,y,i) <= i;	
	        			END LOOP;
        			END IF;
        		END LOOP;
        	END LOOP;

        	state <= update_candidates;

        ELSIF state = update_candidates THEN

        	FOR x in 0 to 8 LOOP
        		FOR y in 0 to 8 LOOP
        			IF candboard(x,y,0) /= 0 THEN
        				FOR xc in 0 to 8 LOOP
        					IF candboard(xc,y,0) = 0 THEN
        						candboard(xc,y,(candboard(x,y,0))) <= 0;
        						candboard(xc,y,10) <= candboard(xc,y,10) - 1;
        					END IF;
        				END LOOP;
        			END IF;
        		END LOOP; 
        	END LOOP;
        	state <= singles;

        ELSIF state = singles THEN
        	state <= hidden_singles;

        ELSIF state = hidden_singles THEN

        	state <= mem_send;

        ELSIF state = mem_send THEN
        	mem_write_enable <= '1';

    		mem_data_in <= std_logic_vector(to_unsigned(candboard(x,y,i),4));
    		mem_write_address <= address(x,y,i);

    		IF i = 12 THEN
        		i <= 0;
        		x <= x + 1;
        	ELSE
        		i <= i + 1;
        	END IF;

        	IF x = 9 THEN
        		x <= 0;
        		y <= y + 1;
        	END IF;

        	IF y = 9 THEN
        		x <= 0;
        		y <= 0;
        		i <= 0;
        		state <= done;
        		mem_write_enable <= '0';
        	END IF;


        ELSIF state = done THEN

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