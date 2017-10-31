LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY multiplexer IS
  PORT (
       	control : IN std_logic_vector(2 downto 0);

       	mem_read_address: OUT integer range 0 to 255;
       	show_mem_read_address: IN integer range 0 to 255;
       	send_mem_read_address: IN integer range 0 to 255;
       	solve_mem_read_address: IN integer range 0 to 255;

       	mem_store_address: OUT integer range 0 to 255;
       	solve_mem_store_address: IN integer range 0 to 255;
       	receive_mem_store_address: IN integer range 0 to 255;

       	mem_write_enable: OUT std_logic;
       	solve_mem_write_enable: IN std_logic;
       	receive_mem_write_enable: IN std_logic;

       	mem_data_in: OUT std_logic_vector(3 downto 0);
       	receive_mem_data_in: IN std_logic_vector(3 downto 0);
       	solve_mem_data_in: IN std_logic_vector(3 downto 0)

       	);

END ENTITY multiplexer;

ARCHITECTURE bhv of multiplexer IS



BEGIN


mem_read_address <= show_mem_read_address WHEN control = "100" 
                        ELSE solve_mem_read_address WHEN control = "011"  
                        ELSE send_mem_read_address;

mem_data_in <= solve_mem_data_in WHEN control = "011" 
                    ELSE receive_mem_data_in;


mem_store_address <= solve_mem_store_address WHEN control = "011"  
                        ELSE receive_mem_store_address;

mem_write_enable <= solve_mem_write_enable WHEN control = "011" 
                            ELSE receive_mem_write_enable;

END bhv;