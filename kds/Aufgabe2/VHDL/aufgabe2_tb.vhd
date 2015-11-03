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
            TYPE frame IS RECORD
                BTN0: std_logic;
                BTN1: std_logic;
                BTN2: std_logic;
                sw:   std_logic_vector(7 DOWNTO 0);
                seg:  std_logic_vector(7 DOWNTO 1);
                LD0:  std_logic;
            END RECORD;
            TYPE frames IS ARRAY(natural RANGE <>) OF frame;
            CONSTANT SEG_0: std_logic_vector(7 DOWNTO 1) := "0000001";
            CONSTANT SEG_1: std_logic_vector(7 DOWNTO 1) := "1001111";
            CONSTANT SEG_2: std_logic_vector(7 DOWNTO 1) := "0010010";
            CONSTANT SEG_3: std_logic_vector(7 DOWNTO 1) := "0000110";
            CONSTANT SEG_4: std_logic_vector(7 DOWNTO 1) := "1001100";
            CONSTANT SEG_5: std_logic_vector(7 DOWNTO 1) := "0100100";
            CONSTANT SEG_6: std_logic_vector(7 DOWNTO 1) := "0100000";
            CONSTANT SEG_7: std_logic_vector(7 DOWNTO 1) := "0001111";
            CONSTANT SEG_8: std_logic_vector(7 DOWNTO 1) := "0000000";
            CONSTANT SEG_9: std_logic_vector(7 DOWNTO 1) := "0000100";
            CONSTANT SEG_A: std_logic_vector(7 DOWNTO 1) := "0001000";
            CONSTANT SEG_B: std_logic_vector(7 DOWNTO 1) := "1100000";
            CONSTANT SEG_C: std_logic_vector(7 DOWNTO 1) := "0110001";
            CONSTANT SEG_D: std_logic_vector(7 DOWNTO 1) := "1000010";
            CONSTANT SEG_E: std_logic_vector(7 DOWNTO 1) := "0110000";
            CONSTANT SEG_F: std_logic_vector(7 DOWNTO 1) := "0111000";
            CONSTANT testtab: frames := (
                ('0', '0', '0', "00000000", SEG_0, '0'),
                ('1', '0', '0', "00000000", SEG_0, '0'),
                ('1', '0', '0', "00000001", SEG_1, '0'),
                ('1', '0', '0', "00000010", SEG_2, '0'),
                ('1', '0', '0', "00000011", SEG_3, '0'),
                ('1', '0', '0', "00000100", SEG_4, '0'),
                ('1', '0', '0', "00000101", SEG_5, '0'),
                ('1', '0', '0', "00000110", SEG_6, '0'),
                ('1', '0', '0', "00000111", SEG_7, '0'),
                ('1', '0', '0', "00001000", SEG_8, '0'),
                ('1', '0', '0', "00001001", SEG_9, '0'),
                ('1', '0', '0', "00001010", SEG_A, '0'),
                ('1', '0', '0', "00001011", SEG_B, '0'),
                ('1', '0', '0', "00001100", SEG_C, '0'),
                ('1', '0', '0', "00001101", SEG_D, '0'),
                ('1', '0', '0', "00001110", SEG_E, '0'),
                ('1', '0', '0', "00001111", SEG_F, '0'),
                ('1', '0', '0', "00000000", SEG_0, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_1, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_2, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_3, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_4, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_5, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_6, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_7, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_8, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_9, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_A, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_B, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_C, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_D, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_E, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_F, '0'),
                ('0', '0', '1', "XXXXXXXX", SEG_0, '1'),
                ('0', '1', '0', "XXXXXXXX", SEG_F, '1'),      -- NOTE: Underflow activates carry
                ('0', '1', '0', "XXXXXXXX", SEG_E, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_D, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_C, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_B, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_A, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_9, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_8, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_7, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_6, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_5, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_4, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_3, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_2, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_1, '0'),
                ('0', '1', '0', "XXXXXXXX", SEG_0, '0')
            );
        BEGIN
            ASSERT FALSE REPORT "starting test for std_counter..." SEVERITY note;
            FOR i IN testtab'RANGE LOOP
                WAIT UNTIL clk'EVENT AND clk = '1';
                BTN0 <= testtab(i).BTN0;
                BTN1 <= testtab(i).BTN1;
                BTN2 <= testtab(i).BTN2;
                sw   <= testtab(i).sw;
                WAIT UNTIL clk'EVENT AND clk = '1';
                ASSERT seg = testtab(i).seg REPORT "wrong segment" SEVERITY error;
                ASSERT LD0 = testtab(i).LD0 REPORT "wrong dot point" SEVERITY error;
            END LOOP;
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

        ASSERT FALSE REPORT "all tests completed" SEVERITY note;

        hlt <= '1';
        WAIT;
    END PROCESS;

END test;
