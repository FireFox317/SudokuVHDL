LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY sudoku IS
  PORT (
			clk: IN std_logic;
			reset_btn: IN std_logic;
            reset_rpi: IN std_logic;

			spi_data_receive: IN std_logic_vector(7 downto 0);
			spi_data_valid: IN std_logic;

			spi_data_send: OUT std_logic_vector(7 downto 0);
			spi_write_enable: OUT std_logic;
			spi_data_request: IN std_logic;

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0);

            sw_debug: IN std_logic;
            sw_mode: IN std_logic;

            raspi_receive: IN std_logic;
            raspi_send: OUT std_logic;

            sw_location: IN unsigned(7 downto 0);
            HEX0, HEX1, HEX2, HEX5: OUT std_logic_vector(6 downto 0)
    );		
END ENTITY sudoku;

ARCHITECTURE bhv of sudoku IS
    
    COMPONENT send IS
      PORT (
        clk: IN std_logic;
        reset: IN std_logic;

        control : IN std_logic_vector(2 downto 0);

        sw_debug: IN std_logic;

        mem_read_address: OUT integer range 0 to 4095;
        mem_data_out: IN std_logic_vector(3 downto 0);
          
        spi_write_enable: OUT std_logic;
        spi_data_send: OUT std_logic_vector(7 downto 0);
        spi_data_request: IN std_logic;

        sending_done: OUT std_logic
    ); 
    END COMPONENT send;

    COMPONENT receive IS
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
    END COMPONENT receive;


    COMPONENT controller IS
     PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control: OUT std_logic_vector(2 downto 0);

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0);

            sw_mode: IN std_logic;
            raspi_receive : IN std_logic;
            raspi_send: OUT std_logic;

            HEX5: OUT std_logic_vector(6 downto 0);

            solving_done: IN std_logic;
            sending_done: IN std_logic;
            clear_done: IN std_logic
        );     
    END COMPONENT controller;

    COMPONENT memory IS
        PORT(
            clk: IN std_logic;
            data: IN std_logic_vector(3 downto 0);
            write_address: IN integer RANGE 0 to 4095;
            read_address: IN integer RANGE 0 to 4095;
            we: IN std_logic;
            q: OUT std_logic_vector(3 downto 0)
        );
    END COMPONENT memory;

    COMPONENT show IS
      PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            mem_read_address: OUT integer range 0 to 4095;
            mem_data_out: IN std_logic_vector(3 downto 0);

            sw_location: IN unsigned(7 downto 0);

            HEX0, HEX1, HEX2: OUT std_logic_vector(6 downto 0)
        );      
    END COMPONENT show;

    COMPONENT solving IS
        PORT (
            reset           : IN std_logic;
            clk             : IN std_logic;

            control: IN std_logic_vector(2 downto 0);

            mem_read_address: OUT integer range 0 to 4095;
            mem_data_out: IN std_logic_vector(3 downto 0);

            mem_write_address: OUT integer range 0 to 4095;
            mem_write_enable: OUT std_logic;
            mem_data_in : OUT std_logic_vector(3 downto 0);
            
            solving_done: OUT std_logic

            );
    END COMPONENT solving;

    COMPONENT multiplexer IS
  PORT (
        control : IN std_logic_vector(2 downto 0);

        mem_read_address: OUT integer range 0 to 4095;
        show_mem_read_address: IN integer range 0 to 4095;
        send_mem_read_address: IN integer range 0 to 4095;
        solve_mem_read_address: IN integer range 0 to 4095;

        mem_write_address: OUT integer range 0 to 4095;
        solve_mem_write_address: IN integer range 0 to 4095;
        receive_mem_write_address: IN integer range 0 to 4095;
        clear_mem_write_address: IN integer range 0 to 4095;

        mem_write_enable: OUT std_logic;
        solve_mem_write_enable: IN std_logic;
        receive_mem_write_enable: IN std_logic;
        clear_mem_write_enable: IN std_logic;

        mem_data_in: OUT std_logic_vector(3 downto 0);
        receive_mem_data_in: IN std_logic_vector(3 downto 0);
        solve_mem_data_in: IN std_logic_vector(3 downto 0);
        clear_mem_data_in: IN std_logic_vector(3 downto 0)

        );

    END COMPONENT multiplexer;

    COMPONENT clear_memory IS
  PORT(
        clk: IN std_logic;
        reset: IN std_logic;

        control: IN std_logic_vector(2 downto 0);

        mem_write_address: OUT integer range 0 to 4095;
        mem_write_enable : OUT std_logic;
        mem_data_in : OUT std_logic_vector(3 downto 0);

        clear_done : OUT std_logic

    );
