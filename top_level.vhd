LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY top_level IS
  PORT (
        reset: IN std_logic;
        clk : IN std_logic;

        sclk : IN std_logic;
        ss_n : IN std_logic;
        mosi : IN std_logic;
        miso : OUT std_logic
    );		
END ENTITY top_level;

ARCHITECTURE bhv of top_level IS

    COMPONENT sudoku IS
        PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            spi_data_receive: IN std_logic_vector(11 downto 0);
            spi_data_valid: IN std_logic;

            spi_data_send: OUT std_logic_vector(11 downto 0);
            spi_write_enable: OUT std_logic;
            spi_data_request: IN std_logic
        );
    END COMPONENT sudoku;

    COMPONENT spi IS
        PORT (
			  clk : IN std_logic;

			  sclk : IN std_logic;
			  ss_n : IN std_logic;
			  mosi : IN std_logic;
			  miso : OUT std_logic;

			  spi_data_receive: OUT std_logic_vector(11 downto 0);
			  spi_data_send: IN std_logic_vector(11 downto 0);

			  spi_data_valid : OUT std_logic;
			  spi_write_enable : IN std_logic;

			  spi_data_request: OUT std_logic
		 );  
    END COMPONENT spi;

    SIGNAL spi_data_receive_wire: std_logic_vector(11 downto 0);
    SIGNAL spi_data_send_wire: std_logic_vector(11 downto 0);

    SIGNAL spi_data_valid_wire: std_logic;
    SIGNAL spi_write_enable_wire: std_logic;
    SIGNAL spi_data_request_wire: std_logic;


BEGIN

    sud: sudoku PORT MAP(
        clk => clk,
        reset => reset,

        spi_data_receive => spi_data_receive_wire,
        spi_data_send => spi_data_send_wire,

        spi_data_valid => spi_data_valid_wire,

        spi_write_enable => spi_write_enable_wire,
        spi_data_request => spi_data_request_wire
        );

    sp: spi PORT MAP(
        clk => clk,
		  
        sclk => sclk,
        ss_n => ss_n,
        mosi => mosi,
        miso => miso,
		  
        spi_data_receive => spi_data_receive_wire,
        spi_data_send => spi_data_send_wire,

        spi_data_valid => spi_data_valid_wire,
        spi_write_enable => spi_write_enable_wire,
        spi_data_request => spi_data_request_wire
        );






END bhv;