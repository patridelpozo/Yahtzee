----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2025 13:04:24
-- Design Name: 
-- Module Name: yahztee_score_sel_2 - Behavioral
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

entity yahtzee_score_sel_2 is
    port(
        clk      : in  std_logic;  
        segments : out std_logic_vector(6 downto 0);
        anodes   : out std_logic_vector(7 downto 0);
        sw       : in  std_logic_vector(2 downto 0);    -- seleccion test case
        cat_sw   : in  std_logic_vector(10 downto 0);   -- switches de categoria
        leds     : out std_logic_vector(10 downto 0)
    );
end entity;

architecture behavioral of yahtzee_score_sel_2 is

    -- Test cases
    constant TEST_CASE_0 : std_logic_vector(14 downto 0) := "001010011100101";  -- 1,2,3,4,5
    constant TEST_CASE_1 : std_logic_vector(14 downto 0) := "010010010010010";  -- 2,2,2,2,2
    constant TEST_CASE_2 : std_logic_vector(14 downto 0) := "100100100010010";  -- 4,4,4,2,2
    constant TEST_CASE_3 : std_logic_vector(14 downto 0) := "110110110110001";  -- 6,6,6,6,1
    constant TEST_CASE_4 : std_logic_vector(14 downto 0) := "011011011010001";  -- 3,3,3,4,1

    signal dice_in : std_logic_vector(14 downto 0);

    signal d1, d2, d3, d4, d5 : unsigned(2 downto 0);

    signal used       : std_logic_vector(10 downto 0) := (others => '0');
    signal prev_cat_sw: std_logic_vector(10 downto 0) := (others => '0');
    signal leds_out   : std_logic_vector(10 downto 0);
    signal score      : integer := 0;

    -- Señales (resultado del proceso combinacional)
    signal freq1, freq2, freq3, freq4, freq5, freq6 : integer := 0;
    signal dice_sum : integer := 0;
    signal trio  : boolean := false;
    signal poker : boolean := false;
    signal yahtz : boolean := false;
    signal full  : boolean := false;
    signal chance: boolean := true;

    -- Display multiplexado
    signal d_0, d_1, d_2, d_3, d_4, d_5, d_6, d_7 : integer := 0;
    signal refresh_cnt : integer := 0;
    signal mux_sel : integer range 0 to 7 := 0;

    -- Función 7 segmentos
    function to7seg(n : integer) return std_logic_vector is
    begin
        case n is
            when 0 => return "0000001";
            when 1 => return "1001111";
            when 2 => return "0010010";
            when 3 => return "0000110";
            when 4 => return "1001100";
            when 5 => return "0100100";
            when 6 => return "0100000";
            when 7 => return "0001111";
            when 8 => return "0000000";
            when 9 => return "0000100";
            when others => return "1111111";
        end case;
    end function;

begin

    -- Selector de test case
    with sw select
        dice_in <= TEST_CASE_0 when "000",
                   TEST_CASE_1 when "001",
                   TEST_CASE_2 when "010",
                   TEST_CASE_3 when "011",
                   TEST_CASE_4 when "100",
                   TEST_CASE_0 when others;

    -- Extraer dados
    d1 <= unsigned(dice_in(14 downto 12));
    d2 <= unsigned(dice_in(11 downto 9));
    d3 <= unsigned(dice_in(8 downto 6));
    d4 <= unsigned(dice_in(5 downto 3));
    d5 <= unsigned(dice_in(2 downto 0));

   -------------------------------------------------------------------
-- PROCESO COMBINACIONAL: calcular frecuencias y categorías
-------------------------------------------------------------------
process(d1, d2, d3, d4, d5, used)
    variable vv1, vv2, vv3, vv4, vv5 : integer;
    variable v1, v2, v3, v4, v5, v6 : integer;
