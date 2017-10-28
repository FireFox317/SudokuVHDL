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
			spi_data_request: IN std_logic;

            sw_address: IN unsigned(3 downto 0);

            btn_state: IN std_logic;
            led_state: OUT std_logic_vector(2 downto 0);

            HEX0, HEX1, HEX2: OUT std_logic_vector(6 downto 0)
    );		
END ENTITY sudoku;

ARCHITECTURE bhv of sudoku IS

    FUNCTION hex2display (n:std_logic_vector(3 DOWNTO 0)) RETURN std_logic_vector IS
        VARIABLE res : std_logic_vector(6 DOWNTO 0);
      BEGIN
        CASE n IS          --        gfedcba; low active
            WHEN "0000" => RETURN NOT "0111111";
            WHEN "0001" => RETURN NOT "0000110";
            WHEN "0010" => RETURN NOT "1011011";
            WHEN "0011" => RETURN NOT "1001111";
            WHEN "0100" => RETURN NOT "1100110";
            WHEN "0101" => RETURN NOT "1101101";
            WHEN "0110" => RETURN NOT "1111101";
            WHEN "0111" => RETURN NOT "0000111";
            WHEN "1000" => RETURN NOT "1111111";
            WHEN "1001" => RETURN NOT "1101111";
            WHEN "1010" => RETURN NOT "1110111";
            WHEN "1011" => RETURN NOT "1111100";
            WHEN "1100" => RETURN NOT "0111001";
            WHEN "1101" => RETURN NOT "1011110";
            WHEN "1110" => RETURN NOT "1111001";
            WHEN OTHERS => RETURN NOT "1110001";            
        END CASE;
      END hex2display;

    COMPONENT send IS
      PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            mem_read_address: OUT integer range 0 to 15;
              
            spi_write_enable: OUT std_logic;
            spi_data_request: IN std_logic
        );      
    END COMPONENT send;

    COMPONENT receive IS
        PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            mem_store_address: OUT integer range 0 to 15;
            mem_write_enable : OUT std_logic;
                
            spi_data_valid : IN std_logic   
        );             
    END COMPONENT receive;

    COMPONENT show IS
      PORT (
            clk: IN std_logic;
            reset: IN std_logic;

            control : IN std_logic_vector(2 downto 0);

            sw_address: IN unsigned(3 downto 0);

            mem_read_address: OUT integer range 0 to 15 
        );      
    END COMPONENT show;

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
            data: IN std_logic_vector(11 downto 0);
            write_address: IN integer RANGE 0 to 9;
            read_address: IN integer RANGE 0 to 9;
            we: IN std_logic;
            q: OUT std_logic_vector(11 downto 0)
        );
    END COMPONENT memory;

SIGNAL control_wire: std_logic_vector(2 downto 0);

SIGNAL send_mem_read_address_wire: integer range 0 to 15;
SIGNAL show_mem_read_address_wire: integer range 0 to 15;

SIGNAL mem_store_address_wire: integer range 0 to 15;
SIGNAL mem_write_enable_wire: std_logic;
SIGNAL mem_read_address_wire: integer range 0 to 15;

SIGNAL mem_output_data_wire: std_logic_vector(11 downto 0);

 
BEGIN

    d_s: send PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_read_address => send_mem_read_address_wire,
        spi_write_enable => spi_write_enable,
        spi_data_request => spi_data_request
        );

    d_r: receive PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        mem_store_address => mem_store_address_wire,
        mem_write_enable => mem_write_enable_wire,
        spi_data_valid => spi_data_valid
        );

    sh: show PORT MAP(
        clk => clk,
        reset => reset,
        control => control_wire,
        sw_address => sw_address,
        mem_read_address => show_mem_read_address_wire
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
        data => spi_data_receive,
        write_address => mem_store_address_wire,
        read_address => mem_read_address_wire,
        we => mem_write_enable_wire,
        q => mem_output_data_wire
        );

mem_read_address_wire <= show_mem_read_address_wire WHEN control_wire = "100" ELSE send_mem_read_address_wire;

spi_data_send <= mem_output_data_wire;
HEX0 <= hex2display(mem_output_data_wire(3 downto 0));
HEX1 <= hex2display(mem_output_data_wire(7 downto 4));
HEX2 <= hex2display(mem_output_data_wire(11 downto 8));







END bhv;