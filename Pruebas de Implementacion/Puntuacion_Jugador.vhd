----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2025 12:12:08
-- Design Name: 
-- Module Name: Puntuacion_Jugador - Behavioral
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

entity Puntuacion_Jugador is
    Port (
        CLK             : in std_logic;
        RESET           : in std_logic;         -- Reset (Activo Alto)
        GUARDAR         : in std_logic;         -- Señal desde FSM (S_GUARDAR_PUNTUACION)
        CATEGORIA       : in unsigned(3 downto 0); -- 0-10
        PUNTOS_CALCULADOS : in unsigned(6 downto 0); -- puntos del detector

        TOTAL           : out unsigned(10 downto 0); -- puntuación total del jugador
        CATEGORIA_USADA : inout std_logic             -- '1' si ya estaba puntuada
    );
end Puntuacion_Jugador;

architecture Behavioral of Puntuacion_Jugador is

    type t_tabla is array(0 to 10) of unsigned(6 downto 0);
    signal tabla_puntos : t_tabla := (others => (others => '0'));
    signal total_reg : unsigned(10 downto 0) := (others => '0');

begin

    -- Asignaciones Concurrente (Salidas)
    TOTAL <= total_reg;

    -- LÓGICA CONCURRENTE: Detecta si la categoría YA está usada (antes de GUARDAR)
    -- El valor '0' en tabla_puntos indica que está libre.
    CATEGORIA_USADA <= '1' when tabla_puntos(to_integer(CATEGORIA)) /= 0 else '0';


    process(CLK, RESET) -- El proceso debe ser sensible a CLK y RESET
    begin
        if RESET = '1' then -- CORRECCIÓN: Reset Activo Alto
            tabla_puntos <= (others => (others => '0'));
            total_reg <= (others => '0');
            
        elsif rising_edge(CLK) then
            
            -- Lógica de GUARDAR PUNTUACION
            if GUARDAR = '1' then
                
                -- Verificar si la categoría NO está usada
                if CATEGORIA_USADA = '0' then
                    
                    -- Registrar puntuación
                    tabla_puntos(to_integer(CATEGORIA)) <= PUNTOS_CALCULADOS;

                    -- Sumar al total
                    total_reg <= total_reg + resize(PUNTOS_CALCULADOS, total_reg'length);
                
                -- Si CATEGORIA_USADA es '1', la FSM debería ignorar el pulso GUARDAR
                -- o pasar al estado de error. Este módulo solo almacena.
                end if;
            end if;

        end if;
    end process;

end Behavioral;