begin
    -- Convertir dados
    vv1 := to_integer(d1);
    vv2 := to_integer(d2);
    vv3 := to_integer(d3);
    vv4 := to_integer(d4);
    vv5 := to_integer(d5);

    -- Inicializar
    v1 := 0; v2 := 0; v3 := 0; v4 := 0; v5 := 0; v6 := 0;

    -- Contar frecuencias
    case vv1 is when 1=>v1:=v1+1; when 2=>v2:=v2+1; when 3=>v3:=v3+1; when 4=>v4:=v4+1; when 5=>v5:=v5+1; when 6=>v6:=v6+1; when others=>null; end case;
    case vv2 is when 1=>v1:=v1+1; when 2=>v2:=v2+1; when 3=>v3:=v3+1; when 4=>v4:=v4+1; when 5=>v5:=v5+1; when 6=>v6:=v6+1; when others=>null; end case;
    case vv3 is when 1=>v1:=v1+1; when 2=>v2:=v2+1; when 3=>v3:=v3+1; when 4=>v4:=v4+1; when 5=>v5:=v5+1; when 6=>v6:=v6+1; when others=>null; end case;
    case vv4 is when 1=>v1:=v1+1; when 2=>v2:=v2+1; when 3=>v3:=v3+1; when 4=>v4:=v4+1; when 5=>v5:=v5+1; when 6=>v6:=v6+1; when others=>null; end case;
    case vv5 is when 1=>v1:=v1+1; when 2=>v2:=v2+1; when 3=>v3:=v3+1; when 4=>v4:=v4+1; when 5=>v5:=v5+1; when 6=>v6:=v6+1; when others=>null; end case;

    -- Asignar señales
    freq1 <= v1;
    freq2 <= v2;
    freq3 <= v3;
    freq4 <= v4;
    freq5 <= v5;
    freq6 <= v6;

    dice_sum <= vv1 + vv2 + vv3 + vv4 + vv5;

    trio  <= (v1=3 or v2=3 or v3=3 or v4=3 or v5=3 or v6=3);
    poker <= (v1=4 or v2=4 or v3=4 or v4=4 or v5=4 or v6=4);
    yahtz <= (v1=5 or v2=5 or v3=5 or v4=5 or v5=5 or v6=5);

    full  <= ( (v1=3 and (v2=2 or v3=2 or v4=2 or v5=2 or v6=2)) or
               (v2=3 and (v1=2 or v3=2 or v4=2 or v5=2 or v6=2)) or
               (v3=3 and (v1=2 or v2=2 or v4=2 or v5=2 or v6=2)) or
               (v4=3 and (v1=2 or v2=2 or v3=2 or v5=2 or v6=2)) or
               (v5=3 and (v1=2 or v2=2 or v3=2 or v4=2 or v6=2)) or
               (v6=3 and (v1=2 or v2=2 or v3=2 or v4=2 or v5=2)) );

    chance <= true;

    -------------------------------------------------------------------
    -- GENERAR LEDs (IF / ELSE)
    -------------------------------------------------------------------

    -- Unidades (1-6)
    if (freq1 > 0 and used(0) = '0') then 
        leds_out(0) <= '1'; 
    else 
        leds_out(0) <= '0'; 
    end if;

    if (freq2 > 0 and used(1) = '0') then 
        leds_out(1) <= '1'; 
    else 
        leds_out(1) <= '0'; 
    end if;

    if (freq3 > 0 and used(2) = '0') then 
        leds_out(2) <= '1'; 
    else 
        leds_out(2) <= '0'; 
    end if;

    if (freq4 > 0 and used(3) = '0') then 
        leds_out(3) <= '1'; 
    else 
        leds_out(3) <= '0'; 
    end if;

    if (freq5 > 0 and used(4) = '0') then 
        leds_out(4) <= '1'; 
    else 
        leds_out(4) <= '0'; 
    end if;

    if (freq6 > 0 and used(5) = '0') then 
        leds_out(5) <= '1'; 
    else 
        leds_out(5) <= '0'; 
    end if;

    -- Categorías especiales (6-10)
    -- Trío
    if (trio = true and used(6) = '0') then
        leds_out(6) <= '1';
    else
        leds_out(6) <= '0';
    end if;

    -- Póker
    if (poker = true and used(7) = '0') then
        leds_out(7) <= '1';
    else
        leds_out(7) <= '0';
    end if;

    -- Full
    if (full = true and used(8) = '0') then
        leds_out(8) <= '1';
    else
        leds_out(8) <= '0';
    end if;

    -- Yahtzee
    if (yahtz = true and used(9) = '0') then
        leds_out(9) <= '1';
    else
        leds_out(9) <= '0';
    end if;

    -- Chance
    if (chance = true and used(10) = '0') then
        leds_out(10) <= '1';
    else
        leds_out(10) <= '0';
    end if;

