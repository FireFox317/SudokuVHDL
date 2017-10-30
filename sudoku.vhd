LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY sudoku IS
  PORT (
			clk: IN std_logic;
			reset: IN std_logic;

			spi_data_receive: IN std_logic_vector(7 downto 0);
			spi_data_valid: IN std_logic;

			spi_data_send: OUT std_logic_vector(7 downto 0);
			spi_write_enable: OUT std_logic;
			spi_data_request: IN std_logic;

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0);

            sw_location: IN unsigned(7 downto 0);
            HEX0: OUT std_logic_vector(6 downto 0)
    );		
END ENTITY sudoku;

ARCHITECTURE bhv of sudoku IS

    COMPONENT send IS
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
    END COMPONENT send;

    COMPONENT receive IS
          PORT (
                clk: IN std_logic;
                reset: IN std_logic;

                control : IN std_logic_vector(2 downto 0);

                mem_store_address: OUT integer range 0 to 255;
                mem_write_enable : OUT std_logic;
                mem_data_in : OUT std_logic_vector(3 downto 0); 
                    
                spi_data_valid : IN std_logic;
                spi_data_receive: IN std_logic_vector(7 downto 0)     
            );           
    END COMPONENT receive;


    COMPONENT controller IS
     PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control: OUT std_logic_vector(2 downto 0);

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0)
        );     
    END COMPONENT controller;

    COMPONENT memory IS
        PORT(
            clk: IN std_logic;
            data: IN std_logic_vector(3 downto 0);
            write_address: IN integer RANGE 0 to 255;
            read_address: IN integer RANGE 0 to 255;
            we: IN std_logic;
            q: OUT std_logic_vector(3 downto 0)
        );
    END COMPONENT memory;

    COMPONENT show IS
      PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            mem_read_address: OUT integer range 0 to 255;
            mem_data_out: IN std_logic_vector(3 downto 0);

            sw_location: IN unsigned(7 downto 0);

            HEX0: OUT std_logic_vector(6 downto 0)
        );      
    END COMPONENT show;

SIGNAL control_wire: std_logic_vector(2 downto 0);

SIGNAL mem_data_in_wire: std_logic_vector(3 downto 0);

SIGNAL mem_data_out_wire: std_logic_vector(3 downto 0);

SIGNAL mem_read_address_wire: integer range 0 to 255;
SIGNAL send_mem_read_address_wire: integer range 0 to 255;
SIGNAL show_mem_read_address_wire: integer range 0 to 255;


SIGNAL mem_store_address_wire: integer range 0 to 255;

SIGNAL mem_write_enable_wire: std_logic;



 
BEGIN

    d_s: send PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => send_mem_read_address_wire,
        mem_data_out => mem_data_out_wire,
        spi_write_enable => spi_write_enable,
        spi_data_send => spi_data_send,
        spi_data_request => spi_data_request
        );

    d_r: receive PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_store_address => mem_store_address_wire,
        mem_write_enable => mem_write_enable_wire,
        mem_data_in => mem_data_in_wire,
        spi_data_valid => spi_data_valid,
        spi_data_receive => spi_data_receive
        );

    cont : controller PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        btn_state => btn_state,
        led_state => led_state
        );

    mem: memory PORT MAP(
        clk => clk,
        data => mem_data_in_wire,
        write_address => mem_store_address_wire,
        read_address => mem_read_address_wire,
        we => mem_write_enable_wire,
        q => mem_data_out_wire
        );

    sh: show PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => show_mem_read_address_wire,
        mem_data_out => mem_data_out_wire,
        sw_location => sw_location,
        HEX0 => HEX0
        );

mem_read_address_wire <= show_mem_read_address_wire WHEN control_wire = "100" ELSE send_mem_read_address_wire;

END bhv;