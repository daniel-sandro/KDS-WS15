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
        -- handshake signals
        strt:  IN  std_logic;                      -- start,          high active
        rdy:   OUT std_logic;                      -- ready,          high active
        -- address/data signals
        sw:    IN  std_logic_vector( 7 DOWNTO 0);  -- address input
        dout:  OUT std_logic_vector(15 DOWNTO 0)); -- result output
END core;

ARCHITECTURE behavioral OF core IS
    CONSTANT BASE_ADDR_A:   integer := 16#0000#;
    CONSTANT BASE_ADDR_B:   integer := 16#0100#;
    CONSTANT VECTOR_LEN:    integer := 256;
    CONSTANT MATRIX_DIM:    integer := 16;

    COMPONENT rom_block IS
        PORT(addra: IN std_logic_vector(9 DOWNTO 0);
             addrb: IN std_logic_vector(9 DOWNTO 0);
             clka:  IN std_logic;
             clkb:  IN std_logic;
             douta: OUT std_logic_vector(15 DOWNTO 0);
             doutb: OUT std_logic_vector(15 DOWNTO 0);
             ena:   IN std_logic;
             enb:   IN std_logic);
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

    COMPONENT ram_block IS
        PORT(addra:   IN  std_logic_vector(9 DOWNTO 0);
             addrb:   IN  std_logic_vector(9 DOWNTO 0);
             clka:    IN  std_logic;
             clkb:    IN  std_logic;
             dina:    IN  std_logic_vector(15 DOWNTO 0);
             douta:   OUT std_logic_vector(15 DOWNTO 0);
             doutb:   OUT std_logic_vector(15 DOWNTO 0);
             ena:     IN  std_logic;
             enb:     IN  std_logic;
             wea:     IN  std_logic);
    END COMPONENT;

    SIGNAL ram_addr_a:      std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_addr_b:      std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL ram_input_a:     std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL ram_input_b:     std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ram_output_a:    std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL ram_output_b:    std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    --SIGNAL ram_enable:      std_logic := '0';
    SIGNAL ram_wenable:     std_logic := '0';

    SIGNAL rom_input_a:     std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rom_input_b:     std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rom_output_a:    std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rom_output_b:    std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rom_enable:      std_logic := '0';

    SIGNAL mult_input_a:    std_logic_vector(17 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mult_input_b:    std_logic_vector(17 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mult_output:     std_logic_vector(35 DOWNTO 0) := (OTHERS => '0');

    SIGNAL acc_enable:      std_logic := '0';
    SIGNAL acc_rst:         std_logic := '0';
    SIGNAL acc_manualrst:   std_logic := '0';
    SIGNAL acc_input:       std_logic_vector(35 DOWNTO 0) := (OTHERS => '0');
    SIGNAL acc_output:      std_logic_vector(43 DOWNTO 0) := (OTHERS => '0');

    SIGNAL current_elem:    integer := 0;

    TYPE tstate IS (S0, S1, S2, S3, IDLE);
    SIGNAL state: tstate := IDLE;

BEGIN
    u_romblock: rom_block
    PORT MAP(addra => rom_input_a,
             addrb => rom_input_b,
             clka => clk,
             clkb => clk,
             douta => rom_output_a,
             doutb => rom_output_b,
             ena => rom_enable,
             enb => rom_enable);

    u_MULT18X18: MULT18X18S
    PORT MAP(C  => clk,
             CE => '1',
             R  => rst,
             A  => mult_input_a,
             B  => mult_input_b,
             P  => mult_output);
    mult_input_a <= std_logic_vector(resize(signed(rom_output_a), mult_input_a'LENGTH));
    mult_input_b <= std_logic_vector(resize(signed(rom_output_b), mult_input_b'LENGTH));

    u_signedacc: signed_accumulator
    GENERIC MAP(RSTDEF => RSTDEF,
                INPUT_LEN => 36,
                OUTPUT_LEN => 44)
    PORT MAP(rst => acc_rst,
             clk => clk,
             din => acc_input,
             dout => acc_output);
    acc_rst <= rst OR strt OR acc_manualrst;
    acc_input <= mult_output WHEN acc_enable = '1' ELSE (OTHERS => '0');

    u_ramblock: ram_block
    PORT MAP(addra => ram_addr_a,
             addrb => ram_addr_b,
             clka => clk,
             clkb => clk,
             -- TODO: check
             dina => acc_output(15 DOWNTO 0),
             douta => OPEN,
             doutb => dout,
             ena => '0',
             enb => '1',
             wea => ram_wenable);
    ram_addr_b <= "00" & sw;

    main: PROCESS(clk, rst)
    BEGIN
        IF rst = RSTDEF OR (clk'EVENT AND clk = '1' AND swrst = RSTDEF) THEN
            ram_wenable <= '0';
            rom_enable <= '0';
            acc_enable <= '0';

            rdy <= '0';
            state <= IDLE;
        ELSIF clk'EVENT AND clk = '1' THEN
            IF strt = '1' THEN
                rom_enable <= '1';
                rom_input_a <= std_logic_vector(to_unsigned(BASE_ADDR_A, rom_input_a'LENGTH));
                rom_input_b <= std_logic_vector(to_unsigned(BASE_ADDR_B, rom_input_b'LENGTH));
                acc_enable <= '0';
                ram_wenable <= '0';

                rdy <= '0';
                current_elem <= 1;

                state <= S0;
            ELSE
                CASE state IS
                    WHEN S0 =>
                        -- Pipeline: ROM -> MUL -> ACC -> RAM
                        rom_input_a <= std_logic_vector(to_unsigned(BASE_ADDR_A + current_elem, rom_input_a'LENGTH));
                        rom_input_b <= std_logic_vector(to_unsigned(BASE_ADDR_B + current_elem, rom_input_b'LENGTH));

                        IF current_elem > 1 THEN
                            acc_enable <= '1';
                        END IF;

                        -- The current element will be available to be written within 2 cycles
                        IF (current_elem + 1) MOD (MATRIX_DIM + 2) = 0 THEN
                            acc_manualrst <= '1';
                            ram_addr_a <= std_logic_vector(to_unsigned((current_elem + 1) / (VECTOR_LEN - 2), ram_addr_a'LENGTH));
                            ram_wenable <= '1';
                        ELSIF (current_elem + 1) MOD (MATRIX_DIM + 3) = 0 THEN
                            acc_manualrst <= '0';
                            ram_wenable <= '0';
                        END IF;

                        IF current_elem < VECTOR_LEN THEN
                            current_elem <= current_elem + 1;
                        ELSE
                            rom_enable <= '0';
                            state <= S1;
                        END IF;
                    WHEN S1 =>
                        -- MUL -> ACC -> RAM
                        acc_enable <= '1';
                        ram_wenable <= '0';

                        state <= S2;
                    WHEN S2 =>
                        -- ACC -> RAM
                        acc_enable <= '0';
                        ram_wenable <= '0';

                        state <= S3;
                    WHEN S3 =>
                        -- RAM
                        acc_enable <= '0';
                        ram_addr_a <= std_logic_vector(to_unsigned(VECTOR_LEN - 1, ram_addr_a'LENGTH));
                        ram_wenable <= '1';

                        rdy <= '1';

                        state <= IDLE;
                    WHEN IDLE =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END behavioral;
