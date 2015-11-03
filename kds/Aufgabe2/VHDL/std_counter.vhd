
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY std_counter IS
   GENERIC(RSTDEF: std_logic := '1';
           CNTLEN: natural   := 4);
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
END std_counter;

--
-- Funktionstabelle
-- rst clk swrst en  load dec inc | Aktion
----------------------------------+-------------------------
--  V   -    -    -    -   -   -  | cnt := 000..0, asynchrones Reset
--  N   r    V    -    -   -   -  | cnt := 000..0, synchrones  Reset
--  N   r    N    0    -   -   -  | keine Aenderung
--  N   r    N    1    1   -   -  | cnt := din, paralleles Laden
--  N   r    N    1    0   1   -  | cnt := cnt - 1, dekrementieren
--  N   r    N    1    0   0   1  | cnt := cnt + 1, inkrementieren
--  N   r    N    1    0   0   0  | keine Aenderung
--
-- Legende:
-- V = valid, = RSTDEF
-- N = not valid, = NOT RSTDEF
-- r = rising egde
-- din = Dateneingang des Zaehlers
-- cnt = Wert des Zaehlers
--

ARCHITECTURE structural OF std_counter IS
  CONSTANT MAXCNT: integer := (2 ** CNTLEN) - 1;
  SIGNAL cnt: integer RANGE 0 TO MAXCNT;
BEGIN
  p1: PROCESS(clk, rst)
  BEGIN
    IF rst = RSTDEF OR swrst = RSTDEF THEN
      cnt <= 0;
    ELSIF en = '1' AND clk'EVENT AND clk = '1' THEN
      IF inc = '1' THEN
        cnt <= (cnt + 1) MOD MAXCNT;
      ELSIF dec = '1' THEN
        cnt <= (cnt - 1) MOD MAXCNT;
      ELSIF load = '1' THEN
        cnt <= to_integer(unsigned(din));
      END IF;
    END IF;
    dout <= std_logic_vector(to_unsigned(cnt, dout'LENGTH));
  END PROCESS;
END structural;
