library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX_tb is
end UART_RX_tb;

architecture Bench of UART_RX_tb is
    signal Clk         : std_logic := '0';
    signal Reset       : std_logic := '0';
    signal Go          : std_logic := '0';
    signal Data        : std_logic_vector(7 downto 0) := (others => '0');
    signal Tick        : std_logic := '0';
    signal Tick_h      : std_logic := '0';
    signal TX          : std_logic;
    signal Clear_fdiv  : std_logic;
    signal Reg         : std_logic_vector(9 downto 0) := (others => '0');
    signal OK          : boolean := TRUE;
    signal Err         : std_logic;
    signal Dataout     : std_logic_vector(7 downto 0);
    signal RST         : std_logic := '0';   
    signal tick2       : std_logic;
    signal tick_h2     : std_logic;
    signal a_tick_half : std_logic;
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


    Data <= "00111001";
    Go <= '1';
    Reset <= '0';

    wait until Tick = '1';
    wait for 30 ns;
    Go <= '0';

    for i in 0 to Reg'length - 1 loop
        if (TX /= Reg(i)) then
            report "There is a problem with the TX waveform" severity error;
            OK <= FALSE;
        end if;
        wait for 8680.6 ns;
    end loop;

    if (OK) then
        report "UART TX testbench passed" severity note;
    else
        report "UART TX testbench failed" severity error;
    end if;
    
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    Go <= '1';
    wait until Tick = '1';
    wait for 30 ns;
    Go <= '0';
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;

    wait;
end process;

RST <= (Reset or Clear_fdiv);
a_tick_half <= (Tick2) xor (Tick_h2);

fdiv: entity work.FDIV
    port map (
        Clk       => Clk,
        Reset     => Reset,
        Baud      => '0',
        Tick      => Tick,
        Tick_half => Tick_h
    );

fdiv2: entity work.FDIV
    port map (
        Clk       => Clk,
        Reset     => RST,
        Baud      => '0',
        Tick      => Tick2,
        Tick_half => Tick_h2

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

UART_RX: entity work.UART_RX
    generic map(
        Parity => true,
        Even => true
    )
    port map(
        Clk          => Clk,
        Reset        => Reset,
        Rx           => TX,
        Tick_halfbit => a_tick_half,
        Clear_fdiv   => Clear_fdiv,
        Err          => Err,
        Data         => Dataout,
        RxRDY        => rxrdy
    );


end Bench;