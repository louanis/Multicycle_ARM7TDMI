-- UARTS.vhd
-- -----------------------------------------------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- ----------------------------------------------
    Entity VALIDATION_UART is
-- ----------------------------------------------
  Generic ( Fxtal   : integer  := 50e6;  -- in Hertz
            Parity  : boolean  := false;
            Even    : boolean  := false;
            Baud1   : positive := 115200;
            Baud2   : positive := 19200
          );
  Port (  CLK     : in  std_logic;  -- System Clock at Fxtal
          RST     : in  std_logic;  -- Asynchronous Reset active high

          Din     : in  std_logic_vector (7 downto 0);
          Rx      : in  std_logic;

          Baud    : in  std_logic;  -- Baud Rate Select Baud1 (1) / Baud2 (0)

          Dout    : out std_logic_vector(7 downto 0);
          Tx      : out std_logic;
          TxBusy  : out std_logic;  -- '1' when Busy sending
          RxErr   : out std_logic;
          RxRDY   : out std_logic
       );
end VALIDATION_UART;


-- ---------------------------------------------------------------
    Architecture RTL of VALIDATION_UART is
-- ---------------------------------------------------------------
signal s_dout, s_din   : std_logic_vector(7 downto 0);
signal s_rxrdy,s_go,prec,s_TxBusy : std_logic;
--------
begin
--------
process(clk,rst)
begin
  if rst = '0' then
    s_go <= '1';
    prec <= '1';
  elsif rising_edge(clk) then
    prec <= s_rxrdy;
    if prec = '0' and s_rxrdy = '1' then
      s_go <= '0';
    elsif (s_go = '0' and s_txbusy = '1') then
      s_go <= '1'; -- Reset s_go only after TX is no longer busy
    end if;
  end if;
end process;

uart_rx: entity work.tp_uart_rx(RTL) port map(
  Clk          => clk,
  Reset        => rst,
  Rx           => Rx,
  Baud         => Baud, -- Baud Rate Select Baud1 (1) / Baud2 (0) 
  Err          => RxErr,
  Data         => s_dout,
  RxRDY        => s_rxrdy
);

uart_tx: entity work.tp_uart_tx(RTL) port map(
  Clk   =>clk,
  Reset => rst,
  Go    => s_go,
  Baud  => baud, -- Baud Rate Select Baud1 (1) / Baud2 (0) 
  Tx    => Tx,
  Data  => s_din,
  Busy  => s_TxBusy
);

RxRDY <= s_RxRDY;
s_din <= std_logic_vector(unsigned(s_dout)+1);
txbusy <= s_TxBusy;
Dout <= s_din;
end RTL;
