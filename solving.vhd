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
	

BEGIN
PROCESS(clk,reset)
	VARIABLE set_candidates: std_logic;
BEGIN
    IF reset = '0' THEN
    	x <= 0;
    	y <= 0;
    	i <= 0;
    	first_candidate_initialise <= '0';
    	stage <= 0;
	ELSIF rising_edge(clk) THEN
       

        IF control = "011" THEN

        	IF first_candidate_initialise = '0' THEN
        		IF stage = 0 THEN
	        		mem_write_enable <= '1';
		        	IF y < 9 THEN
		        		IF x < 9 THEN
		        			mem_write_address <= address(x,y,11);
		        			mem_data_in <= data(seg_assign(x,y));
		        			x <= x + 1;
		        		END IF;
		        		IF x = 9 THEN
		        			y <= y + 1;
		        			x <= 0;
		        		END IF;
		        	ELSE
		        		x <= 0;
		        		y <= 0;
		        		i <= 1;
		        		stage <= 1;
		        		mem_write_enable <= '0';
		        	END IF;
		        ELSE
		        	mem_write_enable <= '1';

		        	IF y < 9 THEN
		        		IF x < 9 THEN
		        			IF i < 11 THEN
			        				mem_write_address <= address(x,y,i);
			        				IF i = 10 THEN
				        				mem_data_in <= data(9);
				        			ELSE
				        				mem_data_in <= data(i);
			        				END IF;
			        				i <= i + 1;
		        			ELSE
		        				x <= x + 1;
		        				i <= 1;
		        			END IF;
		        		END IF;
		        		IF x = 9 THEN
		        			x <= 0;
		        			y <= y + 1;
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