LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY signed_accumulator IS
    GENERIC(RSTDEF: std_logic := '0';
            INPUT_LEN:  integer := 36;
            OUTPUT_LEN: integer := 44);
    PORT(rst:   IN  std_logic;
         clk:   IN  std_logic;
         din:   IN  std_logic_vector(INPUT_LEN-1 DOWNTO 0);
         dout:  OUT std_logic_vector(OUTPUT_LEN-1 DOWNTO 0));
END signed_accumulator;

ARCHITECTURE behavioral OF signed_accumulator IS
    --SIGNAL acc: integer := 0;
	 SIGNAL acc: signed(OUTPUT_LEN-1 DOWNTO 0);
BEGIN
    main: PROCESS(rst, clk)
    BEGIN
        IF rst = '1' THEN
            acc <= (others => '0');
            dout <= conv_std_logic_vector(acc, OUTPUT_LEN);
        ELSIF clk'EVENT AND clk = '1' THEN
            --acc <= acc + conv_integer(signed(din));
			acc <= acc + signed(din);
            dout <= conv_std_logic_vector(acc + signed(din), OUTPUT_LEN);
        END IF;
    END PROCESS;
END behavioral;
