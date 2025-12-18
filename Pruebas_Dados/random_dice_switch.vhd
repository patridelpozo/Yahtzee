----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2025 15:35:42
-- Design Name: 
-- Module Name: random_dice_switch - Behavioral
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

entity random_dice_switch is
    Port (
        clk   : in  STD_LOGIC;
        sw_in    : in  STD_LOGIC;   -- Switch físico de la FPGA
        dice_out : out STD_LOGIC_VECTOR(14 downto 0)
    );
end random_dice_switch;

architecture Behavioral of random_dice_switch is

    -- LFSR de 8 bits (semilla inicial)
    signal lfsr : STD_LOGIC_VECTOR(7 downto 0) := "11001011";

    -- Para detectar flanco ascendente
    signal sw_prev : STD_LOGIC := '0';

    -- 5 números aleatorios
    signal dice : STD_LOGIC_VECTOR(14 downto 0) := (others => '0');

begin

    ---------------------------------------------------------------------
    -- LFSR pseudoaleatorio
    ---------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            lfsr <= lfsr(6 downto 0) &
                   (lfsr(7) xor lfsr(5) xor lfsr(4) xor lfsr(3));
        end if;
    end process;

    ---------------------------------------------------------------------
    -- Generación de 5 números al levantar el switch
    ---------------------------------------------------------------------
    process(clk)
        variable rnd : integer;
    begin
        if rising_edge(clk) then

            -- Detectar flanco ascendente del switch
            if (sw_prev = '0' and sw_in = '1') then

                -- Generar 5 números entre 1 y 6
                for i in 0 to 4 loop
                    rnd := (to_integer(unsigned(lfsr(2 downto 0))) mod 6) + 1;
                    dice(i*3+2 downto i*3) <= std_logic_vector(to_unsigned(rnd, 3));
                end loop;

            end if;

            -- Actualizar estado previo
            sw_prev <= sw_in;

        end if;
    end process;

    dice_out <= dice;

end Behavioral;
