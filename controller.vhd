LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY controller IS
  PORT (
  		clk: IN std_logic;
        reset: IN std_logic;

        control: OUT std_logic_vector(2 downto 0);

        btn_state: IN std_logic;
        led_state: OUT std_logic_vector(2 downto 0);

        mem_we : OUT std_logic;

        solve_read_request : IN std_logic;
        solve_read_feedback : OUT std_logic;
        solve_write_request : IN std_logic;
        solve_write_feedback : OUT std_logic;
        send_read_request : IN std_logic;
        send_read_feedback : OUT std_logic;
        receive_write_request : IN std_logic;
        receive_write_feedback : OUT std_logic;
        show_read_request : IN std_logic;
        show_read_feedback : OUT std_logic
    );		
END ENTITY controller;

ARCHITECTURE bhv of controller IS
	SIGNAL edge: std_logic;
	SIGNAL btn_state_1: std_logic;
	TYPE states IS (receiving, sending, showing, solving);
	SIGNAL state: states := receiving;

	TYPE mem_access_states IS (none, receive, send, solve_read, solve_write, show);
	SIGNAL mem_access: mem_access_states := none;

BEGIN

	PROCESS(clk,reset)
	BEGIN
		IF reset = '0' THEN

		ELSIF rising_edge(clk) THEN
			btn_state_1 <= NOT btn_state;
			IF edge = '1' THEN
				CASE state IS
					WHEN receiving => state <= sending;
					WHEN sending => state <= showing;
					WHEN showing => state <= solving;
					WHEN solving => state <= receiving;
				END CASE;
			END IF;

			CASE state IS
				WHEN receiving => control <= "001"; led_state <= "001";
				WHEN sending => control <= "010"; led_state <= "010";
				WHEN showing => control <= "100"; led_state <= "100";
				WHEN solving => control <= "011"; led_state <= "011";
			END CASE;
		END IF;
	END PROCESS;
	edge <= NOT btn_state_1 AND NOT btn_state;

	mem:PROCESS(clk,reset)
	BEGIN
		IF reset = '0' THEN
			mem_access <= none;
		ELSIF solve_read_request = '1' THEN
			mem_access <= solve_read;
			mem_we <= '0';
		ELSIF solve_write_request = '1' THEN
			mem_access <= solve_write;
			mem_we <= '1';
		ELSIF send_read_request = '1' THEN
			mem_access <= send;
			mem_we <= '0';
		ELSIF receive_write_request = '1' THEN
			mem_access <= receive;
			mem_we <= '1';
		ELSIF show_read_request = '1' THEN
			mem_access <= show;
			mem_we <= '0';

		END IF;
	END PROCESS;

	PROCESS(mem_access)
	BEGIN
		CASE mem_access IS
					WHEN none =>	solve_read_feedback <= '0';
									solve_write_feedback <= '0';
									send_read_feedback <= '0';
									receive_write_feedback <= '0';
									show_read_feedback <= '0';
					WHEN solve_read =>	solve_read_feedback <= '1';
										solve_write_feedback <= '0';
										send_read_feedback <= '0';
										receive_write_feedback <= '0';
										show_read_feedback <= '0';
					WHEN solve_write =>	solve_read_feedback <= '0';
										solve_write_feedback <= '1';
										send_read_feedback <= '0';
										receive_write_feedback <= '0';
										show_read_feedback <= '0';
					WHEN send =>	solve_read_feedback <= '0';
									solve_write_feedback <= '0';
									send_read_feedback <= '1';
									receive_write_feedback <= '0';
									show_read_feedback <= '0';
					WHEN receive =>	solve_read_feedback <= '0';
									solve_write_feedback <= '0';
									send_read_feedback <= '0';
									receive_write_feedback <= '1';
									show_read_feedback <= '0';
					WHEN show =>	solve_read_feedback <= '0';
									solve_write_feedback <= '0';
									send_read_feedback <= '0';
									receive_write_feedback <= '0';
									show_read_feedback <= '1';
		END CASE;
	END PROCESS;

END bhv;