END COMPONENT clear_memory;




SIGNAL control_wire: std_logic_vector(2 downto 0);

SIGNAL mem_data_in_wire: std_logic_vector(3 downto 0);
SIGNAL receive_mem_data_in_wire: std_logic_vector(3 downto 0);
SIGNAL solve_mem_data_in_wire: std_logic_vector(3 downto 0);
SIGNAL clear_mem_data_in_wire: std_logic_vector(3 downto 0);

SIGNAL mem_data_out_wire: std_logic_vector(3 downto 0);



SIGNAL mem_read_address_wire: integer range 0 to 4095;
SIGNAL send_mem_read_address_wire: integer range 0 to 4095;
SIGNAL show_mem_read_address_wire: integer range 0 to 4095;
SIGNAL solve_mem_read_address_wire: integer range 0 to 4095;


SIGNAL mem_write_address_wire: integer range 0 to 4095;
SIGNAL solve_mem_write_address_wire: integer range 0 to 4095;
SIGNAL receive_mem_write_address_wire: integer range 0 to 4095;
SIGNAL clear_mem_write_address_wire: integer range 0 to 4095;


SIGNAL mem_write_enable_wire: std_logic;
SIGNAL solve_mem_write_enable_wire: std_logic;
SIGNAL receive_mem_write_enable_wire: std_logic;
SIGNAL clear_mem_write_enable_wire: std_logic;

SIGNAL solving_done_wire: std_logic;
SIGNAL sending_done_wire: std_logic;
SIGNAL clear_done_wire: std_logic;

SIGNAL reset: std_logic;




 
BEGIN

    solv: solving PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => solve_mem_read_address_wire,
        mem_data_out => mem_data_out_wire,

        mem_write_address => solve_mem_write_address_wire,
        mem_write_enable => solve_mem_write_enable_wire,
        mem_data_in => solve_mem_data_in_wire,

        solving_done => solving_done_wire
        );   



    s: send PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => send_mem_read_address_wire,
        mem_data_out => mem_data_out_wire,
        sw_debug => sw_debug,
        spi_write_enable => spi_write_enable,
        spi_data_send => spi_data_send,
        spi_data_request => spi_data_request,
        sending_done => sending_done_wire
        );


    d_r: receive PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_write_address => receive_mem_write_address_wire,
        mem_write_enable => receive_mem_write_enable_wire,
        mem_data_in => receive_mem_data_in_wire,
        spi_data_valid => spi_data_valid,
        spi_data_receive => spi_data_receive
        );

    cont : controller PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        btn_state => btn_state,
        led_state => led_state,
        sw_mode => sw_mode,
        raspi_send => raspi_send,
        raspi_receive => raspi_receive,
        HEX5 => HEX5,
        solving_done => solving_done_wire,
        sending_done => sending_done_wire,
        clear_done => clear_done_wire
        );

    mem: memory PORT MAP(
        clk => clk,
        data => mem_data_in_wire,
        write_address => mem_write_address_wire,
        read_address => mem_read_address_wire,
        we => mem_write_enable_wire,
        q => mem_data_out_wire
        );

    cl_mem : clear_memory PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_write_address => clear_mem_write_address_wire,
        mem_write_enable => clear_mem_write_enable_wire,
        mem_data_in => clear_mem_data_in_wire,
        clear_done => clear_done_wire
        );


    sh: show PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => show_mem_read_address_wire,
        mem_data_out => mem_data_out_wire,
        sw_location => sw_location,
        HEX0 => HEX0,
        HEX1 => HEX1,
        HEX2 => HEX2
        );

    mul: multiplexer PORT MAP(
        control => control_wire,

        mem_read_address => mem_read_address_wire,
        show_mem_read_address =>  show_mem_read_address_wire,
        send_mem_read_address =>  send_mem_read_address_wire,
        solve_mem_read_address =>  solve_mem_read_address_wire,

        mem_write_address => mem_write_address_wire,
        solve_mem_write_address => solve_mem_write_address_wire,
        receive_mem_write_address => receive_mem_write_address_wire,
        clear_mem_write_address => clear_mem_write_address_wire,

        mem_write_enable => mem_write_enable_wire,
        solve_mem_write_enable => solve_mem_write_enable_wire,
        receive_mem_write_enable => receive_mem_write_enable_wire,
        clear_mem_write_enable => clear_mem_write_enable_wire,

        mem_data_in => mem_data_in_wire,
        receive_mem_data_in =>  receive_mem_data_in_wire,
        solve_mem_data_in =>  solve_mem_data_in_wire,
        clear_mem_data_in => clear_mem_data_in_wire


        );

reset <= reset_btn AND reset_rpi;


END bhv;