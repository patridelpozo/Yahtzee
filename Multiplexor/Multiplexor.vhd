----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2025 11:03:05
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
               -- DICE_IN1 : in std_logic_vector (2 downto 0);--:= "010";
               -- DICE_IN2 : in std_logic_vector (2 downto 0);--:= "001";
               -- DICE_IN3 : in std_logic_vector (2 downto 0);--:= "100";
               -- DICE_IN4 : in std_logic_vector (2 downto 0);--:= "110" ;
               -- DICE_IN5 : in std_logic_vector (2 downto 0);--:= "011";
                ANODES: out std_logic_vector (4 downto 0);
                ANODES_NEG: out std_logic_vector (2 downto 0);
                SEGMENT: out std_logic_vector (6 downto 0)
                
              );
end Multiplexor;

architecture Behavioral of Multiplexor is
    Signal Cuenta : integer range 0 to 100000;
    signal seleccion: unsigned (2 downto 0):= "000";
    signal displays: std_logic_vector ( 4 downto 0):= "00000";
   -- signal num1,num2,num3,num4,num5 : std_logic_vector (2 downto 0);
    
    --signal dados : std_logic_vector (14 downto 0):="001010001011110";
    --signal num : std_logic_vector (6 downto 0);
    signal s_current_dice_value : std_logic_vector (2 downto 0);
   -- DICE_IN <= "001010001011110";
begin
--num1 <= "001";
--num2 <= "010";
--num3 <= "100";
--num4 <= "110";
--num5 <= "011";

    process (CLK)
begin
    if rising_edge(CLK) then
        -- 1. Contador del divisor
        if Cuenta < 100000 then
            Cuenta <= Cuenta + 1;
        else
            -- 2. RESET del contador y avance del selector
            Cuenta <= 0;
            if seleccion = 5 then -- Solo 5 displays (0 a 4)
                 seleccion <= "000";
            else
                 seleccion <= seleccion + 1;
            end if;
        end if;
    end if;
    end process;
    with std_logic_vector(seleccion) select
        s_current_dice_value <= 
            DICE_IN(2 downto 0)   when "000",
            DICE_IN(5 downto 3)   when "001", 
            DICE_IN(8 downto 6)   when "010", 
            DICE_IN(11 downto 9)  when "011", 
            DICE_IN(14 downto 12) when "100", 
            (others => '0')       when others;
    Mostrar_Displays : process (seleccion)
    begin
        case seleccion is
            when "000" =>
                displays <= "11110";
                --s_current_dice_value <= num1;
                 -- s_current_dice_value <= DICE_IN (2 downto 0);
            when "001" =>
                displays <= "11101"; 
                --s_current_dice_value <= num2;
                --s_current_dice_value <= DICE_IN (5 downto 3);
            when "010" =>
                displays <= "11011";
               -- s_current_dice_value <= num3;
               --s_current_dice_value <= DICE_IN (8 downto 6);
            when "011" =>
                displays <= "10111";
               -- s_current_dice_value <= num4;
               --s_current_dice_value <= DICE_IN (11 downto 9);
            when "100" =>
                displays <= "01111";
                --s_current_dice_value <= num5;
                --s_current_dice_value <= DICE_IN(14 downto 12);
            when others =>
                displays <= "11111";
                --s_current_dice_value <= "000";
         end case;
         
       case s_current_dice_value is
        --       a      b      c      d      e      f      g
        when "000" =>  -- Valor '0' (Apagado o valor inicial)
            SEGMENT <= "1111111"; 
        
        when "001" =>  -- Valor '1'
            SEGMENT <= "1001111"; 
            
        when "010" =>  -- Valor '2'
            SEGMENT <= "0010010"; 
            
        when "011" =>  -- Valor '3'
            SEGMENT <= "0000110"; 
            
        when "100" =>  -- Valor '4'
            SEGMENT <= "1001100"; 
            
        when "101" =>  -- Valor '5'
            SEGMENT <= "0100100"; 
            
        when "110" =>  -- Valor '6'
            SEGMENT <= "0100000"; 
            
        when others => 
            -- Cualquier otro valor (ej. 7) o error se apaga
            SEGMENT <= "1111111";
            
    end case;    
    end process;  
 ANODES <= displays;
 ANODES_NEG <= "111";
end Behavioral;
