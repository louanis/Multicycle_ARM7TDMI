library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TP_UART_RX_TB is
end TP_UART_RX_TB;

architecture Bench of TP_UART_RX_TB is
    signal Clk         : std_logic := '0';
    signal Reset       : std_logic := '0';
    signal Go          : std_logic := '0';
    signal Data        : std_logic_vector(7 downto 0) := (others => '0');
    signal Tick        : std_logic := '0';
    signal Tick_h      : std_logic := '0';
    signal TX          : std_logic;
    signal Reg         : std_logic_vector(9 downto 0) := (others => '0');
    signal Err         : std_logic;
    signal Dataout     : std_logic_vector(7 downto 0);
    signal a_tick_half : std_logic;
    signal RST         : std_logic;
    signal RxRDY       : std_logic;
begin

process
begin
    while (now <= 500 us) loop
        Clk <= '0';
        wait for 10 ns;
        Clk <= '1';
        wait for 10 ns;
    end loop;
    wait;
end process;

    Reg <= '1' & Data & '0';

process
begin
    report "Starting UART RX testbench...";

    Reset <= '1';
    wait for 1 ns;
    wait for 10 ns;


    Data <= "00111000";
    Go <= '1';
    Reset <= '0';

    wait until Tick = '1';
    wait for 30 ns;
    Go <= '0';

    
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;

    wait;
end process;

RST <= not reset;

fdiv: entity work.FDIV
    port map (
        Clk       => Clk,
        Reset     => Reset,
        Tick      => Tick,
        Tick_half => Tick_h,
        Baud         => '0'
    );

UART_TX: entity work.UART_TX
generic map(
    Parity => true,
    Even => true
)
    port map (
        Clk   => Clk,
        Reset => Reset,
        Go    => Go,
        Data  => Data,
        Tick  => Tick,
        TX    => TX
    );

TP_UART_RX: entity work.TP_UART_RX
generic map(
    Parity => true,
    Even => true
)
    port map(
        Clk          => Clk,
        Reset        => RST,
        Rx           => TX,
        Err          => Err,
        Data         => Dataout,
        Baud         => '0',
        RxRDY        => RxRDY
    );


end Bench;