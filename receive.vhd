LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY receive IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

       	control : IN std_logic_vector(2 downto 0);

       	mem_write_address: INOUT unsigned(7 downto 0);
       	mem_data_in : INOUT std_logic_vector(3 downto 0);
       	--mem_write_request : OUT std_logic;
       	--mem_write_feedback : IN std_logic;
		
		spi_data_valid : IN std_logic;
		spi_data_receive: IN std_logic_vector(7 downto 0)	
    );		
END ENTITY receive;

ARCHITECTURE bhv of receive IS

	SIGNAL count: std_logic := '0';
	SIGNAL spi_data_valid_1 : std_logic;
	SIGNAL edge: std_logic;
	SIGNAL tmp_write_address : unsigned(7 downto 0);
	SIGNAL tmp_data_in : std_logic_vector(3 downto 0);

BEGIN

	PROCESS(clk,reset)

	BEGIN
		IF reset = '0' THEN

		ELSIF rising_edge(clk) THEN
			spi_data_valid_1 <= spi_data_valid;
			IF control = "001" THEN
				IF spi_data_valid = '1' THEN
					IF count = '0' THEN
						tmp_write_address <= unsigned(spi_data_receive);
						
					ELSE
						tmp_data_in <= spi_data_receive(3 downto 0);
						
					END IF;
				END IF;

				IF edge = '1' THEN
					IF count = '0' THEN
						count <= '1';
					ELSE
						count <= '0';
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	edge <= NOT spi_data_valid_1 AND spi_data_valid;

	mem_write_address <= "ZZZZZZZZ" WHEN control /= "001" 
		ELSE tmp_write_address;
	mem_data_in <= "ZZZZ" WHEN control /= "001" 
		ELSE tmp_data_in;
END bhv;