LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY send IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

        control : IN std_logic_vector(2 downto 0);

        mem_read_address: INOUT unsigned(7 downto 0);
        mem_data_out: IN std_logic_vector(3 downto 0);
        --mem_read_request : OUT std_logic;
        --mem_read_feedback : IN std_logic;
		  
		spi_write_enable: OUT std_logic;
        spi_data_send: OUT std_logic_vector(7 downto 0);
        spi_data_request: IN std_logic
    );		
END ENTITY send;

ARCHITECTURE bhv of send IS

    SIGNAL stage : std_logic := '0';
    SIGNAL spi_data_request_1 : std_logic;
    SIGNAL fal_edge: std_logic;
    SIGNAL location: unsigned(7 downto 0);
    SIGNAL tmp_read_address : unsigned(7 downto 0);


BEGIN

PROCESS(clk,reset)
    VARIABLE x: integer range 0 to 8 := 0;
    VARIABLE y: integer range 0 to 8 := 0;
    
BEGIN
    IF reset = '0' THEN

	ELSIF rising_edge(clk) THEN
       spi_data_request_1 <= spi_data_request;

        IF control = "010" THEN
            IF spi_data_request = '1' THEN
                location <= to_unsigned(x,4) & to_unsigned(y,4);

                tmp_read_address <= location;
                IF stage = '0' THEN
                    spi_data_send <= std_logic_vector(location);
                ELSE
                    spi_data_send <= mem_data_out & "0000";
                END IF;
            END IF;

            IF fal_edge = '1' THEN
                spi_write_enable <= '1';
                IF x = 8 THEN
                    x := 0;
                    y := y + 1;
                ELSE
                    x := x + 1;
                END IF;

                IF y = 8 THEN
                    y := 0;
                END IF;

                IF stage = '1' THEN
                    stage <= '0';
                ELSE
                    stage <= '1';
                END IF;
            ELSE
                spi_write_enable <= '0';
            END IF;
        ELSE
            mem_read_address <= "ZZZZZZZZ";
        END IF;
	END IF;
END PROCESS;

fal_edge <= NOT spi_data_request AND spi_data_request_1;
    
    mem_read_address <= "ZZZZZZZZ" WHEN control /= "010" 
        ELSE tmp_read_address;

END bhv;


