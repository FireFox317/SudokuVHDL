LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY receive IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

       	control : IN std_logic_vector(2 downto 0);

       	mem_store_address: OUT integer range 0 to 15;
       	mem_write_enable : OUT std_logic;
			
		spi_data_valid : IN std_logic 	
    );		
END ENTITY receive;

ARCHITECTURE bhv of receive IS
	SIGNAL count : integer range 0 to 15 := 0;
	SIGNAL edge: std_logic;
	SIGNAL spi_data_valid_1: std_logic;
BEGIN

	PROCESS(clk,reset)

	BEGIN
		IF reset = '0' THEN
			count <= 0;
		ELSIF rising_edge(clk) THEN
			spi_data_valid_1 <= spi_data_valid;

			IF control = "001" THEN
				-- receiving
				mem_write_enable <= '1';
				IF spi_data_valid = '1' THEN

					-- write to memory
					mem_store_address <= count;
				END IF;

				IF edge = '1' THEN
					IF count = 15 THEN
						count <= 0;
					ELSE 
						count <= count + 1;
					END IF;
				END IF;

			ELSE
				mem_write_enable <= '0';
			END IF;

		END IF;
	END PROCESS;


	edge <= NOT spi_data_valid_1 AND spi_data_valid;


END bhv;