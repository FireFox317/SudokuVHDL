LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY show IS
  PORT (
		clk: IN std_logic;
        reset: IN std_logic;

       	control : IN std_logic_vector(2 downto 0);

       	mem_read_address: OUT integer range 0 to 4095;
       	mem_data_out: IN std_logic_vector(3 downto 0);

       	sw_location: IN unsigned(7 downto 0);

       	HEX0, HEX1, HEX2: OUT std_logic_vector(6 downto 0)
    );		
END ENTITY show;

ARCHITECTURE bhv of show IS

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

BEGIN

	PROCESS(clk,reset)

	BEGIN
		IF reset = '0' THEN
			HEX0 <= NOT "1000000";
			HEX1 <= NOT "1000000";
			HEX2 <= NOT "1000000";
		ELSIF rising_edge(clk) THEN

			IF control = "100" THEN
				mem_read_address <= to_integer("0000" & sw_location(3 DOWNTO 0) & sw_location(7 downto 4));
				HEX0 <= hex2display(mem_data_out);
				HEX1 <= hex2display(std_logic_vector(sw_location(3 downto 0)));
				HEX2 <= hex2display(std_logic_vector(sw_location(7 downto 4)));

			ELSE
				HEX0 <= NOT "0000000";
				HEX1 <= NOT "0000000";
				HEX2 <= NOT "0000000";
			END IF;

		END IF;
	END PROCESS;


END bhv;