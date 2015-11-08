LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY sync_module IS
    GENERIC(RSTDEF: std_logic := '1');
    PORT(rst:  IN  std_logic;  -- reset, active RSTDEF
        clk:   IN  std_logic;  -- clock, risign edge
        swrst: IN  std_logic;  -- software reset, active RSTDEF
        BTN0:  IN  std_logic;  -- push button -> load
        BTN1:  IN  std_logic;  -- push button -> dec
        BTN2:  IN  std_logic;  -- push button -> inc
        load:  OUT std_logic;  -- load,      high active
        dec:   OUT std_logic;  -- decrement, high active
        inc:   OUT std_logic); -- increment, high active
END sync_module;

ARCHITECTURE behavioral OF sync_module IS
    COMPONENT sync_buffer IS
        GENERIC(RSTDEF: std_logic);
        PORT(rst:   IN  std_logic;  -- reset, RSTDEF active
            clk:    IN  std_logic;  -- clock, rising edge
            en:     IN  std_logic;  -- enable, high active
            swrst:  IN  std_logic;  -- software reset, RSTDEF active
            din:    IN  std_logic;  -- data bit, input
            dout:   OUT std_logic;  -- data bit, output
            redge:  OUT std_logic;  -- rising  edge on din detected
            fedge:  OUT std_logic); -- falling edge on din detected
    END COMPONENT;

    CONSTANT MAXCNT: integer := 2 ** 15;

    SIGNAL buf_en: std_logic;
    SIGNAL freq_divider_cnt: integer RANGE 0 TO MAXCNT - 1;
BEGIN

    buf0: sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst    => rst,
             clk    => clk,
             en     => buf_en,
             swrst  => swrst,
             din    => BTN0,
             -- TODO: check outputs mappings
             dout   => load,
             redge  => open,
             fedge  => open);

    buf1: sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst    => rst,
             clk    => clk,
             en     => buf_en,
             swrst  => swrst,
             din    => BTN1,
             -- TODO: check outputs mappings
             dout   => dec,
             redge  => open,
             fedge  => open);

    buf2: sync_buffer
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst    => rst,
             clk    => clk,
             en     => buf_en,
             swrst  => swrst,
             din    => BTN2,
             -- TODO: check outputs mappings
             dout   => inc,
             redge  => open,
             fedge  => open);

    freq_divider: PROCESS(clk, rst)
    BEGIN
        IF rst = RSTDEF OR swrst = RSTDEF THEN
            buf_en <= '0';
            freq_divider_cnt <= 0;
        ELSIF clk'EVENT AND clk = '1' THEN
            IF freq_divider_cnt = 0 THEN
                buf_en <= '1';
            ELSE
                buf_en <= '0';
            END IF;
            freq_divider_cnt <= (freq_divider_cnt + 1) MOD MAXCNT;
        END IF;
    END PROCESS;

END behavioral;
