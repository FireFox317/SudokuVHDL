LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY controller IS
  PORT (
  		clk: IN std_logic;
        reset: IN std_logic;

        control: OUT std_logic_vector(2 downto 0);

        SW: IN std_logic_vector(3 downto 0)
    );		
END ENTITY controller;

ARCHITECTURE bhv of controller IS



BEGIN

PROCESS(clk,reset)
BEGIN
	IF reset = '0' THEN


	ELSIF rising_edge(clk) THEN
		control <= "001";
	END IF;


END PROCESS;







END bhv;