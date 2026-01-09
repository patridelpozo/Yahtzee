----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2025 15:31:49
-- Design Name: 
-- Module Name: Multiplexor - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity Multiplexor is
             Port (
                CLK : in std_logic;
                DICE_IN  : in std_logic_vector (14 downto 0);
                Mostrar_Dados: in boolean;
                Mostrar_Puntuacion: in boolean;
                Puntuacion: in integer;
                ANODES: out std_logic_vector (4 downto 0);
                ANODES_NEG: out std_logic_vector (2 downto 0);
                SEGMENT: out std_logic_vector (6 downto 0)
                
              );
end Multiplexor;

architecture Behavioral of Multiplexor is
    Signal Cuenta : integer range 0 to 100000;
    signal seleccion: unsigned (2 downto 0):= "000";
    signal displays: std_logic_vector ( 4 downto 0):= "00000";

    signal s_display_value : integer range 0 to 15 := 0;

    signal d_0, d_1, d_2, d_3, d_4 : integer := 0;
begin

---------------------------------------------------------------
-- PROCESO PRINCIPAL: CÁLCULO DE DÍGITOS / DIVISOR / SELECCIÓN
---------------------------------------------------------------
process (CLK)
    variable temp : integer;
begin
    if rising_edge(CLK) then
        
        -- convertir puntuación a dígitos
        temp := puntuacion;
        if temp < 0 then temp := 0; end if;
        if temp > 99999 then temp := 99999; end if;

        d_0 <= temp mod 10;
        d_1 <= (temp/10) mod 10;
        d_2 <= (temp/100) mod 10;
        d_3 <= (temp/1000) mod 10;
        d_4 <= (temp/10000) mod 10;

        -- divisor multiplexor
        if Cuenta < 100000 then
            Cuenta <= Cuenta + 1;
        else
            Cuenta <= 0;
            if seleccion = 4 then
                seleccion <= "000";
            else
                seleccion <= seleccion + 1;
            end if;
        end if;

    end if;
end process;


---------------------------------------------------------------
-- SELECCIÓN ENTRE DADOS Y PUNTUACIÓN
---------------------------------------------------------------
process(seleccion, Mostrar_Dados, Mostrar_Puntuacion, DICE_IN,
        d_0, d_1, d_2, d_3, d_4)
begin
    if Mostrar_Puntuacion = true then
        case seleccion is
            when "000" => s_display_value <= d_0;
            when "001" => s_display_value <= d_1;
            when "010" => s_display_value <= d_2;
            when "011" => s_display_value <= d_3;
            when "100" => s_display_value <= d_4;
            when others => s_display_value <= 0;
        end case;

    elsif Mostrar_Dados = true then
        case seleccion is
            when "000" => s_display_value <= to_integer(unsigned(DICE_IN(2 downto 0)));
            when "001" => s_display_value <= to_integer(unsigned(DICE_IN(5 downto 3)));
            when "010" => s_display_value <= to_integer(unsigned(DICE_IN(8 downto 6)));
            when "011" => s_display_value <= to_integer(unsigned(DICE_IN(11 downto 9)));
            when "100" => s_display_value <= to_integer(unsigned(DICE_IN(14 downto 12)));
            when others => s_display_value <= 0;
        end case;

    else
        s_display_value <= 0; -- todo apagado
    end if;
end process;


---------------------------------------------------------------
-- CONTROL DE QUÉ DISPLAY SE ENCIENDE
---------------------------------------------------------------
process(seleccion)
begin
    case seleccion is
        when "000" => displays <= "11110";
        when "001" => displays <= "11101";
        when "010" => displays <= "11011";
        when "011" => displays <= "10111";
        when "100" => displays <= "01111";
        when others => displays <= "11111";
    end case;
end process;


---------------------------------------------------------------
-- DECODIFICADOR 7 SEGMENTOS
---------------------------------------------------------------
process(s_display_value, Mostrar_Dados, Mostrar_Puntuacion)
begin
    if Mostrar_Dados = true then
        -- decodificación de dados (1-6)
        case s_display_value is
            when 0 => SEGMENT <= "1111111";
            when 1 => SEGMENT <= "1001111";
            when 2 => SEGMENT <= "0010010";
            when 3 => SEGMENT <= "0000110";
            when 4 => SEGMENT <= "1001100";
            when 5 => SEGMENT <= "0100100";
            when 6 => SEGMENT <= "0100000";
            when others => SEGMENT <= "1111111";
        end case;

    elsif Mostrar_Puntuacion = true then
        -- decodificación numérica (0-9)
        case s_display_value is
            when 0 => SEGMENT <= "0000001";
            when 1 => SEGMENT <= "1001111";
            when 2 => SEGMENT <= "0010010";
            when 3 => SEGMENT <= "0000110";
            when 4 => SEGMENT <= "1001100";
            when 5 => SEGMENT <= "0100100";
            when 6 => SEGMENT <= "0100000";
            when 7 => SEGMENT <= "0001111";
            when 8 => SEGMENT <= "0000000";
            when 9 => SEGMENT <= "0000100";
            when others => SEGMENT <= "1111111";
        end case;

    else
        SEGMENT <= "1111111";
    end if;
end process;


ANODES <= displays;
ANODES_NEG <= "111";

end Behavioral;
