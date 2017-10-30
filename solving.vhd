LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY solving IS
	PORT (
		reset			: IN std_logic;
		clk 			: IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_read_address: OUT integer range 0 to 255;
		mem_data_out: IN std_logic_vector(3 downto 0);

		mem_store_address: OUT integer range 0 to 255;
		mem_write_enable: OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0)

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

END bhv;