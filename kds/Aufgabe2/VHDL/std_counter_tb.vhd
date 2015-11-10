LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY std_counter_test IS
    -- empty
END std_counter_test;

ARCHITECTURE test OF std_counter_test IS
    CONSTANT RSTDEF: std_ulogic := '1';
    CONSTANT tpd: time := 20 ns;    -- 1/50 MHz
    CONSTANT CNTLEN: natural := 16;

    COMPONENT std_counter IS
        GENERIC(RSTDEF: std_logic;
               CNTLEN: natural);
        PORT(rst:   IN  std_logic;  -- reset,           RSTDEF active
             clk:   IN  std_logic;  -- clock,           rising edge
             en:    IN  std_logic;  -- enable,          high active
             inc:   IN  std_logic;  -- increment,       high active
             dec:   IN  std_logic;  -- decrement,       high active
             load:  IN  std_logic;  -- load value,      high active
             swrst: IN  std_logic;  -- software reset,  RSTDEF active
             cout:  OUT std_logic;  -- carry,           high active        
             din:   IN  std_logic_vector(CNTLEN-1 DOWNTO 0);
             dout:  OUT std_logic_vector(CNTLEN-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT hex4x7seg IS
        GENERIC(RSTDEF:  std_logic);
        PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
             clk:   IN  std_logic;                       -- clock,           rising edge
             en:    IN  std_logic;                       -- enable,          active high
             swrst: IN  std_logic;                       -- software reset,  active RSTDEF
             data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
             dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
             an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
             dp:    OUT std_logic;                       -- decimal point output,                        active low
             seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
    END COMPONENT;

    SIGNAL rst:     std_logic := RSTDEF;
    SIGNAL clk:     std_logic := '0';
    SIGNAL hlt:     std_logic := '0';

    SIGNAL swrst:   std_logic := NOT RSTDEF;
    SIGNAL load:    std_logic := '0';
    SIGNAL dec:     std_logic := '0';
    SIGNAL inc:     std_logic := '0';
    SIGNAL din:     std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cnt:     std_logic_vector(CNTLEN-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cout:    std_logic := '0';
    SIGNAL an:      std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL seg:     std_logic_vector(7 DOWNTO 1) := (OTHERS => '0');
BEGIN
    rst <= RSTDEF, NOT RSTDEF AFTER 5*tpd;
    clk <= clk WHEN hlt = '1' ELSE '1' AFTER tpd/2 WHEN clk='0' ELSE '0' AFTER tpd/2;

    counter: std_counter
    GENERIC MAP(RSTDEF => RSTDEF,
                CNTLEN => CNTLEN)
    PORT MAP(rst   => rst,
             clk   => clk,
             en    => '1',
             inc   => inc,
             dec   => dec,
             load  => load,
             swrst => swrst,
             cout  => cout,
             din   => din,
             dout  => cnt);

    transcoder: hex4x7seg
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst   => rst,
             clk   => clk,
             en    => '1',
             swrst => swrst,
             data  => cnt,
             dpin  => "0000",
             an    => an,
             dp    => open,
             seg   => seg);

    main: PROCESS
        PROCEDURE test_std_counter IS
            TYPE frame IS RECORD
                an:     std_logic_vector(3 DOWNTO 0);
                load:   std_logic;
                dec:    std_logic;
                inc:    std_logic;
                din:    std_logic_vector(CNTLEN-1 DOWNTO 0);
                seg:    std_logic_vector(7 DOWNTO 1);
                cout:   std_logic;
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
                ("1110", '0', '0', '0', X"0000", SEG_0, '0'),
                ("1110", '1', '0', '0', X"0000", SEG_0, '0'),
                ("1110", '1', '0', '0', X"0001", SEG_1, '0'),
                ("1110", '1', '0', '0', X"0002", SEG_2, '0'),
                ("1110", '1', '0', '0', X"0003", SEG_3, '0'),
                ("1110", '1', '0', '0', X"0004", SEG_4, '0'),
                ("1110", '1', '0', '0', X"0005", SEG_5, '0'),
                ("1110", '1', '0', '0', X"0006", SEG_6, '0'),
                ("1110", '1', '0', '0', X"0007", SEG_7, '0'),
                ("1110", '1', '0', '0', X"0008", SEG_8, '0'),
                ("1110", '1', '0', '0', X"0009", SEG_9, '0'),
                ("1110", '1', '0', '0', X"000A", SEG_A, '0'),
                ("1110", '1', '0', '0', X"000B", SEG_B, '0'),
                ("1110", '1', '0', '0', X"000C", SEG_C, '0'),
                ("1110", '1', '0', '0', X"000D", SEG_D, '0'),
                ("1110", '1', '0', '0', X"000E", SEG_E, '0'),
                ("1110", '1', '0', '0', X"000F", SEG_F, '0'),
                ("1110", '1', '0', '0', X"0000", SEG_0, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_1, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_2, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_3, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_4, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_5, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_6, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_7, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_8, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_9, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_A, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_B, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_C, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_D, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_E, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_F, '0'),
                ("1110", '0', '0', '1', "XXXXXXXXXXXXXXXX", SEG_0, '1'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_F, '1'),      -- NOTE: Underflow activates carry
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_E, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_D, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_C, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_B, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_A, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_9, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_8, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_7, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_6, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_5, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_4, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_3, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_2, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_1, '0'),
                ("1110", '0', '1', '0', "XXXXXXXXXXXXXXXX", SEG_0, '0')
            );
        BEGIN
            ASSERT FALSE REPORT "starting test for std_counter..." SEVERITY note;
            FOR i IN testtab'RANGE LOOP
                WAIT UNTIL clk'EVENT AND clk = '1';
                load <= testtab(i).load;
                dec <= testtab(i).dec;
                inc <= testtab(i).inc;
                din <= testtab(i).din;
                WAIT UNTIL clk'EVENT AND clk = '1';
                load <= '0';
                dec <= '0';
                inc <= '0';
                WAIT UNTIL clk'EVENT AND clk = '1' AND an = testtab(i).an;
                ASSERT seg = testtab(i).seg REPORT "wrong segment, i=" & integer'IMAGE(i) SEVERITY error;
                ASSERT cout = testtab(i).cout REPORT "wrong carry out, i=" & integer'IMAGE(i) SEVERITY error;
            END LOOP;
        END PROCEDURE;

    BEGIN
        WAIT UNTIL clk'EVENT AND clk = '1' AND rst = (NOT RSTDEF);

        test_std_counter;

        ASSERT FALSE REPORT "all tests completed" SEVERITY note;

        hlt <= '1';
        WAIT;
    END PROCESS;

END test;
