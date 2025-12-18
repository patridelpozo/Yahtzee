----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2025 15:11:41
-- Design Name: 
-- Module Name: Prueba_Leds - Behavioral
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

entity Prueba_Leds is
    Port ( 
        CLK_100MHZ : in  std_logic;
        SW_IN      : in  std_logic;               -- Switch para el lanzamiento
        LEDS       : out std_logic_vector(4 downto 0)  -- 5 LEDs de salida
    );
end entity Prueba_Leds;

architecture Structural of Prueba_Leds is
    
    -- Señales para las salidas de los 5 dados (3 bits cada una)
    signal s_dice_1_value, s_dice_2_value, s_dice_3_value, 
           s_dice_4_value, s_dice_5_value : std_logic_vector(2 downto 0);

    -- Para detectar flanco ascendente del switch
    signal sw_prev : std_logic := '0';

    -- LFSR de 8 bits para pseudoaleatorios
    signal lfsr : std_logic_vector(7 downto 0) := "11001011";

begin

    ----------------------------------------------------------------------
    -- A. LFSR corriendo continuamente
    ----------------------------------------------------------------------
    process(CLK_100MHZ)
    begin
        if rising_edge(CLK_100MHZ) then
            -- x^8 + x^6 + x^5 + x^4 + 1
            lfsr <= lfsr(6 downto 0) &
                    (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
        end if;
    end process;


    ----------------------------------------------------------------------
    -- B. Generación de 5 números aleatorios cuando SW pasa 0 → 1
    ----------------------------------------------------------------------
    process(CLK_100MHZ)
        variable rnd : integer;
    begin
        if rising_edge(CLK_100MHZ) then

            -- Detectar flanco ascendente
            if (sw_prev = '0' and SW_IN = '1') then

                -- Generar dado 1
                rnd := (to_integer(unsigned(lfsr(2 downto 0))) mod 6) + 1;
                s_dice_1_value <= std_logic_vector(to_unsigned(rnd, 3));

                -- Generar dado 2
                rnd := (to_integer(unsigned(lfsr(5 downto 3))) mod 6) + 1;
                s_dice_2_value <= std_logic_vector(to_unsigned(rnd, 3));

                -- Generar dado 3
                rnd := (to_integer(unsigned(lfsr(7 downto 5))) mod 6) + 1;
                s_dice_3_value <= std_logic_vector(to_unsigned(rnd, 3));

                -- Generar dado 4
                rnd := (to_integer(unsigned(lfsr(4 downto 2))) mod 6) + 1;
                s_dice_4_value <= std_logic_vector(to_unsigned(rnd, 3));

                -- Generar dado 5
                rnd := (to_integer(unsigned(lfsr(7 downto 5))) mod 6) + 1;
                s_dice_5_value <= std_logic_vector(to_unsigned(rnd, 3));

            end if;

            -- Actualizar valor previo del switch
            sw_prev <= SW_IN;

        end if;
    end process;


    ----------------------------------------------------------------------
    -- C. Lógica de salida a LEDs (igual que tu diseño original)
    ----------------------------------------------------------------------
    LEDS(0) <= '1' when (s_dice_1_value >= "100") else '0';
    LEDS(1) <= '1' when (s_dice_2_value >= "100") else '0';
    LEDS(2) <= '1' when (s_dice_3_value >= "100") else '0';
    LEDS(3) <= '1' when (s_dice_4_value >= "100") else '0';
    LEDS(4) <= '1' when (s_dice_5_value >= "100") else '0';

end architecture Structural;