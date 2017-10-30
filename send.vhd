LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY send IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

        control : IN std_logic_vector(2 downto 0);

        mem_read_address: OUT integer range 0 to 255;
        mem_data_out: IN std_logic_vector(3 downto 0);
		  
		spi_write_enable: OUT std_logic;
        spi_data_send: OUT std_logic_vector(7 downto 0);
        spi_data_request: IN std_logic
    );		
END ENTITY send;

ARCHITECTURE bhv of send IS


BEGIN

PROCESS(clk,reset)
  
    
BEGIN
    IF reset = '0' THEN
       
	ELSIF rising_edge(clk) THEN
       

        IF control = "010" THEN
           
        END IF;
	
	END IF;
END PROCESS;




END bhv;