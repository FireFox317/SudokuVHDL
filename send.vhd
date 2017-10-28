LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY send IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

        control : IN std_logic_vector(2 downto 0);

        mem_read_address: OUT integer range 0 to 15;
		  
		spi_write_enable: OUT std_logic;
        spi_data_request: IN std_logic
    );		
END ENTITY send;

ARCHITECTURE bhv of send IS

    SIGNAL count : integer range 0 to 15 := 0;
    SIGNAL count_write: integer range 0 to 3;
    SIGNAL start_count: std_logic;
    SIGNAL spi_data_request_1: std_logic;
    SIGNAL ris_edge: std_logic;
    SIGNAL fal_edge: std_logic;
    
BEGIN


PROCESS(clk,reset)
BEGIN
    IF reset = '0' THEN
        count <= 0;
	ELSIF rising_edge(clk) THEN
        spi_data_request_1 <= spi_data_request;

        IF control = "010" THEN
            IF spi_data_request = '1' THEN
                 -- read from memory
                mem_read_address <= count;
            END IF;


            IF ris_edge = '1' THEN
                IF count = 15 THEN
                    count <= 0;
                ELSE 
                    count <= count + 1;
                END IF;
            END IF;

            IF start_count = '1' THEN
                IF count_write = 3 THEN
                    start_count <= '0';
                    count_write <= 0;
                    spi_write_enable <= '1';
                ELSE
                    count_write <= count_write + 1;
                END IF;
            ELSE
                spi_write_enable <= '0';
            END IF;

            IF fal_edge = '1' THEN
                start_count <= '1';
            END IF;

        END IF;
	
	END IF;
END PROCESS;

ris_edge <= NOT spi_data_request_1 AND spi_data_request;
fal_edge <= NOT spi_data_request AND spi_data_request_1;


END bhv;