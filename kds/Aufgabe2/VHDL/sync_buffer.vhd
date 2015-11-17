LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_buffer IS
   GENERIC(RSTDEF:  std_logic := '1');
   PORT(rst:    IN  std_logic;  -- reset, RSTDEF active
        clk:    IN  std_logic;  -- clock, rising edge
        en:     IN  std_logic;  -- enable, high active
        swrst:  IN  std_logic;  -- software reset, RSTDEF active
        din:    IN  std_logic;  -- data bit, input
        dout:   OUT std_logic;  -- data bit, output
        redge:  OUT std_logic;  -- rising  edge on din detected
        fedge:  OUT std_logic); -- falling edge on din detected
END sync_buffer;

ARCHITECTURE behavioral OF sync_buffer IS

	CONSTANT N: integer := 32;

	SIGNAL q1: std_logic;
	SIGNAL automaton_input: std_logic;
	SIGNAL automaton_output: std_logic;
	SIGNAL cnt: integer RANGE 0 TO N - 1;
	TYPE STATE_TYPE IS (s0, s1);
	SIGNAL state: STATE_TYPE;
	SIGNAL qout: std_logic;
BEGIN

	flip_flops: PROCESS(clk, rst)
	BEGIN
		IF rst = RSTDEF OR swrst = RSTDEF THEN
			qout <= '0';
			automaton_input <= '0';
			q1 <= '0';
		ELSIF clk'EVENT AND clk = '1' THEN
			qout <= automaton_output;
			automaton_input <= q1;
			q1 <= din;
		END IF;
	END PROCESS;

	automaton: PROCESS(clk, rst)
	BEGIN
		IF rst = RSTDEF OR swrst = RSTDEF THEN
			automaton_output <= '0';
		ELSIF en = '1' AND clk'EVENT AND clk = '1' THEN
			-- TODO: optimize
			CASE state IS
				WHEN s0 =>
					IF automaton_input = '0' THEN
						IF cnt = 0 THEN
							--cnt <= cnt;
							--state <= s0;
						ELSIF cnt > 0 THEN
							cnt <= cnt - 1;
							--state <= s0;
						END IF;
					ELSIF automaton_input = '1' THEN
						IF cnt < N - 1 THEN
							cnt <= cnt + 1;
							--state <= s0;
						ELSIF cnt = N - 1 THEN
							--cnt <= cnt;
							state <= s1;
						END IF;
					END IF;
					automaton_output <= '0';
				WHEN s1 =>
					IF automaton_input = '0' THEN
						IF cnt = 0 THEN
							--cnt <= cnt;
							state <= s0;
						ELSIF cnt > 0 THEN
							cnt <= cnt - 1;
							--state <= s1;
						END IF;
					ELSIF automaton_input = '1' THEN
						IF cnt < N - 1 THEN
							cnt <= cnt + 1;
							--state <= s1;
						ELSIF cnt = N - 1 THEN
							--cnt <= cnt;
							--state <= s1;
						END IF;
					END IF;
					automaton_output <= '1';
			END CASE;
		END IF;
	END PROCESS;

	redge <= (NOT automaton_output) AND qout;
	fedge <= (NOT qout) AND automaton_output;

	dout <= qout;

END behavioral;
