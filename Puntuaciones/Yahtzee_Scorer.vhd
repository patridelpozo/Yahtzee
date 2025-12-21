----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2025 17:28:44
-- Design Name: 
-- Module Name: Yahtzee_Scorer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity yahtzee_score is
    port(
        sw       : in  std_logic_vector(2 downto 0);  -- selector test case
        leds     : out std_logic_vector(10 downto 0)   -- LEDs para jugadas
    );
end entity;

architecture rtl of yahtzee_score is

    ---------------------------------------------------------------------
    -- TEST CASES (15 bits = 5 dados × 3 bits por dado)
    ---------------------------------------------------------------------
    constant TEST_CASE_0 : std_logic_vector(14 downto 0) := "001010011100101";  -- 1 2 3 4 5
    constant TEST_CASE_1 : std_logic_vector(14 downto 0) := "010010010010010";  -- 2 2 2 2 2
    constant TEST_CASE_2 : std_logic_vector(14 downto 0) := "100100100010010";  -- 4 4 4 2 2
    constant TEST_CASE_3 : std_logic_vector(14 downto 0) := "110110110110001";  -- 6 6 6 6 1
    constant TEST_CASE_4 : std_logic_vector(14 downto 0) := "011011011010001";  -- 3 3 3 5 1

    signal dice_in : std_logic_vector(14 downto 0);

    ---------------------------------------------------------------------
    -- Señales para los 5 dados
    ---------------------------------------------------------------------
    signal d1, d2, d3, d4, d5 : unsigned(2 downto 0);

begin

    ---------------------------------------------------------------------
    -- Selector de test case
    ---------------------------------------------------------------------
    with sw select
        dice_in <= TEST_CASE_0 when "000",
                   TEST_CASE_1 when "001",
                   TEST_CASE_2 when "010",
                   TEST_CASE_3 when "011",
                   TEST_CASE_4 when "100",
                   TEST_CASE_0 when others;

    ---------------------------------------------------------------------
    -- Extraer los 5 dados del vector de entrada
    ---------------------------------------------------------------------
    d1 <= unsigned(dice_in(14 downto 12));
    d2 <= unsigned(dice_in(11 downto 9));
    d3 <= unsigned(dice_in(8  downto 6));
    d4 <= unsigned(dice_in(5  downto 3));
    d5 <= unsigned(dice_in(2  downto 0));

    ---------------------------------------------------------------------
    -- Lógica combinacional para puntuaciones
    ---------------------------------------------------------------------
    process(d1, d2, d3, d4, d5)
    variable f1, f2, f3, f4, f5, f6 : integer;
    variable v1, v2, v3, v4, v5 : integer;
    variable trio, poker, full, yahtz : boolean;
    variable sum_all : integer;
begin
    -- Inicializar frecuencias
    f1 := 0; f2 := 0; f3 := 0;
    f4 := 0; f5 := 0; f6 := 0;

    -- Convertir a enteros (dados van de 0 a 6, pero 0 no se usa)
    v1 := to_integer(d1);
    v2 := to_integer(d2);
    v3 := to_integer(d3);
    v4 := to_integer(d4);
    v5 := to_integer(d5);

    -- Aumentar frecuencia correcta
    case v1 is
        when 1 => f1 := f1 + 1;
        when 2 => f2 := f2 + 1;
        when 3 => f3 := f3 + 1;
        when 4 => f4 := f4 + 1;
        when 5 => f5 := f5 + 1;
        when 6 => f6 := f6 + 1;
        when others => null;
    end case;

    case v2 is
        when 1 => f1 := f1 + 1;
        when 2 => f2 := f2 + 1;
        when 3 => f3 := f3 + 1;
        when 4 => f4 := f4 + 1;
        when 5 => f5 := f5 + 1;
        when 6 => f6 := f6 + 1;
        when others => null;
    end case;

    case v3 is
        when 1 => f1 := f1 + 1;
        when 2 => f2 := f2 + 1;
        when 3 => f3 := f3 + 1;
        when 4 => f4 := f4 + 1;
        when 5 => f5 := f5 + 1;
        when 6 => f6 := f6 + 1;
        when others => null;
    end case;

    case v4 is
        when 1 => f1 := f1 + 1;
        when 2 => f2 := f2 + 1;
        when 3 => f3 := f3 + 1;
        when 4 => f4 := f4 + 1;
        when 5 => f5 := f5 + 1;
        when 6 => f6 := f6 + 1;
        when others => null;
    end case;

    case v5 is
        when 1 => f1 := f1 + 1;
        when 2 => f2 := f2 + 1;
        when 3 => f3 := f3 + 1;
        when 4 => f4 := f4 + 1;
        when 5 => f5 := f5 + 1;
        when 6 => f6 := f6 + 1;
        when others => null;
    end case;

    -- Jugadas grandes
    trio  := (f1=3 or f2=3 or f3=3 or f4=3 or f5=3 or f6=3);
    poker := (f1=4 or f2=4 or f3=4 or f4=4 or f5=4 or f6=4);
    yahtz := (f1=5 or f2=5 or f3=5 or f4=5 or f5=5 or f6=5);

    full := false;
    if ( (f1=3 and (f2=2 or f3=2 or f4=2 or f5=2 or f6=2)) or
         (f2=3 and (f1=2 or f3=2 or f4=2 or f5=2 or f6=2)) or
         (f3=3 and (f1=2 or f2=2 or f4=2 or f5=2 or f6=2)) or
         (f4=3 and (f1=2 or f2=2 or f3=2 or f5=2 or f6=2)) or
         (f5=3 and (f1=2 or f2=2 or f3=2 or f4=2 or f6=2)) or
         (f6=3 and (f1=2 or f2=2 or f3=2 or f4=2 or f5=2)) ) then
        full := true;
    end if;

    -- CHANCE (suma total)
    sum_all := v1 + v2 + v3 + v4 + v5;

    -----------------------------------------------------------------
    -- LEDs
    -----------------------------------------------------------------

    -- unos a seises
    if f1 > 0 then leds(0) <= '1'; else leds(0) <= '0'; end if;
    if f2 > 0 then leds(1) <= '1'; else leds(1) <= '0'; end if;
    if f3 > 0 then leds(2) <= '1'; else leds(2) <= '0'; end if;
    if f4 > 0 then leds(3) <= '1'; else leds(3) <= '0'; end if;
    if f5 > 0 then leds(4) <= '1'; else leds(4) <= '0'; end if;
    if f6 > 0 then leds(5) <= '1'; else leds(5) <= '0'; end if;

    if trio  then leds(6) <= '1'; else leds(6) <= '0'; end if;
    if poker then leds(7) <= '1'; else leds(7) <= '0'; end if;
    if full  then leds(8) <= '1'; else leds(8) <= '0'; end if;
    if yahtz  then leds(9) <= '1'; else leds(9) <= '0'; end if;

    leds(10) <= '1'; -- chance siempre disponible

end process;

end rtl;
