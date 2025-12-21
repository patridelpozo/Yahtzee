----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2025 10:41:13
-- Design Name: 
-- Module Name: yahztee_score_sel - Behavioral
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

entity yahtzee_score_sel is
    port(
        clk    : in  std_logic;  
        segments : out std_logic_vector(6 downto 0);  -- CA..CG
        anodes   : out std_logic_vector(7 downto 0);  -- AN0..AN7                     -- reloj para muestreo de switches
        sw     : in  std_logic_vector(2 downto 0);    -- seleccion test case
        cat_sw : in  std_logic_vector(10 downto 0);   -- switches de categoria (1=seleccionar/consumir)
        leds   : out std_logic_vector(10 downto 0)    -- LEDs disponibles (1 = disponible y no usada)
    );
end entity;

architecture behavioral of yahtzee_score_sel is

    ---------------------------------------------------------------------
    -- TEST CASES (15 bits = 5 dados × 3 bits por dado)
    ---------------------------------------------------------------------
    constant TEST_CASE_0 : std_logic_vector(14 downto 0) := "001010011100101";  -- 1,2,3,4,5
    constant TEST_CASE_1 : std_logic_vector(14 downto 0) := "010010010010010";  -- 2,2,2,2,2
    constant TEST_CASE_2 : std_logic_vector(14 downto 0) := "100100100010010";  -- 4,4,4,2,2
    constant TEST_CASE_3 : std_logic_vector(14 downto 0) := "110110110110001";  -- 6,6,6,6,1
    constant TEST_CASE_4 : std_logic_vector(14 downto 0) := "011011011010001";  -- 3,3,3,4,1
    --constant TEST_CASE_5 : std_logic_vector(14 downto 0) := "011011011010001";  -- 3,3,3,4,1
    --constant TEST_CASE_6 : std_logic_vector(14 downto 0) := "011011011010001";  -- 3,3,3,4,1
    signal dice_in : std_logic_vector(14 downto 0);

    -- Dados como unsigned(2 downto 0)
    signal d1, d2, d3, d4, d5 : unsigned(2 downto 0);
    -- Frecuencias (señales para que el proceso secuencial las lea)
    signal f1, f2, f3, f4, f5, f6 : integer := 0;
    -- Registro de categorías ya usadas
    signal used       : std_logic_vector(10 downto 0) := (others => '0');

    -- Para detectar flancos en cat_sw
    signal prev_cat_sw : std_logic_vector(10 downto 0) := (others => '0');

    -- Señal interna para pintar leds (combinacional)
    signal leds_out   : std_logic_vector(10 downto 0);
    signal score : integer := 0;
    -- Digitos display (8 dígitos)
    signal d_0, d_1, d_2, d_3, d_4, d_5, d_6, d_7 : integer := 0; -- nombres con d1_d,d5_d para evitar conflicto con d1 señal
    signal refresh_cnt : integer := 0;
    signal mux_sel : integer range 0 to 7 := 0;
    signal dice_sum : integer := 0; -- <--- ¡NUEVA SEÑAL AQUÍ!
     -------------------------------------------------------------------
    -- Función conversión a 7 segmentos (activo en bajo) para Nexys DDR4
    -------------------------------------------------------------------
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
    
    ---------------------------------------------------------------------
    -- Selector de test case (compatible VHDL-93)
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
    -- Lógica combinacional: calcula disponibilidad de categorías
    ---------------------------------------------------------------------
    process(d1, d2, d3, d4, d5, used)
        -- frecuencias como variables individuales (no se usa integer_vector)
       variable v1, v2, v3, v4, v5, v6 : integer := 0;
        variable vv1, vv2, vv3, vv4, vv5 : integer;
        variable trio_var, poker_var, yahtz_var, full_var : boolean;
        --variable sum_all_var : integer;
        --variable p0, p1, p2, p3, p4, p5 : integer;
    begin
        -- Inicializar frecuencias
        --f1 := 0; f2 := 0; f3 := 0;
       -- f4 := 0; f5 := 0; f6 := 0;
       -- p0 := f1 * 1;
       -- p1 := f2 * 2;
       -- p2 := f3 * 3;
       -- p3 := f4 * 4;
        --p4 := f5 * 5;
       -- p5 := f6 * 6;
        -- convertir dados a enteros (valores 0..7; esperamos 1..6)
         v1 := 0; v2 := 0; v3 := 0; v4 := 0; v5 := 0; v6 := 0;
       -- v1 := to_integer(d1);
        --v2 := to_integer(d2);
       -- v3 := to_integer(d3);
       -- v4 := to_integer(d4);
       -- v5 := to_integer(d5);
 -- convertir a integer (los valores vienen 0..7, esperamos 1..6)
        vv1 := to_integer(d1);
        vv2 := to_integer(d2);
        vv3 := to_integer(d3);
        vv4 := to_integer(d4);
        vv5 := to_integer(d5);
        -- Contar frecuencias (case por cada dado)
       -- contar frecuencias (case para evitar indices fuera de rango)
        case vv1 is
            when 1 => v1 := v1 + 1;
            when 2 => v2 := v2 + 1;
            when 3 => v3 := v3 + 1;
            when 4 => v4 := v4 + 1;
            when 5 => v5 := v5 + 1;
            when 6 => v6 := v6 + 1;
            when others => null;
        end case;
        case vv2 is
            when 1 => v1 := v1 + 1;
            when 2 => v2 := v2 + 1;
            when 3 => v3 := v3 + 1;
            when 4 => v4 := v4 + 1;
            when 5 => v5 := v5 + 1;
            when 6 => v6 := v6 + 1;
            when others => null;
        end case;
        case vv3 is
            when 1 => v1 := v1 + 1;
            when 2 => v2 := v2 + 1;
            when 3 => v3 := v3 + 1;
            when 4 => v4 := v4 + 1;
            when 5 => v5 := v5 + 1;
            when 6 => v6 := v6 + 1;
            when others => null;
        end case;
        case vv4 is
            when 1 => v1 := v1 + 1;
            when 2 => v2 := v2 + 1;
            when 3 => v3 := v3 + 1;
            when 4 => v4 := v4 + 1;
            when 5 => v5 := v5 + 1;
            when 6 => v6 := v6 + 1;
            when others => null;
        end case;
        case vv5 is
            when 1 => v1 := v1 + 1;
            when 2 => v2 := v2 + 1;
            when 3 => v3 := v3 + 1;
            when 4 => v4 := v4 + 1;
            when 5 => v5 := v5 + 1;
            when 6 => v6 := v6 + 1;
            when others => null;
        end case;

        -- actualizar señales de frecuencia (para que el proceso sincrónico lea)
        f1 <= v1;
        f2 <= v2;
        f3 <= v3;
        f4 <= v4;
        f5 <= v5;
        f6 <= v6;

         -- detectar trío/póker/yahtzee
        trio_var  := (v1=3 or v2=3 or v3=3 or v4=3 or v5=3 or v6=3);
        poker_var := (v1=4 or v2=4 or v3=4 or v4=4 or v5=4 or v6=4);
        yahtz_var := (v1=5 or v2=5 or v3=5 or v4=5 or v5=5 or v6=5);

        -- detectar full (3+2)
        full_var := false;
        if ( (v1=3 and (v2=2 or v3=2 or v4=2 or v5=2 or v6=2)) or
             (v2=3 and (v1=2 or v3=2 or v4=2 or v5=2 or v6=2)) or
             (v3=3 and (v1=2 or v2=2 or v4=2 or v5=2 or v6=2)) or
             (v4=3 and (v1=2 or v2=2 or v3=2 or v5=2 or v6=2)) or
             (v5=3 and (v1=2 or v2=2 or v3=2 or v4=2 or v6=2)) or
             (v6=3 and (v1=2 or v2=2 or v3=2 or v4=2 or v5=2)) ) then
            full_var := true;
        end if;

        -- sum total (chance)
        --sum_all_var := vv1 + vv2 + vv3 + vv4 + vv5;
        dice_sum <= vv1 + vv2 + vv3 + vv4 + vv5;
        -- construir leds_out (solo ON si disponible y no usada)
        -- Unos..Seises (leds_out 0..5)
        if (v1 > 0 and used(0) = '0') then leds_out(0) <= '1'; else leds_out(0) <= '0'; end if;
        if (v2 > 0 and used(1) = '0') then leds_out(1) <= '1'; else leds_out(1) <= '0'; end if;
        if (v3 > 0 and used(2) = '0') then leds_out(2) <= '1'; else leds_out(2) <= '0'; end if;
        if (v4 > 0 and used(3) = '0') then leds_out(3) <= '1'; else leds_out(3) <= '0'; end if;
        if (v5 > 0 and used(4) = '0') then leds_out(4) <= '1'; else leds_out(4) <= '0'; end if;
        if (v6 > 0 and used(5) = '0') then leds_out(5) <= '1'; else leds_out(5) <= '0'; end if;

         -- trío (6)
        if (trio_var and used(6) = '0') then leds_out(6) <= '1'; else leds_out(6) <= '0'; end if;
        -- póker (7)
        if (poker_var and used(7) = '0') then leds_out(7) <= '1'; else leds_out(7) <= '0'; end if;
        -- full (8)
        if (full_var and used(8) = '0') then leds_out(8) <= '1'; else leds_out(8) <= '0'; end if;
        -- yahtzee (9)
        if (yahtz_var and used(9) = '0') then leds_out(9) <= '1'; else leds_out(9) <= '0'; end if;
        -- chance (10) -> disponible si suma>0 y no usada
       -- if (sum_all_var > 0 and used(10) = '0') then leds_out(10) <= '1'; else leds_out(10) <= '0'; end if;
       if (dice_sum > 0 and used(10) = '0') then leds_out(10) <= '1'; else leds_out(10) <= '0'; end if; -- <--- USAR dice_sum EN LUGAR DE sum_all_var
    end process;
    leds <= leds_out;
    ---------------------------------------------------------------------
    -- Proceso sincronizado: detectar flancos en cat_sw y "consumir" categoría
    ---------------------------------------------------------------------
     -------------------------------------------------------------------
    -------------------------------------------------------------------
