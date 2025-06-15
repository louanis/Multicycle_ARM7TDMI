library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_validation is
end tb_validation;

architecture Bench of tb_validation is
    signal Clk         : std_logic := '0';
    signal Reset       : std_logic := '0';
    signal Go          : std_logic := '0';
    signal Data        : std_logic_vector(7 downto 0) := (others => '0');
    signal TX          : std_logic;
    signal Tx_2        : std_logic;
    signal Tx_3        : std_logic;
    signal Reg         : std_logic_vector(9 downto 0) := (others => '0');
    signal OK          : boolean := TRUE;
    signal Err         : std_logic;
    signal Dataout     : std_logic_vector(7 downto 0);
    signal RST         : std_logic := '0';   
    signal RxRDY       : std_logic;
    signal TxBusy      : std_logic;
    signal rxRDY2      : std_logic;
    signal Dout2       : std_logic_vector(7 downto 0);
    signal TxBusy2     : std_logic;
    signal TxBusy3     : std_logic;
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


    Data <= "00000001";
    Go <= '1';
    Reset <= '0';

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
    wait for 10000 ns;
    Go <= '0';
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;
    wait for 8680.6 ns;

    wait;
end process;

RST <= not reset;


UART_TX: entity work.TP_UART_TX
port map(
    Clk   => Clk,
    Reset => rst,
    Go    => Go,
    Baud  => '0', -- Baud Rate Select Baud1 (1) / Baud2 (0) 
    Data  => Data,
    Tx    => Tx_2,
    Busy  => TxBusy
);

UART_RX: entity work.TP_UART_RX
port map(
    Clk   => Clk,
    Reset => rst,
    Rx    => Tx_2,
    Baud  => '0',
    Data  =>Dout2,
    RxRDY => rxRDY2
);

UART_TX2: entity work.TP_UART_TX
port map(
    Clk   => Clk,
    Reset => rst,
    Go    => rxRDY2,
    Baud  => '0', -- Baud Rate Select Baud1 (1) / Baud2 (0) 
    Data  => Dout2,
    Tx    => Tx_3,
    Busy  => TxBusy2
);

TEST_VAL: entity work.VALIDATION_UART
    Port map
    (  CLK  =>clk,
    RST     => rst,
    Din     => Data,
    Rx      => Tx_2,

    Baud    => '0',
    Dout    => Dataout,
    Tx      => Tx,
    RxErr   => Err,
    RxRDY   => RxRDY,   -- '1' when Data available
    Txbusy  => Txbusy3
    );

end Bench;