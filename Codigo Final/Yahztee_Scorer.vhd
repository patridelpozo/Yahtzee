----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2025 18:34:05
-- Design Name: 
-- Module Name: Yahztee_Scorer - Behavioral
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

entity Yahtzee_Scorer is
    port(
        clk    : in  std_logic;
        RESET : in std_logic;
        DICE_IN  : in std_logic_vector (14 downto 0);  -- selector test case
        cat_sw : in  std_logic_vector(10 downto 0);   -- switches de categoria (1=seleccionar/consumir)
        leds     : out std_logic_vector(10 downto 0);   -- LEDs para jugadas
        puntuacion: out integer
    );
end Yahtzee_Scorer;

architecture behavioral of Yahtzee_Scorer is
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

begin

    ---------------------------------------------------------------------
    -- Selector de test case (compatible VHDL-93)
    ---------------------------------------------------------------------
   

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
    process(d1, d2, d3, d4, d5, used,RESET)
    variable vv1, vv2, vv3, vv4, vv5 : integer;
    variable v1, v2, v3, v4, v5, v6 : integer;
begin
     if (RESET = '0') then
       leds_out<= (others=>'0');
       freq1 <= 0;freq2 <= 0;freq3 <= 0;freq4 <= 0;freq5 <= 0;freq6 <= 0;
       
       trio <= false;poker <= false;yahtz <= false;full <= false;chance <= false;
    else 
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
end if;
end process;

leds <= leds_out;

    ---------------------------------------------------------------------
    -- Proceso sincronizado: detectar flancos en cat_sw y "consumir" categoría
    ---------------------------------------------------------------------
    process(clk)
        variable addpoints : integer;
        variable i : integer;
    begin
        if rising_edge(clk) then
            if (RESET = '0') then 
                score <=0;
            else 
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
        end if;
    end process;
puntuacion <= score;
end architecture;
