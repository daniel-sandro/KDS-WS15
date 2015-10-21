LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF:  std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        en:    IN  std_logic;                       -- enable,          active high
        swrst: IN  std_logic;                       -- software reset,  active RSTDEF
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
        dp:    OUT std_logic;                       -- 1 decimal point output,                      active low
        seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS
  SIGNAL cnt_1 integer RANGE 0 TO 213;
  SIGNAL cnt_2: integer RANGE 0 TO 3;
  SIGNAL mod_4_counter_2_enable: std_logic;
  SIGNAL 7_4_decoder_5_input: std_logic_vector(3 DOWNTO 0);
BEGIN

  freq_divider_1: PROCESS(clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      cnt_1 <= (cnt_1 + 1) MOD 214;
    END IF;
    mod_4_counter_2_enable = 1 WHEN cnt_1 = 0 ELSE 0;
  END;

  mod_4_counter_2 PROCESS(clk, mod_4_counter_2_enable)
  BEGIN
    IF clk'event AND clk = '1' AND mod_4_counter_2_enable = '1' THEN
      cnt_2 <= (cnt_2 + 1) MOD 4;
    END IF;
  END;

  1_4_decoder_3 PROCESS(count)
  BEGIN
    CASE count IS
      WHEN "00" => an <= "1000";
      WHEN "01" => an <= "0100";
      WHEN "10" => an <= "0010";
      WHEN "11" => an <= "0001";
    END CASE;
  END;

  1_4_multiplexer_4: PROCESS(count)
  BEGIN
    CASE count IS
      WHEN "00" => 7_4_decoder_5_input <= data(15 DOWNTO 12);
      WHEN "01" => 7_4_decoder_5_input <= data(11 DOWNTO 8 );
      WHEN "10" => 7_4_decoder_5_input <= data( 7 DOWNTO 4 );
      WHEN "11" => 7_4_decoder_5_input <= data( 3 DOWNTO 0 );
    END CASE;
  END;

  7_4_decoder_5: PROCESS(7_4_decoder_5_input)
  BEGIN
    CASE 7_4_decoder_5_input IS
      WHEN "0000" => seg <= "1111110";
      WHEN "0001" => seg <= "0110000";
      WHEN "0010" => seg <= "1101101";
      WHEN "0011" => seg <= "1111001";
      WHEN "0100" => seg <= "0110011";
      WHEN "0101" => seg <= "1011011";
      WHEN "0110" => seg <= "1011111";
      WHEN "0111" => seg <= "1110000";
      WHEN "1000" => seg <= "1111111";
      WHEN "1001" => seg <= "1111011";
      WHEN "1010" => seg <= "1110111";
      WHEN "1011" => seg <= "0011111";
      WHEN "1100" => seg <= "1001110";
      WHEN "1101" => seg <= "0111101";
      WHEN "1110" => seg <= "1001111";
      WHEN "1111" => seg <= "1000111";
    END CASE;
  END;

  1_4_multiplexer_6: PROCESS(count)
  BEGIN
    CASE count IS
      WHEN "00" => dp <= dpin(3);
      WHEN "01" => dp <= dpin(2);
      WHEN "10" => dp <= dpin(1);
      WHEN "11" => dp <= dpin(0);
    END CASE;
  END;

END struktur;
