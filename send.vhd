LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY send IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

        control : IN std_logic_vector(2 downto 0);

        address_data: OUT integer range 0 to 9;
		  
		spi_write_enable: OUT std_logic;
        spi_data_request: IN std_logic
    );		
END ENTITY send;

ARCHITECTURE bhv of send IS

    SIGNAL count : integer range 0 to 9;
    
BEGIN


PROCESS(clk,reset)
BEGIN
    IF reset = '0' THEN
        count <= 0;
	ELSIF rising_edge(clk) THEN

        IF control = "010" THEN
            count <= count + 1;
            IF spi_data_request = '1' THEN
                 -- write to memory
                address_data <= count;
            END IF;


        END IF;
	
	END IF;
END PROCESS;


END bhv;