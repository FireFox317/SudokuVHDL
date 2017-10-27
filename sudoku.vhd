LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY sudoku IS
  PORT (
			clk: IN std_logic;
			reset: IN std_logic;

			spi_data_receive: IN std_logic_vector(11 downto 0);
			spi_data_valid: IN std_logic;

			spi_data_send: OUT std_logic_vector(11 downto 0);
			spi_write_enable: OUT std_logic;
			spi_data_request: IN std_logic
    );		
END ENTITY sudoku;

ARCHITECTURE bhv of sudoku IS

    COMPONENT send IS
      PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            address_data: OUT integer range 0 to 9;
              
            spi_write_enable: OUT std_logic;
            spi_data_request: IN std_logic
        );   
    END COMPONENT send;

    COMPONENT receive IS
          PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            data_store_address: OUT integer range 0 to 9;
                
            spi_data_valid : IN std_logic;
            memory_we : OUT std_logic
        );            
    END COMPONENT receive;

    COMPONENT controller IS
     PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control: OUT std_logic_vector(2 downto 0)
        );     
    END COMPONENT controller;

    COMPONENT memory IS
      PORT(
            clk: IN std_logic;
            data: IN std_logic_vector(11 downto 0);
            write_address: IN integer RANGE 0 to 9;
            read_address: IN integer RANGE 0 to 9;
            we: IN std_logic;
            q: OUT std_logic_vector(11 downto 0)
        );
    END COMPONENT memory;

SIGNAL control_wire: std_logic_vector(2 downto 0);

SIGNAL data_memory_wire: std_logic_vector(11 downto 0);
SIGNAL address_data_wire: integer range 0 to 9;
SIGNAL data_store_wire: std_logic_vector(11 downto 0);
SIGNAL data_store_address_wire: integer range 0 to 9;
SIGNAL memory_we_wire: std_logic;


 
BEGIN

    d_s: send PORT MAP(
        clk => clk,
        reset => reset,
        spi_write_enable => spi_write_enable,
        control => control_wire,
        address_data => address_data_wire,
        spi_data_request => spi_data_request
        );

    d_r: receive PORT MAP(
        clk => clk,
        reset => reset,
        spi_data_valid => spi_data_valid,
        control => control_wire,
        data_store_address => data_store_address_wire,
        memory_we => memory_we_wire
        );

    cont : controller PORT MAP(
        clk => clk,
        reset => reset,

        control => control_wire
        );

    mem: memory PORT MAP(
        clk => clk,
        data => spi_data_receive,
        write_address => data_store_address_wire,
        read_address => address_data_wire,
        we => memory_we_wire,
        q => spi_data_send
        );










END bhv;