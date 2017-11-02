LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE sudoku_package IS
	PROCEDURE wcandboard(
		x: IN natural; y: IN natural; i: IN natural; d: IN natural;
		tmp_write_address : OUT unsigned(11 downto 0);
		tmp_data_in : OUT unsigned(3 downto 0)
	);
	PROCEDURE address(x: IN natural; y: IN natural; i: IN natural; tmp_read_address : OUT unsigned(11 downto 0));
	FUNCTION candboard(x: IN natural; y: IN natural; i: IN natural) RETURN natural;
END sudoku_package;

PACKAGE BODY sudoku_package IS
	PROCEDURE wcandboard(x: IN natural; y: IN natural; i: IN natural; d: IN natural;
						tmp_write_address : OUT unsigned(11 downto 0);
						tmp_data_in : OUT unsigned(3 downto 0)) IS-- write to memory
	BEGIN
		tmp_write_address := to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4);
		tmp_data_in := to_unsigned(d,4);
	END wcandboard;

	PROCEDURE address(x: IN natural; y: IN natural; i: IN natural; tmp_read_address : OUT unsigned(11 downto 0)) IS
	BEGIN
		tmp_read_address := to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4);
	END address;

	FUNCTION candboard(x: IN natural; y: IN natural; i: IN natural) RETURN natural IS-- read from memory
	BEGIN
		address(x,y,i);
		return to_integer(unsigned(mem_data_out));
	END candboard;

END sudoku_package;


--FUNCTION candboard(x: IN natural; y: IN natural; i: IN natural; tmp_read_address : OUT unsigned(11 downto 0)) RETURN natural IS-- read from memory
--	BEGIN
--		tmp_read_address <= to_unsigned(i,4) & to_unsigned(y-1,4) & to_unsigned(x-1,4);
--		return to_integer(unsigned(mem_data_out));
--	END candboard;