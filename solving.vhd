LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY solving IS
	PORT (
		reset			: IN std_logic;
		clk 			: IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_read_address: INOUT unsigned(7 downto 0);
		mem_data_out: IN std_logic_vector(3 downto 0);
		mem_write_address: INOUT unsigned(7 downto 0);
		mem_data_in : INOUT std_logic_vector(3 downto 0);

		mem_write_request : OUT std_logic;
       	mem_write_feedback : IN std_logic;
       	mem_read_request : OUT std_logic;
        mem_read_feedback : IN std_logic
		);
END ENTITY solving;

ARCHITECTURE bhv of solving IS

BEGIN

PROCESS(clk,reset)
  
BEGIN
    IF reset = '0' THEN
       
	ELSIF rising_edge(clk) THEN
       

        IF control = "011" THEN
           
        END IF;
	
	END IF;
END PROCESS;

	PROCESS(mem_read_feedback,mem_write_feedback)
	BEGIN
		IF mem_read_feedback = '0' THEN
			mem_read_address <= "ZZZZZZZZ";
		END IF;
		IF mem_write_feedback = '0' THEN
			mem_write_address <= "ZZZZZZZZ";
			mem_data_in <= "ZZZZ";
		END IF;
	END PROCESS;

END bhv;