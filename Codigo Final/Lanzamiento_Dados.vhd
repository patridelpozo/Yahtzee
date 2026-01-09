----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2025 15:30:28
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
        CLK : in std_logic;     
        SW_HOLD     : in  std_logic_vector(4 downto 0); -- switches para congelar cada dado
        RESET : in std_logic;
        BTNC        : in  std_logic;                    -- botón para tirar
        --ANODES      : out std_logic_vector (4 downto 0);
       -- ANODES_NEG  : out std_logic_vector (2 downto 0);
        RESET_LANZAMIENTO : in std_logic;
        DICE_OUT : out std_logic_vector( 14 downto 0);
        Lanzamiento_Completado : out std_logic
       -- Tiradas : out unsigned (1 downto 0)
        --SEGMENT     : out std_logic_vector(6 downto 0)
    );
end entity Lanzamiento_Dados;
architecture structural of Lanzamiento_Dados is

    ----------------------------------------------------------------------
    -- Vector de 5 dados (5 × 3 bits = 15 bits)
    ----------------------------------------------------------------------
    signal s_dice_vector : std_logic_vector(14 downto 0) := (others => '0');
    signal tirada_count : unsigned (1 downto 0):= "00";
    signal Lanzamiento_Complete : std_logic := '0';
    ----------------------------------------------------------------------
    -- Señales para flanco ascendente con debounce
    ----------------------------------------------------------------------
    signal btn_sync_0, btn_sync_1 : std_logic := '0';
    signal btn_prev : std_logic := '0';
    signal btn_clean : std_logic := '0';

    ----------------------------------------------------------------------
    -- LFSR pseudoaleatorio
    ----------------------------------------------------------------------
    signal lfsr : std_logic_vector(7 downto 0) := "11001011";

begin
    ----------------------------------------------------------------------
    -- Sincronización del botón + "debounce"
    ----------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            btn_sync_0 <= BTNC;
            btn_sync_1 <= btn_sync_0;

            -- botón "limpio"
            btn_clean <= btn_sync_1;
        end if;
    end process;

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
    -- Tirada de dados SOLO para los que están libres (SW_HOLD = 0)
    ----------------------------------------------------------------------
    process(CLK)
        variable rnd : integer;
    begin
        if rising_edge(CLK) then
            if (RESET = '0') then
             s_dice_vector <= (others => '0');
             tirada_count <= "00";
             Lanzamiento_Complete <= '0';
           else
            Lanzamiento_Complete <= '0';
            if RESET_LANZAMIENTO = '1' then
                 tirada_count <= "00";
                 Lanzamiento_Complete <= '0';
               else
            -- flanco ascendente del botón BTNC
            if (btn_prev = '0' and btn_clean = '1') then
                if tirada_count /= "10"  then
                     tirada_count <= tirada_count + 1;
                     Lanzamiento_Complete <= '0';
                  else 
                    Lanzamiento_Complete <= '1';
                    tirada_count <= "00";
                  end if;
                --------------------------------------------------------------
                -- Dado 1 (bits 2 downto 0)
                --------------------------------------------------------------
                if SW_HOLD(0) = '0' then
                    rnd := (to_integer(unsigned(lfsr(2 downto 0))) mod 6) + 1;
                    s_dice_vector(2 downto 0) <= std_logic_vector(to_unsigned(rnd, 3));
                end if;

                --------------------------------------------------------------
                -- Dado 2 (bits 5 downto 3)
                --------------------------------------------------------------
                if SW_HOLD(1) = '0' then
                    rnd := (to_integer(unsigned(lfsr(5 downto 3))) mod 6) + 1;
                    s_dice_vector(5 downto 3) <= std_logic_vector(to_unsigned(rnd, 3));
                end if;

                --------------------------------------------------------------
                -- Dado 3 (bits 8 downto 6)
                --------------------------------------------------------------
                if SW_HOLD(2) = '0' then
                    rnd := (to_integer(unsigned(lfsr(7 downto 5))) mod 6) + 1;
                    s_dice_vector(8 downto 6) <= std_logic_vector(to_unsigned(rnd, 3));
                end if;

                --------------------------------------------------------------
                -- Dado 4 (bits 11 downto 9)
                --------------------------------------------------------------
                if SW_HOLD(3) = '0' then
                    rnd := (to_integer(unsigned(lfsr(4 downto 2))) mod 6) + 1;
                    s_dice_vector(11 downto 9) <= std_logic_vector(to_unsigned(rnd, 3));
                end if;

                --------------------------------------------------------------
                -- Dado 5 (bits 14 downto 12)
                --------------------------------------------------------------
                if SW_HOLD(4) = '0' then
                    rnd := (to_integer(unsigned(lfsr(3 downto 1))) mod 6) + 1;
                    s_dice_vector(14 downto 12) <= std_logic_vector(to_unsigned(rnd, 3));
                end if;
            end if;

            btn_prev <= btn_clean;
        end if;
        end if;
        end if;
    end process;
    DICE_OUT <= s_dice_vector;
    Lanzamiento_Completado<= Lanzamiento_Complete;
    --Tiradas <= tirada_count;
    ----------------------------------------------------------------------
    -- Instancia del multiplexor
    ----------------------------------------------------------------------
    --Display_Inst : entity work.Multiplexor
       -- port map (
          --  CLK        => CLK,
           -- DICE_IN    => s_dice_vector,
           -- ANODES     => ANODES,
           -- ANODES_NEG => ANODES_NEG,
           -- SEGMENT    => SEGMENT
       -- );

end architecture structural;