-- Proceso sincrónico: detectar flancos en cat_sw y consumir categoría
-- ahora SUMAMOS TODAS LAS PUNTUACIONES (0..10)
-------------------------------------------------------------------
process(clk)
    variable i : integer;
    variable addpoints : integer;
begin
    if rising_edge(clk) then
        
        for i in 0 to 10 loop
            -- DETECTAR FLANCO DE SUBIDA EN EL SWITCH
            if (prev_cat_sw(i) = '0' and cat_sw(i) = '1') then

                -- SOLO SI LA CATEGORÍA ESTÁ DISPONIBLE
                if (leds_out(i) = '1' and used(i) = '0') then
                    
                    used(i) <= '1';    -- marcar como usada
                    addpoints := 0;

                    ------------------------------------------------
                    -- PUNTUACIONES YAHTZEE COMPLETAS
                    ------------------------------------------------
                    case i is
                        -----------------------------------------------------------------
                        -- UNOS-SEISES
                        -----------------------------------------------------------------
                        when 0 => addpoints := f1 * 1;
                        when 1 => addpoints := f2 * 2;
                        when 2 => addpoints := f3 * 3;
                        when 3 => addpoints := f4 * 4;
                        when 4 => addpoints := f5 * 5;
                        when 5 => addpoints := f6 * 6;

                        -----------------------------------------------------------------
                        -- TRÍO → suma total
                        -----------------------------------------------------------------
                        when 6 =>
                            --addpoints := (f1*1 + f2*2 + f3*3 + f4*4 + f5*5 + f6*6);
                              addpoints := dice_sum;
                        -----------------------------------------------------------------
                        -- PÓKER → suma total
                        -----------------------------------------------------------------
                        when 7 =>
                            --addpoints := (f1*1 + f2*2 + f3*3 + f4*4 + f5*5 + f6*6);
                               addpoints := dice_sum;
                        -----------------------------------------------------------------
                        -- FULL HOUSE → 25 puntos fijos
                        -----------------------------------------------------------------
                        when 8 =>
                            addpoints := 1;

                        -----------------------------------------------------------------
                        -- YAHTZEE → 50 puntos fijos
                        -----------------------------------------------------------------
                        when 9 =>
                            addpoints := 2;

                        -----------------------------------------------------------------
                        -- CHANCE → suma total
                        -----------------------------------------------------------------
                        when 10 =>
                            --addpoints := (f1*1 + f2*2 + f3*3 + f4*4 + f5*5 + f6*6);
                             addpoints := dice_sum;
                        when others =>
                            addpoints := 0;
                    end case;

                    -- ACTUALIZAR SCORE GLOBAL
                    score <= score + addpoints;

                end if;
            end if;
        end loop;

        -- actualizar switches
        prev_cat_sw <= cat_sw;

    end if;
