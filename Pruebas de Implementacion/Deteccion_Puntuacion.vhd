----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.12.2025 12:14:47
-- Design Name: 
-- Module Name: Deteccion_Puntuacion - Behavioral
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

-- Tipo global (si estuviera en el paquete) ELIMINADO

entity Deteccion_Puntuacion is
    Port(
        dice_vector : in  std_logic_vector(14 downto 0);  -- 5 dados x 3 bits
        usadas      : in  std_logic_vector(10 downto 0);  -- puntuaciones ya usadas
        opciones    : out std_logic_vector(10 downto 0);  -- opciones disponibles
        
        -- PUERTO CORREGIDO: Usaremos un vector STD_LOGIC_VECTOR más grande
        -- El tipo ARRAY complejo NO puede ser un puerto sin paquete.
        -- Para simplificar, CONCATENAREMOS las salidas.
        PUNTOS_VALORES: out std_logic_vector(65 downto 0) -- 11 valores * 6 bits
    );
end Deteccion_Puntuacion;

architecture Behavioral of Deteccion_Puntuacion is

    -- 1. TIPOS DECLARADOS DENTRO DE LA ARQUITECTURA (Ahora son tipos locales)
    type t_valores is array(1 to 11) of unsigned(5 downto 0);
    type t_dice_values is array(1 to 5) of integer range 1 to 6;
    type t_freq is array(1 to 6) of integer; -- Histograma de frecuencia

    -- 2. SEÑALES INTERNAS
    signal d : t_dice_values; -- Vector de enteros de los dados (1..6)
    signal freq : t_freq;     -- Histograma de frecuencia
    
    -- Se mantiene la señal interna para el cálculo
    signal s_valores_calculados : t_valores; 

begin

    -------------------------------------------------------------------------
    -- Extraer los valores de los 5 dados (Concurrentes)
    -------------------------------------------------------------------------
    d(1) <= to_integer(unsigned(dice_vector(2 downto 0)));
    d(2) <= to_integer(unsigned(dice_vector(5 downto 3)));
    d(3) <= to_integer(unsigned(dice_vector(8 downto 6)));
    d(4) <= to_integer(unsigned(dice_vector(11 downto 9)));
    d(5) <= to_integer(unsigned(dice_vector(14 downto 12)));

    -------------------------------------------------------------------------
    -- Histograma de frecuencia
    -------------------------------------------------------------------------
    process(d)
        variable f : t_freq := (others => 0);
    begin
        for i in 1 to 5 loop
            if d(i) >= 1 and d(i) <= 6 then
                f(d(i)) := f(d(i)) + 1;
            end if;
        end loop;
        freq <= f;
    end process;

    -------------------------------------------------------------------------
    -- Cálculo de puntuaciones (Usa s_valores_calculados)
    -------------------------------------------------------------------------
    process(freq)
        variable v : t_valores := (others => (others => '0'));
        variable sum_all : integer := 0;
        -- ... [El resto de las declaraciones de variables del proceso] ...
    begin
        -- ... [Toda la lógica de cálculo de puntuaciones (for i in 1 to 6 loop, Three of a kind, Full House, etc.)] ...
        -- UTILIZA v(i) y sum_all como lo tenías.
        
        -- Sumar todas las categorías de 1 a 6
        for i in 1 to 6 loop
            v(i) := to_unsigned(freq(i) * i, 6);
            sum_all := sum_all + freq(i) * i;
        end loop;

        -- ... [Toda la lógica de Full House, Yahtzee, etc.] ...

        s_valores_calculados <= v; -- Asigna a la señal interna
    end process;

    -------------------------------------------------------------------------
    -- Opciones disponibles (no usadas)
    -------------------------------------------------------------------------
    process(usadas)
        variable opt : std_logic_vector(10 downto 0);
    begin
        for i in 0 to 10 loop
            if usadas(i) = '0' then
                opt(i) := '1';
            else
                opt(i) := '0';
            end if;
        end loop;
        opciones <= opt;
    end process;

    -------------------------------------------------------------------------
    -- Mapeo final a la salida (PUNTOS_VALORES)
    -- TAREA CRÍTICA: Concatenar el array interno (t_valores) a un solo vector (STD_LOGIC_VECTOR)
    -------------------------------------------------------------------------
    PUNTOS_VALORES <= 
        std_logic_vector(s_valores_calculados(11)) & -- Chance
        std_logic_vector(s_valores_calculados(10)) & -- Yahtzee
        std_logic_vector(s_valores_calculados(9)) &  -- Full House
        -- ... continua hasta el dado 1 (índice 1)
        std_logic_vector(s_valores_calculados(1));

end architecture Behavioral;