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

	FUNCTION address(x: integer; y: integer; i: integer) return integer IS
	BEGIN
		return to_integer(to_unsigned(i,4) & to_unsigned(y,4) & to_unsigned(x,4));
	END address;

	FUNCTION data(val: integer) return std_logic_vector IS
	BEGIN
		return std_logic_vector(to_unsigned(val,4));
	END data;

	FUNCTION seg_assign(x,y : IN integer) RETURN integer IS
	BEGIN
		CASE x IS 
			WHEN 0 to 2 =>	return 1;
			WHEN 3 to 5 =>	return 2;
			WHEN 6 to 8 =>	return 3;
			WHEN OTHERS => return 0;
		END CASE;
	END seg_assign;

	SIGNAL x : integer range 0 to 9;
	SIGNAL y : integer range 0 to 9;
	SIGNAL i : integer range 0 to 12;
	SIGNAL first_candidate_initialise: std_logic;
	SIGNAL stage: integer range 0 to 2;
	SIGNAL wacht: std_logic;
	SIGNAL check_value: std_logic;
			SIGNAL count: integer range 0 to 3;
	SIGNAL set_candidates: std_logic;
	SIGNAL value: std_logic_vector(3 downto 0);
	

BEGIN
PROCESS(clk,reset)

BEGIN
    IF reset = '0' THEN
    	mem_write_enable <= '0';
    	mem_write_address <= address(0,0,0);
    	mem_read_address <= address(0,0,0);
    	mem_data_in <= data(0);
    	x <= 0;
    	y <= 0;
    	i <= 0;
    	count <= 0;
    	value <= "0000";
    	set_candidates <= '0';
    	first_candidate_initialise <= '0';
    	stage <= 0;
	ELSIF rising_edge(clk) THEN
       

        IF control = "011" THEN

        	IF first_candidate_initialise = '0' THEN
        		IF stage = 0 THEN
	        		mem_write_enable <= '1';

	        		mem_write_address <= address(x,y,11);
		        	mem_data_in <= data(seg_assign(x,y));	

	        		IF x = 9 THEN
                        x <= 0;
                        y <= y + 1;
                    ELSE
                        x <= x + 1;
                    END IF;

                    IF y = 9 THEN
                        y <= 0;
                        x <= 0;
                        i <= 1;
                        value <= "1111";
                        stage <= 1;
                        mem_write_enable <= '0';
                    END IF;

		        ELSE
		        	mem_write_enable <= '1';

		        	IF count /= 2 THEN
		        		count <= count + 1;
		        	END IF;

		        	IF count = 0 THEN
		        		mem_read_address <= address(x,y,0);
		        		
		        	ELSIF count = 1 THEN
		        		IF mem_data_out = "0000" THEN
		        			set_candidates <= '1';
		        			
		        		ELSE
		        			set_candidates <= '0';
		        		
		        		END IF;
		        	ELSIF count = 3 THEN
		        		x <= x + 1;
		        	END IF;

		        	IF y < 9 THEN
		        		IF x < 9 THEN
		        			IF set_candidates = '1' AND count = 2 THEN
			        			IF i < 11 THEN
			        					IF x = 0 THEN
			        						mem_write_address <= address(8,y,i);
			        					ELSE
			        						mem_write_address <= address(x-1,y,i);
			        					END IF;
			        					
				        				IF i = 10 THEN
					        				mem_data_in <= data(9);
					        			ELSE
					        				mem_data_in <= data(i);
				        				END IF;
				        				i <= i + 1;
			        			ELSE
			        				i <= 1;
			        				count <= 3;
			        				set_candidates <= '0';
			        			END IF;
			        		ELSIF set_candidates = '0' AND count = 2 THEN
			        				i <= 1;
			        				
			        				count <= 3;
			        				set_candidates <= '0';
		        			END IF;
		        		END IF;
		        		IF x = 8 AND count = 2 THEN
		        			x <= 0;
		        			y <= y + 1;
		        			
		        			i <= 1;
        					count <= 0;
	        				set_candidates <= '0';
		        		END IF;
		        	ELSE
		        		x <= 0;
		        		y <= 0;
		        		first_candidate_initialise <= '1';
		        		mem_write_enable <= '0';
		        	END IF;
		        END IF;

	        ELSE

	        	mem_write_enable <= '0';
	        END IF;
           
        END IF;
	
	END IF;
END PROCESS;

END bhv;