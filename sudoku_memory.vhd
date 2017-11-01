LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY sudoku_memory IS
  PORT(
        clk: IN std_logic;
        data: IN std_logic_vector(3 downto 0);
        write_address: IN unsigned(11 downto 0);
        read_address: IN unsigned(11 downto 0);
        we: IN std_logic;
        q: OUT std_logic_vector(3 downto 0)
    );
END ENTITY sudoku_memory;

ARCHITECTURE bhv of sudoku_memory IS

  TYPE mem IS ARRAY(0 TO 4096) OF std_logic_vector(3 downto 0);
  SIGNAL ram_block : mem;
BEGIN


PROCESS(clk)
BEGIN
  IF rising_edge(clk) THEN

    IF we = '1' THEN
      ram_block(write_address) <= data;
    END IF;

    q <= ram_block(read_address);


  END IF;
END PROCESS;




END bhv;