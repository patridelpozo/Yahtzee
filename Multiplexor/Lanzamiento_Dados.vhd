----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2025 14:44:17
-- Design Name: 
-- Module Name: Lanzamiento_Dados - Behavioral
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

entity Lanzamiento_Dados is
    Port ( 
        CLK         : in  std_logic;
        SW_IN       : in  std_logic;              
        ANODES      : out std_logic_vector (4 downto 0);
        ANODES_NEG  : out std_logic_vector (2 downto 0);
        SEGMENT     : out std_logic_vector(6 downto 0)
    );
end entity Lanzamiento_Dados;

architecture Structural of Lanzamiento_Dados is

    ----------------------------------------------------------------------
    -- Vector de 5 dados (5 × 3 bits = 15 bits)
    ----------------------------------------------------------------------
    signal s_dice_vector : std_logic_vector(14 downto 0) := (others => '0');

    ----------------------------------------------------------------------
    -- Flanco ascendente del switch
    ----------------------------------------------------------------------
    signal sw_prev : std_logic := '0';

    ----------------------------------------------------------------------
    -- LFSR para generar datos pseudoaleatorios
    ----------------------------------------------------------------------
    signal lfsr : std_logic_vector(7 downto 0) := "11001011";

begin
    ----------------------------------------------------------------------
    -- LFSR corriendo continuamente
    ----------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            lfsr <= lfsr(6 downto 0) &
                    (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));  
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Generación de los 5 valores de dados (1-6) en vector de 15 bits
    ----------------------------------------------------------------------
    process(CLK)
        variable rnd : integer;
    begin
        if rising_edge(CLK) then

            if (sw_prev = '0' and SW_IN = '1') then
                ------------------------------------------------------------------
                -- Cada dado se almacena en 3 bits consecutivos del vector
                ------------------------------------------------------------------

                -- Dado 1 → bits 2 downto 0
                rnd := (to_integer(unsigned(lfsr(2 downto 0))) mod 6) + 1;
                s_dice_vector(2 downto 0) <= std_logic_vector(to_unsigned(rnd, 3));

                -- Dado 2 → bits 5 downto 3
                rnd := (to_integer(unsigned(lfsr(5 downto 3))) mod 6) + 1;
                s_dice_vector(5 downto 3) <= std_logic_vector(to_unsigned(rnd, 3));

                -- Dado 3 → bits 8 downto 6
                rnd := (to_integer(unsigned(lfsr(7 downto 5))) mod 6) + 1;
                s_dice_vector(8 downto 6) <= std_logic_vector(to_unsigned(rnd, 3));

                -- Dado 4 → bits 11 downto 9
                rnd := (to_integer(unsigned(lfsr(4 downto 2))) mod 6) + 1;
                s_dice_vector(11 downto 9) <= std_logic_vector(to_unsigned(rnd, 3));

                -- Dado 5 → bits 14 downto 12
                rnd := (to_integer(unsigned(lfsr(3 downto 1))) mod 6) + 1;
                s_dice_vector(14 downto 12) <= std_logic_vector(to_unsigned(rnd, 3));

            end if;

            sw_prev <= SW_IN;

        end if;
    end process;

    ----------------------------------------------------------------------
    -- Instancia del MULTIPLEXOR tal como lo tienes definido
    ----------------------------------------------------------------------
    Display_Inst : entity work.Multiplexor
        port map (
            CLK        => CLK,
            DICE_IN    => s_dice_vector,    -- AHORA ES EL VECTOR DE 15 BITS
            ANODES     => ANODES,
            ANODES_NEG => ANODES_NEG,
            SEGMENT    => SEGMENT
        );

end architecture Structural;



