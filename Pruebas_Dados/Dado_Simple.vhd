----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2025 15:01:55
-- Design Name: 
-- Module Name: Dado_Simple - Behavioral
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

entity Dado_Simple is
    Port ( CLK : in STD_LOGIC;
           -- NUEVA ENTRADA: Indica la "Semilla" o desfase inicial
           SEEK_VALUE : in INTEGER range 0 to 4; 
           SW_ACTIVO : in STD_LOGIC;
           Dice_Value : out STD_LOGIC_VECTOR (2 downto 0));
end entity Dado_Simple;

architecture Behavioral of Dado_Simple is
    
    signal s_fast_counter : unsigned(2 downto 0) := (others => '0');
    signal s_captured_value : std_logic_vector(2 downto 0) := "000"; 
    
    signal s_prev_sw_state : std_logic := '0';
    signal s_roll_trigger : std_logic := '0'; 

    -- Señales para el cálculo del Desfase Permanente
    signal s_sum : unsigned(3 downto 0); 
    signal s_offset_counter : unsigned(2 downto 0);
    
begin
    
    -- -----------------------------------------------------------
    -- LÓGICA CONCURRENTE: CÁLCULO DEL DESFASE PERMANENTE
    -- Asegura que los 5 dados tengan una fase diferente en todo momento.
    -- s_offset_counter = (s_fast_counter + SEEK_VALUE) mod 6
    -- -----------------------------------------------------------
    
    -- 1. Suma del contador y el offset (Necesita 4 bits, max 5+4=9)
    s_sum <= resize(s_fast_counter, 4) + to_unsigned(SEEK_VALUE, 4);

    -- 2. Aplicación del módulo 6 para limitar el resultado a 0-5
    s_offset_counter <= s_sum when s_sum < 6 else s_sum - 6; 

    -- -----------------------------------------------------------
    -- PROCESO SÍNCRONO
    -- -----------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            
            -- 1. Contador de 6 estados (SIEMPRE 0-5)
            if s_fast_counter = 5 then  
                s_fast_counter <= (others => '0');  
            else
                s_fast_counter <= s_fast_counter + 1;
            end if;
            
            -- 2. Detección de Flanco de Subida
            s_roll_trigger <= '0'; 
            if s_prev_sw_state = '0' and SW_ACTIVO = '1' then
                s_roll_trigger <= '1';
            end if;

            -- 3. Lógica de Captura
            if s_roll_trigger = '1' then
                -- CAPTURA EL VALOR DESFASADO + 1
                s_captured_value <= std_logic_vector(s_offset_counter + 1); 
            end if;
            
            s_prev_sw_state <= SW_ACTIVO;
            
        end if;
    end process;
    
    Dice_Value <= s_captured_value;

end Behavioral;