----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2025 15:38:54
-- Design Name: 
-- Module Name: debouncer_simple - Behavioral
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

entity debouncer_simple is
    Port(
        CLK     : in  std_logic;
        BTN_IN  : in  std_logic;
        BTN_OUT : out std_logic
    );
end entity;

architecture Behavioral of debouncer_simple is
    signal ff1, ff2 : std_logic := '0';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            ff1 <= BTN_IN;
            ff2 <= ff1;
        end if;
    end process;

    BTN_OUT <= ff1 and ff2;  -- solo se activa si se mantiene dos ciclos
end Behavioral;
