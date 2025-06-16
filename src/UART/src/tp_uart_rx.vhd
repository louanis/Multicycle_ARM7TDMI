library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


entity TP_UART_RX is
    Generic ( Fxtal   : integer  := 50e6;  -- in Hertz
            Parity  : boolean  := false;
            Even    : boolean  := false
          );
    port (
        Clk          : in std_logic;
        Reset        : in std_logic;
        Rx           : in std_logic;
        Baud         : in std_logic; -- Baud Rate Select Baud1 (1) / Baud2 (0) 
        Err          : out std_logic;
        Data         : out std_logic_vector(7 downto 0);
        RxRDY        : out std_logic
    );
end TP_UART_RX;


architecture RTL of TP_UART_RX is
    signal s_tick          : std_logic;
    signal s_tick_half     : std_logic;
    signal sig_Data        : std_logic_vector (7 downto 0);
    signal rst_fdiv        : std_logic;
    signal s_clear_fdiv    : std_logic;
    signal a_tick_half     : std_logic;
    signal s_rst           : std_logic;
    signal s_err           : std_logic;
begin
    inst1: entity work.fdiv(RTL) port map(Baud=>Baud,Clk=>clk, Reset=>rst_fdiv, Tick=>s_tick, Tick_half=>s_tick_half);
    inst2: entity work.uart_rx(RTL) port map(Clk=>CLK,Reset =>s_rst,Rx=>(Rx),Tick_halfbit=>a_tick_half,Clear_fdiv=>s_clear_fdiv,Err=>s_Err,Data=>Data,rxrdy=>rxrdy);

    rst_fdiv <= (not reset) or s_clear_fdiv;
    a_tick_half <= (s_tick) xor s_tick_half;
    s_rst <= (not reset);
    err <= s_err;
end RTL;