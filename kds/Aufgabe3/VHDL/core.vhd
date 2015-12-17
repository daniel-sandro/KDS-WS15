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
        -- RSTDEF?
        PORT(rst:   IN std_logic;
             clk:   IN std_logic;
             clken: IN std_logic;
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
             din:   IN std_logic_vector(INPUT_LEN DOWNTO 0);
             dout:  OUT std_logic_vector(OUTPUT_LEN DOWNTO 0));
    END COMPONENT;

    CONSTANT BASE_ADDR_A:   integer := 0;
    CONSTANT BASE_ADDR_B:   integer := 256;

    SIGNAL ram_input_a:     std_logic_vector(9 DOWNTO 0);
    SIGNAL ram_input_b:     std_logic_vector(9 DOWNTO 0);

    SIGNAL ram_output_a:    std_logic_vector(15 DOWNTO 0);
    SIGNAL ram_output_b:    std_logic_vector(15 DOWNTO 0);
    SIGNAL mult_output:     std_logic_vector(35 DOWNTO 0);
    SIGNAL acc_output:      std_logic_vector(43 DOWNTO 0);

    SIGNAL vector_len:      integer;
    SIGNAL current_elem:    integer;
BEGIN
    u_ramblock: ram_block
    PORT MAP(addra => ram_input_a,
             addrb => ram_input_b,
             clka => clk,
             clkb => clk,
             douta => ram_output_a,
             doutb => ram_output_b,
             ena => '0',
             enb => '0');

    u_MULT18X18: MULT18X18S
    PORT MAP(clk => clk,
             clken => '1',
             rst => rst,
             A => std_logic_vector(resize(signed(ram_output_a), A'LENGTH)),
             B => std_logic_vector(resize(signed(ram_output_b), B'LENGTH)),
             P => mult_output);

    u_signedacc: signed_accumulator
    GENERIC MAP(RSTDEF => RSTDEF,
                INPUT_LEN => 36,
                OUTPUT_LEN => 44);
    PORT MAP(rst => rst,
             clk => clk,
             din => mult_output,
             dout => acc_output);

    main: PROCESS
    BEGIN
        IF rst = RSTDEF THEN
            res <= "X0000000000000000000000000000000000000000000";
            done <= '1';
        ELSIF clk'EVENT AND clk = '1' THEN
            res <= acc_output;
            IF strt = '1' THEN
                vector_len <= to_integer(unsigned(sw));
                done <= '0';
                current_elem <= 0;
            ELSE
                IF current_elem < vector_len THEN
                    ram_input_a <= std_logic_vector(unsigned(BASE_ADDR_A + current_elem));
                    ram_input_b <= std_logic_vector(unsigned(BASE_ADDR_B + current_elem));
                    done <= '0';
                    current_elem <= current_elem + 1;
                ELSE
                    done <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

END behavioral;
