LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY controller IS
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
        sending_done: IN std_logic
    );		
END ENTITY controller;

ARCHITECTURE bhv of controller IS
	SIGNAL btn_state_edge: std_logic;
	SIGNAL btn_state_1: std_logic;

	TYPE states IS (idle, receiving, sending, showing, solving);
	SIGNAL state: states := receiving;

BEGIN

PROCESS(clk,reset)
BEGIN
	IF reset = '0' THEN
		state <= idle;
	ELSIF rising_edge(clk) THEN
		btn_state_1 <= NOT btn_state;

		IF sw_mode = '0' THEN
			-- manual mode
			IF btn_state_edge = '1' THEN
				CASE state IS
					WHEN idle => state <= receiving;
					WHEN receiving => state <= sending;
					WHEN sending => state <= showing;
					WHEN showing => state <= solving;
					WHEN solving => state <= idle;
				END CASE;
			END IF;
		ELSE
			-- auto mode
			CASE state IS
				WHEN idle => 
						IF raspi_receive = '1' THEN 
							state <= receiving;
						END IF;
				WHEN receiving => 
						IF raspi_receive = '0' THEN
							state <= solving;
						END IF;
				WHEN solving => 
						IF solving_done = '1' THEN
							state <= sending;
						END IF;
				WHEN sending => 
						IF sending_done = '1' THEN
							state <= idle;
						END IF;
				WHEN showing => state <= idle;
			END CASE;

		END IF;

		CASE state IS
			WHEN idle => control <= "000"; led_state <= "000"; raspi_send <= '0';
			WHEN receiving => control <= "001"; led_state <= "001"; raspi_send <= '0';
			WHEN sending => control <= "010"; led_state <= "010"; raspi_send <= '1';
			WHEN showing => control <= "100"; led_state <= "100"; raspi_send <= '0';
			WHEN solving => control <= "011"; led_state <= "011"; raspi_send <= '0';
		END CASE;
	END IF;


END PROCESS;


btn_state_edge <= NOT btn_state_1 AND NOT btn_state;



HEX5 <= NOT "1110111" WHEN sw_mode = '1' ELSE NOT "1110110";




END bhv; 