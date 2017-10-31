LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY memory IS
  PORT(
        clk: IN std_logic;
        data: IN std_logic_vector(3 downto 0);
        write_address: IN unsigned(7 downto 0);
        read_address: IN unsigned(7 downto 0);
        we: IN std_logic;
        q: OUT std_logic_vector(3 downto 0)
    );
END ENTITY memory;

ARCHITECTURE bhv of memory IS

  TYPE mem IS ARRAY(0 TO 255) OF std_logic_vector(3 downto 0);
  SIGNAL ram_block : mem;
BEGIN


PROCESS(clk)
BEGIN
  IF rising_edge(clk) THEN

    IF we = '1' THEN
      ram_block(to_integer(write_address)) <= data;
    END IF;

    q <= ram_block(to_integer(read_address));


  END IF;
END PROCESS;




END bhv;