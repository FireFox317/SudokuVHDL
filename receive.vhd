LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY receive IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

       	control : IN std_logic_vector(2 downto 0);

       	mem_store_address: OUT integer range 0 to 255;
       	mem_write_enable : OUT std_logic;
       	mem_data_in : OUT std_logic_vector(3 downto 0); 
			
		spi_data_valid : IN std_logic;
		spi_data_receive: IN std_logic_vector(11 downto 0)	
    );		
END ENTITY receive;

ARCHITECTURE bhv of receive IS

BEGIN

	PROCESS(clk,reset)

	BEGIN
		IF reset = '0' THEN
			
		ELSIF rising_edge(clk) THEN

			IF control = "001" THEN
				-- receiving
				mem_write_enable <= '1';
				IF spi_data_valid = '1' THEN
					-- write to memory
					mem_store_address <= to_integer(unsigned(spi_data_receive(7 downto 0)));
					mem_data_in <= spi_data_receive(11 downto 8);
				END IF;
			ELSE
				mem_write_enable <= '0';
			END IF;

		END IF;
	END PROCESS;


END bhv;