LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY receive IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

       	control : IN std_logic_vector(2 downto 0);

       	mem_write_address: OUT integer range 0 to 4095;
       	mem_write_enable : OUT std_logic;
       	mem_data_in : OUT std_logic_vector(3 downto 0); 
			
		spi_data_valid : IN std_logic;
		spi_data_receive: IN std_logic_vector(7 downto 0)	
    );		
END ENTITY receive;

ARCHITECTURE bhv of receive IS

	SIGNAL stage: std_logic := '0';
	SIGNAL spi_data_valid_1 : std_logic;
	SIGNAL edge: std_logic;

BEGIN

	PROCESS(clk,reset)
		VARIABLE count: integer range 0 to 4095;
	BEGIN
		IF reset = '0' THEN
			stage <= '0';
			

			--if rising_edge(clk) THEN
			--	if count = 4096 THEN
			--		count := 0;
			--	ELSE
			--		count := count + 1;
			--	END IF;
			--END IF;
			
			--mem_write_address <= count;
			--mem_data_in <= "0000";

		ELSIF rising_edge(clk) THEN
			spi_data_valid_1 <= spi_data_valid;

			IF control = "001" THEN
				-- receiving
				mem_write_enable <= '1';
				IF spi_data_valid = '1' THEN
					IF stage = '0' THEN
						mem_write_address <= to_integer(unsigned("0000" & spi_data_receive));
						
					ELSE
						mem_data_in <= spi_data_receive(3 downto 0);
						
					END IF;
	
				END IF;

				IF edge = '1' THEN
					IF stage = '0' THEN
						stage <= '1';
					ELSE
						stage <= '0';
					END IF;
				END IF;

			ELSIF control = "000" THEN
				mem_write_enable <= '1';
			ELSE
				mem_write_enable <= '0';
			END IF;

		END IF;
	END PROCESS;

edge <= NOT spi_data_valid AND spi_data_valid_1;

END bhv;