LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY aufgabe2_test IS
    -- empty
END aufgabe2_test;

ARCHITECTURE test OF aufgabe2_test IS
    CONSTANT RSTDEF: std_ulogic := '1';
    CONSTANT tpd: time := 20 ns;    -- 1/50 MHz

    COMPONENT aufgabe2 IS
        PORT(rst:  IN  std_logic;                     -- (BTN3) User Reset
             clk:  IN  std_logic;                     -- 50 MHz crystal oscillator clock source
             BTN0: IN  std_logic;                     -- load
             BTN1: IN  std_logic;                     -- decrement
             BTN2: IN  std_logic;                     -- increment
             sw:   IN  std_logic_vector(7 DOWNTO 0);  -- 8 slide switches: SW7 SW6 SW5 SW4 SW3 SW2 SW1 SW0
             an:   OUT std_logic_vector(3 DOWNTO 0);  -- 4 digit enable (anode control) signals (active low)
             seg:  OUT std_logic_vector(7 DOWNTO 1);  -- 7 FPGA connections to seven-segment display (active low)
             dp:   OUT std_logic;                     -- 1 FPGA connection to digit dot point (active low)
             LD0:  OUT std_logic);                    -- 1 FPGA connection to LD0 (carry output)
    END COMPONENT;

    SIGNAL rst:     std_logic := RSTDEF;
    SIGNAL clk:     std_logic := '0';
    SIGNAL hlt:     std_logic := '0';

    SIGNAL BTN0:    std_logic := '0';
    SIGNAL BTN1:    std_logic := '0';
    SIGNAL BTN2:    std_logic := '0';
    SIGNAL sw:      std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL an:      std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL seg:     std_logic_vector(7 DOWNTO 1) := (OTHERS => '0');
    SIGNAL dp:      std_logic := '0';
    SIGNAL LD0:     std_logic := '0';
BEGIN
    rst <= RSTDEF, NOT RSTDEF AFTER 5*tpd;
    clk <= clk WHEN hlt = '1' ELSE '1' AFTER tpd/2 WHEN clk='0' ELSE '0' AFTER tpd/2;

    u1: aufgabe2
    PORT MAP(rst  => rst,
             clk  => clk,
             BTN0 => BTN0,
             BTN1 => BTN1,
             BTN2 => BTN2,
             sw   => sw,
             an   => an,
             seg  => seg,
             dp   => dp,
             LD0  => LD0);

    main: PROCESS
        PROCEDURE test_std_counter IS
        BEGIN
            ASSERT FALSE REPORT "starting test for std_counter..." SEVERITY note;
            -- TODO: implement test
        END PROCEDURE;

        PROCEDURE test_sync_buffer IS
        BEGIN
            ASSERT FALSE REPORT "starting test for sync_buffer..." SEVERITY note;
            -- TODO: implement test
        END PROCEDURE;

        PROCEDURE test_sync_module IS
        BEGIN
            ASSERT FALSE REPORT "starting test for sync_module..." SEVERITY note;
            -- TODO: implement test
        END PROCEDURE;

        PROCEDURE test_aufgabe2 IS
        BEGIN
            ASSERT FALSE REPORT "starting test for aufgabe2..." SEVERITY note;
            -- TODO: implement test
        END PROCEDURE;
    BEGIN
        WAIT UNTIL clk'EVENT AND clk = '1' AND rst = (NOT RSTDEF);

        test_std_counter;
        test_sync_buffer;
        test_sync_module;
        test_aufgabe2;

        ASSERT FALSE REPORT "all tests done" SEVERITY note;

        hlt <= '1';
        WAIT;
    END PROCESS;

END test;
