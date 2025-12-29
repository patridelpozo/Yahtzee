----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2025 12:24:31
-- Design Name: 
-- Module Name: Seleccion_Puntuacion - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity Seleccion_Puntuacion is
    Port (
        -- Asumo que VALORES es la salida 'opciones' del Detector (1=Disponible)
        VALORES    : in  std_logic_vector(10 downto 0);  
        SWITCHES   : in  std_logic_vector(15 downto 0);  -- SW15..SW5 (Solo SW15 a SW5 son relevantes)
        LEDS       : out std_logic_vector(15 downto 5);  -- LED15..LED5 (Para mostrar opciones disponibles)
        CATEGORIA  : out unsigned(3 downto 0);           -- 0..10
        VALIDA     : out std_logic                       -- '1' si la seleccion es valida y disponible
    );
end entity Seleccion_Puntuacion;

architecture Behavioral of Seleccion_Puntuacion is
begin

    ----------------------------------------------------------------------
    -- Encender LEDs solo en categorías disponibles (VALORES)
    ----------------------------------------------------------------------
    -- Mapeo LED15 <= VALORES(10), LED5 <= VALORES(0)
    LEDS(15 downto 5) <= VALORES; 

    ----------------------------------------------------------------------
    -- Detectar selección válida y asignarle prioridad (combinacional)
    ----------------------------------------------------------------------
    process(VALORES, SWITCHES)
        variable cat   : unsigned(3 downto 0);
        variable valid : std_logic := '0';
    begin
        -- Inicializar salidas seguras
        valid := '0';
        cat   := (others => '0'); 

        -- Recorrer los switches de mayor a menor índice (SW15 -> SW5).
        -- Esto da PRIORIDAD al switch de mayor índice.
        for i in 15 downto 5 loop
            
            -- La categoría asociada al LED/Switch i
            -- Indices del VALORES van de 0 a 10.
            -- Categoria (0) = LED/SW (15); Categoria (10) = LED/SW (5)
            -- Índice de CATEGORIA_VALOR = 15 - i
            
            -- ¿El switch está ON?
            if SWITCHES(i) = '1' then
                
                -- Asignar la categoría (0 a 10)
                cat := to_unsigned(15 - i, 4);

                -- La categoría es válida solo si: 
                -- 1. El switch está pulsado Y
                -- 2. La opción está DISPONIBLE (VALORES(15-i) = '1')
                if VALORES(15 - i) = '1' then
                    valid := '1';
                end if;
                
                -- CRÍTICO: Salir del bucle. Solo procesamos el primer switch activo.
                exit; 
                
            end if;
        end loop;

        CATEGORIA <= cat;
        VALIDA    <= valid;
    end process;

end Behavioral;