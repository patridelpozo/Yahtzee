----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2025 11:54:23
-- Design Name: 
-- Module Name: Video_YT - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Video_YT is
             Port (
                CLK : in std_logic;
                --DICE_IN : in std_logic_vector (14 downto 0);
                ANODES: out std_logic_vector (4 downto 0);
                ANODES_NEG: out std_logic_vector (2 downto 0);
                SEGMENT: out std_logic_vector (6 downto 0)
              );
end Video_YT;

architecture Behavioral of Video_YT is
    Signal Cuenta : integer range 0 to 100000;
    signal seleccion: unsigned (2 downto 0):= "000";
    signal displays: std_logic_vector ( 4 downto 0):= "00000";
    signal num1: std_logic_vector (6 downto 0) := "1000000"; -- Patrón 1
    signal num2: std_logic_vector (6 downto 0) := "1111001"; -- Patrón 2
    signal num3: std_logic_vector (6 downto 0) := "0100100"; -- Patrón 3
    signal num4: std_logic_vector (6 downto 0) := "0110000"; -- Patrón 4
    signal num5: std_logic_vector (6 downto 0) := "1000000"; -- Patrón 5
    
begin
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
    Mostrar_Displays : process (seleccion)
    begin
        case seleccion is
            when "000" =>
                displays <= "11110";
            when "001" =>
                displays <= "11101"; 
            when "010" =>
                displays <= "11011";
            when "011" =>
                displays <= "10111";
            when "101" =>
                displays <= "01111";
            when others =>
                displays <= "11111";
         end case;
       
       case displays is
            when "11110" =>
                SEGMENT <= num5;
            when "11101" =>
                SEGMENT <= num4;
            when "11011" =>
                SEGMENT <= num3;
            when "10111" =>
                SEGMENT <= num2;
            when "01111" =>
                SEGMENT <= num1; 
             when others =>
             SEGMENT <= "1111111";
          end case;     
    end process;  
 ANODES <= displays;
 ANODES_NEG <= "111";
end Behavioral;
