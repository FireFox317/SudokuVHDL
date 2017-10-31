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
     COMPONENT controller IS
     PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control: OUT std_logic_vector(2 downto 0);

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0);

            mem_we : OUT std_logic

            
            
            
            
            
            
            
            
            
            
        );     
    END COMPONENT controller;

    COMPONENT memory IS
        PORT(
            clk: IN std_logic;
            data: IN std_logic_vector(3 downto 0);
            write_address: IN unsigned(7 downto 0);
            read_address: IN unsigned(7 downto 0);
            we: IN std_logic;
            q: OUT std_logic_vector(3 downto 0)
        );
    END COMPONENT memory;

        COMPONENT send IS
          PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            mem_read_address: INOUT unsigned(7 downto 0);
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

                mem_write_address: INOUT unsigned(7 downto 0);
                mem_data_in : INOUT std_logic_vector(3 downto 0);
                
                
                    
                spi_data_valid : IN std_logic;
                spi_data_receive: IN std_logic_vector(7 downto 0)     
            );           
    END COMPONENT receive;

    COMPONENT solving IS
    PORT (
        reset           : IN std_logic;
        clk             : IN std_logic;

        control: IN std_logic_vector(2 downto 0);

        mem_read_address: INOUT unsigned(7 downto 0);
        mem_data_out: IN std_logic_vector(3 downto 0);
        mem_write_address: INOUT unsigned(7 downto 0);
        mem_data_in : INOUT std_logic_vector(3 downto 0)

        
        
        
        

        );
    END COMPONENT solving;

    COMPONENT show IS
      PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            mem_read_address: INOUT unsigned(7 downto 0);
            mem_data_out: IN std_logic_vector(3 downto 0);
            
            

            sw_location: IN unsigned(7 downto 0);

            HEX0: OUT std_logic_vector(6 downto 0)
        );      
    END COMPONENT show;

SIGNAL control_wire: std_logic_vector(2 downto 0);

SIGNAL write_address_bus : unsigned(7 downto 0);
SIGNAL data_bus : std_logic_vector(3 downto 0);
SIGNAL read_address_bus : unsigned(7 downto 0);
SIGNAL q_bus : std_logic_vector(3 downto 0);

SIGNAL we_wire: std_logic;













 
BEGIN
    cont : controller PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        btn_state => btn_state,
        led_state => led_state,

        mem_we => we_wire

        
        
        
        
        
        
        
        
        
        
        );

    mem: memory PORT MAP(
        clk => clk,
        data => data_bus,
        write_address => write_address_bus,
        read_address => read_address_bus,
        we => we_wire,
        q => q_bus
        );

    solv: solving PORT MAP(
        clk => clk,
        reset => reset,

        control => control_wire,

        mem_read_address => read_address_bus,
        mem_data_out => q_bus,
        mem_write_address => write_address_bus,
        mem_data_in => data_bus

        
        
        
        
        );   



    s: send PORT MAP(
        clk => clk,
        reset => reset,

        control => control_wire,

        mem_read_address => read_address_bus,
        mem_data_out => q_bus,
        
        

        spi_write_enable => spi_write_enable,
        spi_data_send => spi_data_send,
        spi_data_request => spi_data_request
        );


    d_r: receive PORT MAP(
        clk => clk,
        reset => reset,

        control => control_wire,

        mem_write_address => write_address_bus,
        mem_data_in => data_bus,
        
        

        spi_data_valid => spi_data_valid,
        spi_data_receive => spi_data_receive
        );

    sh: show PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => read_address_bus,
        mem_data_out => q_bus,
        
        
        sw_location => sw_location,
        HEX0 => HEX0
        );





END bhv;