end process;

leds <= leds_out;

    -------------------------------------------------------------------
    -- Proceso sincrónico: sumar puntuaciones al pulsar cat_sw
    -- (usa las señales calculadas; NO recalcula frecuencias)
    -------------------------------------------------------------------
    process(clk)
        variable addpoints : integer;
        variable i : integer;
    begin
        if rising_edge(clk) then

            for i in 0 to 10 loop
                if (prev_cat_sw(i)='0' and cat_sw(i)='1') then
                    if (used(i) = '0') then
                        addpoints := 0;
                        case i is
                            when 0 => addpoints := freq1 * 1;
                            when 1 => addpoints := freq2 * 2;
                            when 2 => addpoints := freq3 * 3;
                            when 3 => addpoints := freq4 * 4;
                            when 4 => addpoints := freq5 * 5;
                            when 5 => addpoints := freq6 * 6;

                            when 6 => if (trio)  then addpoints := dice_sum; end if;
                            when 7 => if (poker) then addpoints := dice_sum; end if;
                            when 8 => if (full)  then addpoints := 25;      end if;
                            when 9 => if (yahtz) then addpoints := 50;     end if;
                            when 10=> if (chance) then addpoints := dice_sum; end if;

                            when others => addpoints := 0;
                        end case;

                        score <= score + addpoints;
                        used(i) <= '1';
                    end if;
                end if;
            end loop;

            prev_cat_sw <= cat_sw;

        end if;
    end process;

    -------------------------------------------------------------------
    -- Display multiplexado
    -------------------------------------------------------------------
    process(clk)
        variable temp : integer;
    begin
        if rising_edge(clk) then
            temp := score;
            if temp < 0 then temp := 0; end if;
            if temp > 99999999 then temp := 99999999; end if;

            d_0  <= temp mod 10;
            d_1 <= (temp / 10) mod 10;
            d_2  <= (temp / 100) mod 10;
            d_3  <= (temp / 1000) mod 10;
            d_4  <= (temp / 10000) mod 10;
            d_5 <= (temp / 100000) mod 10;
            d_6  <= (temp / 1000000) mod 10;
            d_7  <= (temp / 10000000) mod 10;

            refresh_cnt <= refresh_cnt + 1;
            if refresh_cnt = 100000 then
                refresh_cnt <= 0;
                if mux_sel = 7 then mux_sel <= 0; else mux_sel <= mux_sel + 1; end if;
            end if;
        end if;
    end process;

    process(mux_sel, d_0, d_1, d_2, d_3, d_4, d_5, d_6, d_7)
    begin
        case mux_sel is
            when 0 => anodes <= "11111110"; segments <= to7seg(d_0);
            when 1 => anodes <= "11111101"; segments <= to7seg(d_1);
            when 2 => anodes <= "11111011"; segments <= to7seg(d_2);
            when 3 => anodes <= "11110111"; segments <= to7seg(d_3);
            when 4 => anodes <= "11101111"; segments <= to7seg(d_4);
            when 5 => anodes <= "11011111"; segments <= to7seg(d_5);
            when 6 => anodes <= "10111111"; segments <= to7seg(d_6);
            when 7 => anodes <= "01111111"; segments <= to7seg(d_7);
            when others => anodes <= "11111111"; segments <= "1111111";
        end case;
    end process;
    
end behavioral;
