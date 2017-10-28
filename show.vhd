LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY show IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

       	control : IN std_logic_vector(2 downto 0);

       	sw_address: IN unsigned(3 downto 0);

       	mem_read_address: OUT integer range 0 to 15	
    );		
END ENTITY show;

ARCHITECTURE bhv of show IS

BEGIN

	PROCESS(clk,reset)

	BEGIN
		IF reset = '0' THEN
			mem_read_address <= 0;
		ELSIF rising_edge(clk) THEN
			IF control = "100" THEN
				mem_read_address <= to_integer(sw_address);
			ELSE
				mem_read_address <= 0;
			END IF;
		END IF;
	END PROCESS;


END bhv;