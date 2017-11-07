LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY clear_memory IS
  PORT(
		clk: IN std_logic;
		reset: IN std_logic;

		control: IN std_logic_vector(2 downto 0);

		mem_write_address: OUT integer range 0 to 4095;
		mem_write_enable : OUT std_logic;
		mem_data_in : OUT std_logic_vector(3 downto 0);

		clear_done : OUT std_logic

	);
END ENTITY clear_memory;

ARCHITECTURE bhv of clear_memory IS

  
BEGIN


PROCESS(clk,reset)
  VARIABLE count: integer range 0 to 4096;
BEGIN 
  IF reset = '0' THEN
	count := 0;
	clear_done <= '0';
  ELSIF rising_edge(clk) THEN
  	IF control = "111" THEN
  		mem_write_enable <= '1';
	  
		if count = 4096 THEN
		  count := 0;
		  clear_done <= '1';
		ELSE
		  count := count + 1;
		  clear_done <= '0';
		END IF;
  
	  
	  mem_write_address <= count;
	  mem_data_in <= "0000";

	 ELSE
	 	mem_write_enable <= '0';
		clear_done <= '0';
	 END IF;

  END IF;
END PROCESS;




END bhv;