end process;
     -------------------------------------------------------------------
    -- Mostrar score en 8 displays (multiplexado)
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

            -- divisor de frecuencia para refresco (~1 kHz)
            refresh_cnt <= refresh_cnt + 1;
            if refresh_cnt = 100000 then   -- 100MHz / 100k = 1kHz
                refresh_cnt <= 0;
                if mux_sel = 7 then
                    mux_sel <= 0;
                else
                    mux_sel <= mux_sel + 1;
                end if;
            end if;
        end if;
    end process;
    process(mux_sel, d_0, d_1, d_2, d_3, d_4, d_5, d_6, d_7)
    begin
        case mux_sel is
            when 0 =>
                anodes   <= "11111110";
                segments <= to7seg(d_0);
            when 1 =>
                anodes   <= "11111101";
                segments <= to7seg(d_1);
            when 2 =>
                anodes   <= "11111011";
                segments <= to7seg(d_2);
            when 3 =>
                anodes   <= "11110111";
                segments <= to7seg(d_3);
            when 4 =>
                anodes   <= "11101111";
                segments <= to7seg(d_4);
            when 5 =>
                anodes   <= "11011111";
                segments <= to7seg(d_5);
            when 6 =>
                anodes   <= "10111111";
                segments <= to7seg(d_6);
            when 7 =>
                anodes   <= "01111111";
                segments <= to7seg(d_7);
            when others =>
                anodes   <= "11111111";
                segments <= "1111111";
        end case;
    end process;


end architecture;