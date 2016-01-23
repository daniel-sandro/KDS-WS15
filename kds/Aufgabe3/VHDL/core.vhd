LIBRARY ieee;
LIBRARY unisim;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE unisim.vcomponents.ALL;

ENTITY core IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                      -- reset,          RSTDEF active
        clk:   IN  std_logic;                      -- clock,          rising edge
        swrst: IN  std_logic;                      -- software reset, RSTDEF active
        strt:  IN  std_logic;                      -- start,          high active
        sw:    IN  std_logic_vector( 7 DOWNTO 0);  -- length counter, input
        res:   OUT std_logic_vector(43 DOWNTO 0);  -- result
        done:  OUT std_logic);                     -- done,           high active
END core;

ARCHITECTURE behavioral OF core IS
    COMPONENT ram_block IS
        PORT(addra:   IN  std_logic_vector(9 DOWNTO 0);
             addrb:   IN  std_logic_vector(9 DOWNTO 0);
             clka:    IN  std_logic;
             clkb:    IN  std_logic;
             douta:   OUT std_logic_vector(15 DOWNTO 0);
             doutb:   OUT std_logic_vector(15 DOWNTO 0);
             ena:     IN  std_logic;
             enb:     IN  std_logic);
    END COMPONENT;

    COMPONENT MULT18X18S IS
        PORT(R:     IN std_logic;
             C:     IN std_logic;
             CE:    IN std_logic;
             A:     IN  std_logic_vector(17 DOWNTO 0);
             B:     IN  std_logic_vector(17 DOWNTO 0);
             P:     OUT std_logic_vector(35 DOWNTO 0));
    END COMPONENT;

    COMPONENT signed_accumulator IS
        GENERIC(RSTDEF:     std_logic;
                INPUT_LEN:  integer;
                OUTPUT_LEN: integer);
        PORT(rst:   IN std_logic;
             clk:   IN std_logic;
             din:   IN std_logic_vector(INPUT_LEN-1 DOWNTO 0);
             dout:  OUT std_logic_vector(OUTPUT_LEN-1 DOWNTO 0));
    END COMPONENT;

    SIGNAL acc_rst:         std_logic := '0';
    SIGNAL acc_enable:      std_logic := '0';
    SIGNAL ram_enable:      std_logic := '0';

    CONSTANT BASE_ADDR_A:   integer := 0;
    CONSTANT BASE_ADDR_B:   integer := 256;

    SIGNAL ram_input_a:     std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_input_b:     std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');

    SIGNAL ram_output_a:    std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_output_b:    std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL mult_input_a:    std_logic_vector(17 DOWNTO 0) := (OTHERS => '0');
	SIGNAL mult_input_b:    std_logic_vector(17 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mult_output:     std_logic_vector(35 DOWNTO 0) := (OTHERS => '0');
    SIGNAL acc_input:       std_logic_vector(35 DOWNTO 0) := (OTHERS => '0');
    SIGNAL acc_output:      std_logic_vector(43 DOWNTO 0) := (OTHERS => '0');

    SIGNAL vector_len:      integer := 0;
    SIGNAL current_elem:    integer := 0;

    TYPE tstate IS (S0, S1, S2, S3, S4, S5, IDLE);
    SIGNAL state: tstate := IDLE;
BEGIN
    u_ramblock: ram_block
    PORT MAP(addra => ram_input_a,
             addrb => ram_input_b,
             clka => clk,
             clkb => clk,
             douta => ram_output_a,
             doutb => ram_output_b,
             ena => ram_enable,
             enb => ram_enable);

    u_MULT18X18: MULT18X18S
    PORT MAP(C  => clk,
             CE => '1',
             R  => rst,
             A  => mult_input_a,
             B  => mult_input_b,
             P  => mult_output);

    u_signedacc: signed_accumulator
    GENERIC MAP(RSTDEF => RSTDEF,
                INPUT_LEN => 36,
                OUTPUT_LEN => 44)
    PORT MAP(rst => acc_rst,
             clk => clk,
             din => acc_input,
             dout => acc_output);

    acc_rst <= rst OR strt;

    main: PROCESS(clk, rst)
    BEGIN
        IF rst = RSTDEF THEN
            acc_enable <= '0';
            ram_enable <= '0';
            done <= '0';
            state <= IDLE;
        ELSIF clk'EVENT AND clk = '1' THEN
            IF strt = '1' THEN
                IF to_integer(unsigned(sw)) > 0 THEN
                    vector_len <= to_integer(unsigned(sw));
                    acc_enable <= '0';
                    done <= '0';
                    current_elem <= 0;
                    state <= S0;
                ELSE
                    state <= S5;
                END IF;
            ELSE
                -- Pipeline: @ -> RAM -> MUL -> ACC -> res (6 cycles because of the sign extender between RAM and MUL)
                CASE state IS
                    WHEN S0 =>
                        -- current_elem = 0 (@ -> RAM -> MUL -> ACC -> res)
                        ram_enable <= '1';
                        ram_input_a <= std_logic_vector(to_unsigned(BASE_ADDR_A + current_elem, ram_input_a'LENGTH));
                        ram_input_b <= std_logic_vector(to_unsigned(BASE_ADDR_B + current_elem, ram_input_a'LENGTH));

                        current_elem <= current_elem + 1;
                        state <= S1;
                    WHEN S1 =>
                        -- 0 < current_elem < vector_len (@ -> RAM -> MUL -> ACC -> res)
                        ram_input_a <= std_logic_vector(to_unsigned(BASE_ADDR_A + current_elem, ram_input_a'LENGTH));
                        ram_input_b <= std_logic_vector(to_unsigned(BASE_ADDR_B + current_elem, ram_input_a'LENGTH));

                        IF current_elem > 1 THEN
                            acc_enable <= '1';
                        END IF;

                        IF current_elem < vector_len THEN
                            current_elem <= current_elem + 1;
                        ELSE
                            ram_enable <= '0';
                            state <= S2;
                        END IF;
                    WHEN S2 =>
                        -- RAM -> MUL -> ACC -> res
                        acc_enable <= '1';

                        state <= S3;
                    WHEN S3 =>
                        -- MUL -> ACC -> res
                        done <= '1';

                        state <= IDLE;
                    WHEN S4 =>
                        -- ACC -> res
                        state <= S5;
                    WHEN S5 =>
                        -- res available
                        done <= '1';

                        state <= IDLE;
                    WHEN IDLE =>
                        
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    mult_input_a <= std_logic_vector(resize(signed(ram_output_a), mult_input_a'LENGTH));
    mult_input_b <= std_logic_vector(resize(signed(ram_output_b), mult_input_b'LENGTH));

    acc_input <= mult_output WHEN acc_enable = '1' ELSE (OTHERS => '0');

    res <= acc_output;

END behavioral;
