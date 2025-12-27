----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.12.2025 15:28:38
-- Design Name: 
-- Module Name: Control_Juego - Behavioral
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

entity Control_Juego is
    Port(
        CLK        : in  std_logic;
        RESET      : in  std_logic;        -- BTNU por ejemplo para reset general
        BTNC       : in  std_logic;        -- Botón para lanzar dados
        BTNU       : in  std_logic;        -- Botón para avanzar de estado
        SW_HOLD    : in  std_logic_vector(4 downto 0); -- Mantener dados
        SW_PUNT : in std_logic_vector (10 downto 0); --Puntuaciones
        ANODES     : out std_logic_vector(4 downto 0);
        ANODES_NEG : out std_logic_vector(2 downto 0);
        SEGMENT    : out std_logic_vector(6 downto 0);
        --Lanzamiento:  inout std_logic;
        --LEDS_TIRADAS : out std_logic_vector (2 downto 0);
        STATE_LEDS : out std_logic_vector(4 downto 0); -- LEDs debug
        leds : out std_logic_vector (10 downto 0)
    );
end Control_Juego;

architecture Behavioral of Control_Juego is

    --------------------------------------------------------------------
    -- Debouncers
    --------------------------------------------------------------------
    signal BTNC_clean : std_logic;
    signal BTNU_clean : std_logic;
    signal detector: std_logic;
    --------------------------------------------------------------------
    -- FSM
    --------------------------------------------------------------------
    type t_state is (
        S_RESET,
        S_START_TURNO,
        S_LANZAMIENTO,
        S_SELECCION_PUNTUACION,
        S_GUARDAR_PUNTUACION,
        S_FIN_JUEGO
    );
    signal state, next_state : t_state := S_RESET;
    signal BTNC_LANZAR : std_logic;
    signal tirada_count : unsigned (1 downto 0):= "00";
    -------------------------------------------------
    -------------------
    signal reset_lanzamiento : std_logic := '0';
    -- Dados
    signal lanzamiento_reset : std_logic;
    signal Lanzamiento_Complete : std_logic;
    --------------------------------------------------------------------
    signal dice_vector : std_logic_vector(14 downto 0) := (others => '0');
    signal score_leds : std_logic_vector(10 downto 0);
    COMPONENT Yahtzee_Scorer
        port(
        DICE_IN  : in std_logic_vector (14 downto 0);  -- selector test case
        clk    : in  std_logic;
        cat_sw : in  std_logic_vector(10 downto 0);
        leds     : out std_logic_vector(10 downto 0)   -- LEDs para jugadas
    );
    END COMPONENT;
begin

    --------------------------------------------------------------------
    -- Instanciar debouncers
    --------------------------------------------------------------------
   -- DBNC_BTN_LANZAR : entity work.debouncer_simple
     --   port map(
       --     CLK     => CLK,
         --   BTN_IN  => BTNC,
           -- BTN_OUT => BTNC_clean
        --);
    SINCRO: entity work.SYNCHRNZR
        port map (
            CLK => CLK,
            ASYNC_IN => BTNU, 
            SYNC_OUT => detector);
      EDGE : entity work.EDGEDTCTR 
            Port map  ( 
           CLK => CLK,
           SYNC_IN => detector,
           EDGE => BTNU_clean);
    --DBNC_BTN_ESTADO : entity work.debouncer_simple
      --  port map(
         --   CLK     => CLK,
          --  BTN_IN  => BTNU,
           -- BTN_OUT => BTNU_clean
       -- );

    --------------------------------------------------------------------
    -- Registro FSM
    --------------------------------------------------------------------
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '0'then
                state <= S_RESET;
                --Lanzamiento_Complete<= '0';
            else
                state <= next_state;
            end if;
        end if;
    end process;
    
    --------------------------------------------------------------------
    -- Lógica siguiente estado
    --------------------------------------------------------------------
    process(state, BTNU_clean)
    begin
        next_state <= state;

        case state is

            when S_RESET =>
                next_state <= S_START_TURNO;

           when S_START_TURNO =>
              reset_lanzamiento <= '1';   -- reseteas las tiradas
              if BTNU_clean = '1' then
              next_state <= S_LANZAMIENTO;
             end if;

        when S_LANZAMIENTO =>
             reset_lanzamiento <= '0';   -- ahora ya no se resetea
             if BTNU_clean = '1' or Lanzamiento_Complete = '1' then
             next_state <= S_SELECCION_PUNTUACION;
            end if;

            when S_SELECCION_PUNTUACION =>
                if BTNU_clean = '1' then
                    next_state <= S_GUARDAR_PUNTUACION;
                end if;

            when S_GUARDAR_PUNTUACION =>
                if BTNU_clean = '1' then
                 next_state <= S_START_TURNO;
                   end if;
            when S_FIN_JUEGO =>
                if BTNU_clean = '1' then
                    next_state <= S_RESET;
                end if;

        end case;
    end process;
     BTNC_LANZAR <= BTNC when state = S_LANZAMIENTO else '0';
     
    --------------------------------------------------------------------
    -- Lógica de tirada de dados
    --------------------------------------------------------------------
    Lanzamiento_Dados_Inst : entity work.Lanzamiento_Dados
        port map(
            CLK        => CLK,
            SW_HOLD    => SW_HOLD,
            BTNC       => BTNC_LANZAR,
            DICE_OUT => dice_vector,
            RESET_LANZAMIENTO => reset_lanzamiento,
            Tiradas    =>  tirada_count,
            Lanzamiento_Completado =>Lanzamiento_complete
        );
    --------------------------------------------------------------------
    -- Multiplexor
    --------------------------------------------------------------------
    Display_Inst : entity work.Multiplexor
       port map (
            CLK        => CLK,
            DICE_IN    => dice_vector,
            ANODES     => ANODES,
            ANODES_NEG => ANODES_NEG,
            SEGMENT    => SEGMENT
        );
    Puntuaciones_Inst : Yahtzee_Scorer
        port map (
            DICE_IN => dice_vector,
            leds => leds,
            clk => clk,
            cat_sw => SW_PUNT
        );
    --------------------------------------------------------------------
    -- LEDs de estado (debug)
    --------------------------------------------------------------------
    STATE_LEDS <=
        "00001" when state = S_RESET                else
        "00010" when state = S_START_TURNO          else
        "00100" when state = S_LANZAMIENTO          else
        "01000" when state = S_SELECCION_PUNTUACION else
        "10000" when state = S_GUARDAR_PUNTUACION   else
        "00000";  -- S_FIN_JUEGO
     --with tirada_count selected
     
end Behavioral;
